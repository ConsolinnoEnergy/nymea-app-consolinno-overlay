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
            newConfig.durationMinAfterTurnOn = minRuntimeStepper.value * 15;
        }
        if (maxTotalRuntimeStepper.visible) {
            newConfig.durationMaxTotal = maxTotalRuntimeStepper.value * 15;
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
                                 if (thingId === dynamicPrice.get(0).id) {
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
                           columnLayout.anchors.bottomMargin
            clip: true

            ColumnLayout {
                id: columnLayout
                anchors.fill: parent
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
                        visible: root.totalConsumptionState !== null
                        icon: Qt.resolvedUrl("qrc:/icons/electric_bolt.svg")
                        labelText: qsTr("Total consumption") // #TODO wording
                        // #TODO use decimal places when value is small?
                        valueText: (root.totalConsumptionState ? NymeaUtils.floatToLocaleString((+root.totalConsumptionState.value), 0) : "-") + qsTr(" kWh")
                    }

                    CoKPICard {
                        id: pvSurplusPowerCard
                        Layout.fillWidth: true
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
                    headerText: qsTr("Control") // #TODO wording

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Style.smallMargins

                        CoComboBox {
                            id: optimizationModeDropdown
                            Layout.fillWidth: true
                            labelText: qsTr("Optimization") // #TODO wording
                            infoUrl: "HeatpumpOptimizationInfo.qml"
                            textRole: "text"

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

                                for (let i = 0; i < fullModel.length; ++i) {
                                    const item = fullModel[i];
                                    if (item.enumname === "OptimizationModePVSurplus" && pvEnabled) {
                                        filteredModel.append(item);
                                    }
                                    else if (item.enumname === "OptimizationModeDynamicPricing" && dynEnabled) {
                                        filteredModel.append(item);
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
                    headerText: qsTr("PV Surplus") // #TODO wording, quotation marks from design?
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
                            maxTotalRuntimeStepper.value = Math.round(root.heatingconfig.durationMaxTotal / 15)
                            minRuntimeStepper.value = Math.round(root.heatingconfig.durationMinAfterTurnOn / 15)
                        }

                        CoCard {
                            id: pvPrioCard
                            Layout.fillWidth: true
                            labelText: qsTr("Priority")
                            text: (hemsManager.emsConfiguration.pvSurplusPriolist.indexOf(root.thing.id) + 1).toString()
                            showChildrenIndicator: true

                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("../optimization/PVPriorities.qml"));
                            }
                        }

                        CoInputField {
                            id: minPVSurplusPower
                            Layout.fillWidth: true
                            visible: thing.thingClass.interfaces.indexOf("smartgridheatpump") >= 0
                            compactTextField: true
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
                            unit: qsTr("h")
                            compact: true
                            from: 0
                            to: maxTotalRuntimeStepper.value
                            stepSize: 1
                            feedbackText: qsTr("Value must be between 0 and %1 h.").arg(NymeaUtils.floatToLocaleString(maxTotalRuntimeStepper.value / 4, 2))
                            spinbox.textFromValue: function(value, locale) {
                                return NymeaUtils.floatToLocaleString(value / 4, 2);
                            }
                            spinbox.valueFromText: function(text, locale) {
                                return Math.round(Number.fromLocaleString(Qt.locale(), text) * 4);
                            }
                            spinbox.validator: DoubleValidator {
                                bottom: 0
                                top: maxTotalRuntimeStepper.value / 4
                                decimals: 2
                                notation: DoubleValidator.StandardNotation
                            }
                        }

                        CoInputStepper {
                            id: maxTotalRuntimeStepper
                            Layout.fillWidth: true
                            visible: thing.thingClass.interfaces.indexOf("smartgridheatpump") >= 0
                            labelText: qsTr("Maximum runtime")
                            helpText: qsTr("Limits the daily runtime and automatically switches the device off.")
                            unit: qsTr("h")
                            compact: true
                            from: minRuntimeStepper.value
                            to: 96 // 24 h * 4 quarter-hours
                            stepSize: 1
                            feedbackText: qsTr("Value must be between %1 and 24 h.").arg(NymeaUtils.floatToLocaleString(minRuntimeStepper.value / 4, 2))
                            spinbox.textFromValue: function(value, locale) {
                                return NymeaUtils.floatToLocaleString(value / 4, 2);
                            }
                            spinbox.valueFromText: function(text, locale) {
                                return Math.round(Number.fromLocaleString(Qt.locale(), text) * 4);
                            }
                            spinbox.validator: DoubleValidator {
                                bottom: minRuntimeStepper.value / 4
                                top: 24
                                decimals: 2
                                notation: DoubleValidator.StandardNotation
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: dynamicPricingGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Dynamic pricing") // #TODO wording, quotation marks from design?
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

                Button {
                    id: saveButton
                    Layout.fillWidth: true
                    visible: thing.thingClass.interfaces.indexOf("smartgridheatpump") >= 0
                    text: qsTr("Apply changes")
                    enabled: {
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
                                minRuntimeStepper.value * 15 !== root.heatingconfig.durationMinAfterTurnOn) {
                            return true;
                        }
                        if (maxTotalRuntimeStepper.visible &&
                                maxTotalRuntimeStepper.value * 15 !== root.heatingconfig.durationMaxTotal) {
                            return true;
                        }
                        if (heatpumpPriceWidget.visible &&
                                -heatpumpPriceWidget.currentRelativeValue !== root.heatingconfig.priceThreshold) {
                            return true;
                        }
                        return false;
                    }
                    onClicked: {
                        saveSettings();
                    }
                }
            }
        }
    ]
}
