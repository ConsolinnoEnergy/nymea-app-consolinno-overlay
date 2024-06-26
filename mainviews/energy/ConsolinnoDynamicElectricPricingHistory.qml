import QtQuick 2.0
import QtCharts 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
import "qrc:/ui/components"

Item {
    id: root
    property int validSince: 0
    property int validUntil: 0
    property string averagePrice: ""
    property double currentPrice: 0
    property var prices: ({})

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
                date.setTime((validSince + 133200) * 1000);
            }
            return date;
        }

        readonly property var endTimeUntil: {
            var date = new Date(now);
            if(selectionTabs.currentIndex == 0){
                date.setTime((validUntil + 3600) * 1000 );
            }else{
                date.setTime((validUntil + 86400) * 1000);
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
            visible: root.titleVisible
        }

        SelectionTabs {
            id: selectionTabs
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            visible: false
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
                d.now = new Date()
                console.error(d.endTimeUntil)
            }
        }

        Component.onCompleted: {
            validSince = thing.stateByName("validSince").value
            validUntil = thing.stateByName("validUntil").value
            currentPrice = thing.stateByName("currentMarketPrice").value
            averagePrice = thing.stateByName("averagePrice").value.toFixed(0).toString();
            valueAxis.adjustMax(thing.stateByName("averagePrice").value);

            consumptionSeries.insertEntry(thing.stateByName("priceSeries").value)
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
                legend.alignment: Qt.AlignBottom
                legend.font: Style.extraSmallFont
                legend.labelColor: Style.foregroundColor

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
                    lineVisible: false
                    titleVisible: false
                    shadesVisible: false

                    function adjustMax(value) {
                        max = Math.max(max, Math.ceil(value) * 2)
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
                            text: (Math.ceil(valueAxis.max - (index * valueAxis.max / (valueAxis.tickCount - 1)))) + " ct" //linke Seite vom Graphen
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
                    name: qsTr("Unknown")

                    upperSeries: LineSeries {
                        id: pricingUpperSeries
                    }

                    function insertEntry(value){
                        var lastObjectValue = value[Object.keys(value)[Object.keys(value).length - 1]];

                        var i = 0;
                        let lastChange = 0;
                        let lastChangeTimestamp = 0;
                        let identicalIndexes = [];

                        for (const item in value){
                            const date = new Date(item);
                            var z = date.getTime();

                            if(lastChange !== value[item]) {
                                lastChangeTimestamp = z;

                                for(const ts of identicalIndexes) {
                                    prices[ts].end = z;
                                }

                                identicalIndexes = [z];
                            }
                            else {
                                identicalIndexes.push(z);
                            }

                            lastChange = value[item];

                            prices[z] = {
                                start: lastChangeTimestamp,
                                value: value[item]
                            };

                            if(i == 0){
                                i = 1
                                z = z - 600000
                            }

                            pricingUpperSeriesAbove.append(z,averagePrice);
                            pricingUpperSeries.append(z,value[item]);
                        }
                        pricingUpperSeriesAbove.append(z + 6000000, averagePrice);
                        pricingUpperSeries.append(z + 6000000, lastObjectValue);
                    }
                }

                AreaSeries {
                    id: consumptionSeriesAbove
                    axisX: dateTimeAxis
                    axisY: valueAxis
                    color: 'transparent'
                    borderWidth: 1
                    borderColor: Style.red
                    name: qsTr("Unknown")

                    upperSeries: LineSeries {
                        id: pricingUpperSeriesAbove
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

                    backgroundItem: pricingUpperSeries
                    backgroundRect: Qt.rect(mouseArea.x + toolTip.x, mouseArea.y + toolTip.y, toolTip.width, toolTip.height)

                    property double currentValueY: 0
                    property int idx: mouseArea.mouseX
                    property int timeSince: new Date(d.startTimeSince).getTime()
                    property var timestamp: (new Date(d.endTimeUntil).getTime() - new Date(d.startTimeSince).getTime())

                    property int xOnRight: Math.max(0, mouseArea.mouseX) + Style.smallMargins
                    property int xOnLeft: Math.min(mouseArea.width, mouseArea.mouseX) - Style.smallMargins - width
                    x: xOnRight + width < mouseArea.width ? xOnRight : xOnLeft
                    property double maxValue: 0
                    y: Math.min(Math.max(mouseArea.height - (maxValue * mouseArea.height / valueAxis.max) - height - Style.margins, 0), mouseArea.height - height)

                    width: tooltipLayout.implicitWidth + Style.smallMargins * 2
                    height: tooltipLayout.implicitHeight + Style.smallMargins * 2

                    function getQuaterlyTimestamp(timestamp) {
                       const currTime = new Date(timestamp);
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
                           return timestamp;
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
                                let x = Number.parseInt(((new Date(d.endTimeUntil).getTime() - new Date(d.startTimeSince).getTime())/Math.ceil(mouseArea.width)*toolTip.idx+new Date(d.startTimeSince).getTime())/100000) * 100000// +"XXX"+toolTip.idx

                                d.startTimeSince.toLocaleString(Qt.locale(), Locale.ShortFormat)

                                let val = prices[toolTip.getQuaterlyTimestamp(x)].start;
                                val = new Date(val).toLocaleString(Qt.locale(), Locale.ShortFormat);

                                let endVal = prices[toolTip.getQuaterlyTimestamp(x)].end;
                                endVal = new Date(endVal).toLocaleString(Qt.locale(), Locale.ShortFormat);

                                return val + " - " + endVal;
                            }
                            font: Style.smallFont
                        }
                        Label {
                            property string unit: qsTr("Cents / kWh")
                            text: {
                                let x = Number.parseInt(((new Date(d.endTimeUntil).getTime() - new Date(d.startTimeSince).getTime())/Math.ceil(mouseArea.width)*toolTip.idx+new Date(d.startTimeSince).getTime())/100000) * 100000// +"XXX"+toolTip.idx
                                let val = prices[toolTip.getQuaterlyTimestamp(x)].value;

                                val = Number.parseFloat(val).toFixed(2);
                                return "%1 %2".arg(val).arg(unit)
                            }
                            font: Style.extraSmallFont
                        }

                    }
                }
            }


        }
    }
}
