import QtQuick 2.0
import QtCharts 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.15
import Nymea 1.0
import "qrc:/ui/components"

Item {
    id: root
    property Thing thing
    property int validSince: 0
    property int validUntil: 0
    property string averagePrice: ""
    property double currentPrice: 0
    property double lowestPrice: 0
    property double highestPrice: 0
    property var prices: ({})

    property bool isDynamicPrice: false

    readonly property var addedGridFee: thing.paramByName("addedGridFee").value
    readonly property var addedLevies: thing.paramByName("addedGridFee").value

    QtObject {
        id: d

        property date now: new Date()

        readonly property var startTimeSince: {
            var date = new Date();
            date.setHours(0);
            date.setMinutes(0);
            date.setSeconds(0);

            if(selectionTabs.currentIndex == 0){

            }else{
                date.setDate(date.getDate()+1);
            }
            return date;
        }

        readonly property var endTimeUntil: {
            var date = new Date();
            date.setHours(0);
            date.setMinutes(0);
            date.setSeconds(0);

            if(selectionTabs.currentIndex == 0){
                date.setDate(date.getDate()+1);
            }else{
                date.setDate(date.getDate()+2);
            }
            return date;
        }

    }

    Component {
        id: lineSeriesComponent
        LineSeries { }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Label {
            Layout.fillWidth: true
            Layout.margins: Style.smallMargins
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Dynamic electricity tariff")
            visible: isDynamicPrice
        }

        ConsolinnoAlert {
            Layout.margins: Style.margins
            visible: (addedLevies === 0 || addedGridFee === 0)
            backgroundColor: Style.warningBackground
            borderColor: Style.warningAccent
            textColor: Style.warningAccent
            iconColor: Style.warningAccent
            pagePath: "../optimization/DynamicElectricityRate.qml"
            pageStartView: "taxesAndFeesSetUp"

            text: qsTr("Please provide information on taxes, surcharges, and network fees. <u>Continue to configuration</u>")
            headerText: qsTr("Tariff details are not available")
        }

        ConsolinnoSelectionTabs {
            id: selectionTabs
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            visible: true
            currentIndex: 0
            model: ListModel {
                ListElement {
                    modelData: qsTr("today")
                }
                ListElement {
                    modelData: qsTr("tomorrow")
                }
            }

            onTabSelected: {
                d.now = new Date();

                let arrLength = 192;

                const pricelength = Object.keys(prices).length;
                noDataLabel.visible = selectionTabs.currentIndex && pricelength < arrLength;
                noDataIndicator.visible = selectionTabs.currentIndex && pricelength < arrLength;

                if(pricelength < arrLength && selectionTabs.currentIndex == 1){
                    consumptionSeries.visible = false
                    consumptionSeriesAbove.visible = false
                }else{
                    consumptionSeries.visible = true
                    consumptionSeriesAbove.visible = true
                }
            }
        }

        Component.onCompleted: {
            if(!thing)
                return;

            validSince = thing.stateByName("validSince").value
            validUntil = thing.stateByName("validUntil").value
            currentPrice = thing.stateByName("currentTotalCost").value
            averagePrice = thing.stateByName("averageTotalCost").value.toFixed(2);
            consumptionSeries.insertEntry(thing.stateByName("totalCostSeries").value)
            valueAxis.adjustMax((Math.ceil(lowestPrice)),highestPrice);
        }

        Label {
            Layout.fillWidth: true
            Layout.topMargin: Style.smallMargins
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 13
            text: qsTr("Current Electricity Price: ") + (+currentPrice.toFixed(2)).toLocaleString() + " ct/kWh"
        }

        Label {
            Layout.fillWidth: true
            Layout.topMargin: Style.smallMargins
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 13
            text: qsTr("Average Electricity Price: ") + (+averagePrice).toLocaleString() + " ct/kWh"
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ChartView {
                id: chartView
                anchors.fill: parent

                backgroundColor: "transparent"
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
                        min = 0
                        max = 1

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
                    id: consumptionSeries
                    axisX: dateTimeAxis
                    axisY: valueAxis
                    color: 'transparent'
                    borderWidth: 1
                    borderColor: Style.epexMainLineColor

                    lowerSeries: LineSeries {
                        id: pricingLowerSeries
                    }

                    upperSeries: LineSeries {
                        id: pricingUpperSeries
                    }

                    function insertEntry(value){

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

                            pricingUpperSeriesAbove.append(currentTimestamp,averagePrice);
                            pricingLowerSeriesAbove.append(currentTimestamp,averagePrice);

                            pricingUpperSeries.append(currentTimestamp - (60000 * 15),itemValue);
                            pricingUpperSeries.append(currentTimestamp,itemValue);

                            pricingLowerSeries.append(currentTimestamp - (60000 * 15),itemValue);
                            pricingLowerSeries.append(currentTimestamp,itemValue);
                        }

                        const todayMidnight = new Date(identicalIndexes[0]);
                        todayMidnight.setDate(todayMidnight.getDate() +1);
                        todayMidnight.setMinutes(0);
                        todayMidnight.setHours(0);

                        const todayMidnightTs = todayMidnight.getTime();

                        for(const ts of identicalIndexes) {
                            prices[ts].end = todayMidnightTs;
                        }

                        pricingUpperSeriesAbove.append(todayMidnightTs + 6000000, averagePrice);
                        pricingUpperSeries.append(todayMidnightTs + 6000000, lastObjectValue);
                    }
                }

                AreaSeries {
                    id: consumptionSeriesAbove
                    axisX: dateTimeAxis
                    axisY: valueAxis
                    color: 'transparent'
                    borderWidth: 1
                    borderColor: Style.epexAverageColor

                    upperSeries: LineSeries {
                        id: pricingUpperSeriesAbove
                    }

                    lowerSeries: LineSeries {
                        id: pricingLowerSeriesAbove
                    }

                }

                ScatterSeries {
                    id: currentValuePoint
                    borderColor: Style.epexMainLineColor
                    color: Style.epexMainLineColor
                    markerSize: isDynamicPrice ? 5 : parent.height / 80
                    markerShape: AbstractSeries.MarkerShapeCircle
                    axisX: dateTimeAxis
                    axisY: valueAxis
                }

                Timer {
                    property bool isOn: false
                    interval: isOn ? 60000 : 100
                    running: true
                    repeat: true
                    onTriggered: {
                        isOn = true;
                        var currentTime = new Date();

                        currentValuePoint.remove(0);
                        currentPrice = thing.stateByName("currentTotalCost").value;
                        currentTime.setTime(currentTime.getTime() - (15 * 60 * 1000));

                        currentValuePoint.append(currentTime.getTime(), currentPrice);
                    }
                }

            }

            GridLayout {
                anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
                columns: 2
                height: Style.smallIconSize
                anchors.margins: Style.margins
                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 5
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Style.epexMainLineColor
                        width: 8
                        height: 8
                    }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        font: Style.extraSmallFont
                        text: qsTr("Current electricity price")
                    }
                }

                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 5
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Style.epexAverageColor
                        width: 8
                        height: 8
                    }
                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        font: Style.extraSmallFont
                        text: qsTr("Average electricity price")
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
}
