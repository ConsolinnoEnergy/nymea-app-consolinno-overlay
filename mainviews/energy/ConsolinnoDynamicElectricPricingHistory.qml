import QtQuick 2.0
import QtCharts 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
import "qrc:/ui/components"

Item {
    id: root

    property HemsManager hemsManager
    property ConEMSState conState: hemsManager.conEMSState
    property int validSince: 0
    property int validUntil: 0
    property int currentSlot: 0
    property string averagePrice: ""
    property double currentPrice: 0

    property ThingsProxy electrics: ThingsProxy {
        engine: _engine
        shownInterfaces: ["dynamicelectricitypricing"]
    }

    readonly property Thing thing: electrics ? electrics.get(0) : null

    property LogsModelNg thingHistory: LogsModelNg{
        id: logsModelNg
        engine: _engine
        thingId: electrics.get(0).id
        live: true
        graphSeries: pricingUpperSeries
        viewStartTime: dateTimeAxis.min
    }

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
                date.setTime(validUntil * 1000);
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
            text: qsTr("Dynamic electro price")
            visible: root.titleVisible
        }

        SelectionTabs {
            id: selectionTabs
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            currentIndex: 0
            model: ListModel {
                ListElement {
                    modelData: qsTr("today")
                }
                ListElement {
                    modelData: qsTr("tommorow")
                }
            }

            onTabSelected: {
                d.now = new Date()
                console.error(dateTimeAxis.min)
                pricingUpperSeries.clear();


            }
        }

        Component.onCompleted: {
            validSince = thing.stateByName("validSince").value
            validUntil = thing.stateByName("validUntil").value
            currentSlot = thing.stateByName("currentSlot").value
            currentPrice = thing.stateByName("currentMarketPrice").value
            averagePrice = thing.stateByName("averagePrice").value.toFixed(0).toString();
            valueAxis.adjustMax(thing.stateByName("highestPrice").value);
        }

        Text {
            Layout.fillWidth: true
            Layout.topMargin: Style.smallMargins
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 13
            text: "Average Market Price: " + (averagePrice) + " ct"
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
                    visible: thingHistory.busy
                    opacity: .5
                }

                Label {
                    x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                    y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                    text: qsTr("No data available")
                    visible: thingHistory.busy
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
                        max = Math.max(max, Math.ceil(value))
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
                            text: (Math.ceil(valueAxis.max - (index * valueAxis.max / (valueAxis.tickCount - 1))) / 1) + " ct" //linke Seite vom Graphen
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
                    borderWidth: 2
                    borderColor: Style.green
                    name: qsTr("Unknown")


                    upperSeries: LineSeries {
                        id: pricingUpperSeries
                        onPointAdded: {
                            var newPoint = 0;

                            if(currentPrice < averagePrice){
                                newPoint =  pricingUpperSeries.at(index);
                                consumptionSeries.borderColor = Style.green;
                            }else{
                                newPoint = pricingUpperSeriesAbove.at(index)
                                consumptionSeriesAbove.borderColor = Style.red;
                            }


                            if (newPoint.x <= dateTimeAxis.max.getTime() || logsModelNg.busy) {
                                return;
                            }

                            var diffMaxToNew = newPoint.x - dateTimeAxis.max.getTime();
                            if (diffMaxToNew < 1000 * 60 * 5) {
                                chartView.animationOptions = ChartView.NoAnimation;
                                var newMin = dateTimeAxis.min.getTime() + diffMaxToNew;
                                dateTimeAxis.max = new Date(newPoint.x);
                                dateTimeAxis.min = new Date(newMin);
                                chartView.animationOptions = NymeaUtils.chartsAnimationOptions;
                            }
                        }
                    }

                    onHovered: {
                        findClosestPoint(point);
                    }

                    function findClosestPoint(point){

                        var searchIdx = Math.floor(pricingUpperSeries.count / 2);
                        var prevIdx = 0;
                        var nextIdx = pricingUpperSeries.count - 1;

                        while (prevIdx + 1 != nextIdx) {
                            if(point.x < pricingUpperSeries.at(searchIdx).x){
                                prevIdx = searchIdx;
                            }else if(point.x > pricingUpperSeries.at(searchIdx).x ){
                                nextIdx = searchIdx;
                            }

                            searchIdx = prevIdx + Math.floor((nextIdx - prevIdx) / 2);
                        }

                        var diffToPrevious = Math.abs(point.x - pricingUpperSeries.at(prevIdx).x);
                        var diffToNext = Math.abs(point.x - pricingUpperSeries.at(prevIdx).x);
                        var closestPoint = diffToPrevious < diffToNext ? pricingUpperSeries.at(prevIdx) : pricingUpperSeries.at(nextIdx);


                        toolTip.currentValueY = closestPoint.y
                    }
                }

                AreaSeries {
                    id: consumptionSeriesAbove
                    axisX: dateTimeAxis
                    axisY: valueAxis
                    color: 'transparent'
                    borderWidth: 2
                    borderColor: Style.red
                    name: qsTr("Unknown")

                    upperSeries: LineSeries {
                        id: pricingUpperSeriesAbove
                    }

                }

                /*
                ScatterSeries {
                    id: selectedValue
                    color: Style.green
                    markerSize: 5
                    borderWidth: 2
                    borderColor: Style.green
                    axisX: dateTimeAxis
                    axisY: valueAxis
                    pointLabelsVisible: true
                    pointLabelsColor: Style.foregroundColor
                    pointLabelsFont.pixelSize: app.smallFont
                    pointLabelsFormat: "@yPoint"
                    pointLabelsClipping: false

                }*/

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

                    property var currentValueY: 0

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
                            text: d.startTime.toLocaleString(Qt.locale(), Locale.ShortFormat)
                            font: Style.smallFont
                        }
                        RowLayout {
                            Label {
                                property string unit: "Cents / kwWh"
                                text: "%1 %2".arg(toolTip.currentValueY).arg(unit)
                                font: Style.extraSmallFont
                            }
                        }
                    }
                }
            }


        }
    }
}
