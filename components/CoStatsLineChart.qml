import QtQuick
import QtQuick.Controls
import QtCharts
import Nymea
import NymeaApp.Utils

// CoStatsLineChart
//
// A multi-line chart for the statistics page. Shows a left kW y-axis (auto
// scaled to "nice" round numbers with 5 labels) and an optional right
// percentage y-axis (fixed 0-100%, 5 labels). The visible x-axis window can
// be zoomed (pinch) between 6h and 24h and panned (drag). Vertical light-grey
// lines mark day boundaries that fall within the visible window.
//
// The chart itself does not fetch any data. Each entry in "series" references
// an external model (e.g. an EnergyLogs-derived model exposing get(index),
// count, entriesAddedIdx(index, count) and entriesRemoved(index, count),
// like the ones used in PowerBalanceHistory.qml) plus a "valueFunction" that
// extracts the numeric value to plot from a model entry. This lets the same
// chart be reused with different underlying log types without hard-coding
// property names.
//
// series: array of objects, each with:
//   - name: string, series name (used by CoStatsChartLegend)
//   - color: color, line/legend color
//   - visible: bool (optional, defaults to true), toggled by the legend
//   - axis: "left" (default) or "right" - which y-axis the series belongs to
//   - model: object exposing count, get(index), entriesAddedIdx, entriesRemoved
//   - valueFunction: function(entry) -> real, extracts the y value
//
// Note: because "series" is a plain JS array (not a ListModel), re-assign a
// new array reference (e.g. via slice()/spread) whenever its contents change
// (e.g. toggling "visible") so the chart picks up the change.
//
// selectedDay: externally settable. When changed, resets the visible window
// to a midnight-to-midnight 24h window for that day.
//
// visibleDay: readonly, the calendar day of which the greater part of the
// current visible window belongs to (updates while panning/zooming).
//
// visibleRangeChanged(startTime, endTime): emitted (debounced) whenever the
// visible time window settles after a pan/zoom/selectedDay change. Intended
// to be used by the page to know when it needs to (re)fetch data for the
// newly visible range.
Item {
    id: root

    // ── Public API ────────────────────────────────────────────────────────
    property var series: []
    property date selectedDay: new Date()
    property bool percentAxisVisible: false
    property bool loading: false

    readonly property date visibleDay: new Date(d.visibleStartTime + d.visibleWindowMs / 2)

    signal visibleRangeChanged(date startTime, date endTime)

    // Sets the visible x-axis window to the given size (clamped to
    // [d.minWindowMs, d.maxWindowMs]) while keeping the current center time,
    // similar to a pinch-zoom centered on the middle of the current view.
    // Intended for programmatic/test use (e.g. quick "24h/12h/6h" buttons).
    function setVisibleWindowHours(hours) {
        var newWindow = d.clamp(hours * d.hourMs, d.minWindowMs, d.maxWindowMs)
        var center = d.visibleStartTime + d.visibleWindowMs / 2
        d.visibleWindowMs = newWindow
        d.visibleStartTime = center - newWindow / 2
        rangeSettleTimer.restart()
    }

    onSelectedDayChanged: d.resetToSelectedDay()
    Component.onCompleted: d.resetToSelectedDay()

    // ── Private state & helpers ──────────────────────────────────────────
    QtObject {
        id: d

        readonly property int maxSeriesCount: 8
        readonly property real hourMs: 3600000
        readonly property real dayMs: 24 * hourMs
        readonly property real minWindowMs: 6 * hourMs
        readonly property real maxWindowMs: 24 * hourMs
        readonly property int yLabelCount: 5

        property real visibleStartTime: 0
        property real visibleWindowMs: maxWindowMs

        // Reserved ChartView margins, sized via FontMetrics for the custom
        // axis label overlays below. ChartView's own plotArea auto-sizing
        // (with labelsVisible: false on all axes) is not reliable across
        // platforms/fonts - it left far too little room in some
        // environments, causing the label overlays to render outside the
        // chart bounds. Reserving explicit margins on the ChartView itself
        // guarantees the plotArea always leaves enough room for them.
        readonly property real leftAxisReserve: axisFontMetrics.advanceWidth("999.9") + Style.extraSmallMargins
        readonly property real rightAxisReserve: root.percentAxisVisible ? (axisFontMetrics.advanceWidth("100%") + Style.extraSmallMargins) : Style.extraSmallMargins
        readonly property real xLabelsHeight: axisFontMetrics.height * 2 + 2
        readonly property real bottomAxisReserve: xLabelsHeight + Style.smallMargins
        readonly property real topAxisReserve: Style.margins + axisFontMetrics.height + Style.extraSmallMargins * 2

        function seriesDescriptor(index) {
            return index < root.series.length ? root.series[index] : null
        }

        function clamp(value, min, max) {
            return Math.max(min, Math.min(max, value))
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

        function maxLeftValue() {
            var max = 0
            for (var i = 0; i < root.series.length; i++) {
                var desc = root.series[i]
                if (!desc || desc.axis === "right" || desc.visible === false || !desc.model)
                    continue
                var model = desc.model
                var count = model.count !== undefined ? model.count : 0
                for (var j = 0; j < count; j++) {
                    var entry = model.get(j)
                    if (!entry)
                        continue
                    var v = desc.valueFunction(entry)
                    if (v > max)
                        max = v
                }
            }
            return max
        }

        function updateLeftAxisRange() {
            var intervals = d.yLabelCount - 1
            var maxValue = d.maxLeftValue()
            if (maxValue <= 0)
                maxValue = intervals
            var step = d.niceStep(maxValue / intervals)
            yAxisLeft.max = step * intervals
        }

        function resetToSelectedDay() {
            var dt = new Date(root.selectedDay)
            dt.setHours(0, 0, 0, 0)
            d.visibleStartTime = dt.getTime()
            d.visibleWindowMs = d.maxWindowMs
            d.updateLeftAxisRange()
            rangeSettleTimer.restart()
        }

        function dayBoundariesInRange(startMs, endMs) {
            var result = []
            var dt = new Date(startMs)
            dt.setHours(0, 0, 0, 0)
            if (dt.getTime() < startMs)
                dt.setDate(dt.getDate() + 1)
            while (dt.getTime() <= endMs) {
                result.push(dt.getTime())
                dt.setDate(dt.getDate() + 1)
            }
            return result
        }

        function dayNoonsInRange(startMs, endMs) {
            var result = []
            var dt = new Date(startMs)
            dt.setHours(12, 0, 0, 0)
            if (dt.getTime() < startMs)
                dt.setDate(dt.getDate() + 1)
            while (dt.getTime() <= endMs) {
                result.push(dt.getTime())
                dt.setDate(dt.getDate() + 1)
            }
            return result
        }

        // Picks a "nice" hour step (divisor of 24h) for the x-axis time
        // labels, aiming for roughly 4 evenly spaced intervals across the
        // visible window, e.g. 6h steps for a 24h window, 3h steps for 12h,
        // 1h steps for a 6h window. Ticks are then placed at absolute
        // clock-time multiples of this step (not relative to the visible
        // window start), so they stay at fixed positions (e.g. always
        // 00:00, 06:00, 12:00, 18:00) while panning instead of shifting
        // with the visible window.
        function niceHourStep(windowHours) {
            var candidates = [1, 2, 3, 4, 6, 8, 12, 24]
            var target = windowHours / 4
            var step = candidates[0]
            for (var i = 0; i < candidates.length; i++) {
                if (candidates[i] <= target)
                    step = candidates[i]
                else
                    break
            }
            return step
        }

        // Absolute clock-time tick positions (multiples of stepHours since
        // local midnight) that fall within [startMs, endMs].
        function xTicksInRange(startMs, endMs, stepHours) {
            var stepMs = stepHours * hourMs
            var dt = new Date(startMs)
            dt.setHours(0, 0, 0, 0)
            var t = dt.getTime()
            while (t < startMs)
                t += stepMs
            var result = []
            while (t <= endMs) {
                result.push(t)
                t += stepMs
            }
            return result
        }

        // -- Position the day-boundary marker lines --
        function updateDayBoundaries() {
            var boundaries = d.dayBoundariesInRange(d.visibleStartTime, d.visibleStartTime + d.visibleWindowMs)
            var slots = [dayBoundarySeries0, dayBoundarySeries1]
            for (var i = 0; i < slots.length; i++) {
                var s = slots[i]
                s.clear()
                if (i < boundaries.length) {
                    s.append(boundaries[i], yAxisLeft.min)
                    s.append(boundaries[i], yAxisLeft.max)
                    s.visible = true
                } else {
                    s.visible = false
                }
            }
        }
    }

    // Debounce visibleRangeChanged so pan/zoom gestures don't flood
    // listeners (e.g. a page that triggers a data (re)fetch on this
    // signal).
    Timer {
        id: rangeSettleTimer
        interval: 200
        onTriggered: root.visibleRangeChanged(new Date(d.visibleStartTime), new Date(d.visibleStartTime + d.visibleWindowMs))
    }

    FontMetrics {
        id: axisFontMetrics
        font: Style.newExtraSmallFont
    }

    Connections {
        target: d
        function onVisibleStartTimeChanged() { d.updateDayBoundaries() }
        function onVisibleWindowMsChanged() { d.updateDayBoundaries() }
    }

    Item {
        id: chartContainer
        anchors.fill: parent

        ChartView {
            id: chartView
            anchors.fill: parent
            legend.visible: false
            antialiasing: true
            margins.top: d.topAxisReserve
            margins.bottom: d.bottomAxisReserve
            margins.left: d.leftAxisReserve
            margins.right: d.rightAxisReserve

            ValueAxis {
                id: yAxisLeft
                min: 0
                max: 4
                tickCount: d.yLabelCount
                labelsVisible: false
                gridLineColor: Style.colors.components_Statistics_Grid
                lineVisible: false
                minorGridVisible: false
            }

            ValueAxis {
                id: yAxisRight
                min: 0
                max: 100
                tickCount: d.yLabelCount
                labelsVisible: false
                gridVisible: false
                lineVisible: false
                minorGridVisible: false
                visible: root.percentAxisVisible
            }

            DateTimeAxis {
                id: xAxis
                min: new Date(d.visibleStartTime)
                max: new Date(d.visibleStartTime + d.visibleWindowMs)
                labelsVisible: false
                gridVisible: false
                lineVisible: false
                minorGridVisible: false
            }

            // -- Day boundary markers (at most 2 midnights can fall within any
            // window <= 24h wide) --
            LineSeries {
                id: dayBoundarySeries0
                axisX: xAxis
                axisY: yAxisLeft
                color: Style.colors.typography_Basic_Divider
                width: 1
                visible: false
            }
            LineSeries {
                id: dayBoundarySeries1
                axisX: xAxis
                axisY: yAxisLeft
                color: Style.colors.typography_Basic_Divider
                width: 1
                visible: false
            }

            // -- Fixed data-series slots, bound to root.series[i] --
            LineSeries { id: dataSeries0; axisX: xAxis; width: 2 }
            LineSeries { id: dataSeries1; axisX: xAxis; width: 2 }
            LineSeries { id: dataSeries2; axisX: xAxis; width: 2 }
            LineSeries { id: dataSeries3; axisX: xAxis; width: 2 }
            LineSeries { id: dataSeries4; axisX: xAxis; width: 2 }
            LineSeries { id: dataSeries5; axisX: xAxis; width: 2 }
            LineSeries { id: dataSeries6; axisX: xAxis; width: 2 }
            LineSeries { id: dataSeries7; axisX: xAxis; width: 2 }
        }

        // Helper that binds one fixed LineSeries slot to root.series[index] and
        // rebuilds its points whenever the referenced model's data changes.
        QtObject {
            id: seriesBinder

            function slot(index) {
                switch (index) {
                case 0: return dataSeries0
                case 1: return dataSeries1
                case 2: return dataSeries2
                case 3: return dataSeries3
                case 4: return dataSeries4
                case 5: return dataSeries5
                case 6: return dataSeries6
                case 7: return dataSeries7
                }
                return null
            }

            function rebuild(index) {
                var s = slot(index)
                if (!s)
                    return
                s.clear()
                var desc = d.seriesDescriptor(index)
                if (!desc || !desc.model)
                    return
                var model = desc.model
                var fn = desc.valueFunction
                var count = model.count !== undefined ? model.count : 0
                for (var i = 0; i < count; i++) {
                    var entry = model.get(i)
                    if (!entry)
                        continue
                    var t = entry.timestamp instanceof Date ? entry.timestamp.getTime() : entry.timestamp
                    s.append(t, fn(entry))
                }
                d.updateLeftAxisRange()
            }

            function updateSlotProperties(index) {
                var s = slot(index)
                if (!s)
                    return
                var desc = d.seriesDescriptor(index)
                s.visible = desc ? desc.visible !== false : false
                s.color = desc && desc.color ? desc.color : "transparent"
                s.axisY = desc && desc.axis === "right" ? yAxisRight : yAxisLeft
                rebuild(index)
            }
        }

        // One Connections block per fixed slot, dynamically re-targeting the
        // model referenced by root.series[i] so slot i's line is rebuilt whenever
        // that model's data changes (mirrors the entriesAddedIdx/entriesRemoved
        // driven approach used in PowerBalanceHistory.qml, but with a full
        // rebuild instead of fine-grained incremental updates - simpler and fast
        // enough for the point counts involved here).
        Repeater {
            model: d.maxSeriesCount
            delegate: Item {
                id: slotBinding
                required property int index
                visible: false
                readonly property int seriesIndex: index
                readonly property var desc: d.seriesDescriptor(seriesIndex)

                onSeriesIndexChanged: seriesBinder.updateSlotProperties(slotBinding.seriesIndex)
                Component.onCompleted: seriesBinder.updateSlotProperties(slotBinding.seriesIndex)

                Connections {
                    target: root
                    function onSeriesChanged() {
                        seriesBinder.updateSlotProperties(slotBinding.seriesIndex)
                    }
                }

                Connections {
                    target: slotBinding.desc ? slotBinding.desc.model : null
                    function onEntriesAddedIdx(index, count) { seriesBinder.rebuild(slotBinding.seriesIndex) }
                    function onEntriesRemoved(index, count) { seriesBinder.rebuild(slotBinding.seriesIndex) }
                    function onCountChanged() { seriesBinder.rebuild(slotBinding.seriesIndex) }
                }
            }
        }

        // -- Custom x-axis labels: hh:mm at fixed clock-time positions (based on
        // the current zoom level's nice hour step, anchored to absolute time so
        // they don't shift while panning), date at the tick nearest noon of each
        // visible day --
        Item {
            id: xLabelsLayout
            x: chartView.plotArea.x
            y: chartView.plotArea.y + chartView.plotArea.height + Style.smallMargins
            width: chartView.plotArea.width
            height: d.xLabelsHeight

            Repeater {
                model: d.xTicksInRange(d.visibleStartTime, d.visibleStartTime + d.visibleWindowMs, d.niceHourStep(d.visibleWindowMs / d.hourMs))

                delegate: Label {
                    required property var modelData
                    x: xLabelsLayout.width * ((modelData - d.visibleStartTime) / d.visibleWindowMs) - width / 2
                    horizontalAlignment: Text.AlignHCenter
                    font: Style.newExtraSmallFont
                    color: Style.colors.typography_Basic_Secondary
                    text: Qt.formatTime(new Date(modelData), "hh:mm")
                }
            }

            Repeater {
                model: d.dayNoonsInRange(d.visibleStartTime, d.visibleStartTime + d.visibleWindowMs)

                delegate: Label {
                    required property var modelData
                    x: xLabelsLayout.width * ((modelData - d.visibleStartTime) / d.visibleWindowMs) - width / 2
                    y: axisFontMetrics.height + 2
                    horizontalAlignment: Text.AlignHCenter
                    font: Style.newExtraSmallFont
                    color: Style.colors.typography_Basic_Secondary
                    text: Qt.formatDate(new Date(modelData), "d. MMM yyyy")
                }
            }
        }

        // -- Unit label (top-left, "kW") - right-aligned in the same
        // column/width as the y-axis numbers below it, so it lines up with them
        // regardless of how narrow/wide the current numbers are (see analogous
        // comment in CoStatsBarChart.qml) --
        Label {
            x: 0
            y: Style.margins
            width: yLeftLabelsLayout.width - Style.extraSmallMargins
            height: axisFontMetrics.height
            horizontalAlignment: Text.AlignRight
            font: Style.newExtraSmallFontBold
            color: Style.colors.typography_Basic_Secondary
            text: qsTr("kW")
        }

        // -- Left (kW) y-axis labels --
        Item {
            id: yLeftLabelsLayout
            x: 0
            y: chartView.plotArea.y
            width: chartView.plotArea.x
            height: chartView.plotArea.height

            Repeater {
                model: d.yLabelCount

                delegate: Label {
                    width: parent.width - Style.extraSmallMargins
                    y: parent.height / (d.yLabelCount - 1) * index - font.pixelSize / 2
                    horizontalAlignment: Text.AlignRight
                    font: Style.newExtraSmallFont
                    color: Style.colors.typography_Basic_Secondary
                    text: NymeaUtils.floatToLocaleString(yAxisLeft.max - index * (yAxisLeft.max - yAxisLeft.min) / (d.yLabelCount - 1), 1)
                }
            }
        }

        // -- Right (%) y-axis labels --
        Item {
            id: yRightLabelsLayout
            x: chartView.plotArea.x + chartView.plotArea.width
            y: chartView.plotArea.y
            width: chartContainer.width - x
            height: chartView.plotArea.height
            visible: root.percentAxisVisible

            Repeater {
                model: d.yLabelCount

                delegate: Label {
                    width: parent.width - Style.extraSmallMargins
                    x: Style.extraSmallMargins
                    y: parent.height / (d.yLabelCount - 1) * index - font.pixelSize / 2
                    horizontalAlignment: Text.AlignLeft
                    font: Style.newExtraSmallFont
                    color: Style.colors.typography_Basic_Secondary
                    text: NymeaUtils.floatToLocaleString(yAxisRight.max - index * (yAxisRight.max - yAxisRight.min) / (d.yLabelCount - 1), 0) + "%"
                }
            }
        }

        // -- Pinch (zoom, 6h..24h clamp) and drag (pan) gesture handling --
        PinchHandler {
            id: pinchHandler
            target: null
            minimumPointCount: 2
            maximumPointCount: 2

            property real startWindowMs
            property real startStartTime
            property real pivotFraction

            onActiveChanged: {
                if (active) {
                    startWindowMs = d.visibleWindowMs
                    startStartTime = d.visibleStartTime
                    pivotFraction = d.clamp((centroid.position.x - chartView.plotArea.x) / chartView.plotArea.width, 0, 1)
                } else {
                    rangeSettleTimer.restart()
                }
            }

            onScaleChanged: {
                if (!active)
                    return
                var newWindow = d.clamp(startWindowMs / scale, d.minWindowMs, d.maxWindowMs)
                var timeAtPivot = startStartTime + pivotFraction * startWindowMs
                d.visibleWindowMs = newWindow
                d.visibleStartTime = timeAtPivot - pivotFraction * newWindow
            }
        }

        DragHandler {
            id: dragHandler
            target: null
            minimumPointCount: 1
            maximumPointCount: 1

            property real startStartTime

            onActiveChanged: {
                if (active) {
                    startStartTime = d.visibleStartTime
                } else {
                    rangeSettleTimer.restart()
                }
            }

            onTranslationChanged: {
                if (!active)
                    return
                var deltaMs = -(translation.x / chartView.plotArea.width) * d.visibleWindowMs
                d.visibleStartTime = startStartTime + deltaMs
            }
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
