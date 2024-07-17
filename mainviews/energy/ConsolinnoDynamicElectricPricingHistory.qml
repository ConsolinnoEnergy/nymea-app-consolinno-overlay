import QtQuick 2.0
import QtCharts 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.15
import Nymea 1.0
import "qrc:/ui/components"

Item {
    id: root
    property int validSince: 0
    property int validUntil: 0
    property string averagePrice: ""
    property double currentPrice: 0
    property double lowestPrice: 0
    property double highestPrice: 0
    property var prices: ({})

    property bool isDynamicPrice: false

    property ThingsProxy electrics: ThingsProxy {
        engine: _engine
        shownInterfaces: ["dynamicelectricitypricing"]
    }

    readonly property Thing thing: root.electrics ? root.electrics.get(0) : null

    QtObject {
        id: d

        property date now: new Date()

        readonly property var startTimeSince: {
            var date = new Date(now);
            if(selectionTabs.currentIndex == 0){
                date.setTime(validSince * 1000);
            }else{
                date.setTime((validSince + 86400) * 1000);
            }
            return date;
        }

        readonly property var endTimeUntil: {
            var date = new Date(now);
            if(selectionTabs.currentIndex == 0){
                const today = new Date();
                const validUntilDate = new Date(validUntil*1000);

                let adjustTime = 3660;

                if(today.getDate() < validUntilDate.getDate())
                    adjustTime = -86340;

                date.setTime((validUntil + adjustTime) * 1000);
            }else{
                date.setTime((validUntil + 60) * 1000);
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
            text: qsTr("Dynamic electricity price")
            visible: true
        }

        SelectionTabs {
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
            }
        }

        Component.onCompleted: {
            if(!thing)
                return;
            validSince = thing.stateByName("validSince").value
            validUntil = thing.stateByName("validUntil").value
            currentPrice = thing.stateByName("currentMarketPrice").value
            averagePrice = thing.stateByName("averagePrice").value.toFixed(0).toString();

            consumptionSeries.insertEntry(thing.stateByName("priceSeries").value)
            console.error(lowestPrice)
            valueAxis.adjustMax(lowestPrice,highestPrice);
        }

        Text {
            Layout.fillWidth: true
            Layout.topMargin: Style.smallMargins
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 13
            text: qsTr("Current Market Price: ") + (currentPrice.toFixed(0)) + " ct"
        }

        Text {
            Layout.fillWidth: true
            Layout.topMargin: Style.smallMargins
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 13
            text: qsTr("Average Market Price: ") + (averagePrice) + " ct"
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
                    x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                    y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                    visible: false
                    opacity: .5
                }

                Label {
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
                    borderColor: Style.green

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

                            if(value[item] < lowestPrice){
                                lowestPrice = value[item]
                            }

                            if(value[item] > highestPrice){
                                highestPrice = value[item]
                            }

                            if(lastChange !== value[item]) {
                                lastChangeTimestamp = currentTimestamp;

                                for(const ts of identicalIndexes) {
                                    prices[ts].end = currentTimestamp;
                                }

                                identicalIndexes = [currentTimestamp];
                            }
                            else {
                                identicalIndexes.push(currentTimestamp);
                            }

                            lastChange = value[item];

                            prices[currentTimestamp] = {
                                start: lastChangeTimestamp,
                                value: value[item]
                            };

                            if(firstRun === true){
                                firstRun = false;
                                highestPrice = value[item]
                                lowestPrice = value[item]
                                currentTimestamp = currentTimestamp - 600000;
                            }

                            pricingUpperSeriesAbove.append(currentTimestamp,averagePrice);
                            pricingUpperSeries.append(currentTimestamp,value[item]);
                            pricingLowerSeries.append(currentTimestamp,value[item]);
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
                    borderWidth: 2
                    borderColor: Style.red

                    upperSeries: LineSeries {
                        id: pricingUpperSeriesAbove
                    }

                    lowerSeries: LineSeries {
                        XYPoint { x: dateTimeAxis.min.getTime(); y: 0 }
                        XYPoint { x: dateTimeAxis.max.getTime(); y: 0 }
                    }

                }

                ScatterSeries {
                    id: currentValuePoint
                    borderColor: Style.green
                    color: Style.green
                    markerSize: isDynamicPrice ? 5 : parent.height / 80
                    markerShape: AbstractSeries.MarkerShapeCircle
                    axisX: dateTimeAxis
                    axisY: valueAxis
                }

                Timer {
                    property bool isOn: false
                    interval: isOn ? 5000 : 100
                    running: true
                    repeat: true
                    onTriggered: {
                        isOn = true;
                        var currentTime = new Date().getTime()
                        currentValuePoint.remove(0)
                        currentValuePoint.append(currentTime, currentPrice)

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
                        color: Style.green
                        width: 8
                        height: 8
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font: Style.extraSmallFont
                        text: qsTr("Current market price")
                    }
                }

                Row {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 5
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Style.red
                        width: 8
                        height: 8
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font: Style.extraSmallFont
                        text: qsTr("Average market price")
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
                            property string unit: qsTr("Cents / kWh")
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
                                const val = currentPrice.value.toFixed(2);
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
