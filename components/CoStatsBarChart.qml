import QtQuick
import QtQuick.Controls
import QtCharts
import Nymea

// CoStatsBarChart
//
// A stacked bar chart for the statistics page. Shows two bar stacks side by
// side per x-axis category (e.g. "sources" vs "consumers"), a left kWh/MWh
// y-axis (auto scaled to "nice" round numbers with 5 labels, unit chosen
// automatically based on the data magnitude), and category labels on the
// x-axis. Unlike CoStatsLineChart, this chart has no pinch-zoom or pan/drag
// gesture support - the visible data is entirely determined by "categories"
// and "stacks".
//
// The chart itself does not fetch or aggregate any data - the caller is
// expected to already have one aggregated value per category per series
// (e.g. from server-side pre-bucketed EnergyLogs at the appropriate sample
// rate). This keeps the chart source-agnostic: the two stacks may reference
// entirely unrelated data sources (e.g. power-balance logs vs. per-device
// consumption logs) that aren't guaranteed to share indices or timestamps -
// aligning them onto a common category axis is page-specific logic that
// does not belong in a reusable chart component.
//
// categories: array of strings, x-axis labels (e.g. ["Mo", "Di", ...] or
//   ["KW18", "KW19", ...]). Both stacks share this same x-axis.
//
// stacks: array of exactly 2 objects, each with:
//   - series: array of objects, each with:
//     - name: string, series name (used by CoStatsLineChartLegend)
//     - color: color, bar segment/legend color
//     - visible: bool (optional, defaults to true), toggled by the legend
//     - values: array of numbers, same length as "categories" - the value
//       contributed by this series to each category's bar stack
//
// Note: because "stacks"/"series" are plain JS arrays/objects (not
// ListModels), re-assign a new array reference (e.g. via slice()/spread)
// whenever their contents change (e.g. toggling "visible") so the chart
// picks up the change.
Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────
    property var categories: []
    property var stacks: []
    property bool loading: false

    // ── Private state & helpers ──────────────────────────────────────────
    QtObject {
        id: d

        readonly property int maxSeriesPerStack: 8
        readonly property int yLabelCount: 5
        // Once the "nice" axis max reaches this many kWh, switch the y-axis
        // unit to MWh (only affects label formatting, not the underlying
        // values, which are always assumed to be in kWh).
        readonly property real mWhThreshold: 1000

        readonly property real leftAxisReserve: axisFontMetrics.advanceWidth("999.9") + Style.extraSmallMargins
        readonly property real xLabelsHeight: axisFontMetrics.height + 2
        readonly property real bottomAxisReserve: xLabelsHeight + Style.extraSmallMargins

        function stackAt(stackIndex) {
            return stackIndex < root.stacks.length ? root.stacks[stackIndex] : null
        }

        function seriesDescriptor(stackIndex, seriesIndex) {
            var stack = d.stackAt(stackIndex)
            if (!stack || !stack.series || seriesIndex >= stack.series.length)
                return null
            return stack.series[seriesIndex]
        }

        // "Nice numbers" axis calculation: rounds the per-label step up to
        // the next value in a widened set of round fractions so that 5
        // evenly spaced labels are as round as possible while never
        // clipping the data.
        function niceStep(rawStep) {
            if (rawStep <= 0)
                return 1
            var exponent = Math.floor(Math.log(rawStep) / Math.LN10)
            var base = Math.pow(10, exponent)
            var fraction = rawStep / base
            var niceFractions = [1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10]
            for (var i = 0; i < niceFractions.length; i++) {
                if (fraction <= niceFractions[i] + 1e-9)
                    return niceFractions[i] * base
            }
            return 10 * base
        }

        function maxStackedValue() {
            var max = 0
            for (var s = 0; s < root.stacks.length; s++) {
                var stack = root.stacks[s]
                if (!stack || !stack.series)
                    continue
                for (var c = 0; c < root.categories.length; c++) {
                    var sum = 0
                    for (var i = 0; i < stack.series.length; i++) {
                        var desc = stack.series[i]
                        if (!desc || desc.visible === false || !desc.values)
                            continue
                        var v = desc.values[c]
                        if (v)
                            sum += v
                    }
                    if (sum > max)
                        max = sum
                }
            }
            return max
        }

        function updateAxisRange() {
            var intervals = d.yLabelCount - 1
            var maxValue = d.maxStackedValue()
            if (maxValue <= 0)
                maxValue = intervals
            var step = d.niceStep(maxValue / intervals)
            yAxis.max = step * intervals
            unitUsesMWh = yAxis.max >= d.mWhThreshold
        }

        property bool unitUsesMWh: false

        function unitLabel() {
            return d.unitUsesMWh ? qsTr("MWh") : qsTr("kWh")
        }

        function formatAxisValue(value) {
            var scaled = d.unitUsesMWh ? value / 1000 : value
            return Math.round(scaled * 10) / 10
        }

        function valuesForSlot(stackIndex, seriesIndex) {
            var desc = d.seriesDescriptor(stackIndex, seriesIndex)
            var count = root.categories.length
            var result = []
            for (var c = 0; c < count; c++) {
                if (!desc || desc.visible === false || !desc.values) {
                    result.push(0)
                    continue
                }
                var v = desc.values[c]
                result.push(v ? v : 0)
            }
            return result
        }

        function updateBarSet(barSet, stackIndex, seriesIndex) {
            var desc = d.seriesDescriptor(stackIndex, seriesIndex)
            barSet.color = desc && desc.color ? desc.color : "transparent"
            barSet.borderColor = barSet.color
            barSet.values = d.valuesForSlot(stackIndex, seriesIndex)
        }

        function rebuildStack(stackIndex) {
            var sets = stackIndex === 0 ? chartView.barSets0 : chartView.barSets1
            for (var i = 0; i < sets.length; i++)
                d.updateBarSet(sets[i], stackIndex, i)
            d.updateAxisRange()
        }
    }

    onCategoriesChanged: { d.rebuildStack(0); d.rebuildStack(1) }
    onStacksChanged: { d.rebuildStack(0); d.rebuildStack(1) }
    Component.onCompleted: { d.rebuildStack(0); d.rebuildStack(1) }

    FontMetrics {
        id: axisFontMetrics
        font: Style.extraSmallFont
    }

    Item {
        id: chartContainer
        anchors.fill: parent
        anchors.margins: Style.smallMargins

        ChartView {
            id: chartView
            anchors.fill: parent
            legend.visible: false
            antialiasing: true
            margins.top: Style.extraSmallMargins
            margins.bottom: d.bottomAxisReserve
            margins.left: d.leftAxisReserve
            margins.right: Style.extraSmallMargins

            ValueAxis {
                id: yAxis
                min: 0
                max: 4
                tickCount: d.yLabelCount
                labelsVisible: false
                gridLineColor: Style.colors.components_Statistics_Grid
                lineVisible: false
                minorGridVisible: false
            }

            BarCategoryAxis {
                id: categoryAxis
                categories: root.categories
                labelsVisible: false
                gridVisible: false
                lineVisible: false
            }

            // -- Stack 0 (e.g. "sources") - fixed data-series slots, bound
            // to root.stacks[0].series[i] --
            StackedBarSeries {
                id: barSeries0
                axisX: categoryAxis
                axisY: yAxis
                barWidth: 0.35

                BarSet { id: barSet0_0 }
                BarSet { id: barSet0_1 }
                BarSet { id: barSet0_2 }
                BarSet { id: barSet0_3 }
                BarSet { id: barSet0_4 }
                BarSet { id: barSet0_5 }
                BarSet { id: barSet0_6 }
                BarSet { id: barSet0_7 }
            }

            // -- Stack 1 (e.g. "consumers") - fixed data-series slots, bound
            // to root.stacks[1].series[i] --
            StackedBarSeries {
                id: barSeries1
                axisX: categoryAxis
                axisY: yAxis
                barWidth: 0.35

                BarSet { id: barSet1_0 }
                BarSet { id: barSet1_1 }
                BarSet { id: barSet1_2 }
                BarSet { id: barSet1_3 }
                BarSet { id: barSet1_4 }
                BarSet { id: barSet1_5 }
                BarSet { id: barSet1_6 }
                BarSet { id: barSet1_7 }
            }

            property var barSets0: [barSet0_0, barSet0_1, barSet0_2, barSet0_3, barSet0_4, barSet0_5, barSet0_6, barSet0_7]
            property var barSets1: [barSet1_0, barSet1_1, barSet1_2, barSet1_3, barSet1_4, barSet1_5, barSet1_6, barSet1_7]
        }

        // -- x-axis category labels --
        Item {
            id: xLabelsLayout
            x: chartView.plotArea.x
            y: chartView.plotArea.y + chartView.plotArea.height + Style.extraSmallMargins
            width: chartView.plotArea.width
            height: d.xLabelsHeight

            Repeater {
                model: root.categories

                delegate: Label {
                    required property var modelData
                    required property int index

                    width: xLabelsLayout.width / Math.max(1, root.categories.length)
                    x: width * index
                    horizontalAlignment: Text.AlignHCenter
                    font: Style.extraSmallFont
                    color: Style.colors.typography_Basic_Secondary
                    text: modelData
                }
            }
        }

        // -- Left (kWh/MWh) y-axis labels --
        Item {
            id: yLabelsLayout
            x: 0
            y: chartView.plotArea.y
            width: chartView.plotArea.x
            height: chartView.plotArea.height

            Repeater {
                model: d.yLabelCount

                delegate: Label {
                    required property int index

                    width: parent.width - Style.extraSmallMargins
                    y: parent.height / (d.yLabelCount - 1) * index - font.pixelSize / 2
                    horizontalAlignment: Text.AlignRight
                    font: Style.extraSmallFont
                    color: Style.colors.typography_Basic_Secondary
                    text: d.formatAxisValue(yAxis.max - index * (yAxis.max - yAxis.min) / (d.yLabelCount - 1))
                }
            }
        }

        // -- Unit label (top-left, e.g. "kWh" or "MWh") --
        Label {
            x: 0
            y: 0
            font: Style.extraSmallFont
            color: Style.colors.typography_Basic_Secondary
            text: d.unitLabel()
        }
    } // chartContainer

    // -- Busy overlay: dim the chart and show a spinner while loading --
    Rectangle {
        anchors.fill: parent
        color: Style.colors.typography_Background_Overlay
        visible: root.loading
    }

    ActivityIndicator {
        anchors.centerIn: parent
        running: root.loading
        visible: root.loading
    }
}
