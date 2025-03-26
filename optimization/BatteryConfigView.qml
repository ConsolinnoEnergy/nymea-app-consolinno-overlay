import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtQml 2.2
import QtGraphicalEffects 1.15
import Nymea 1.0
import QtCharts 2.3

import "qrc:/ui/components"

import "../components"
import "../delegates"
import "../devicepages"

GenericConfigPage {
    id: root
    property Thing thing
    property HemsManager hemsManager
    property UserConfiguration userconfig: hemsManager.userConfigurations.getUserConfiguration("528b3820-1b6d-4f37-aea7-a99d21d42e72")
    readonly property State batteryChargingState: root.thing.stateByName("chargingState")
    readonly property State batteryLevelState: root.thing.stateByName("batteryLevel")
    readonly property State currentPowerState: root.thing.stateByName("currentPower")
    property BatteryConfiguration batteryConfiguration: hemsManager.batteryConfigurations.getBatteryConfiguration(thing.id)


    property double currentValue : batteryConfiguration.priceThreshold
    property double thresholdPrice: 0
    property int valueAxisUpdate: {
        (0 > barSeries.lowestValue) ? valueAxisUpdate = barSeries.lowestValue :  (currentValue < 0) ? valueAxisUpdate = currentValue - 2 : valueAxisUpdate = -2
    }

    property int validSince: 0
    property int validUntil: 0
    property double averagePrice: 0
    property double currentPrice: 0
    property double lowestPrice: 0
    property double highestPrice: 0
    property var prices: ({})

    title: root.thing.name
    headerOptionsVisible: false

    QtObject {
        id: rootObject
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onSetBatteryConfigurationReply: {

            if (commandId === rootObject.pendingCallId) {
                rootObject.pendingCallId = -1
                let props = "";
                switch (error) {
                case "HemsErrorNoError":
                    return
                case "HemsErrorInvalidParameter":
                    props.text = qsTr("Could not save configuration. One of the parameters is invalid.")
                    break
                case "HemsErrorInvalidThing":
                    props.text = qsTr("Could not save configuration. The thing is not valid.")
                    break
                default:
                    props.errorCode = error
                }
                var comp = Qt.createComponent("../components/ErrorDialog.qml")
                var popup = comp.createObject(app, {props})
                popup.open()
            }
        }

        onBatteryConfigurationChanged: {
            optimizationController.checked = batteryConfiguration.optimizationEnabled
            chargeOnceController.checked = batteryConfiguration.chargeOnce
            currentValue = batteryConfiguration.priceThreshold
        }
    }

    Connections {
        target: engine.thingManager
        onThingStateChanged: (thingId, stateTypeId, value)=> {
            if (thingId === dynamicPrice.get(0).id ) {
                updatePrice()
            }
        }
    }

    Component.onCompleted: {
        currentPrice = dynamicPrice.get(0).stateByName("currentMarketPrice").value
    }


    function updatePrice() {
        currentPrice = dynamicPrice.get(0).stateByName("currentMarketPrice").value
        currentPriceLabel.text = Number(currentPrice).toLocaleString(Qt.locale(), 'f', 2) + " ct/kWh"
    }


    function relPrice2AbsPrice(relPrice){
        averagePrice = dynamicPrice.get(0).stateByName("averagePrice").value
        let minPrice = dynamicPrice.get(0).stateByName("lowestPrice").value
        let maxPrice = dynamicPrice.get(0).stateByName("highestPrice").value
        if (averagePrice === minPrice || averagePrice === maxPrice){
            return averagePrice
        }
        if (relPrice <= 0){
            thresholdPrice = averagePrice - 0.01 * relPrice * (minPrice - averagePrice)
        }else{
            thresholdPrice = 0.01 * relPrice * (maxPrice - averagePrice) + averagePrice
        }
        thresholdPrice = thresholdPrice.toFixed(2)
        return thresholdPrice
    }


    function saveSettings()
    {
        rootObject.pendingCallId = hemsManager.setBatteryConfiguration(thing.id, {"optimizationEnabled": optimizationController.checked,
                        "priceThreshold": currentValue,
                        "relativePriceEnabled": false,
                        "chargeOnce": chargeOnceController.checked,
                        "controllableLocalSystem": optimizationController.checked})
    }

    function enableSave(obj)
    {
        saveButton.enabled = true
    }


    ThingsProxy {
        id: dynamicPrice
        engine: _engine
        shownInterfaces: ["dynamicelectricitypricing"]
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.margins: app.margins

        //Status
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 30

            Label {
                text: qsTr("Status")
                Layout.fillWidth: true
                font.weight: Font.Bold
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Rectangle {
                    id: status

                    width: 120
                    height: description.height + 10
                    Layout.alignment: Qt.AlignRight

                    color: batteryChargingState.value === "charging" ? Configuration.batteriesColor : batteryChargingState.value === "discharging" ? Configuration.batteryDischargeColor : Configuration.batteryIdleColor
                    radius: width*0.1

                    Label {
                        id: description
                        text: batteryChargingState.value === "charging" ? qsTr("Charging") : batteryChargingState.value === "discharging" ? qsTr("Discharging") : qsTr("Idle")
                        color: "white"
                        anchors.centerIn: parent
                    }
                }
            }

        }


        // Current Battery Level
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 5
            Label {
                text: qsTr("State of Charge")
                Layout.fillWidth: true
            }

            Label {
                text: ("%1 %").arg(batteryLevelState.value)
            }
        }

        // Current Power
        RowLayout {
            Layout.topMargin: 5
            Label {
                Layout.fillWidth: true
                text: qsTr("Power")
            }

            Label {
                text: currentPowerState.value > 0 ? Math.round(currentPowerState.value) + " W" : (Math.round(currentPowerState.value) * -1) + " W"
            }
        }

        RowLayout {
            Layout.topMargin: 10
            Label {
                text: qsTr("Charging from grid")
                font.weight: Font.Bold
            }
        }

        ColumnLayout {
            visible: dynamicPrice.count >= 1 && thing.thingClass.interfaces.indexOf("controllablebattery") >= 0
            id: columnContainer

            // Optimization enabled
            RowLayout {
                Label {
                    text: qsTr("Tariff-guided charging")
                }

                InfoButton {
                    id: chargingOptimizationInfo
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    push: "TariffGuidedChargingInfo.qml"
                }

                Column {
                    Switch{
                        spacing: 0
                        height: 15
                        id: optimizationController
                        onClicked: {
                            if(!optimizationController.checked){
                                chargeOnceController.checked = false;
                            }
                            //saveSettings()
                            enableSave(this)
                        }
                        Component.onCompleted: {
                            checked = batteryConfiguration.optimizationEnabled
                        }
                    }
                }
            }

            // Charge once
            RowLayout {
                Layout.topMargin: 5
                visible: optimizationController.checked
                Label {
                    text: qsTr("Activate instant charging")
                }

                InfoButton {
                    id: chargingOnceInfo
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    push: "ActivateInstantChargingInfo.qml"
                }

                Column {
                    Switch {
                        spacing: 0
                        height: 15
                        id: chargeOnceController
                        Component.onCompleted: {
                            checked = batteryConfiguration.chargeOnce
                        }
                        onClicked: {
                            //saveSettings()
                            enableSave(this)
                        }
                    }
                }
            }

        ColumnLayout {
            id: columnLayer
            // Charging Plan Header
            RowLayout {
                Layout.topMargin: 15
                visible: optimizationController.checked
                Label {
                    text: qsTr("Charging Plan")
                    font.weight: Font.Bold
                }
            }

            // Price Limit
            RowLayout {
                id: currentPriceRow
                visible: optimizationController.checked
                Layout.topMargin: 5

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Current price")
                }

                Label {
                    id: currentPriceLabel
                    text: Number(currentPrice).toLocaleString(Qt.locale(), 'f', 2) + " ct/kWh"
                }
            }

            // Graph Info Today
            ColumnLayout {
                Layout.fillWidth: true
                visible: optimizationController.checked
                enabled: chargeOnceController.checked ? false : true
                Component.onCompleted: {
                    const dpThing = dynamicPrice.get(0)
                    if(!dpThing)
                        return;

                    currentPrice = dpThing.stateByName("currentMarketPrice").value
                    averagePrice = dpThing.stateByName("averagePrice").value.toFixed(0).toString();
                    barSeries.addValues(dpThing.stateByName("priceSeries").value)
                }

                QtObject {
                    id: d

                    property date now: new Date()

                    readonly property var startTimeSince: {
                        var date = new Date();
                        date.setHours(0);
                        date.setMinutes(0);
                        date.setSeconds(0);

                        return date;
                    }

                    readonly property var endTimeUntil: {
                        var date = new Date();
                        date.setHours(0);
                        date.setMinutes(0);
                        date.setSeconds(0);
                        date.setDate(date.getDate()+1);
                        return date;
                    }

                }

                Item {
                    Layout.fillWidth: parent.width
                    Layout.fillHeight: true
                    Layout.minimumHeight: 50

                    CustomBarSeries {
                      id: barSeries
                      anchors.fill: parent
                      margins.left: 0
                      margins.right: 0
                      margins.top: 0
                      margins.bottom: 0
                      backgroundColor: chargeOnceController.checked ? "whitesmoke" : "transparent"
                      startTime: d.startTimeSince
                      endTime: d.endTimeUntil
                      hoursNow: d.now.getHours()
                      currentPrice: currentValue
                      currentMarketPrice: currentPrice
                    }

                }

                Label {
                    visible: optimizationController.checked
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    text: qsTr("Prices represent the pure exchange price without taxes and fees.")
                    font.pixelSize: 12
                }
            }

            // Space divider
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }


            ItemDelegate {
                Layout.fillWidth: true
                topPadding: 0
                visible: optimizationController.checked
                enabled: chargeOnceController.checked ? false : true
                contentItem: ColumnLayout {
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Price limit : %1 ct/kWh").arg(currentValue)
                    }
                    Slider {
                        Layout.fillWidth: true
                        value: currentValue
                        onMoved: () => {
                          currentValue = value;
                          saveButton.enabled = batteryConfiguration.priceThreshold !== currentValue;

                          barSeries.clearValues();
                          barSeries.addValues(dynamicPrice.get(0).stateByName("priceSeries").value);
                        }
                        from: -50
                        to: 50
                        stepSize: 0.2
                    }
                }
            }
        }

            // Save Button
            RowLayout {
                id: saveBtnContainer
                anchors.margins: app.margins

                Button {
                    id: saveButton
                    Layout.fillWidth: true
                    text: qsTr("Save")
                    enabled: false

                    onClicked: {
                        saveSettings()
                        saveButton.enabled = false
                    }
                }
            }
        }
    }
}
