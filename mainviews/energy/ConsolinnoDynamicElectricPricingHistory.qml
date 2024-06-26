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
    property var prices: []

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
            }
        }

        Component.onCompleted: {
            validSince = thing.stateByName("validSince").value
            validUntil = thing.stateByName("validUntil").value
            currentPrice = thing.stateByName("currentMarketPrice").value
            averagePrice = thing.stateByName("averagePrice").value.toFixed(0).toString();

            let minPrice = thing.stateByName("lowestPrice").value
            let maxPrice = thing.stateByName("highestPrice").value

            valueAxis.adjustMax(minPrice,maxPrice);
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
                        max = maxPrice + 5
                        min = minPrice >= 10 ? minPrice - 10 : minPrice
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

                    upperSeries: LineSeries {
                        id: pricingUpperSeries
                    }

                    function insertEntry(value){
                        var lastObjectValue = value[Object.keys(value)[Object.keys(value).length - 1]];



                        var i = 0;
                        for (const item in value){
                            const date = new Date(item);
                            var z = date.getTime();
                            prices.push([z,value[item]])

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

                    upperSeries: LineSeries {
                        id: pricingUpperSeriesAbove
                    }

                }

            }

            RowLayout {
                anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
                height: Style.smallIconSize
                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Style.green
                        width: 8
                        height: 8
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font: Style.smallFont
                        text: qsTr("Current market price")
                    }
                }

                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 5
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Style.red
                        width: 8
                        height: 8
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        font: Style.smallFont
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
                                x = new Date(x).toLocaleString(Qt.locale(), Locale.ShortFormat);
                                d.startTimeSince.toLocaleString(Qt.locale(), Locale.ShortFormat)
                                return x;
                            }
                            font: Style.smallFont
                        }
                        Label {
                            property string unit: qsTr("Cents / kWh")
                            text: {
                                let x = Number.parseInt(((new Date(d.endTimeUntil).getTime() - new Date(d.startTimeSince).getTime())/Math.ceil(mouseArea.width)*toolTip.idx+new Date(d.startTimeSince).getTime())/100000) * 100000// +"XXX"+toolTip.idx
                                let val = "";
                                for(const item in prices) {
                                    if(x >= prices[item][0] || x === prices[item][0]) {
                                        val = prices[item][1]
                                    } else {
                                        break;
                                    }

                                }
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
