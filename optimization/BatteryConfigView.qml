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
    property bool isZeroCompensation : batteryConfiguration.avoidZeroFeedInActive && batteryConfiguration.avoidZeroFeedInEnabled

    // Propertes will be bound to the RangeSlider's values:
    // Upper slider handle sets the Charge Price Limit
    property double currentValue : batteryConfiguration.priceThreshold
    // Lower slider handle sets the Discharge Price Offset
    property double dischargePriceThresholdValue : batteryConfiguration.dischargePriceThreshold

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
    headerOptionsVisible: true

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
            // Initialize both properties for the RangeSlider
            currentValue = batteryConfiguration.priceThreshold
            dischargePriceThresholdValue = batteryConfiguration.dischargePriceThreshold
            console.debug("Battery configuration changed received. New priceThreshold: " + batteryConfiguration.priceThreshold + ", dischargePriceThreshold: " + batteryConfiguration.dischargePriceThreshold)
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
        // Save both values controlled by the RangeSlider
        rootObject.pendingCallId = hemsManager.setBatteryConfiguration(thing.id, {"optimizationEnabled": optimizationController.checked,
                                                                           "priceThreshold": currentValue,
                                                                           "dischargePriceThreshold": dischargePriceThresholdValue,
                                                                           "relativePriceEnabled": false,
                                                                           "chargeOnce": chargeOnceController.checked,
                                                                           "avoidZeroFeedInActive": batteryConfiguration.avoidZeroFeedInActive,})
    }

    function enableSave(obj)
    {
        // Check if either of the two RangeSlider values has changed from the stored configuration
        saveButton.enabled = batteryConfiguration.priceThreshold !== currentValue || batteryConfiguration.dischargePriceThreshold !== dischargePriceThresholdValue
    }

    ThingsProxy {
        id: dynamicPrice
        engine: _engine
        shownInterfaces: ["dynamicelectricitypricing"]
    }

    content: [

        Flickable {
            anchors.fill: parent
            contentHeight: columnLayoutContainer.implicitHeight + (isZeroCompensation ? 100 : 0)
            topMargin: 0
            clip: true

            ColumnLayout {
                id: columnLayoutContainer
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.margins: app.margins

                ConsolinnoAlert {
                    visible: isZeroCompensation
                    backgroundColor: "#FFEE89"
                    borderColor: "#864A0D"
                    textColor: "#864A0D"
                    iconColor: "#864A0D"

                    imagePath: "../components/ConsolinnoDialog.qml"
                    dialogHeaderText: qsTr("Avoid zero compensation")
                    dialogText: qsTr("On days with negative electricity prices on the power exchange, battery capacity is actively reserved to allow charging the battery during hours with these negative exchange prices, thus avoiding feeding electricity into the grid without compensation. Once this control is active, battery charging is limited (indicated by the yellow message on the screen). The control system is based on PV production and household consumption forecasts and shifts the battery charging accordingly.")
                    dialogPicture: "../images/avoidZeroCompansation.svg"

                    text: qsTr("Battery charging is limited while the controller is active. <u>More Information</u>")
                    headerText: qsTr("Avoid zero compensation active")
                }

                //Status
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: true ? 5 : 30

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
                    Label {
                        text: qsTr("State of Charge")
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        spacing: 0
                        Layout.rightMargin: 20
                        Label {
                            text: ("%1 %").arg(batteryLevelState.value)
                            horizontalAlignment: Text.AlignRight
                        }

                        ThingInfoPane {
                            id: infoPane
                            width: 0
                            Layout.leftMargin: -12
                            thing: root.thing
                            hideLabel: true
                        }
                    }
                }

                // Current Power
                RowLayout {

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
                    id: columnContainer
                    visible: dynamicPrice.count >= 1 && thing.thingClass.interfaces.indexOf("controllablebattery") >= 0

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
                            ConsolinnoSwitch {
                                spacing: 1
                                height: 18
                                id: optimizationController

                                onClicked: {
                                    if(!optimizationController.checked){
                                        chargeOnceController.checked = false;
                                    }
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
                            id: columnArea

                            Item {
                                id: switchContainer
                                width: chargeOnceController.width
                                height: chargeOnceController.height

                                ConsolinnoSwitch {
                                    id: chargeOnceController
                                    anchors.fill: parent
                                    spacing: 1
                                    height: 18
                                    enabled: isZeroCompensation ? false : true

                                    Component.onCompleted: {
                                        checked = batteryConfiguration.chargeOnce
                                    }
                                    onClicked: {
                                        if (!isZeroCompensation)
                                            enableSave(this)
                                    }
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    enabled: isZeroCompensation

                                    onEntered: {
                                        if (isZeroCompensation)
                                            toolTipSwitch.visible = true
                                    }
                                    onExited: {
                                        if (isZeroCompensation)
                                            toolTipSwitch.visible = false
                                    }
                                }

                                NymeaToolTip {
                                    id: toolTipSwitch
                                    visible: false

                                    z: 10
                                    anchors.right: parent.right
                                    anchors.bottom: parent.top
                                    anchors.bottomMargin: 5

                                    width: toolTopLayout.width + Style.smallMargins * 2
                                    height: toolTopLayout.implicitHeight + Style.smallMargins * 2

                                    ColumnLayout {
                                        id: toolTopLayout
                                        width: 305
                                        anchors.fill: parent
                                        anchors.margins: Style.smallMargins

                                        Label {
                                            id: labelID
                                            Layout.fillWidth: true
                                            wrapMode: Text.WordWrap
                                            text: qsTr("If the zero-compensation avoidance is active, immediate battery charging is not possible.")
                                            font: Style.smallFont
                                        }
                                    }
                                }
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
                        enabled: chargeOnceController.checked ? false : true
                        Label {
                            text: qsTr("Charging Plan")
                            font.weight: Font.Bold
                        }
                    }

                    // Price Limit (Current Price)
                    RowLayout {
                        id: currentPriceRow
                        visible: optimizationController.checked
                        enabled: chargeOnceController.checked ? false : true
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

                            d.startTimeSince = new Date(dpThing.stateByName("validSince").value * 1000);
                            d.endTimeUntil = new Date(dpThing.stateByName("validUntil").value * 1000);
                            currentPrice = dpThing.stateByName("currentTotalCost").value
                            averagePrice = dpThing.stateByName("averageTotalCost").value.toFixed(0).toString();
                            lowestPrice = dpThing.stateByName("lowestPrice").value
                            highestPrice = dpThing.stateByName("highestPrice").value
                            barSeries.addValues(dpThing.stateByName("totalCostSeries").value,
                                                dpThing.stateByName("priceSeries").value,
                                                dpThing.stateByName("gridFeeSeries").value,
                                                dpThing.stateByName("leviesSeries").value,
                                                19.0);

                        }

                        QtObject {
                            id: d

                            property date now: new Date()
                            property date startTimeSince: new Date(0) // placeholder
                            property date endTimeUntil: new Date(0) // placeholder
                        }

                        Item {
                            Layout.fillWidth: parent.width
                            Layout.fillHeight: true
                            Layout.minimumHeight: 150

                            CustomBarSeries {
                                id: barSeries
                                anchors.fill: parent
                                margins.left: 0
                                margins.right: 0
                                margins.top: 0
                                margins.bottom: 0
                                backgroundColor: isZeroCompensation || chargeOnceController.checked ? Style.barSeriesDisabled : "transparent"
                                startTime: d.startTimeSince
                                endTime: d.endTimeUntil
                                hoursNow: d.now.getHours()
                                currentPrice: currentValue
                                currentMarketPrice: currentPrice
                                upperPriceLimit: dischargePriceThresholdValue
                                lowestValue: root.lowestPrice
                                highestValue: root.highestPrice
                            }
                        }

                        Label { // breaks view when removed
                            visible: optimizationController.checked
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            text: ""
                            font.pixelSize: 1
                        }
                    }

                    // Space divider
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Charge Price Limit: %1 ct/kWh").arg(currentValue.toFixed(2))
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: -5.0
                        to: 90.0
                        stepSize: 0.2
                        value: currentValue

                        onMoved: {
                            // Use a fixed precision and update the property
                            currentValue = value.toFixed(2);
                            if (currentValue > dischargePriceThresholdValue) {
                                dischargePriceThresholdValue = currentValue;
                            }

                            enableSave(this);

                            // Redraw graph (Update the graph immediately when Charge Price changes)
                            barSeries.clearValues();
                            barSeries.addValues(dynamicPrice.get(0).stateByName("totalCostSeries").value,
                                                dynamicPrice.get(0).stateByName("priceSeries").value,
                                                dynamicPrice.get(0).stateByName("gridFeeSeries").value,
                                                dynamicPrice.get(0).stateByName("leviesSeries").value,
                                                19.0);
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Discharge Price Limit: %1 ct/kWh").arg(dischargePriceThresholdValue.toFixed(2))
                    }

                    Slider {
                        Layout.fillWidth: true
                        from: -5.0
                        to: 90.0
                        stepSize: 0.2
                        value: dischargePriceThresholdValue

                        onMoved: {
                            // Use a fixed precision and update the property
                            dischargePriceThresholdValue = value.toFixed(2);
                            if (dischargePriceThresholdValue < currentValue) {
                                currentValue = dischargePriceThresholdValue;
                            }

                            enableSave(this);
                            // Redraw graph (Update the graph immediately when Charge Price changes)
                            barSeries.clearValues();
                            barSeries.addValues(dynamicPrice.get(0).stateByName("totalCostSeries").value,
                                                dynamicPrice.get(0).stateByName("priceSeries").value,
                                                dynamicPrice.get(0).stateByName("gridFeeSeries").value,
                                                dynamicPrice.get(0).stateByName("leviesSeries").value,
                                                19.0);
                        }
                    }

//                    RangeSlider {
//                        id: priceRangeSlider
//                        Layout.fillWidth: true

//                        // Set up range and step
//                        from: -5.0
//                        to: 90.0
//                        stepSize: 0.2

//                        // Initialize slider handles based on properties
//                        second.value: dischargePriceThresholdValue
//                        first.value: currentValue

//                        second.onMoved: () => {
//                                            // Upper value controls the Discharge Price Offset
//                                            // Use a fixed precision and update the property
//                                            dischargePriceThresholdValue = second.value.toFixed(2);
//                                            enableSave(this);
//                                            // Redraw graph (Update the graph immediately when Charge Price changes)
//                                            barSeries.clearValues();
//                                            barSeries.addValues(dynamicPrice.get(0).stateByName("totalCostSeries").value,
//                                                                dynamicPrice.get(0).stateByName("priceSeries").value,
//                                                                dynamicPrice.get(0).stateByName("gridFeeSeries").value,
//                                                                dynamicPrice.get(0).stateByName("leviesSeries").value,
//                                                                19.0);

//                                        }

//                        first.onMoved: () => {
//                                           // Lower value controls the Charge Price Limit
//                                           // Use a fixed precision and update the property
//                                           currentValue = first.value.toFixed(2);
//                                           enableSave(this);

//                                           // Redraw graph (Update the graph immediately when Charge Price changes)
//                                           barSeries.clearValues();
//                                           barSeries.addValues(dynamicPrice.get(0).stateByName("totalCostSeries").value,
//                                                               dynamicPrice.get(0).stateByName("priceSeries").value,
//                                                               dynamicPrice.get(0).stateByName("gridFeeSeries").value,
//                                                               dynamicPrice.get(0).stateByName("leviesSeries").value,
//                                                               19.0);
//                                       }

//                    }
                    
                }

                // Save Button
                RowLayout {
                    id: saveBtnContainer
                    anchors.margins: app.margins
                    Layout.topMargin: 20

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
    ]
}
