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
    readonly property State batteryLevelState: root.thing.stateByName("batteryLevel")
    readonly property State currentPowerState: root.thing.stateByName("currentPower")
    property BatteryConfiguration batteryConfiguration: hemsManager.batteryConfigurations.getBatteryConfiguration(thing.id)


    property double currentValue : batteryConfiguration.priceThreshold 
    property double thresholdPrice: 0

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
                    pageStack.pop();
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

        // Current Battery Level
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 30
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
            Layout.topMargin: 15
            Label {
                Layout.fillWidth: true
                text: qsTr("Charge (+) / Discharge (-) Power")
            }

            Label {
                text: Math.round(currentPowerState.value) + " W"
            }
        }

        Item {
            visible: thing.thingClass.interfaces.indexOf("controllablebattery") === 0 ? false : true
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        ColumnLayout {
            visible: dynamicPrice.count >= 1 && thing.thingClass.interfaces.indexOf("controllablebattery") >= 1

            // Optimization enabled
            RowLayout {
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Optimization enabled")
                }

                Switch {
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

            // Charge once
            RowLayout {
                visible: optimizationController.checked
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Charge once")
                }

                Switch {
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

            // Price Limit
            RowLayout {
                id: currentPriceRow
                visible: optimizationController.checked
                enabled: chargeOnceController.checked ? false : true
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Current price")
                }

                Label {
                    id: currentPriceLabel
                    text: Number(currentPrice).toLocaleString(Qt.locale(), 'f', 2) + " ct/kWh"
                }
            }

            RowLayout {
                id: priceRow
                visible: optimizationController.checked
                enabled: chargeOnceController.checked ? false : true
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Price limit")

                }

                ToolBar {
                    background: Rectangle {
                        color: "transparent"
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 40
                        property var debounceTimer: Timer {
                            interval: 500
                            repeat: false
                            running: false
                             onTriggered: {
                                pricingCurrentLimitSeries.clear();
                                pricingUpperSeriesAbove.clear();
                                pricingLowerSeriesAbove.clear();
                                consumptionSeries.insertEntry(dynamicPrice.get(0).stateByName("priceSeries").value, true);
                            }
                        }


                        function redrawChart() {
                            debounceTimer.stop();
                            debounceTimer.start();
                        }

                        SpinBox {
                            id: spinbox
                            from: -5000
                            value: 0
                            to: 5000
                            stepSize: 1
                            width: 20
                            anchors.centerIn: parent

                            property int decimals: 1
                            property real realValue: value / 10

                            validator: DoubleValidator {
                                bottom: Math.min(spinbox.from, spinbox.to)
                                top:  Math.max(spinbox.from, spinbox.to)
                            }

                            textFromValue: function(value, locale) {
                                return Number(value / 10).toLocaleString(locale, 'f', spinbox.decimals)
                            }

                            valueFromText: function(text, locale) {
                                return Number.fromLocaleString(locale, text) * 10
                            }

                            onValueChanged: {
                                //currentValue = value / 10
                                currentValue = Math.round(value * 100) / 1000
                                //priceRow.getThresholdPrice()
                                parent.redrawChart();
                                //saveSettings()
                                if (Math.round(currentValue * 10) != Math.round(batteryConfiguration.priceThreshold * 10)) {
                                    enableSave(this)
                                }
                            }

                            Component.onCompleted: {
                                value = currentValue * 10
                            }
                        } 

                        Label {
                            text: "ct/kWh"
                        }
                       
                    }
                }

                Component.onCompleted: {
                    //getThresholdPrice()
                }
                /*
                function getThresholdPrice(){
                    let currentValue = parseInt(currentValueField.text)
                    thresholdPrice = relPrice2AbsPrice(currentValue)
                }*/
            }

            RowLayout{
                Layout.topMargin: 10
                id: belowPriceLimit
                enabled: chargeOnceController.checked ? false : true
                Label{
                    Layout.fillWidth: true
                    text: qsTr("Below price limit")
                }

                Rectangle{
                    width: 17
                    height: 17
                    Layout.rightMargin: 0
                    Layout.alignment: Qt.AlignRight
                    color: (currentPrice <= currentValue) ? "#87BD26" : "#CD5C5C"
                    border.color: "black"
                    border.width: 0
                    radius: width*0.5
                }
            }


            // Pricing of ct/kWh
            ColumnLayout {
                id: displayText
                visible: optimizationController.checked
                enabled: chargeOnceController.checked ? false : true
                Label {
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    text: qsTr("Hint for using EPEX prices: The price contains no local fees and margin of electricity provider.")
                    font.pixelSize: 12
                }
            }


            // Graph Header
            RowLayout {
                Layout.topMargin: 15
                Layout.fillWidth: true
                visible: optimizationController.checked
                enabled: chargeOnceController.checked ? false : true
                Label {
                    text: qsTr("Charging Plan")
                    font.pixelSize: 15
                }
            }

            // Graph Info Today
            RowLayout {
                visible: optimizationController.checked
                enabled: chargeOnceController.checked ? false : true
                Component.onCompleted: {
                    const dpThing = dynamicPrice.get(0)
                    if(!dpThing)
                        return;

                    pricingCurrentLimitSeries.clear();
                    pricingUpperSeries.clear();
                    pricingUpperSeriesAbove.clear();

                    validSince = dpThing.stateByName("validSince").value
                    validUntil = dpThing.stateByName("validUntil").value
                    currentPrice = dpThing.stateByName("currentMarketPrice").value
                    averagePrice = dpThing.stateByName("averagePrice").value.toFixed(0).toString();

                    consumptionSeries.insertEntry(dpThing.stateByName("priceSeries").value, false)
                    valueAxis.adjustMax(lowestPrice,highestPrice);
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

                Component {
                    id: lineSeriesComponent
                    LineSeries { }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 50


                    ChartView {
                        id: chartView
                        anchors.fill: parent

                        backgroundColor:  chargeOnceController.checked ? "whitesmoke" : "transparent"
                        margins.left: 0
                        margins.right: 0
                        margins.top: 0
                        margins.bottom: Style.smallIconSize + Style.margins

                        legend.visible: false
                        ActivityIndicator {
                            id: noDataIndicator
                            x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                            y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                            visible: false
                            opacity: .5
                        }

                        Label {
                            id: noDataLabel
                            x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                            y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                            text: qsTr("No data available")
                            visible: false
                            font: Style.smallFont
                            opacity: .5
                        }

                        ValueAxis {
                            id: valueAxis
                            min: 0
                            max: 1
                            labelFormat: ""
                            gridLineColor: Style.tileOverlayColor
                            labelsVisible: false
                            tickCount: 5
                            lineVisible: false
                            titleVisible: false
                            shadesVisible: false
                            function adjustMax(minPrice,maxPrice) {
                                max = Math.ceil(maxPrice) + 1;
                                max += 4 - (max % 4);
                                min = minPrice <= 0 ? minPrice - 5 : 0;

                                if(min < 0) {
                                    max += 4 - ((max + min * (-1)) % 4);
                                }
                            }
                        }

                        Item {
                            id: labelsLayout
                            x: Style.smallMargins
                            y: chartView.plotArea.y
                            height: chartView.plotArea.height
                            width: chartView.plotArea.x - x
                            Repeater {
                                model: valueAxis.tickCount
                                delegate: Label {
                                    y: parent.height / (valueAxis.tickCount - 1) * index - font.pixelSize / 2
                                    width: parent.width - Style.smallMargins
                                    horizontalAlignment: Text.AlignRight
                                    text: (Math.ceil(valueAxis.max - index * (valueAxis.max - valueAxis.min) / (valueAxis.tickCount - 1))) + " ct"  //linke Seite vom Graphen
                                    verticalAlignment: Text.AlignTop
                                    font: Style.extraSmallFont
                                }
                            }
                        }

                        DateTimeAxis {
                            id: dateTimeAxis
                            min: d.startTimeSince
                            max: d.endTimeUntil
                            format: "HH:mm"
                            tickCount: 5
                            labelsFont: Style.extraSmallFont
                            gridVisible: false
                            minorGridVisible: false
                            lineVisible: false
                            shadesVisible: false
                            labelsColor: Style.foregroundColor
                        }


                        AreaSeries {
                            id: currentLimitSeries
                            axisX: dateTimeAxis
                            axisY: valueAxis
                            color: '#ccc'
                            borderWidth: 1
                            borderColor: 'transparent'
                            upperSeries: LineSeries {
                                id: pricingCurrentLimitSeries
                            }
                        }

                        AreaSeries {
                            id: consumptionSeries
                            axisX: dateTimeAxis
                            axisY: valueAxis
                            color: 'transparent'
                            borderWidth: 1
                            borderColor: Configuration.epexMainLineColor

                            upperSeries: LineSeries {
                                id: pricingUpperSeries
                            }

                            function insertEntry(value, onlyThreshold){
                                var lastObjectValue = value[Object.keys(value)[Object.keys(value).length - 1]];

                                var firstRun = true;
                                let lastChange = 0;
                                let lastChangeTimestamp = 0;
                                let identicalIndexes = [];

                                for (const item in value){
                                    const date = new Date(item);
                                    let currentTimestamp = date.getTime();
                                    let itemValue = value[item];
                                    if(itemValue < lowestPrice){
                                        lowestPrice = itemValue
                                    }

                                    if(itemValue > highestPrice){
                                        highestPrice = itemValue
                                    }

                                    if(lastChange !== itemValue) {
                                        lastChangeTimestamp = currentTimestamp;

                                        for(const ts of identicalIndexes) {
                                            prices[ts].end = currentTimestamp;
                                        }

                                        identicalIndexes = [currentTimestamp];
                                    }
                                    else {
                                        identicalIndexes.push(currentTimestamp);
                                    }

                                    lastChange = itemValue;

                                    prices[currentTimestamp] = {
                                        start: lastChangeTimestamp,
                                        value: itemValue
                                    };

                                    if(firstRun === true){
                                        firstRun = false;
                                        highestPrice = itemValue
                                        lowestPrice = itemValue
                                        currentTimestamp = currentTimestamp - 600000;
                                    }

                                    if(itemValue < currentValue) {
                                        pricingCurrentLimitSeries.append(currentTimestamp - (60000 * 15),currentValue);
                                        pricingCurrentLimitSeries.append(currentTimestamp,currentValue);
                                    }
                                    else {
                                        pricingCurrentLimitSeries.append(currentTimestamp - (60000 * 15),valueAxis.min -5);
                                        pricingCurrentLimitSeries.append(currentTimestamp,valueAxis.min - 5);
                                    }

                                    pricingUpperSeriesAbove.append(currentTimestamp,currentValue);
                                    if(!onlyThreshold) {
                                        pricingUpperSeries.append(currentTimestamp - (60000 * 15) + 1,itemValue);
                                        pricingUpperSeries.append(currentTimestamp,itemValue);
                                    }
                                }

                                const todayMidnight = new Date(identicalIndexes[0]);
                                todayMidnight.setDate(todayMidnight.getDate() +1);
                                todayMidnight.setMinutes(0);
                                todayMidnight.setHours(0);

                                const todayMidnightTs = todayMidnight.getTime();

                                for(const ts of identicalIndexes) {
                                    prices[ts].end = todayMidnightTs;
                                }

                                pricingCurrentLimitSeries.append(todayMidnightTs + 6000000, valueAxis.min - 5);
                                pricingUpperSeriesAbove.append(todayMidnightTs + 6000000, currentValue);
                                pricingLowerSeriesAbove.append(todayMidnightTs + 6000000, currentValue);

                                if(!onlyThreshold) {
                                    pricingUpperSeries.append(todayMidnightTs + 6000000, lastObjectValue);
                                }
                            }
                        }

                        AreaSeries {
                            id: consumptionSeriesAbove
                            axisX: dateTimeAxis
                            axisY: valueAxis
                            color: 'transparent'
                            borderWidth: 1
                            borderColor: Configuration.epexAverageColor

                            upperSeries: LineSeries {
                                id: pricingUpperSeriesAbove
                            }

                            lowerSeries: LineSeries {
                                id: pricingLowerSeriesAbove
                            }
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        anchors.leftMargin: chartView.plotArea.x
                        anchors.topMargin: chartView.plotArea.y
                        anchors.rightMargin: chartView.width - chartView.plotArea.width - chartView.plotArea.x
                        anchors.bottomMargin: chartView.height - chartView.plotArea.height - chartView.plotArea.y

                        hoverEnabled: true
                        preventStealing: tooltipping

                        property int startMouseX: 0
                        property bool tooltipping: false
                        property var startDatetime: null

                        Rectangle {
                            height: parent.height
                            width: 1
                            color: Style.foregroundColor
                            x: Math.min(mouseArea.width - 1, Math.max(0, mouseArea.mouseX))
                            visible: (mouseArea.containsMouse || mouseArea.tooltipping)
                        }

                        //Mouseover Details in Graph
                        NymeaToolTip {
                            id: toolTip
                            visible: (mouseArea.containsMouse || mouseArea.tooltipping)

                            backgroundRect: Qt.rect(mouseArea.x + toolTip.x, mouseArea.y + toolTip.y, toolTip.width, toolTip.height)

                            property double currentValueY: 0
                            property int idx: mouseArea.mouseX
                            property int timeSince: new Date(d.startTimeSince).getTime()
                            property int timestamp: (new Date(d.endTimeUntil).getTime() - new Date(d.startTimeSince).getTime())

                            property int xOnRight: Math.max(0, mouseArea.mouseX) + Style.smallMargins
                            property int xOnLeft: Math.min(mouseArea.width, mouseArea.mouseX) - Style.smallMargins - width
                            x: xOnRight + width < mouseArea.width ? xOnRight : xOnLeft
                            property double maxValue: 0
                            y: Math.min(Math.max(mouseArea.height - (maxValue * mouseArea.height / valueAxis.max) - height - Style.margins, 0), mouseArea.height - height)

                            width: tooltipLayout.implicitWidth + Style.smallMargins * 2
                            height: tooltipLayout.implicitHeight + Style.smallMargins * 2

                            function getQuaterlyTimestamp(ts) {
                               const currTime = new Date(ts);
                               const currMinutes = currTime.getMinutes();
                               const modRes = currMinutes % 15;

                               if(modRes !== 0) {
                                   if(modRes < 8) {
                                       currTime.setMinutes(currMinutes - modRes);
                                   }
                                   else {
                                       currTime.setMinutes(currMinutes + (15 - modRes));
                                   }

                                   currTime.setSeconds(0);
                                   return currTime.getTime();
                               }
                               else {
                                   return ts;
                               }
                           }

                            ColumnLayout {
                                id: tooltipLayout
                                anchors {
                                    left: parent.left
                                    top: parent.top
                                    margins: Style.smallMargins
                                }
                                Label {
                                    text: {
                                        if(!mouseArea.containsMouse) {
                                            return "";
                                        }

                                        let hoveredTime = Number.parseInt(((new Date(d.endTimeUntil).getTime() - new Date(d.startTimeSince).getTime())/Math.ceil(mouseArea.width)*toolTip.idx+new Date(d.startTimeSince).getTime())/100000) * 100000;

                                        d.startTimeSince.toLocaleString(Qt.locale(), Locale.ShortFormat);

                                        let currentPrice = prices[toolTip.getQuaterlyTimestamp(hoveredTime)];

                                        if(!currentPrice)
                                            return qsTr("No prices available, yet");

                                        if(!currentPrice || typeof currentPrice === "undefined") {
                                            const priceKeys = Object.keys(prices);
                                            const lastItem = priceKeys[priceKeys.length -1];
                                            currentPrice = prices[lastItem];
                                        }

                                        let val = currentPrice.start;
                                        val = new Date(val).toLocaleString(Qt.locale(), Locale.ShortFormat);

                                        let endVal = currentPrice.end;
                                        endVal = new Date(endVal).toLocaleTimeString(Qt.locale(), Locale.ShortFormat) + ":00";

                                        return val + " - " + endVal.slice(0, -3);
                                    }
                                    font: Style.smallFont
                                }
                                Label {
                                    property string unit: qsTr("ct/kWh")
                                    text: {
                                        if(!mouseArea.containsMouse) {
                                            return "";
                                        }

                                        let hoveredTime = Number.parseInt(((new Date(d.endTimeUntil).getTime() - new Date(d.startTimeSince).getTime())/Math.ceil(mouseArea.width)*toolTip.idx+new Date(d.startTimeSince).getTime())/100000) * 100000;

                                        let currentPrice = prices[toolTip.getQuaterlyTimestamp(hoveredTime)];

                                        if(!currentPrice)
                                            return "";

                                        if(!currentPrice || typeof currentPrice === "undefined") {
                                            const priceKeys = Object.keys(prices);
                                            const lastItem = priceKeys[priceKeys.length -1];
                                            currentPrice = prices[lastItem];
                                        }

                                        let dynamicVal = currentPrice.value;

                                        const scaleValue = valueAxis.max + (valueAxis.min > 0 ? 0 : (valueAxis.min * (-1)));

                                        dynamicVal += valueAxis.min < 0 ? (valueAxis.min * (-1)) : 0;

                                        toolTip.y = mouseArea.height - (mouseArea.height * (dynamicVal / scaleValue)) - toolTip.height - 2;
                                        const val = (+currentPrice.value.toFixed(2)).toLocaleString();
                                        return "%1 %2".arg(val).arg(unit);
                                    }
                                    font: Style.extraSmallFont
                                }
                            }
                        }
                    }
                }
            }


            // Space divider
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
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

        Item {
            visible: !optimizationController.checked
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
