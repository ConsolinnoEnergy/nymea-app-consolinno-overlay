import QtQuick
import QtQuick.Controls
import QtCharts
import Nymea

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
//   - name: string, series name (used by CoStatsLineChartLegend)
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

    property var series: []
    property date selectedDay: new Date()
    property bool percentAxisVisible: false
    property bool loading: false

    readonly property date visibleDay: new Date(_visibleStartTime + _visibleWindowMs / 2)

    signal visibleRangeChanged(date startTime, date endTime)

    readonly property int _maxSeriesCount: 8
    readonly property real _hourMs: 3600000
    readonly property real _dayMs: 24 * _hourMs
    readonly property real _minWindowMs: 6 * _hourMs
    readonly property real _maxWindowMs: 24 * _hourMs
    readonly property int _yLabelCount: 5
    readonly property int _xLabelCount: 6

    property real _visibleStartTime: 0
    property real _visibleWindowMs: _maxWindowMs

    function _seriesDescriptor(index) {
        return index < root.series.length ? root.series[index] : null
    }

    function _clamp(value, min, max) {
        return Math.max(min, Math.min(max, value))
    }

    // "Nice numbers" axis calculation: rounds the per-label step up to the
    // next value in a widened set of round fractions so that 5 evenly spaced
    // labels are as round as possible while never clipping the data.
    function _niceStep(rawStep) {
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

    function _maxLeftValue() {
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

    function _updateLeftAxisRange() {
        var intervals = root._yLabelCount - 1
        var maxValue = root._maxLeftValue()
        if (maxValue <= 0)
            maxValue = intervals
        var step = root._niceStep(maxValue / intervals)
        yAxisLeft.max = step * intervals
    }

    function _resetToSelectedDay() {
        var d = new Date(root.selectedDay)
        d.setHours(0, 0, 0, 0)
        root._visibleStartTime = d.getTime()
        root._visibleWindowMs = root._maxWindowMs
        root._updateLeftAxisRange()
        rangeSettleTimer.restart()
    }

    onSelectedDayChanged: root._resetToSelectedDay()
    Component.onCompleted: root._resetToSelectedDay()

    // Debounce visibleRangeChanged so pan/zoom gestures don't flood listeners
    // (e.g. a page that triggers a data (re)fetch on this signal).
    Timer {
        id: rangeSettleTimer
        interval: 200
        onTriggered: root.visibleRangeChanged(new Date(root._visibleStartTime), new Date(root._visibleStartTime + root._visibleWindowMs))
    }

    function _dayBoundariesInRange(startMs, endMs) {
        var result = []
        var d = new Date(startMs)
        d.setHours(0, 0, 0, 0)
        if (d.getTime() < startMs)
            d.setDate(d.getDate() + 1)
        while (d.getTime() <= endMs) {
            result.push(d.getTime())
            d.setDate(d.getDate() + 1)
        }
        return result
    }

    ChartView {
        id: chartView
        anchors.fill: parent
        legend.visible: false
        antialiasing: true
        margins.top: 0
        margins.bottom: 0
        margins.left: 0
        margins.right: 0

        ValueAxis {
            id: yAxisLeft
            min: 0
            max: 4
            tickCount: root._yLabelCount
            labelsVisible: false
            gridLineColor: Style.colors.components_Statistics_Grid
            lineVisible: false
            minorGridVisible: false
        }

        ValueAxis {
            id: yAxisRight
            min: 0
            max: 100
            tickCount: root._yLabelCount
            labelsVisible: false
            gridVisible: false
            lineVisible: false
            minorGridVisible: false
            visible: root.percentAxisVisible
        }

        DateTimeAxis {
            id: xAxis
            min: new Date(root._visibleStartTime)
            max: new Date(root._visibleStartTime + root._visibleWindowMs)
            labelsVisible: false
            gridLineColor: Style.colors.components_Statistics_Grid
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
            var desc = root._seriesDescriptor(index)
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
            root._updateLeftAxisRange()
        }

        function updateSlotProperties(index) {
            var s = slot(index)
            if (!s)
                return
            var desc = root._seriesDescriptor(index)
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
        model: root._maxSeriesCount
        delegate: Item {
            id: slotBinding
            required property int index
            visible: false
            readonly property int seriesIndex: index
            readonly property var _desc: root._seriesDescriptor(seriesIndex)

            onSeriesIndexChanged: seriesBinder.updateSlotProperties(slotBinding.seriesIndex)
            Component.onCompleted: seriesBinder.updateSlotProperties(slotBinding.seriesIndex)

            Connections {
                target: root
                function onSeriesChanged() {
                    seriesBinder.updateSlotProperties(slotBinding.seriesIndex)
                }
            }

            Connections {
                target: slotBinding._desc ? slotBinding._desc.model : null
                function onEntriesAddedIdx(index, count) { seriesBinder.rebuild(slotBinding.seriesIndex) }
                function onEntriesRemoved(index, count) { seriesBinder.rebuild(slotBinding.seriesIndex) }
                function onCountChanged() { seriesBinder.rebuild(slotBinding.seriesIndex) }
            }
        }
    }

    // -- Custom x-axis labels: time (hh:mm) on every tick, date only on the
    // tick nearest a day boundary --
    Item {
        id: xLabelsLayout
        x: chartView.plotArea.x
        y: chartView.plotArea.y + chartView.plotArea.height
        width: chartView.plotArea.width
        height: 32

        Repeater {
            model: root._xLabelCount

            delegate: Column {
                readonly property real _tickTime: root._visibleStartTime + index * (root._visibleWindowMs / (root._xLabelCount - 1))
                readonly property real _halfSpacing: root._visibleWindowMs / (root._xLabelCount - 1) / 2
                readonly property bool _showDate: {
                    var boundaries = root._dayBoundariesInRange(root._visibleStartTime, root._visibleStartTime + root._visibleWindowMs)
                    for (var i = 0; i < boundaries.length; i++) {
                        if (Math.abs(_tickTime - boundaries[i]) <= _halfSpacing)
                            return true
                    }
                    return false
                }

                x: xLabelsLayout.width * (index / (root._xLabelCount - 1)) - width / 2
                width: xLabelsLayout.width / root._xLabelCount
                spacing: 2

                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    font: Style.extraSmallFont
                    color: Style.colors.typography_Basic_Secondary
                    text: Qt.formatTime(new Date(parent._tickTime), "hh:mm")
                }
                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    font: Style.extraSmallFont
                    color: Style.colors.typography_Basic_Secondary
                    visible: parent._showDate
                    text: Qt.formatDate(new Date(parent._tickTime), "d. MMM yyyy")
                }
            }
        }
    }

    // -- Left (kW) y-axis labels --
    Item {
        id: yLeftLabelsLayout
        x: 0
        y: chartView.plotArea.y
        width: chartView.plotArea.x
        height: chartView.plotArea.height

        Repeater {
            model: root._yLabelCount

            delegate: Label {
                width: parent.width - 4
                y: parent.height / (root._yLabelCount - 1) * index - font.pixelSize / 2
                horizontalAlignment: Text.AlignRight
                font: Style.extraSmallFont
                color: Style.colors.typography_Basic_Secondary
                text: Math.round((yAxisLeft.max - index * (yAxisLeft.max - yAxisLeft.min) / (root._yLabelCount - 1)) * 10) / 10
            }
        }
    }

    // -- Right (%) y-axis labels --
    Item {
        id: yRightLabelsLayout
        x: chartView.plotArea.x + chartView.plotArea.width
        y: chartView.plotArea.y
        width: root.width - x
        height: chartView.plotArea.height
        visible: root.percentAxisVisible

        Repeater {
            model: root._yLabelCount

            delegate: Label {
                width: parent.width - 4
                x: 4
                y: parent.height / (root._yLabelCount - 1) * index - font.pixelSize / 2
                horizontalAlignment: Text.AlignLeft
                font: Style.extraSmallFont
                color: Style.colors.typography_Basic_Secondary
                text: Math.round(yAxisRight.max - index * (yAxisRight.max - yAxisRight.min) / (root._yLabelCount - 1)) + "%"
            }
        }
    }

    // -- Position the day-boundary marker lines --
    function _updateDayBoundaries() {
        var boundaries = root._dayBoundariesInRange(root._visibleStartTime, root._visibleStartTime + root._visibleWindowMs)
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

    Connections {
        target: root
        function on_VisibleStartTimeChanged() { root._updateDayBoundaries() }
        function on_VisibleWindowMsChanged() { root._updateDayBoundaries() }
    }

    // -- Pinch (zoom, 6h..24h clamp) and drag (pan) gesture handling --
    PinchHandler {
        id: pinchHandler
        target: null
        minimumPointCount: 2
        maximumPointCount: 2

        property real _startWindowMs
        property real _startStartTime
        property real _pivotFraction

        onActiveChanged: {
            if (active) {
                _startWindowMs = root._visibleWindowMs
                _startStartTime = root._visibleStartTime
                _pivotFraction = root._clamp((centroid.position.x - chartView.plotArea.x) / chartView.plotArea.width, 0, 1)
            } else {
                rangeSettleTimer.restart()
            }
        }

        onScaleChanged: {
            if (!active)
                return
            var newWindow = root._clamp(_startWindowMs / scale, root._minWindowMs, root._maxWindowMs)
            var timeAtPivot = _startStartTime + _pivotFraction * _startWindowMs
            root._visibleWindowMs = newWindow
            root._visibleStartTime = timeAtPivot - _pivotFraction * newWindow
        }
    }

    DragHandler {
        id: dragHandler
        target: null
        minimumPointCount: 1
        maximumPointCount: 1

        property real _startStartTime

        onActiveChanged: {
            if (active) {
                _startStartTime = root._visibleStartTime
            } else {
                rangeSettleTimer.restart()
            }
        }

        onTranslationChanged: {
            if (!active)
                return
            var deltaMs = -(translation.x / chartView.plotArea.width) * root._visibleWindowMs
            root._visibleStartTime = _startStartTime + deltaMs
        }
    }

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
