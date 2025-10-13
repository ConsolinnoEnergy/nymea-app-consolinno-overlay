import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Nymea 1.0
import QtCharts 2.3

ChartView {
    id: root
    property double currentMarketPrice: 0
    property double currentPrice: 0
    property double highestValue: 0
    property double lowestValue: 0
    property var hoursNow: 0
    property var startTime: 0
    property var endTime: 0
    property var pricesArr: ({})

    legend.visible: false

    Component.onCompleted: {

    }

    ActivityIndicator {
        id: noDataIndicator
        x: root.plotArea.x + (root.plotArea.width - width) / 2
        y: root.plotArea.y + (root.plotArea.height - height) / 2 + (root.plotArea.height / 8)
        visible: false
        opacity: .5
    }

    Label {
        id: noDataLabel
        x: root.plotArea.x + (root.plotArea.width - width) / 2
        y: root.plotArea.y + (root.plotArea.height - height) / 2 + (root.plotArea.height / 8)
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
            // force yaxis steps to multiples of 5
            let step = Math.ceil(maxPrice / 4);
            const rest = step % 5;
            if(rest !== 0) {
               step += 5 - rest;
            }

            max = step * 4;
        }
    }

    Item {
        id: labelsLayout
        x: Style.smallMargins
        y: root.plotArea.y
        height: root.plotArea.height
        width: root.plotArea.x - x
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
        min: startTime
        max: endTime
        format: "HH:mm"
        tickCount: 5
        labelsFont: Style.extraSmallFont
        gridVisible: false
        minorGridVisible: false
        lineVisible: false
        shadesVisible: false
        labelsColor: root.enabled ? Style.foregroundColor : "#909090"
    }

    AreaSeries {
        axisX: dateTimeAxis
        axisY: valueAxis
        color: root.enabled ? Style.epexBarMainLineColor : Style.barSeriesDisabled
        borderWidth: 1
        borderColor: Style.epexBarOutLine
        upperSeries: LineSeries {
          id: mainSeries
        }
    }

    AreaSeries {
        axisX: dateTimeAxis
        axisY: valueAxis
        color: root.enabled ? Style.epexBarCurrentTime : Style.barSeriesDisabled
        borderWidth: 1
        borderColor: Style.epexBarOutLine
        upperSeries: LineSeries {
          id: currentValueSeries
        }
    }

    AreaSeries {
        axisX: dateTimeAxis
        axisY: valueAxis
        color: Style.epexBarPricingPast
        borderWidth: 1
        borderColor: Style.epexBarOutLine
        upperSeries: LineSeries {
            id: pricingPast
        }
    }

    AreaSeries {
        axisX: dateTimeAxis
        axisY: valueAxis
        color: root.enabled ? Style.epexBarPricingCurrentTime : Style.barSeriesDisabled
        borderWidth: 1
        borderColor: Style.epexBarOutLine
        upperSeries: LineSeries {
            id: pricingCurrentTime
        }
    }

    AreaSeries {
        axisX: dateTimeAxis
        axisY: valueAxis
        color: root.enabled ? Style.epexBarPricingOutOfLimit : Style.barSeriesDisabled
        borderWidth: 1
        borderColor: Style.epexBarOutLine
        upperSeries: LineSeries {
            id: pricingOutOfLimit
        }
    }

    AreaSeries {
        axisX: dateTimeAxis
        axisY: valueAxis
        color: 'transparent'
        borderWidth: 1
        borderColor: root.enabled ? Style.epexAverageColor : Style.barSeriesDisabled

        upperSeries: LineSeries {
            id: priceLimitUp
        }

        lowerSeries: LineSeries {
            id: priceLimitLow
        }
    }

    function addValues(value){
        var lastObjectValue = value[Object.keys(value)[Object.keys(value).length - 1]];

        var firstRun = true;
        let lastChange = 0;
        let lastChangeTimestamp = 0;
        let identicalIndexes = [];
        let barToDraw = mainSeries;

        // get highestPrice and lowestPrice of Y
        valueAxis.adjustMax(Math.ceil(root.lowestValue), root.highestValue);

        // Draw Bars
        for (const item in value){
            const date = new Date(item);
            let currentTimestamp = date.getTime();
            let itemValue = value[item];

            const lastChangeDate = new Date(currentTimestamp);
            if(lastChangeTimestamp === 0 || lastChangeDate.getMinutes() === 0) {
                lastChangeTimestamp = currentTimestamp;

                for(const ts of identicalIndexes) {
                    root.pricesArr[ts].end = currentTimestamp;
                }

                identicalIndexes = [currentTimestamp];
            }
            else {
                identicalIndexes.push(currentTimestamp);
            }

            root.pricesArr[currentTimestamp] = {
                start: lastChangeTimestamp,
                value: itemValue
            };

            if(firstRun === true){
                firstRun = false;
                currentTimestamp = currentTimestamp - 600000;
            }

            priceLimitUp.append(currentTimestamp,currentPrice);

            if(lastChangeTimestamp === 0 || lastChangeDate.getMinutes() === 0) { // Draw done to mimick a bar
              barToDraw.append(currentTimestamp, lastChange);
              barToDraw.append(currentTimestamp, valueAxis.min);

              // draw all unused bars along the x axis to prevent overlapping
              mainSeries.append(currentTimestamp, valueAxis.min);
              pricingCurrentTime.append(currentTimestamp, valueAxis.min);
              pricingPast.append(currentTimestamp, valueAxis.min);
              pricingOutOfLimit.append(currentTimestamp, valueAxis.min);
            }

            barToDraw = mainSeries;

            if(date.getHours() < root.hoursNow) {
                barToDraw = pricingPast;
            }
            else if((root.currentPrice > itemValue) && (date.getHours() === root.hoursNow) && (date.getDate() === root.startTime.getDate())){
                barToDraw = currentValueSeries
            }
            else if(date.getHours() === root.hoursNow) {
                barToDraw = pricingCurrentTime;
            }
            else if(itemValue > root.currentPrice) {
                barToDraw = pricingOutOfLimit;
            }

            barToDraw.append(currentTimestamp,itemValue);

            lastChange = itemValue;
        }

        const todayMidnight = new Date(identicalIndexes[0]);
        todayMidnight.setDate(todayMidnight.getDate() +1);
        todayMidnight.setMinutes(0);
        todayMidnight.setHours(0);

        const todayMidnightTs = todayMidnight.getTime();

        for(const ts of identicalIndexes) {
            root.pricesArr[ts].end = todayMidnightTs;
        }

        priceLimitUp.append(todayMidnightTs + 6000000, currentPrice);
        priceLimitLow.append(todayMidnightTs + 6000000, currentPrice);

        barToDraw.append(todayMidnightTs + 6000000, lastObjectValue);
    }

    function clearValues(){
        mainSeries.clear();
        currentValueSeries.clear();
        pricingPast.clear();
        pricingCurrentTime.clear();
        pricingOutOfLimit.clear();
        priceLimitUp.clear();
        priceLimitLow.clear();
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.leftMargin: root.plotArea.x
        anchors.topMargin: root.plotArea.y
        anchors.rightMargin: root.width - root.plotArea.width - root.plotArea.x
        anchors.bottomMargin: root.height - root.plotArea.height - root.plotArea.y

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
            property int timeSince: new Date(root.startTime).getTime()
            property int timestamp: (new Date(root.endTime).getTime() - new Date(root.startTime).getTime())

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

                        let hoveredTime = Number.parseInt(((new Date(root.endTime).getTime() - new Date(root.startTime).getTime())/Math.ceil(mouseArea.width)*toolTip.idx+new Date(root.startTime).getTime())/100000) * 100000;

                        root.startTime.toLocaleString(Qt.locale(), Locale.ShortFormat);

                        let currentPrice = root.pricesArr[toolTip.getQuaterlyTimestamp(hoveredTime)];

                        if(!currentPrice)
                            return qsTr("No prices available, yet");

                        if(!currentPrice || typeof currentPrice === "undefined") {
                            const priceKeys = Object.keys(root.pricesArr);
                            const lastItem = priceKeys[priceKeys.length -1];
                            currentPrice = root.pricesArr[lastItem];
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

                        let hoveredTime = Number.parseInt(((new Date(root.endTime).getTime() - new Date(root.startTime).getTime())/Math.ceil(mouseArea.width)*toolTip.idx+new Date(root.startTime).getTime())/100000) * 100000;

                        let currentPrice = root.pricesArr[toolTip.getQuaterlyTimestamp(hoveredTime)];

                        if(!currentPrice)
                            return "";

                        if(!currentPrice || typeof currentPrice === "undefined") {
                            const priceKeys = Object.keys(root.pricesArr);
                            const lastItem = priceKeys[priceKeys.length -1];
                            currentPrice = root.pricesArr[lastItem];
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
