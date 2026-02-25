import QtQuick 2.3
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtCharts 2.3
import Nymea 1.0
import "qrc:/ui/components/"

StatsBase {
    id: root
    property EnergyManager energyManager: null
    property bool titleVisible: true
    property ThingsProxy producers: ThingsProxy {
        engine: _engine
        shownInterfaces: ["smartmeterproducer"]
    }
    readonly property bool hasProducers: producers.count > 0

    CoKpiStatsProvider {
        id: kpiProvider
        engine: _engine
    }

    Connections {
        target: kpiProvider
        onKpiBarResult: {
            autarkySet.replace(barIndex, selfSufficiency)
            selfConsumptionSet.replace(barIndex, selfConsumption)
        }
    }

    QtObject {
        id: d
        property var config: root.configs[selectionTabs.currentValue.config]
        property int startOffset: 0
        property var selectedSet: null
        property date startTime: root.calculateTimestamp(config.startTime(), config.sampleRate, startOffset)
        property date endTime: root.calculateTimestamp(config.startTime(), config.sampleRate, startOffset + config.count)

        property bool loading: kpiProvider.fetchingKpiSeries

        onConfigChanged: valueAxis.max = 100
        onStartOffsetChanged: fetchKpis()

        function selectSet(set) {
            if (d.selectedSet === set) {
                d.selectedSet = null
            } else {
                d.selectedSet = set
            }
        }

        function fetchKpis() {
            var periods = []
            for (var i = 0; i < d.config.count; i++) {
                var toTimestamp = root.calculateTimestamp(d.config.startTime(), d.config.sampleRate, d.startOffset + i + 1)
                var fromTimestamp = root.calculateTimestamp(toTimestamp, d.config.sampleRate, -1)
                periods.push({
                    from: Math.floor(fromTimestamp.getTime() / 1000),
                    to: Math.floor(toTimestamp.getTime() / 1000)
                })
            }
            kpiProvider.fetchKpiSeries(periods)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Label {
            Layout.fillWidth: true
            Layout.margins: Style.smallMargins
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("KPI Statistics")
            visible: root.titleVisible
        }

        ConsolinnoSelectionTabs {
            id: selectionTabs
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            currentIndex: 1
            model: ListModel {
                ListElement { modelData: qsTr("Hours"); config: "hours" }
                ListElement { modelData: qsTr("Days"); config: "days" }
                ListElement { modelData: qsTr("Weeks"); config: "weeks" }
                ListElement { modelData: qsTr("Months"); config: "months" }
                ListElement { modelData: qsTr("Years"); config: "years" }
            }
            onTabSelected: {
                d.startOffset = 0
            }
        }

        Connections {
            target: energyManager
            onPowerBalanceChanged: {
                d.fetchKpis()
            }
        }

        Component.onCompleted: d.fetchKpis()

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                x: chartView.x + chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                y: chartView.y + chartView.plotArea.y + Style.smallMargins
                text: d.config.toRangeLabel(d.startTime)
                font: Style.smallFont
                opacity: d.startOffset < -d.config.count ? .5 : 0
                Behavior on opacity { NumberAnimation {} }
            }

            ChartView {
                id: chartView
                animationOptions: ChartView.NoAnimation
                anchors.fill: parent

                backgroundColor: "transparent"

                legend.visible: false
                legend.alignment: Qt.AlignBottom
                legend.font: Style.extraSmallFont
                legend.labelColor: Style.foregroundColor

                margins.right: 0
                margins.bottom: Style.smallIconSize + Style.margins
                margins.top: 0

                ActivityIndicator {
                    x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                    y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                    visible: kpiProvider.fetchingKpiSeries
                    opacity: .5
                }

                Item {
                    id: labelsLayout
                    x: Style.smallMargins
                    y: chartView.plotArea.y
                    height: chartView.plotArea.height
                    width: chartView.plotArea.x - x

                    Repeater {
                        model: 6
                        delegate: Label {
                            y: parent.height / 5 * index - font.pixelSize / 2
                            width: parent.width - Style.smallMargins
                            horizontalAlignment: Text.AlignRight
                            text: (100 - index * 20) + "%"
                            verticalAlignment: Text.AlignTop
                            font: Style.extraSmallFont
                        }
                    }
                }

                BarSeries {
                    id: barSeries
                    axisX: BarCategoryAxis {
                        id: categoryAxis
                        labelsColor: Style.foregroundColor
                        labelsFont: Style.extraSmallFont
                        gridVisible: false
                        gridLineColor: Style.tileOverlayColor
                        lineVisible: false
                        titleVisible: false
                        shadesVisible: false

                        categories: {
                            var ret = []
                            for (var i = 0; i < d.config.count; i++) {
                                var timestamp = root.calculateTimestamp(d.config.startTime(), d.config.sampleRate, d.startOffset + i);
                                ret.push(d.config.toLabel(timestamp))
                            }
                            return ret;
                        }
                    }
                    axisY: ValueAxis {
                        id: valueAxis
                        min: 0
                        max: 100
                        gridLineColor: Style.tileOverlayColor
                        labelsVisible: false
                        lineVisible: false
                        titleVisible: false
                        shadesVisible: false
                    }

                    BarSet {
                        id: autarkySet
                        label: qsTr("Self-sufficiency")
                        color: "#87BD26"
                        borderColor: color
                        borderWidth: 0
                        values: {
                            var ret = []
                            for (var i = 0; i < d.config.count; i++) { ret.push(0) }
                            return ret
                        }
                    }
                    BarSet {
                        id: selfConsumptionSet
                        label: qsTr("Self-consumption")
                        color: "#FCE487"
                        borderColor: color
                        borderWidth: 0
                        values: {
                            var ret = []
                            for (var i = 0; i < d.config.count; i++) { ret.push(0) }
                            return ret
                        }
                    }
                }
            }

            RowLayout {
                id: legend
                anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
                anchors.leftMargin: chartView.plotArea.x
                height: Style.smallIconSize
                anchors.margins: Style.margins

                MouseArea {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    opacity: d.selectedSet == null || d.selectedSet == autarkySet ? 1 : 0.3
                    onClicked: d.selectSet(autarkySet)
                    Row {
                        anchors.centerIn: parent
                        spacing: Style.smallMargins
                        Rectangle {
                            width: Style.smallIconSize
                            height: width
                            radius: 2
                            color: "#87BD26"
                        }
                        Label {
                            text: qsTr("Self-sufficiency")
                            font: Style.smallFont
                        }
                    }
                }

                MouseArea {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    opacity: d.selectedSet == null || d.selectedSet == selfConsumptionSet ? 1 : 0.3
                    onClicked: d.selectSet(selfConsumptionSet)
                    Row {
                        anchors.centerIn: parent
                        spacing: Style.smallMargins
                        Rectangle {
                            width: Style.smallIconSize
                            height: width
                            radius: 2
                            color: "#FCE487"
                        }
                        Label {
                            text: qsTr("Self-consumption")
                            font: Style.smallFont
                        }
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                anchors.leftMargin: chartView.x + chartView.plotArea.x
                anchors.topMargin: chartView.y + chartView.plotArea.y
                anchors.rightMargin: chartView.width - chartView.plotArea.width - chartView.plotArea.x
                anchors.bottomMargin: chartView.height - chartView.plotArea.height - chartView.plotArea.y

                hoverEnabled: true

                onDoubleClicked: {
                    var idx = Math.ceil(mouseArea.mouseX * d.config.count / mouseArea.width) - 1
                    var timestamp = root.calculateTimestamp(d.config.startTime(), d.config.sampleRate, d.startOffset + idx)
                    if (selectionTabs.currentIndex > 0) {
                        selectionTabs.currentIndex--
                        var startTime = d.config.startTime()
                        d.startOffset = (timestamp.getTime() - startTime.getTime()) / (d.config.sampleRate * 60 * 1000)
                    }
                }

                NymeaToolTip {
                    id: toolTip
                    backgroundItem: chartView
                    backgroundRect: Qt.rect(chartView.plotArea.x + toolTip.x, chartView.plotArea.y + toolTip.y, toolTip.width, toolTip.height)

                    property int idx: visible ? Math.min(d.config.count -1, Math.max(0, Math.ceil(mouseArea.mouseX * d.config.count / mouseArea.width) - 1)) : 0
                    property date timestamp: root.calculateTimestamp(d.config.startTime(), d.config.sampleRate, d.startOffset + idx)

                    visible: mouseArea.containsMouse

                    property int chartWidth: chartView.plotArea.width
                    property int barWidth: chartWidth / categoryAxis.count

                    x: chartWidth - (idx * barWidth + barWidth + Style.smallMargins) > width ?
                           idx * barWidth + barWidth + Style.smallMargins
                         : idx * barWidth - Style.smallMargins - width

                    y: mouseArea.height / 2 - height / 2
                    width: tooltipLayout.implicitWidth + Style.smallMargins * 2
                    height: tooltipLayout.implicitHeight + Style.smallMargins * 2

                    ColumnLayout {
                        id: tooltipLayout
                        anchors.centerIn: parent
                        Label {
                            text: d.config.toLongLabel(toolTip.timestamp)
                            font: Style.smallFont
                        }
                        RowLayout {
                            Rectangle { width: 10; height: 10; color: "#87BD26" }
                            Label { text: qsTr("Self-sufficiency: %1%").arg(autarkySet.at(toolTip.idx).toFixed(1)); font: Style.extraSmallFont }
                        }
                        RowLayout {
                            Rectangle { width: 10; height: 10; color: "#FCE487" }
                            Label { text: qsTr("Self-consumption: %1%").arg(selfConsumptionSet.at(toolTip.idx).toFixed(1)); font: Style.extraSmallFont }
                        }
                    }
                }
            }
        }
    }
}
