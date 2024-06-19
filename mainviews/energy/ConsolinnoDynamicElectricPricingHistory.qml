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

    QtObject {

        id: d

        property date now: new Date()

        readonly property int range: selectionTabs.currentValue.range
        readonly property int sampleRate: selectionTabs.currentValue.sampleRate
        readonly property int visibleValues: range

        readonly property var startTime: {
            var date = new Date(now);
            date.setTime(date.getTime() - range * 60000 + 2000);
            return date;
        }

        readonly property var endTime: {
            var date = new Date(now);
            date.setTime(date.getTime() + 2000)
            return date;
        }


        readonly property var startTimeSince: {
            var date = new Date(now);
            date.setTime(validSince * 1000);
            return date;
        }

        readonly property var endTimeUntil: {
            var date = new Date(now);
            date.setTime(validUntil * 1000);
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
                    sampleRate: 30
                    range: 660 // 11 Hours: 11 * 60
                }
                ListElement {
                    modelData: qsTr("tommorow")
                    sampleRate: 24
                    range: 1440 // 1 Day: 24 * 60
                }
            }

            onTabSelected: {
                d.now = new Date()
                //console.error(electrics.get(0).stateByName("averagePrice").value.toString())
                console.error(validSince)
                console.error(d.startTimeSince)
                console.error(validUntil)
                console.error(d.endTimeUntil)
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
                    visible: false
                    opacity: .5
                }
                Label {
                    x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                    y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                    text: qsTr("No data available")
                    visible: true
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
                        max = Math.max(max, Math.ceil(value / 100) * 100)
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
                            text: ((valueAxis.max - (index * valueAxis.max / (valueAxis.tickCount - 1))) / 1) + " ct" //linke Seite vom Graphen
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
                    color: Style.gray
                    borderWidth: 0
                    borderColor: color
                    name: qsTr("Unknown")
                    opacity: .2

                    lowerSeries: LineSeries {
                        id: zeroSeries
                        XYPoint { x: dateTimeAxis.min.getTime(); y: 0 }
                        XYPoint { x: dateTimeAxis.max.getTime(); y: 0 }

                    }
                    upperSeries: LineSeries {
                        id: pricingUpperSeries
                    }

                    function addEntry(currentPrice,currentSlot) {
                        pricingUpperSeries.append(0,currentSlot *1000 + 2000)
                        pricingUpperSeries.append(currentPrice,currentSlot * 1000)
                        pricingUpperSeries.append(0,currentSlot *1000 + 1000)
                    }
                    function insertEntry(index, entry) {
                        //pricingUpperSeries.insert()
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
                preventStealing: tooltipping || dragging

                property int startMouseX: 0
                property bool dragging: false
                property bool tooltipping: false
                property var startDatetime: null

                Rectangle {
                    height: parent.height
                    width: 1
                    color: Style.foregroundColor
                    x: Math.min(mouseArea.width - 1, Math.max(0, mouseArea.mouseX))
                    visible: (mouseArea.containsMouse || mouseArea.tooltipping) && !mouseArea.dragging
                }

                //Mouseover Details in Graph
                NymeaToolTip {
                    id: toolTip
                    visible: (mouseArea.containsMouse || mouseArea.tooltipping) && !mouseArea.dragging

                    backgroundItem: chartView
                    backgroundRect: Qt.rect(mouseArea.x + toolTip.x, mouseArea.y + toolTip.y, toolTip.width, toolTip.height)

                    property int idx: Math.min(d.visibleValues, Math.max(0, Math.round(mouseArea.mouseX * d.visibleValues / mouseArea.width)))
                    property var timestamp: new Date(Math.min(d.endTime.getTime(), Math.max(d.startTime, d.startTime.getTime() + (idx * d.sampleRate * 60000))))
                    //property ThingsProxy entry: electrics.get(0).


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
                            Rectangle {
                                width: Style.extraSmallFont.pixelSize
                                height: width
                                color: consumptionSeries.color
                            }
                            Label {
                                //property double rawValue: d.startTime //toolTip.entry ? toolTip.entry.consumption : 0
                                //property double displayValue: 25
                                //property string unit: "Cents / kwWh"
                                text: d.startTime.toLocaleString(Qt.locale(), Locale.ShortFormat) //conState.currentState //"%1: %2 %3".arg().arg(displayValue.toFixed(2)).arg(unit)
                                font: Style.extraSmallFont
                            }
                        }
                    }
                }
            }
        }
    }
}
