import QtQml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import NymeaApp.Utils 1.0
import "../components"
import "../delegates"
import "../devicepages"

GenericConfigPage {
    id: root

    property Thing thing
    property HeatingConfiguration heatingconfig: hemsManager.heatingConfigurations.getHeatingConfiguration(thing.id)
    property double currentPrice: 0
    property double lowestPrice: 0
    property double highestPrice: 0
    readonly property State currentPowerState: thing.stateByName("currentPower")
    readonly property State totalConsumptionState: thing.stateByName("totalEnergyConsumed")
    readonly property State pvSurplusPowerState: thing.stateByName("actualPvSurplus")
    readonly property State sgReadyModeState: thing.stateByName("sgReadyMode")

    readonly property bool applyEnabled: {
        if (!root.heatingconfig) { return false; }
        if (minPVSurplusPower.visible && !minPVSurplusPower.acceptableInput) { return false; }
        if (minRuntimeStepper.visible && !minRuntimeStepper.acceptableInput) { return false; }
        if (maxTotalRuntimeStepper.visible && !maxTotalRuntimeStepper.acceptableInput) { return false; }

        if (optimizationModeDropdown.currentIndex >= 0 &&
                filteredModel.get(optimizationModeDropdown.currentIndex).value !== root.heatingconfig.optimizationMode) { return true; }
        if (minPVSurplusPower.visible &&
                parseInt(minPVSurplusPower.text) !== root.heatingconfig.pvSurplusThreshold) {
            return true;
        }
        if (minRuntimeStepper.visible &&
                minRuntimeStepper.value * 900 !== root.heatingconfig.durationMinAfterTurnOn) {
            return true;
        }
        if (maxTotalRuntimeStepper.visible &&
                maxTotalRuntimeStepper.value * 900 !== root.heatingconfig.durationMaxTotal) {
            return true;
        }
        if (heatpumpPriceWidget.visible &&
                -heatpumpPriceWidget.currentRelativeValue !== root.heatingconfig.priceThreshold) {
            return true;
        }
        return false;
    }

    property Component navbarControls: thing.thingClass.interfaces.indexOf("smartgridheatpump") >= 0
                                       ? heatpumpNavbarControls : null

    Component {
        id: heatpumpNavbarControls
        CoNavbarButton {
            text: qsTr("Apply changes")
            enabled: root.applyEnabled
            onClicked: root.saveSettings()
        }
    }

    title: root.thing.name
    headerOptionsVisible: true
    headerOptionsModel: heatingMenuModel

    ListModel {
        id: heatingMenuModel

        ListElement {
            icon: "/icons/info.svg"
            text: "Details"
            page: "../optimization/HeatingDetailView.qml"
        }

        ListElement {
            icon: "/icons/logs.svg"
            text: "Logs"
            page: "../devicepages/DeviceLogPage.qml"
        }
    }

    function updatePrice() {
        if (dynamicPrice.count === 0) return;
        currentPrice = dynamicPrice.get(0).stateByName("currentMarketPrice").value;
        currentPriceLabel.text = Number(currentPrice).toLocaleString(Qt.locale(), 'f', 2) + " ct/kWh";
    }

    function saveSettings() {
        var newConfig = JSON.parse(JSON.stringify(heatingconfig));
        newConfig.priceThreshold = -heatpumpPriceWidget.currentRelativeValue;
        newConfig.optimizationMode = optimizationModeDropdown.model.get(optimizationModeDropdown.currentIndex).enumname;
        newConfig.relativePriceEnabled = true;
        if (minPVSurplusPower.visible) {
            newConfig.pvSurplusThreshold = parseInt(minPVSurplusPower.text);
        }
        if (minRuntimeStepper.visible) {
            newConfig.durationMinAfterTurnOn = minRuntimeStepper.value * 900;
        }
        if (maxTotalRuntimeStepper.visible) {
            newConfig.durationMaxTotal = maxTotalRuntimeStepper.value * 900;
        }
        // Null UUID means: no meter selected → pass empty string,
        // so C++ omits the field from the RPC request (backend rejects null UUID).
        // Qt serialises QUuid with braces, e.g. "{00000000-0000-0000-0000-000000000000}",
        // so we check for the null-UUID pattern regardless of surrounding braces.
        if (!newConfig.heatMeterThingId ||
                newConfig.heatMeterThingId === "" ||
                (typeof newConfig.heatMeterThingId === "string" &&
                 newConfig.heatMeterThingId.indexOf("00000000-0000-0000-0000-000000000000") !== -1)) {
            newConfig.heatMeterThingId = "";
        }
        console.info("Saving new heating configuration: " + JSON.stringify(newConfig));
        d.pendingCallId = hemsManager.setHeatingConfiguration(thing.id, newConfig);
    }

    function translateNymeaHeatpumpValues(something) {
        switch (something) {
        case "Off":
            return qsTr("Off");
        case "Low":
            return qsTr("Standard");
        case "Standard":
            return qsTr("Increased");
        case "High":
            return qsTr("High");
        }
    }

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: engine.thingManager
        onThingStateChanged: (thingId, stateTypeId, value) => {
                                 if (dynamicPrice.count > 0 && thingId === dynamicPrice.get(0).id) {
                                     updatePrice();
                                 }
                             }
    }

    Connections {
        target: hemsManager
        onSetHeatingConfigurationReply: function(commandId, error) {
            if (commandId === d.pendingCallId) {
                d.pendingCallId = -1;
                let props = "";
                switch (error) {
                case "HemsErrorNoError":
                    return;
                case "HemsErrorInvalidParameter":
                    props.text = qsTr("Could not save configuration. One of the parameters is invalid.");
                    break;
                case "HemsErrorInvalidThing":
                    props.text = qsTr("Could not save configuration. The thing is not valid.");
                    break;
                default:
                    props.errorCode = error;
                }
                var comp = Qt.createComponent("../components/ErrorDialog.qml");
                var popup = comp.createObject(app, { props });
                popup.open();
            }
        }
    }

    ThingsProxy {
        id: dynamicPrice
        engine: _engine
        shownInterfaces: ["dynamicelectricitypricing"]
    }

    content: [
        Flickable {
            anchors.fill: parent
            contentHeight: columnLayout.implicitHeight +
                           columnLayout.anchors.topMargin +
                           columnLayout.anchors.bottomMargin + root.navigationFooterHeight
            clip: true

            ColumnLayout {
                id: columnLayout
                anchors { left: parent.left; right: parent.right; top: parent.top }
                anchors.margins: Style.margins
                spacing: Style.margins

                CoEnergyCircle {
                    id: energyCircle
                    Layout.fillWidth: true
                    visible: root.currentPowerState !== null
                    power: root.currentPowerState.value
                    icon: app.interfacesToIcon(root.thing.thingClass.interfaces)
                    label: qsTr("Current power consumption")
                }

                RowLayout {
                    id: kpiCardsLayout
                    Layout.fillWidth: true
                    spacing: Style.margins

                    CoKPICard {
                        id: totalConsumptionCard
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: pvSurplusPowerCard.visible ?
                                                    Math.max(implicitHeight, pvSurplusPowerCard.implicitHeight) :
                                                    implicitHeight
                        visible: root.totalConsumptionState !== null
                        icon: Qt.resolvedUrl("qrc:/icons/electric_bolt.svg")
                        labelText: qsTr("Total consumption")
                        valueText: UiUtils.energyDisplayValue(root.totalConsumptionState) + " kWh"
                    }

                    CoKPICard {
                        id: pvSurplusPowerCard
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: totalConsumptionCard.visible ?
                                                    Math.max(implicitHeight, totalConsumptionCard.implicitHeight) :
                                                    implicitHeight
                        visible: root.pvSurplusPowerState !== null
                        icon: Qt.resolvedUrl("qrc:/icons/solar_power.svg")
                        labelText: qsTr("Forwarded Solar Surplus")
                        infoUrl: "PvSurplusInfo.qml"
                        valueText: (root.pvSurplusPowerState ? NymeaUtils.floatToLocaleString((+root.pvSurplusPowerState.value) / 1000, 2) : "-") + qsTr(" kW")
                    }
                }

                CoFrostyCard {
                    id: sgReadyStatusGroup
                    Layout.fillWidth: true
                    visible: thing.thingClass.interfaces.indexOf("smartgridheatpump") >= 0
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Status")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoCard {
                            id: sgReadyStatusCard
                            Layout.fillWidth: true
                            labelText: qsTr("Operating mode")
                            text: root.sgReadyModeState ? translateNymeaHeatpumpValues(root.sgReadyModeState.value) : ""
                            infoUrl: "EnergyManagerInfo.qml"
                            interactive: false
                        }
                    }
                }

                CoFrostyCard {
                    id: controlGroup
                    Layout.fillWidth: true
                    visible: thing.thingClass.interfaces.indexOf("smartgridheatpump") >= 0
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Control")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Style.smallMargins

                        CoComboBox {
                            id: optimizationModeDropdown
                            Layout.fillWidth: true
                            labelText: qsTr("Optimization")
                            infoUrl: "HeatpumpOptimizationInfo.qml"
                            infoProperties: ({
                                pvSurplusModeAvailable: false,
                                dynamicPricingModeAvailable: false
                            })
                            textRole: "text"
                            valueRole: "value"

                            // Base model that holds *all* possible options
                            property var fullModel: [
                                { text: qsTr("PV Surplus"), enumname: "OptimizationModePVSurplus", value: 0},
                                { text: qsTr("Dynamic Pricing"), enumname: "OptimizationModeDynamicPricing", value: 1},
                                { text: qsTr("Off"), enumname: "OptimizationModeOff", value: 2},
                            ]
                            // Actual ComboBox model
                            model: ListModel { id: filteredModel }

                            currentIndex: {
                                if (!root.heatingconfig) {
                                    return -1;
                                }
                                for (let i = 0; i < filteredModel.count; ++i) {
                                    if (filteredModel.get(i).enumname === root.heatingconfig.optimizationMode) {
                                        return i;
                                    }
                                }
                                return -1;
                            }

                            onCurrentIndexChanged: {
                                console.info(root.heatingconfig.optimizationMode);
                                console.debug("Optimization mode changed to:", currentIndex >= 0 ? comboBox.model.get(currentIndex).enumname : "none");
                            }

                            Component.onCompleted: {
                                rebuildModel();
                            }

                            Connections {
                                target: hemsManager
                                onAvailableUseCasesChanged: {
                                    optimizationModeDropdown.rebuildModel();
                                }
                            }

                            // --- Core filtering logic ---
                            function rebuildModel() {
                                console.info("Heating Config:", JSON.stringify(root.heatingconfig));

                                filteredModel.clear();
                                const pvEnabled = hemsManager.availableUseCases & HemsManager.HemsUseCasePv;
                                const dynEnabled = hemsManager.availableUseCases & HemsManager.HemsUseCaseDynamicEPricing;

                                infoProperties.pvSurplusModeAvailable = false;
                                infoProperties.dynamicPricingModeAvailable = false;
                                for (let i = 0; i < fullModel.length; ++i) {
                                    const item = fullModel[i];
                                    if (item.enumname === "OptimizationModePVSurplus" && pvEnabled) {
                                        filteredModel.append(item);
                                        infoProperties.pvSurplusModeAvailable = true;
                                    }
                                    else if (item.enumname === "OptimizationModeDynamicPricing" && dynEnabled) {
                                        filteredModel.append(item);
                                        infoProperties.dynamicPricingModeAvailable = true;
                                    }
                                    else if (item.enumname === "OptimizationModeOff") {
                                        filteredModel.append(item);
                                    }
                                }

                                // Set current index to match existing config
                                for (let i = 0; i < filteredModel.count; ++i) {
                                    if (filteredModel.get(i).value === root.heatingconfig.optimizationMode) {
                                        optimizationModeDropdown.currentIndex = i;
                                        return;
                                    }
                                }
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: pvSurplusGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("\"PV Surplus\"")
                    visible: thing.thingClass.interfaces.indexOf("pvsurplusheatpump") >= 0 ||
                             (thing.thingClass.interfaces.indexOf("smartgridheatpump") >= 0 &&
                              optimizationModeDropdown.currentIndex >= 0 &&
                              optimizationModeDropdown.model.get(optimizationModeDropdown.currentIndex).enumname === "OptimizationModePVSurplus")

                    ColumnLayout {
                        id: pvSurplusLayout
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Style.smallMargins

                        Component.onCompleted: {
                            if (!root.heatingconfig) return
                            maxTotalRuntimeStepper.value = Math.round(root.heatingconfig.durationMaxTotal / 900)
                            minRuntimeStepper.value = Math.round(root.heatingconfig.durationMinAfterTurnOn / 900)
                        }

                        CoCard {
                            id: pvPrioCard
                            Layout.fillWidth: true
                            labelText: qsTr("Priority")
                            text: (hemsManager.emsConfiguration.pvSurplusPriolistIndexOf(root.thing.id) + 1).toString()
                            showChildrenIndicator: true

                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("../optimization/PVPriorities.qml"), { alwaysEnabledThingId: root.thing.id.toString() });
                            }
                        }

                        CoInputField {
                            id: minPVSurplusPower
                            Layout.fillWidth: true
                            visible: thing.thingClass.interfaces.indexOf("smartgridheatpump") >= 0
                            compact: true
                            labelText: qsTr("Minimum power")
                            helpText: qsTr("Minimum PV surplus power required for activation.")
                            unit: "W"
                            text: heatingconfig ? heatingconfig.pvSurplusThreshold : ""
                            feedbackText: qsTr("Value must not be below %1 W.").arg(minPVSurplusPowerValidator.bottom)
                            textField.validator: IntValidator {
                                id: minPVSurplusPowerValidator
                                bottom: 100
                            }
                        }

                        CoInputStepper {
                            id: minRuntimeStepper
                            Layout.fillWidth: true
                            visible: thing.thingClass.interfaces.indexOf("smartgridheatpump") >= 0
                            labelText: qsTr("Minimum runtime")
                            helpText: qsTr("Runs at least this long after activation.")
                            unit: qsTr("hh:mm")
                            compact: true
                            from: 0
                            to: maxTotalRuntimeStepper.value
                            stepSize: 1
                            feedbackText: {
                                var v = maxTotalRuntimeStepper.value;
                                var h = Math.floor(v / 4);
                                var m = (v % 4) * 15;
                                var formatted = (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m;
                                return qsTr("Value must be between 00:00 and %1.").arg(formatted);
                            }
                            spinbox.textFromValue: function(value, locale) {
                                var h = Math.floor(value / 4);
                                var m = (value % 4) * 15;
                                return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m;
                            }
                            spinbox.valueFromText: function(text, locale) {
                                var parts = text.split(":");
                                if (parts.length !== 2) return 0;
                                return (parseInt(parts[0]) || 0) * 4 + Math.round((parseInt(parts[1]) || 0) / 15);
                            }
                            spinbox.validator: RegularExpressionValidator {
                                regularExpression: /^([0-1][0-9]|2[0-4]):(00|15|30|45)$/
                            }
                        }

                        CoInputStepper {
                            id: maxTotalRuntimeStepper
                            Layout.fillWidth: true
                            visible: thing.thingClass.interfaces.indexOf("smartgridheatpump") >= 0
                            labelText: qsTr("Maximum runtime")
                            helpText: qsTr("Limits the daily runtime and automatically switches the device off.")
                            unit: qsTr("hh:mm")
                            compact: true
                            from: minRuntimeStepper.value
                            to: 96 // 24 h * 4 quarter-hours
                            stepSize: 1
                            feedbackText: {
                                var v = minRuntimeStepper.value;
                                var h = Math.floor(v / 4);
                                var m = (v % 4) * 15;
                                var formatted = (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m;
                                return qsTr("Value must be between %1 and 24:00.").arg(formatted);
                            }
                            spinbox.textFromValue: function(value, locale) {
                                var h = Math.floor(value / 4);
                                var m = (value % 4) * 15;
                                return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m;
                            }
                            spinbox.valueFromText: function(text, locale) {
                                var parts = text.split(":");
                                if (parts.length !== 2) return 0;
                                return (parseInt(parts[0]) || 0) * 4 + Math.round((parseInt(parts[1]) || 0) / 15);
                            }
                            spinbox.validator: RegularExpressionValidator {
                                regularExpression: /^([0-1][0-9]|2[0-4]):(00|15|30|45)$/
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: dynamicPricingGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("\"Dynamic pricing\"")
                    visible: thing.thingClass.interfaces.indexOf("smartgridheatpump") >= 0 &&
                             optimizationModeDropdown.currentIndex >= 0 &&
                             optimizationModeDropdown.model.get(optimizationModeDropdown.currentIndex).enumname === "OptimizationModeDynamicPricing"

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: Style.margins

                        HeatpumpPriceWidget {
                            id: heatpumpPriceWidget
                            Layout.fillWidth: true
                            currentPrice: root.currentPrice
                            heatingConfiguration: root.heatingconfig
                            dynamicPriceThing: dynamicPrice.get(0)
                        }
                    }
                }
            }
        }
    ]
}
