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

import "../utils/DynPricingUtils.js" as DynPricingUtils

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

    property double absChargingThreshold: 0
    property double absDischargeBlockedThreshold: 0
    property double relChargingThreshold: batteryConfiguration.priceThreshold
    property double relDischargeBlockedThreshold: batteryConfiguration.dischargePriceThreshold

    property double averagePrice: 0
    property double currentPrice: 0
    property double lowestPrice: 0
    property double highestPrice: 0

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
            optimizationController.checked = batteryConfiguration.optimizationEnabled;
            chargeOnceController.checked = batteryConfiguration.chargeOnce;
            // Initialize both properties for the RangeSlider
            relChargingThreshold = batteryConfiguration.priceThreshold;
            relDischargeBlockedThreshold = batteryConfiguration.dischargePriceThreshold;
            console.debug("Battery configuration changed received. New priceThreshold: " + batteryConfiguration.priceThreshold + ", dischargePriceThreshold: " + batteryConfiguration.dischargePriceThreshold);
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

    function saveSettings()
    {
        // Save both values controlled by the RangeSlider
        rootObject.pendingCallId = hemsManager.setBatteryConfiguration(thing.id, {"optimizationEnabled": optimizationController.checked,
                                                                           "priceThreshold": relChargingThreshold,
                                                                           "dischargePriceThreshold": relDischargeBlockedThreshold,
                                                                           "relativePriceEnabled": true,
                                                                           "chargeOnce": chargeOnceController.checked,
                                                                           "avoidZeroFeedInActive": batteryConfiguration.avoidZeroFeedInActive,})
    }

    function enableSave(obj)
    {
        // Check if either of the two RangeSlider values has changed from the stored configuration
        saveButton.enabled = batteryConfiguration.priceThreshold !== relChargingThreshold ||
                batteryConfiguration.dischargePriceThreshold !== relDischargeBlockedThreshold
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
                    Layout.topMargin: 5

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
                    Layout.topMargin: Style.smallMargins
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
                    Layout.topMargin: Style.smallMargins
                    Layout.bottomMargin: Style.smallMargins

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Power")
                    }

                    Label {
                        text: currentPowerState.value > 0 ? Math.round(currentPowerState.value) + " W" : (Math.round(currentPowerState.value) * -1) + " W"
                    }
                }

                RowLayout {
                    Layout.topMargin: Style.margins
                    Label {
                        text: qsTr("Charging from grid")
                        font.weight: Font.Bold
                    }
                }

                ColumnLayout {
                    id: columnContainer
                    visible: dynamicPrice.count >= 1 && thing.thingClass.interfaces.indexOf("controllablebattery") >= 0
                    Layout.topMargin: Style.smallMargins

                    // Optimization enabled
                    RowLayout {
                        Layout.topMargin: Style.smallMargins
                        Layout.bottomMargin: Style.smallMargins

                        Label {
                            text: qsTr("Tariff-controlled charging")
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
                        Layout.topMargin: Style.smallMargins
                        Layout.bottomMargin: Style.smallMargins
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
                                    enabled: !isZeroCompensation

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
                        Layout.topMargin: Style.margins
                        Layout.bottomMargin: Style.smallMargins
                        visible: optimizationController.checked
                        enabled: !chargeOnceController.checked
                        Label {
                            text: qsTr("Charging Plan")
                            font.weight: Font.Bold
                        }
                    }

                    // Price Limit (Current Price)
                    RowLayout {
                        id: currentPriceRow
                        visible: optimizationController.checked
                        enabled: !chargeOnceController.checked
                        Layout.topMargin: Style.smallMargins
                        Layout.bottomMargin: Style.smallMargins

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
                        enabled: !chargeOnceController.checked
                        Component.onCompleted: {
                            const dpThing = dynamicPrice.get(0)
                            if(!dpThing)
                                return;

                            d.startTimeSince = new Date(dpThing.stateByName("validSince").value * 1000);
                            d.endTimeUntil = new Date(dpThing.stateByName("validUntil").value * 1000);
                            absChargingThreshold = DynPricingUtils.relPrice2AbsPrice(batteryConfiguration.priceThreshold,
                                                                                     dpThing);
                            absDischargeBlockedThreshold = DynPricingUtils.relPrice2AbsPrice(batteryConfiguration.dischargePriceThreshold,
                                                                                             dpThing);
                            currentPrice = dpThing.stateByName("currentTotalCost").value
                            averagePrice = dpThing.stateByName("averageTotalCost").value.toFixed(0).toString();
                            lowestPrice = dpThing.stateByName("lowestPrice").value
                            highestPrice = dpThing.stateByName("highestPrice").value
                            barSeries.addValues(dpThing.stateByName("totalCostSeries").value,
                                                dpThing.stateByName("priceSeries").value,
                                                dpThing.stateByName("gridFeeSeries").value,
                                                dpThing.stateByName("leviesSeries").value,
                                                DynPricingUtils.getVAT(dpThing));

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
                                margins.top: Style.margins
                                margins.bottom: 0
                                backgroundColor: isZeroCompensation || chargeOnceController.checked ? Style.barSeriesDisabled : "transparent"
                                startTime: d.startTimeSince
                                endTime: d.endTimeUntil
                                hoursNow: d.now.getHours()
                                currentPrice: absChargingThreshold
                                currentMarketPrice: currentPrice
                                upperPriceLimit: absDischargeBlockedThreshold
                                lowestValue: root.lowestPrice
                                highestValue: root.highestPrice
                            }
                        }

                        Item {
                            visible: optimizationController.checked
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: Style.margins

                            GridLayout {
                                anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
                                columns: 3
                                height: Style.smallIconSize
                                Layout.topMargin: Style.margins

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

                        Label { // breaks view when removed
                            visible: optimizationController.checked
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            text: ""
                            font.pixelSize: 1
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: Style.margins

                        Label {
                            visible: optimizationController.checked
                            enabled: !chargeOnceController.checked
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("\"Charging\" price limit")
                        }

                        Label {
                            visible: optimizationController.checked
                            enabled: !chargeOnceController.checked
                            font.bold: true
                            text: qsTr("%1 %").arg(relChargingThreshold.toFixed(0))
                        }
                    }

                    Label {
                        visible: optimizationController.checked
                        enabled: !chargeOnceController.checked
                        Layout.fillWidth: true
                        Layout.topMargin: Style.smallMargins
                        wrapMode: Text.WordWrap
                        text: qsTr("Deviation from the 48-h average (in %) at which charging takes place. Currently corresponds to %1 ct/kWh.").arg(absChargingThreshold.toLocaleString(Qt.locale(), 'f', 2))
                    }

                    Slider {
                        id: chargingThresholdSlider
                        visible: optimizationController.checked
                        enabled: !chargeOnceController.checked
                        Layout.fillWidth: true
                        from: -100
                        to: 100
                        stepSize: 1
                        value: batteryConfiguration.priceThreshold

                        onMoved: {
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

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: Style.smallMargins

                        Label {
                            visible: optimizationController.checked
                            enabled: !chargeOnceController.checked
                            Layout.fillWidth: true
                            font.bold: true
                            text: qsTr("\"Block discharging\" price limit")
                        }

                        Label {
                            visible: optimizationController.checked
                            enabled: !chargeOnceController.checked
                            font.bold: true
                            text: qsTr("%1 %").arg(relDischargeBlockedThreshold.toFixed(0))
                        }
                    }

                    Label {
                        visible: optimizationController.checked
                        enabled: !chargeOnceController.checked
                        Layout.fillWidth: true
                        Layout.topMargin: Style.smallMargins
                        wrapMode: Text.WordWrap
                        text: qsTr("Deviation from the 48-h average (in %) below which discharging is blocked. Currently corresponds to %1 ct/kWh.").arg(absDischargeBlockedThreshold.toLocaleString(Qt.locale(), 'f', 2))
                    }

                    Slider {
                        id: dischargeBlockedThresholdSlider
                        visible: optimizationController.checked
                        enabled: !chargeOnceController.checked
                        Layout.fillWidth: true
                        from: -100
                        to: 100
                        stepSize: 1
                        value: batteryConfiguration.dischargePriceThreshold

                        onMoved: {
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
