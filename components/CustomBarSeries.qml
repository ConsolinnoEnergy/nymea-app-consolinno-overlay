import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import Nymea 1.0
import QtCharts 2.3

ChartView {
    id: root
    property double currentPrice: 0
    property double highestValue: 0
    property double lowestValue: 0
    property var hoursNow: 0
    property var startTime: 0
    property var endTime: 0
    property var pricesArr: ({})

    legend.visible: false

    Component.onCompleted: {
        valueAxis.adjustMax((Math.ceil(root.lowestValue)), root.highestValue);
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
        labelsColor: Style.foregroundColor
    }

    AreaSeries {
        axisX: dateTimeAxis
        axisY: valueAxis
        color: Configuration.batteryChargeColor
        borderWidth: 2
        borderColor: '#ffffff'
        upperSeries: LineSeries {
          id: mainSeries
        }
    }

    AreaSeries {
        axisX: dateTimeAxis
        axisY: valueAxis
        color: Configuration.epexCurrentTime
        borderWidth: 2
        borderColor: '#ffffff'
        upperSeries: LineSeries {
          id: currentValueSeries
        }
    }

    AreaSeries {
        axisX: dateTimeAxis
        axisY: valueAxis
        color: '#F5F5F5'
        borderWidth: 2
        borderColor: '#ffffff'
        upperSeries: LineSeries {
            id: pricingPast
        }
    }

    AreaSeries {
        axisX: dateTimeAxis
        axisY: valueAxis
        color: '#8D8B8E'
        borderWidth: 2
        borderColor: '#ffffff'
        upperSeries: LineSeries {
            id: pricingCurrentTime
        }
    }

    AreaSeries {
        axisX: dateTimeAxis
        axisY: valueAxis
        color: '#D9D9D9'
        borderWidth: 2
        borderColor: '#ffffff'
        upperSeries: LineSeries {
            id: pricingOutOfLimit
        }
    }

    AreaSeries {
        axisX: dateTimeAxis
        axisY: valueAxis
        color: 'transparent'
        borderWidth: 1
        borderColor: Configuration.epexAverageColor

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

        for (const item in value){
            const date = new Date(item);
            let currentTimestamp = date.getTime();
            let itemValue = value[item];

            if(itemValue < root.lowestValue){
                root.lowestValue = itemValue
            }

            if(itemValue > root.highestValue){
                root.highestValue = itemValue
            }

            if(lastChange !== itemValue) {
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
                root.highestValue = itemValue
                root.lowestValue = itemValue
                currentTimestamp = currentTimestamp - 600000;
            }

            priceLimitUp.append(currentTimestamp,currentPrice);

            if(lastChange !== itemValue) { // Draw done to mimick a bar
              barToDraw.append(currentTimestamp, lastChange);
              barToDraw.append(currentTimestamp, -5);

              // draw all unused bars along the x axis to prevent overlapping
              mainSeries.append(currentTimestamp,-5);
              pricingCurrentTime.append(currentTimestamp,-5);
              pricingPast.append(currentTimestamp,-5);
              pricingOutOfLimit.append(currentTimestamp,-5);
            }

            barToDraw = mainSeries;

            if(date.getHours() < root.hoursNow) {
                barToDraw = pricingPast;
            }
            else if(root.currentPrice > itemValue && date.getHours() === root.hoursNow){
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

        mainSeries.append(todayMidnightTs + 6000000, lastObjectValue);

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

}
