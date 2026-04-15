import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml
import Qt5Compat.GraphicalEffects
import Nymea 1.0
import NymeaApp.Utils 1.0
import QtCharts

import "../components"
import "../delegates"
import "../devicepages"

import "../utils/DynPricingUtils.js" as DynPricingUtils

GenericConfigPage {
    id: root
    property Thing thing
    property BatteryConfiguration batteryConfiguration: hemsManager.batteryConfigurations.getBatteryConfiguration(thing.id)
    readonly property State batteryChargingState: thing.stateByName("chargingState")
    readonly property State batteryLevelState: thing.stateByName("batteryLevel")
    readonly property State currentPowerState: thing.stateByName("currentPower")
    property bool isZeroCompensation : batteryConfiguration.avoidZeroFeedInActive && batteryConfiguration.avoidZeroFeedInEnabled

    property double absChargingThreshold: 0
    property double absDischargeBlockedThreshold: 0
    property double relChargingThreshold: batteryConfiguration.priceThreshold
    property double relDischargeBlockedThreshold: batteryConfiguration.dischargePriceThreshold

    property double currentPrice: 0
    property double lowestPrice: 0
    property double highestPrice: 0

    // #TODO copied from CoDashboardView.qml -> extract to some common utils file
    function batteryIconByLevel(batteryLevel) {
        let batteryLevelForIcon = NymeaUtils.pad(Math.round(batteryLevel / 10) * 10, 3);
        return Qt.resolvedUrl("qrc:/icons/battery/battery-" + batteryLevelForIcon + ".svg");
    }

    title: root.thing.name
    headerOptionsVisible: true

    QtObject {
        id: d
        property int pendingCallId: -1
        property date now: new Date()
        property date startTimeSince: new Date(0)
        property date endTimeUntil: new Date(0)
    }

    Connections {
        target: hemsManager
        onSetBatteryConfigurationReply: function(commandId, error) {

            if (commandId === d.pendingCallId) {
                d.pendingCallId = -1
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

        onBatteryConfigurationChanged: {
            tariffControlledChargingToggle.checked = batteryConfiguration.optimizationEnabled;
            chargeOnceToggle.checked = batteryConfiguration.chargeOnce;
            relChargingThreshold = batteryConfiguration.priceThreshold;
            relDischargeBlockedThreshold = batteryConfiguration.dischargePriceThreshold;
            console.debug("Battery configuration changed received. New priceThreshold: " +
                          batteryConfiguration.priceThreshold +
                          ", dischargePriceThreshold: " +
                          batteryConfiguration.dischargePriceThreshold);
        }
    }

    Connections {
        target: engine.thingManager
        onThingStateChanged: (thingId, stateTypeId, value)=> {
                                 if (dynamicPrice.count > 0 && thingId === dynamicPrice.get(0).id ) {
                                     updatePrice();
                                 }
                             }
    }

    function updatePrice() {
        if (dynamicPrice.count === 0) return;
        currentPrice = dynamicPrice.get(0).stateByName("currentMarketPrice").value;
        currentPriceLabel.text = Number(currentPrice).toLocaleString(Qt.locale(), 'f', 2) + " ct/kWh";
    }

    function saveSettings()
    {
        let targetSocPvSurplus = [ Math.round(pvPrioSlider.value) ];
        d.pendingCallId = hemsManager.setBatteryConfiguration(thing.id,
                                                              {
                                                                  "optimizationEnabled": tariffControlledChargingToggle.checked,
                                                                  "priceThreshold": relChargingThreshold,
                                                                  "dischargePriceThreshold": relDischargeBlockedThreshold,
                                                                  "relativePriceEnabled": true,
                                                                  "chargeOnce": chargeOnceToggle.checked,
                                                                  "avoidZeroFeedInActive": batteryConfiguration.avoidZeroFeedInActive,
                                                                  "targetSocPvSurplus": targetSocPvSurplus
                                                              });
    }

    function enableSave(obj)
    {
        saveButton.enabled = batteryConfiguration.priceThreshold !== relChargingThreshold ||
                batteryConfiguration.dischargePriceThreshold !== relDischargeBlockedThreshold ||
                (chargeOnceToggle.enabled && batteryConfiguration.chargeOnce !== chargeOnceToggle.checked) ||
                batteryConfiguration.optimizationEnabled !== tariffControlledChargingToggle.checked ||
                (batteryConfiguration.targetSocPvSurplus.length > 0 && batteryConfiguration.targetSocPvSurplus[0] !== Math.round(pvPrioSlider.value));
    }

    ThingsProxy {
        id: dynamicPrice
        engine: _engine
        shownInterfaces: ["dynamicelectricitypricing"]
    }

    Component.onCompleted: {
        const dpThing = dynamicPrice.get(0);
        if (!dpThing) { return; }

        d.startTimeSince = new Date(dpThing.stateByName("validSince").value * 1000);
        d.endTimeUntil = new Date(dpThing.stateByName("validUntil").value * 1000);
        absChargingThreshold = DynPricingUtils.relPrice2AbsPrice(batteryConfiguration.priceThreshold,
                                                                 dpThing);
        absDischargeBlockedThreshold = DynPricingUtils.relPrice2AbsPrice(batteryConfiguration.dischargePriceThreshold,
                                                                         dpThing);
        currentPrice = dpThing.stateByName("currentTotalCost").value;
        lowestPrice = dpThing.stateByName("lowestPrice").value;
        highestPrice = dpThing.stateByName("highestPrice").value;
        barSeries.addValues(dpThing.stateByName("totalCostSeries").value,
                            dpThing.stateByName("priceSeries").value,
                            dpThing.stateByName("gridFeeSeries").value,
                            dpThing.stateByName("leviesSeries").value,
                            DynPricingUtils.getVAT(dpThing));

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

                CoNotification {
                    id: avoidZeroCompensationWarning
                    Layout.fillWidth: true
                    visible: isZeroCompensation
                    type: CoNotification.Type.Warning
                    title: qsTr("Avoid zero compensation active")
                    message: qsTr("Battery charging is limited while the controller is active. <u>More Information</u>")
                    clickable: true
                    onClicked: {
                        pageStack.push("/ui/info/AvoidZeroCompensationInfo.qml", {stack: pageStack});
                    }
                }

                CoEnergyCircle {
                    id: energyCircle
                    Layout.fillWidth: true
                    power: root.currentPowerState ? root.currentPowerState.value : 0
                    icon: root.batteryLevelState ?
                              batteryIconByLevel(root.batteryLevelState.value) :
                              app.interfacesToIcon(root.thing.thingClass.interfaces)
                    label: !root.currentPowerState ?
                               "" :
                               Math.round(root.currentPowerState.value) > 0 ?
                                   qsTr("Charging") :
                                   Math.round(root.currentPowerState.value) < 0 ?
                                       qsTr("Discharging") :
                                       qsTr("Idle")
                }

                CoKPICard {
                    id: batteryLevelCard
                    Layout.fillWidth: true
                    visible: root.batteryLevelState !== null
                    icon: root.batteryLevelState ?
                              batteryIconByLevel(root.batteryLevelState.value) :
                              app.interfacesToIcon(root.thing.thingClass.interfaces)
                    labelText: qsTr("State of Charge") // #TODO wording
                    valueText: (root.batteryLevelState ? Math.round(root.batteryLevelState.value) : "-") + qsTr(" %")
                }

                CoFrostyCard {
                    id: pvPrioGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("PV device prioritization") // #TODO wording
                    visible: thing.thingClass.interfaces.indexOf("controllablebattery") >= 0

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Style.smallMargins

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

                        CoSlider {
                            id: pvPrioSlider
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            stepSize: 1
                            labelText: qsTr("Priority applies up to state of charge") // #TODO wording
                            helpText: qsTr("Above this state of charge, the battery is always considered last") // #TODO wording
                            value: batteryConfiguration.targetSocPvSurplus.length > 0 ? batteryConfiguration.targetSocPvSurplus[0] : 80
                            valueText: Math.round(value) + " %"
                            onValueChanged: enableSave(this)
                        }
                    }
                }

                CoFrostyCard {
                    id: chargingFromGridGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Charging from grid") // #TODO wording
                    visible: thing.thingClass.interfaces.indexOf("controllablebattery") >= 0

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Style.smallMargins

                        CoSwitch {
                            id: tariffControlledChargingToggle
                            Layout.fillWidth: true
                            text: qsTr("Tariff-controlled charging")
                            visible: dynamicPrice.count >= 1

                            Component.onCompleted: {
                                checked = root.batteryConfiguration.optimizationEnabled;
                            }
                            onCheckedChanged: {
                                if(!tariffControlledChargingToggle.checked){
                                    chargeOnceToggle.checked = false;
                                }
                                enableSave(this);
                            }
                        }

                        CoSwitch {
                            id: chargeOnceToggle
                            Layout.fillWidth: true
                            text: qsTr("Activate instant charging")
                            enabled: !root.isZeroCompensation
                            // #TODO show helpText when not enabled to explain why?
                            visible: tariffControlledChargingToggle.checked

                            Component.onCompleted: {
                                checked = root.batteryConfiguration.chargeOnce;
                            }
                            onCheckedChanged: {
                                if (!root.isZeroCompensation) {
                                    enableSave(this);
                                }
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: dynamicPricingGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Charging plan") // #TODO wording
                    visible: tariffControlledChargingToggle.checked

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        enabled: !chargeOnceToggle.checked

                        CoSlider {
                            id: chargingThresholdSlider
                            Layout.fillWidth: true
                            visible: tariffControlledChargingToggle.checked
                            from: -100
                            to: 100
                            stepSize: 1
                            value: root.batteryConfiguration.priceThreshold
                            labelText: qsTr("\"Charging\" price limit")
                            helpText: qsTr("Deviation from the 48-h average (in %) at which charging takes place. Currently corresponds to %1 ct/kWh.").arg(root.absChargingThreshold.toLocaleString(Qt.locale(), 'f', 2))
                            valueText: qsTr("%1 %").arg(relChargingThreshold.toFixed(0))

                            slider.onMoved: {
                                absChargingThreshold = DynPricingUtils.relPrice2AbsPrice(value, dynamicPrice.get(0));
                                relChargingThreshold = value;
                                if (absChargingThreshold > absDischargeBlockedThreshold) {
                                    absDischargeBlockedThreshold = absChargingThreshold;
                                    relDischargeBlockedThreshold = relChargingThreshold;
                                    dischargeBlockedThresholdSlider.value = relChargingThreshold
                                }

                                enableSave(this);

                                // Redraw graph (Update the graph immediately when Charge Price changes)
                                barSeries.clearValues();
                                barSeries.addValues(dynamicPrice.get(0).stateByName("totalCostSeries").value,
                                                    dynamicPrice.get(0).stateByName("priceSeries").value,
                                                    dynamicPrice.get(0).stateByName("gridFeeSeries").value,
                                                    dynamicPrice.get(0).stateByName("leviesSeries").value,
                                                    DynPricingUtils.getVAT(dynamicPrice.get(0)));
                            }
                        }

                        CoSlider {
                            id: dischargeBlockedThresholdSlider
                            Layout.fillWidth: true
                            visible: tariffControlledChargingToggle.checked
                            from: -100
                            to: 100
                            stepSize: 1
                            value: root.batteryConfiguration.dischargePriceThreshold
                            labelText: qsTr("\"Block discharging\" price limit")
                            helpText: qsTr("Deviation from the 48-h average (in %) below which discharging is blocked. Currently corresponds to %1 ct/kWh.").arg(root.absDischargeBlockedThreshold.toLocaleString(Qt.locale(), 'f', 2))
                            valueText: qsTr("%1 %").arg(relDischargeBlockedThreshold.toFixed(0))

                            slider.onMoved: {
                                absDischargeBlockedThreshold = DynPricingUtils.relPrice2AbsPrice(value, dynamicPrice.get(0));
                                relDischargeBlockedThreshold = value;
                                if (absDischargeBlockedThreshold < absChargingThreshold) {
                                    absChargingThreshold = absDischargeBlockedThreshold;
                                    relChargingThreshold = relDischargeBlockedThreshold;
                                    chargingThresholdSlider.value = relDischargeBlockedThreshold;
                                }

                                enableSave(this);
                                // Redraw graph (Update the graph immediately when Charge Price changes)
                                barSeries.clearValues();
                                barSeries.addValues(dynamicPrice.get(0).stateByName("totalCostSeries").value,
                                                    dynamicPrice.get(0).stateByName("priceSeries").value,
                                                    dynamicPrice.get(0).stateByName("gridFeeSeries").value,
                                                    dynamicPrice.get(0).stateByName("leviesSeries").value,
                                                    DynPricingUtils.getVAT(dynamicPrice.get(0)));
                            }
                        }

                        CustomBarSeries {
                            id: barSeries
                            Layout.fillWidth: true
                            Layout.preferredHeight: 200
                            Layout.leftMargin: Style.smallMargins
                            backgroundColor: isZeroCompensation || chargeOnceToggle.checked ? Style.barSeriesDisabled : "transparent"
                            startTime: d.startTimeSince
                            endTime: d.endTimeUntil
                            hoursNow: d.now.getHours()
                            currentPrice: absChargingThreshold
                            currentMarketPrice: currentPrice
                            upperPriceLimit: absDischargeBlockedThreshold
                            lowestValue: root.lowestPrice
                            highestValue: root.highestPrice
                        }

                        GridLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            columns: 3
                            height: Style.smallIconSize

                            Row {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 5
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: Style.epexBarMainLineColor
                                    width: 8
                                    height: 8
                                }
                                Label {
                                    anchors.verticalCenter: parent.verticalCenter
                                    font: Style.extraSmallFont
                                    text: qsTr("Charging")
                                }
                            }

                            Row {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 5
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: Style.epexBarPricingOutOfLimit
                                    width: 8
                                    height: 8
                                }
                                Label {
                                    anchors.verticalCenter: parent.verticalCenter
                                    font: Style.extraSmallFont
                                    text: qsTr("Discharging blocked")
                                }
                            }

                            Row {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 5
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: Configuration.batteryDischargeColor
                                    width: 8
                                    height: 8
                                }
                                Label {
                                    anchors.verticalCenter: parent.verticalCenter
                                    font: Style.extraSmallFont
                                    text: qsTr("Discharging allowed")
                                }
                            }
                        }
                    }
                }

                Button {
                    id: saveButton
                    Layout.fillWidth: true
                    text: qsTr("Save")
                    enabled: false
                    visible: thing.thingClass.interfaces.indexOf("controllablebattery") >= 0

                    onClicked: {
                        saveSettings()
                        saveButton.enabled = false
                    }
                }
            }
        }
    ]
}
