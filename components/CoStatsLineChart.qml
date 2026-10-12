import QtQuick
import QtQuick.Controls
import QtCharts
import Nymea
import NymeaApp.Utils

import "../utils/DateUtils.js" as DateUtils

// CoStatsLineChart
//
// A multi-line chart for the statistics page. Shows a left kW y-axis (auto
// scaled to "nice" round numbers with 5 labels) and an optional right
// percentage y-axis (fixed 0-100%, 5 labels). The visible x-axis window can
// be zoomed (pinch) between 3h and 24h and panned (drag). Vertical light-grey
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

    // Timestamp (epoch ms) currently "pinned" by an open tooltip, in
    // milliseconds - drives the vertical highlight line/intersection
    // circles below (see "d.selectedXPixel()"/"d.selectedPoints()").
    // -1 means "no selection". Set internally by the tap MouseArea below;
    // the caller resets it back to -1 once the shared tooltip closes or a
    // different chart's tooltip opens instead - mirrors
    // "selectedCategoryIndex" on CoStatsBarChart.
    property double selectedTimestampMs: -1

    readonly property date visibleDay: new Date(d.visibleStartTime + d.visibleWindowMs / 2)

    // Bounding box of the plot area (excluding axis labels/margins), in this
    // Item's own coordinate space - see the identical property on
    // CoStatsBarChart for why no extra coordinate mapping is needed.
    readonly property alias plotArea: chartView.plotArea

    signal visibleRangeChanged(date startTime, date endTime)

    // Emitted when the user taps/clicks a point on the chart (for the
    // caller's tooltip). "timestamp" is the tapped x position converted back
    // to a time via the current visible window (not snapped to any actual
    // data sample - the caller is expected to look up the nearest sample
    // per series itself, the same way it already extracts values via each
    // series' own "model"/"valueFunction"). "anchorRect" is a thin vertical
    // slice at the tapped x position, spanning the full plot height, in
    // this Item's own coordinate space (see "plotArea" above).
    signal pointSelected(date timestamp, rect anchorRect)

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

        readonly property int maxSeriesCount: 20

        // Highest slot index actually populated by the previous
        // "rebuildAll()" call (see there) - lets that function skip the
        // fixed 20 slots entirely once "root.series" is shorter (the
        // common case; see its own comment), while still clearing any
        // now-unused slots left over from a previous, longer "root.series"
        // array (e.g. switching tabs).
        property int lastSeriesCount: 0

        // Per-slot cache of what's currently rendered in that slot's
        // LineSeries pair, used by rebuild() to incrementally update
        // (rather than clear()+fully re-append) when the new visible
        // window overlaps the previously rendered one - see rebuild()'s
        // own comment. Each entry is either undefined/null (no valid cached
        // state - forces a full rebuild) or { model, lowIdx, highIdx,
        // count }: "model" is the exact model reference last rendered (an
        // incremental update is only valid against the *same* model
        // instance), "lowIdx"/"highIdx" is the model index range [lowIdx,
        // highIdx) last rendered, and "count" is the series' actual point
        // count right after that render - compared against
        // (highIdx - lowIdx) to detect whether any index in that range was
        // skipped (model.get() returning a falsy entry), which would
        // invalidate the 1:1 index-to-series-position mapping the
        // incremental path depends on.
        property var slotRenderState: []
        readonly property real hourMs: 3600000
        readonly property real dayMs: 24 * hourMs
        readonly property real minWindowMs: 3 * hourMs
        readonly property real maxWindowMs: 24 * hourMs
        readonly property int yLabelCount: 5

        // Tracks whether "resetToSelectedDay()" has run at least once. The
        // very first call (from Component.onCompleted) must always run to
        // completion - including the "rangeSettleTimer.restart()" that
        // triggers the page's initial data fetch - even though
        // "visibleStartTime"'s initializer below already matches
        // "selectedDay" (so the isSameDay-based skip in
        // "resetToSelectedDay()" would otherwise short-circuit it).
        property bool initialResetDone: false

        // Initialized from "root.selectedDay" (not a literal 0/epoch)
        // so "visibleDay" never transiently reports an epoch date before
        // "resetToSelectedDay()" runs on Component.onCompleted - such a
        // transient value could otherwise get propagated out (e.g. via a
        // page's onVisibleDayChanged handler) before being corrected,
        // causing spurious clamping against external date bounds.
        property real visibleStartTime: {
            var dt = new Date(root.selectedDay)
            dt.setHours(0, 0, 0, 0)
            return dt.getTime()
        }
        property real visibleWindowMs: maxWindowMs

        // Copy of the above two, but only updated once "rangeSettleTimer"
        // fires (i.e. the same, debounced cadence the data-fetch trigger
        // uses - see rangeSettleTimer below), not on every live drag/pinch
        // frame. Used by "maxLeftValue()"'s y-axis range scan instead of
        // the live values above: that scan is deliberately windowed for
        // performance (see its own comment), but if it tracked the live,
        // continuously-shifting visible window directly, the y-axis would
        // visibly rescale on every single pan/zoom frame instead of
        // staying stable while scrolling through already-loaded data -
        // which is exactly the kind of jitter "maxLeftValue()" already
        // avoids for legend-pill toggles (see its "ignores desc.visible"
        // comment) and should equally avoid here.
        property real settledStartTime: visibleStartTime
        property real settledWindowMs: visibleWindowMs

        // Reserved ChartView margins, sized via FontMetrics for the custom
        // axis label overlays below. ChartView's own plotArea auto-sizing
        // (with labelsVisible: false on all axes) is not reliable across
        // platforms/fonts - it left far too little room in some
        // environments, causing the label overlays to render outside the
        // chart bounds. Reserving explicit margins on the ChartView itself
        // guarantees the plotArea always leaves enough room for them.
        //
        // Note: axisFontMetrics.advanceWidth() is a *method call*, not a
        // property read. QML only re-evaluates a binding when a property it
        // read changes - a method call by itself creates no such dependency.
        // Without the "axisFontMetrics.font," part below, this binding would
        // only ever run once (with whatever font was active at that exact
        // moment, e.g. a fallback font before "DM Sans" finished loading)
        // and then never update again, even after the font changes - which
        // is exactly the bug we hit (leftAxisReserve stayed "frozen" at a
        // too-large value). Reading "axisFontMetrics.font" first (a real,
        // notifying property) and discarding it via the comma operator
        // forces this binding to depend on the font and re-run whenever it
        // changes, while still evaluating to the advanceWidth() result.
        readonly property real leftAxisReserve: (axisFontMetrics.font, axisFontMetrics.advanceWidth("999.9")) + Style.extraSmallMargins
        readonly property real rightAxisReserve: root.percentAxisVisible ? ((axisFontMetrics.font, axisFontMetrics.advanceWidth("100%")) + Style.smallMargins) : Style.smallMargins
        readonly property real xLabelsHeight: axisFontMetrics.height * 2 + 2
        readonly property real bottomAxisReserve: xLabelsHeight + Style.margins
        readonly property real topAxisReserve: Style.margins + axisFontMetrics.height + Style.extraSmallMargins * 2

        // Returns every root.series descriptor *except* the (at most one)
        // right-axis one - this is the list the "dataSeriesN"/
        // "dataBorderSeriesN" fixed-slot pool below is indexed against.
        // The right-axis descriptor (currently always Battery SoC, if any)
        // is deliberately excluded and handled through its own dedicated,
        // never-reassigned series instead - see "batterySocSeries"'s
        // declaration in the ChartView above for why.
        function leftAxisDescriptors() {
            var result = []
            for (var i = 0; i < root.series.length; i++) {
                var desc = root.series[i]
                if (desc && desc.axis !== "right") {
                    result.push(desc)
                }
            }
            return result
        }

        // The single right-axis descriptor in root.series, if any (there is
        // currently never more than one - see "batterySocSeries"'s
        // declaration in the ChartView above).
        function rightAxisDescriptor() {
            for (var i = 0; i < root.series.length; i++) {
                var desc = root.series[i]
                if (desc && desc.axis === "right") {
                    return desc
                }
            }
            return null
        }

        function seriesDescriptor(index) {
            var list = d.leftAxisDescriptors()
            return index < list.length ? list[index] : null
        }

        function clamp(value, min, max) {
            return Math.max(min, Math.min(max, value))
        }

        // Timestamp (epoch ms) of the most recent sample actually available
        // right now, across every distinct model referenced by "root.series"
        // - i.e. the real right-hand data boundary, as opposed to
        // "d.visibleStartTime + d.visibleWindowMs" (the visible *window*,
        // which for "today" extends well past "now" into not-yet-recorded
        // future time). Returns -1 if no series has any data yet (e.g.
        // still loading), in which case callers should fall back to the
        // full visible window instead of clamping to nothing.
        //
        // Takes the *minimum* across models rather than the max: several
        // series can be backed by different models (e.g. one per consumer
        // Thing in the Consumption tab), and if one of them lags slightly
        // behind the others, clamping to the single earliest common cutoff
        // guarantees every currently visible series still has a sample at
        // the clamped timestamp - exactly the bug this avoids (see
        // "selectedPoints()" above, which drops a series entirely once
        // "model.indexOf()" can't find a sample close enough).
        function latestAvailableTimestampMs() {
            var latest = -1
            var seenModels = []
            for (var i = 0; i < root.series.length; i++) {
                var desc = root.series[i]
                if (!desc || desc.visible === false || !desc.model) {
                    continue
                }
                var model = desc.model
                if (seenModels.indexOf(model) !== -1) {
                    continue
                }
                seenModels.push(model)
                if (typeof model.count !== "number" || model.count <= 0) {
                    continue
                }
                var lastEntry = model.get(model.count - 1)
                if (!lastEntry || !lastEntry.timestamp) {
                    continue
                }
                var ts = lastEntry.timestamp.getTime()
                if (latest < 0 || ts < latest) {
                    latest = ts
                }
            }
            return latest
        }

        // Upper bound for "root.selectedTimestampMs": the smaller of the
        // visible window's own end and the real data boundary above - see
        // "latestAvailableTimestampMs()".
        function selectedTimestampMaxMs() {
            var windowEnd = d.visibleStartTime + d.visibleWindowMs
            var dataEnd = d.latestAvailableTimestampMs()
            return dataEnd < 0 ? windowEnd : Math.min(windowEnd, dataEnd)
        }

        // Pixel x-position (in this Item's own coordinate space) of
        // "root.selectedTimestampMs", or -1 if nothing is selected/the
        // chart has no plot area yet. Uses the same time-fraction math as
        // the tap MouseArea below (in reverse), so the highlight always
        // lines up exactly with what a click at that pixel would report.
        function selectedXPixel() {
            if (root.selectedTimestampMs < 0) {
                return -1
            }
            var plotArea = chartView.plotArea
            if (plotArea.width <= 0) {
                return -1
            }
            var fraction = d.clamp((root.selectedTimestampMs - d.visibleStartTime) / d.visibleWindowMs, 0, 1)
            return plotArea.x + fraction * plotArea.width
        }

        // One {x, y, color, borderColor} entry per visible series that has
        // a sample near "root.selectedTimestampMs", in this Item's own
        // coordinate space - used to draw the intersection circles at the
        // selected timestamp (see below). Mirrors CoStatsView's
        // "d.showLineChartTooltip" value lookup (same nearest-neighbour
        // "model.indexOf"/"valueFunction" shape) since it needs the same
        // per-series values, just converted to pixels instead of text.
        function selectedPoints() {
            var xPixel = d.selectedXPixel()
            if (xPixel < 0) {
                return []
            }
            var points = []
            for (var i = 0; i < root.series.length; i++) {
                var desc = root.series[i]
                if (!desc || desc.visible === false || !desc.model || !desc.valueFunction) {
                    continue
                }
                var model = desc.model
                if (typeof model.indexOf !== "function") {
                    continue
                }
                var idx = model.indexOf(new Date(root.selectedTimestampMs))
                if (idx < 0) {
                    continue
                }
                var entry = model.get(idx)
                if (!entry) {
                    continue
                }
                var value = desc.valueFunction(entry)
                if (value === undefined || value === null) {
                    continue
                }
                var axis = desc.axis === "right" ? yAxisRight : yAxisLeft
                if (!axis) {
                    // Defensive only: yAxisRight's own "visible" is now kept
                    // permanently true specifically to avoid it ever
                    // becoming null (see its declaration above for why) -
                    // this guard is just cheap insurance against that
                    // changing again in the future.
                    continue
                }
                var range = axis.max - axis.min
                if (range <= 0) {
                    continue
                }
                var yFraction = d.clamp((value - axis.min) / range, 0, 1)
                var plotArea = chartView.plotArea
                points.push({
                    x: xPixel,
                    y: plotArea.y + plotArea.height * (1 - yFraction),
                    color: desc.color,
                    borderColor: desc.borderColor ? desc.borderColor : desc.color
                })
            }
            return points
        }

        // "Nice numbers" axis calculation: rounds the per-label step up to
        // the next value in a widened set of round fractions so that 5
        // evenly spaced labels are as round as possible while never
        // clipping the data.
        function niceStep(rawStep) {
            if (rawStep <= 0) {
                return 1
            }
            var exponent = Math.floor(Math.log(rawStep) / Math.LN10)
            var base = Math.pow(10, exponent)
            var fraction = rawStep / base
            var niceFractions = [1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10]
            for (var i = 0; i < niceFractions.length; i++) {
                if (fraction <= niceFractions[i] + 1e-9) {
                    return niceFractions[i] * base
                }
            }
            return 10 * base
        }

        function maxLeftValue() {
            // Deliberately ignores "desc.visible" here: the y-axis range
            // must stay stable when the user toggles series on/off via the
            // legend pills, otherwise the chart would visibly rescale on
            // every click, which is jarring and makes it harder to compare
            // line heights across toggles. (Mirrors the same fix in
            // CoStatsBarChart.qml's maxStackedValue().)
            var max = 0
            for (var i = 0; i < root.series.length; i++) {
                var desc = root.series[i]
                if (!desc || desc.axis === "right" || !desc.model) {
                    continue
                }
                var model = desc.model
                var count = model.count !== undefined ? model.count : 0

                // Windowed similarly to rebuild() (see its comment): without
                // this, every rebuild re-scanned the model's *entire* cache -
                // up to ~20x the visible window, see EnergyLogs::trimCache()
                // - instead of just what's on screen. That cost grows
                // unbounded with cache size as a session goes on (more
                // days/zoom levels visited), causing increasingly long pan/
                // zoom stalls over time.
                //
                // Uses the *settled* window (d.settledStartTime/Ms), not the
                // live d.visibleStartTime/d.visibleWindowMs rebuild() itself
                // uses: unlike the series' actual plotted points, the y-axis
                // range is deliberately stabilized against the live drag
                // position too (see "ignores desc.visible" above) - using
                // the live, continuously-shifting window here would rescale
                // the axis on every single pan/zoom frame instead of only
                // once a gesture settles.
                var startIndex = 0
                var endIndex = count
                if (typeof model.indexOf === "function") {
                    var rangeStart = d.settledStartTime
                    var rangeEnd = d.settledStartTime + d.settledWindowMs
                    var lowIdx = model.indexOf(new Date(rangeStart))
                    var highIdx = model.indexOf(new Date(rangeEnd))
                    startIndex = lowIdx >= 0 ? Math.max(0, lowIdx - 1) : 0
                    endIndex = highIdx >= 0 ? Math.min(count, highIdx + 2) : count
                }
                for (var j = startIndex; j < endIndex; j++) {
                    var entry = model.get(j)
                    if (!entry) {
                        continue
                    }
                    var v = desc.valueFunction(entry)
                    if (v > max) {
                        max = v
                    }
                }
            }
            return max
        }

        function updateLeftAxisRange() {
            var intervals = d.yLabelCount - 1
            var maxValue = d.maxLeftValue()
            if (maxValue <= 0) {
                maxValue = intervals
            }
            var step = d.niceStep(maxValue / intervals)
            yAxisLeft.max = step * intervals
        }

        function resetToSelectedDay() {
            // "selectedDay" also changes as a side effect of panning across
            // a day boundary while zoomed in: CoStatsView syncs the newly
            // crossed-into day back to the period selector, which in turn
            // re-assigns this same day to "selectedDay". In that case the
            // chart is already showing (part of) that day - actually
            // resetting to a full 24h window here would undo the user's
            // zoom/pan on every day crossing. Only perform the actual jump
            // (full day, reset zoom) when "selectedDay" refers to a
            // genuinely different day than what's currently visible (i.e.
            // an external "jump to this day" request, e.g. from the date
            // picker). The very first call (Component.onCompleted) is
            // exempt from this check - see "initialResetDone" above - so
            // the initial data fetch always happens even though
            // "visibleStartTime"'s initializer already matches
            // "selectedDay".
            if (d.initialResetDone && DateUtils.isSameDay(root.selectedDay, root.visibleDay)) {
                return
            }
            d.initialResetDone = true

            var dt = new Date(root.selectedDay)
            dt.setHours(0, 0, 0, 0)
            d.visibleStartTime = dt.getTime()
            d.visibleWindowMs = d.maxWindowMs
            // Needed explicitly here: unlike the old direct Repeater
            // bindings (always eager-evaluated on creation), the cached
            // "xTickTimestamps"/"dayNoonTimestamps" (see their doc comment)
            // are only refreshed reactively on a "visibleStartTime"/
            // "visibleWindowMs" *change* - which doesn't fire on this very
            // first call, since both properties' initializers already
            // match the values assigned above.
            d.updateAxisLabels()
            d.updateLeftAxisRange()
            rangeSettleTimer.restart()
        }

        function dayBoundariesInRange(startMs, endMs) {
            var result = []
            var dt = new Date(startMs)
            dt.setHours(0, 0, 0, 0)
            if (dt.getTime() < startMs) {
                dt.setDate(dt.getDate() + 1)
            }
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
            if (dt.getTime() < startMs) {
                dt.setDate(dt.getDate() + 1)
            }
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
                if (candidates[i] <= target) {
                    step = candidates[i]
                } else {
                    break
                }
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
            while (t < startMs) {
                t += stepMs
            }
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

        // Cached x-axis label tick positions, refreshed (together with the
        // day-noon labels below) only by "requestRebuild()"'s throttle - see
        // its doc comment. The two label Repeaters bind their "model" to
        // these instead of calling "xTicksInRange()"/"dayNoonsInRange()"
        // directly: a direct binding re-evaluates (and returns a brand new
        // array) on every single visibleStartTime/visibleWindowMs change,
        // which QML's Repeater treats as a brand new model - destroying and
        // recreating every Label delegate (including the comparatively
        // expensive toLocaleDateString()/standaloneMonthName() calls in the
        // day-noon delegate) at the gesture's raw event rate instead of the
        // throttled rate.
        property var xTickTimestamps: []
        property var dayNoonTimestamps: []

        function updateAxisLabels() {
            d.xTickTimestamps = d.xTicksInRange(d.visibleStartTime, d.visibleStartTime + d.visibleWindowMs, d.niceHourStep(d.visibleWindowMs / d.hourMs))
            d.dayNoonTimestamps = d.dayNoonsInRange(d.visibleStartTime, d.visibleStartTime + d.visibleWindowMs)
        }

        // Set while a pan/pinch gesture (or anything else rapidly touching
        // visibleStartTime/visibleWindowMs) has produced a newer value than
        // the one "rebuildThrottleTimer" last rendered - see
        // "requestRebuild()" below.
        property bool rebuildPending: false

        // Leading+trailing throttle around "updateDayBoundaries()" +
        // "seriesBinder.rebuildAll()" + "updateAxisLabels()": without this,
        // every single visibleStartTime/visibleWindowMs change during a
        // drag/pinch gesture (potentially once per pixel/frame) triggered a
        // full series clear()+append(), day-boundary rebuild and axis-label
        // Repeater rebuild, which caused janky pan/zoom on lower-end
        // hardware (see onVisibleStartTimeChanged/onVisibleWindowMsChanged
        // below). The first change in a burst is still applied immediately
        // (so the chart doesn't feel laggy to start reacting), but any
        // further changes within "rebuildThrottleTimer.interval" are
        // coalesced into a single trailing update once that interval
        // elapses - capping the rebuild rate to roughly that timer's
        // frequency instead of the gesture's raw event rate. This does NOT
        // affect the ChartView axes themselves (bound directly to
        // visibleStartTime/visibleWindowMs, see their min/max below) -
        // those stay perfectly live every frame; only the comparatively
        // expensive series/day-boundary/axis-label rebuilds are throttled.
        function requestRebuild() {
            if (rebuildThrottleTimer.running) {
                d.rebuildPending = true
                return
            }
            d.updateDayBoundaries()
            d.updateAxisLabels()
            seriesBinder.rebuildAll()
            rebuildThrottleTimer.start()
        }
    }

    // See "requestRebuild()" above. ~60fps cap (16ms) on the rebuild rate.
    Timer {
        id: rebuildThrottleTimer
        interval: 16
        repeat: false
        onTriggered: {
            if (d.rebuildPending) {
                d.rebuildPending = false
                d.updateDayBoundaries()
                d.updateAxisLabels()
                seriesBinder.rebuildAll()
                rebuildThrottleTimer.start()
            }
        }
    }

    // Debounce visibleRangeChanged so pan/zoom gestures don't flood
    // listeners (e.g. a page that triggers a data (re)fetch on this
    // signal). Re-rendering the already-cached data for the settled window
    // itself does NOT wait for this timer - see the "onVisibleStartTimeChanged
    // / onVisibleWindowMsChanged" Connections below.
    Timer {
        id: rangeSettleTimer
        interval: 200
        onTriggered: {
            d.settledStartTime = d.visibleStartTime
            d.settledWindowMs = d.visibleWindowMs
            root.visibleRangeChanged(new Date(d.visibleStartTime), new Date(d.visibleStartTime + d.visibleWindowMs))
        }
    }

    FontMetrics {
        id: axisFontMetrics
        font: Style.newExtraSmallFont
    }

    Connections {
        target: d
        function onVisibleStartTimeChanged() { d.requestRebuild() }
        function onVisibleWindowMsChanged() { d.requestRebuild() }
    }

    Item {
        id: chartContainer
        anchors.fill: parent
        opacity: root.loading ? Style.numbers.components_Disabled_opacity : 1

        ChartView {
            id: chartView
            anchors.fill: parent
            // Qt Charts renders its own opaque background (per the current
            // theme) as a separate graphics item - it does not pick up the
            // color of any surrounding QML Rectangle, so it must be set
            // explicitly here to track the app's light/dark style.
            backgroundColor: Style.colors.typography_Background_Default
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
                // Always "visible" (deliberately NOT bound to
                // root.percentAxisVisible) - this axis already draws nothing
                // of its own (labels/grid/line are all disabled above; the
                // actual right-axis appearance is the separate
                // "yRightLabelsLayout" Repeater and "d.rightAxisReserve"
                // margin further below, both independently keyed off
                // root.percentAxisVisible), so toggling *this* property adds
                // no visual benefit. It used to be bound to
                // root.percentAxisVisible, but that hit a known QtCharts QML
                // bug: once a ValueAxis's own "visible" is toggled
                // false -> true, the underlying axis object can remain
                // permanently detached ("null" from QML's point of view,
                // see the now-mostly-historical guards below) instead of
                // reappearing - which is exactly what caused the right axis
                // to never actually render once Battery SoC data made
                // percentAxisVisible true, plus "Trying to set axisY to
                // null." warnings whenever a series bound to this axis had
                // its own visibility toggled. Keeping this permanently true
                // avoids the bug entirely.
                visible: true
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
                color: Style.colors.components_Statistics_Grid
                width: 1
                visible: false
            }
            LineSeries {
                id: dayBoundarySeries1
                axisX: xAxis
                axisY: yAxisLeft
                color: Style.colors.components_Statistics_Grid
                width: 1
                visible: false
            }

            // -- Border "underlay" slots (see "dataSeriesN" below): drawn
            // first (rendered underneath, in QtCharts' declaration-order
            // z-stacking - like all series in this file) at 3px, in each
            // series' "borderColor", with the actual 1px-wide data line
            // painted directly on top of it - faking the outlined-line look
            // from Figma, which QtCharts' LineSeries has no native stroke/
            // border support for. Kept as a fully separate, parallel set of
            // fixed slots (rather than e.g. reusing "dataSeriesN" with some
            // toggle) to keep "seriesBinder" simple: every function below
            // just updates both of a pair's slots identically, give or take
            // width/color.
            LineSeries { id: dataBorderSeries0; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries1; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries2; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries3; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries4; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries5; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries6; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries7; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries8; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries9; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries10; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries11; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries12; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries13; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries14; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries15; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries16; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries17; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries18; axisX: xAxis; width: 3 }
            LineSeries { id: dataBorderSeries19; axisX: xAxis; width: 3 }

            // -- Fixed data-series slots, bound to root.series[i] --
            LineSeries { id: dataSeries0; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries1; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries2; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries3; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries4; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries5; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries6; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries7; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries8; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries9; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries10; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries11; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries12; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries13; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries14; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries15; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries16; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries17; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries18; axisX: xAxis; width: 1 }
            LineSeries { id: dataSeries19; axisX: xAxis; width: 1 }

            // -- Dedicated right-axis series (currently always Battery SoC,
            // if any - see "d.rightAxisDescriptor()" below) --
            //
            // Deliberately NOT part of the "dataSeriesN"/"dataBorderSeriesN"
            // pool above: those slots are reused across tabs for whatever
            // descriptor ends up at their index in "root.series", which
            // meant a slot could switch between axisY: yAxisLeft (e.g. on
            // the Consumption tab) and axisY: yAxisRight (on the Energy
            // Balance tab) depending on which tab/descriptor currently
            // occupies it. Reassigning an already-attached series to a
            // *different* axis at runtime is a known QtCharts QML
            // limitation - the series keeps rendering against its old
            // axis's range even though the "axisY" property itself updates
            // correctly (this is exactly what caused the Battery SoC line
            // to render flat-clipped at the left axis' max). Since there is
            // only ever at most one right-axis series in this app, it gets
            // its own reserved slot instead, with "axisY: yAxisRight"
            // statically declared once and never reassigned - avoiding the
            // bug entirely rather than working around it.
            LineSeries { id: batterySocSeries; axisX: xAxis; axisY: yAxisRight; width: 1 }
            LineSeries { id: batterySocBorderSeries; axisX: xAxis; axisY: yAxisRight; width: 3 }
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
                case 8: return dataSeries8
                case 9: return dataSeries9
                case 10: return dataSeries10
                case 11: return dataSeries11
                case 12: return dataSeries12
                case 13: return dataSeries13
                case 14: return dataSeries14
                case 15: return dataSeries15
                case 16: return dataSeries16
                case 17: return dataSeries17
                case 18: return dataSeries18
                case 19: return dataSeries19
                }
                return null
            }

            // Counterpart to "slot()" above - the wider, "borderColor"-
            // painted underlay slot for the same index (see its doc
            // comment in the ChartView above).
            function borderSlot(index) {
                switch (index) {
                case 0: return dataBorderSeries0
                case 1: return dataBorderSeries1
                case 2: return dataBorderSeries2
                case 3: return dataBorderSeries3
                case 4: return dataBorderSeries4
                case 5: return dataBorderSeries5
                case 6: return dataBorderSeries6
                case 7: return dataBorderSeries7
                case 8: return dataBorderSeries8
                case 9: return dataBorderSeries9
                case 10: return dataBorderSeries10
                case 11: return dataBorderSeries11
                case 12: return dataBorderSeries12
                case 13: return dataBorderSeries13
                case 14: return dataBorderSeries14
                case 15: return dataBorderSeries15
                case 16: return dataBorderSeries16
                case 17: return dataBorderSeries17
                case 18: return dataBorderSeries18
                case 19: return dataBorderSeries19
                }
                return null
            }

            function rebuild(index, updateAxis) {
                rebuildSeries(slot(index), borderSlot(index), d.seriesDescriptor(index), index, updateAxis)
            }

            // Same as rebuild(), but for the dedicated right-axis series
            // (see "batterySocSeries"'s declaration in the ChartView above)
            // instead of one of the by-index "dataSeriesN" slots. Uses
            // "d.maxSeriesCount" (one past the last real index, 0..19) as
            // its own reserved "slotRenderState"/cache key so it can never
            // collide with an actual indexed slot's cached render state.
            function rebuildRightAxisSeries(updateAxis) {
                rebuildSeries(batterySocSeries, batterySocBorderSeries, d.rightAxisDescriptor(), d.maxSeriesCount, updateAxis)
            }

            // Core of rebuild()/rebuildRightAxisSeries() above: renders
            // "desc" (if any) into the given main/border series pair,
            // caching its render state under "cacheKey" for the next call's
            // incremental-diff decision (see "canIncrement" below).
            function rebuildSeries(s, b, desc, cacheKey, updateAxis) {
                if (updateAxis === undefined) {
                    updateAxis = true
                }
                if (!s) {
                    return
                }
                if (!desc || !desc.model) {
                    s.clear()
                    if (b) {
                        b.clear()
                    }
                    d.slotRenderState[cacheKey] = null
                    if (updateAxis) {
                        d.updateLeftAxisRange()
                    }
                    return
                }
                var model = desc.model
                var fn = desc.valueFunction
                var count = model.count !== undefined ? model.count : 0

                // Only append entries within the chart's currently visible
                // window (+ a one-entry buffer on each side, for the line
                // to extend cleanly to the plot edges) - "count" alone is
                // not a safe iteration bound: the underlying EnergyLogs
                // model intentionally retains up to ~20x the visible
                // window's worth of cached entries (see
                // EnergyLogs::trimCache() in the nymea-app submodule) so
                // panning/zooming stays refetch-free. Iterating that whole
                // cache on every rebuild() - which runs on every legend-
                // pill toggle/tab switch, not just when the visible window
                // itself changes - caused multi-second UI freezes once a
                // user had navigated across enough days in one session for
                // the cache to fill up.
                var startIndex = 0
                var endIndex = count
                if (typeof model.indexOf === "function") {
                    var rangeStart = d.visibleStartTime
                    var rangeEnd = d.visibleStartTime + d.visibleWindowMs
                    var lowIdx = model.indexOf(new Date(rangeStart))
                    var highIdx = model.indexOf(new Date(rangeEnd))
                    // indexOf() is a nearest-neighbour lookup (only -1 when
                    // the target is fully outside the loaded range) -
                    // widen by one entry on each side so a near-but-not-
                    // exact boundary match never clips an actually-visible
                    // point.
                    startIndex = lowIdx >= 0 ? Math.max(0, lowIdx - 1) : 0
                    endIndex = highIdx >= 0 ? Math.min(count, highIdx + 2) : count
                }

                // Every pan/zoom frame re-renders this slot via rebuildAll(),
                // and the new window very often overlaps the previously
                // rendered one substantially (e.g. a drag only shifts it by
                // a few pixels/entries). Previously this always did a full
                // clear() + re-append() of every visible point regardless,
                // which dominated this chart's cost on every single
                // throttled frame. Diff against the last rendered range instead and only
                // remove/insert/append the entries that actually scrolled
                // out of/into view - falling back to the full rebuild below
                // whenever that's not safely possible (different model,
                // no cached state yet, no overlap with the new window, or
                // the previous render's point count doesn't match its index
                // range - see slotRenderState's own doc comment for why
                // that last check matters).
                var prevState = d.slotRenderState[cacheKey]
                var canIncrement = !!prevState
                        && prevState.model === model
                        && prevState.count === (prevState.highIdx - prevState.lowIdx)
                        && startIndex < prevState.highIdx && endIndex > prevState.lowIdx

                if (canIncrement) {
                    seriesBinder.incrementalRebuildSlot(s, b, model, fn, prevState.lowIdx, prevState.highIdx, startIndex, endIndex)
                } else {
                    s.clear()
                    if (b) {
                        b.clear()
                    }
                    for (var i = startIndex; i < endIndex; i++) {
                        var entry = model.get(i)
                        if (!entry) {
                            continue
                        }
                        var t = entry.timestamp instanceof Date ? entry.timestamp.getTime() : entry.timestamp
                        var v = fn(entry)
                        s.append(t, v)
                        if (b) {
                            b.append(t, v)
                        }
                    }
                }

                d.slotRenderState[cacheKey] = { model: model, lowIdx: startIndex, highIdx: endIndex, count: s.count }
                if (updateAxis) {
                    d.updateLeftAxisRange()
                }
            }

            // Incrementally updates an already-rendered slot by diffing its
            // previously rendered model-index window [prevLow, prevHigh)
            // against the new one [newLow, newHigh), instead of clear()+
            // fully re-appending every point (see rebuild()'s own comment
            // for when this is/isn't safe to call). Assumes "s"/"b"
            // currently hold exactly one point per model index in
            // [prevLow, prevHigh), in the same order.
            function incrementalRebuildSlot(s, b, model, fn, prevLow, prevHigh, newLow, newHigh) {
                var overlapStart = Math.max(prevLow, newLow)
                var overlapEnd = Math.min(prevHigh, newHigh)

                // Drop points that scrolled out of view at the front (model
                // indices below "overlapStart") - these sit at the start of
                // the series, at positions [0, frontRemoveCount).
                var frontRemoveCount = overlapStart - prevLow
                if (frontRemoveCount > 0) {
                    s.removePoints(0, frontRemoveCount)
                    if (b) {
                        b.removePoints(0, frontRemoveCount)
                    }
                }
                // Drop points that scrolled out of view at the back (model
                // indices at/above "overlapEnd") - these now sit at the end
                // of the already front-trimmed series.
                var backRemoveCount = prevHigh - overlapEnd
                if (backRemoveCount > 0) {
                    var tailStart = s.count - backRemoveCount
                    s.removePoints(tailStart, backRemoveCount)
                    if (b) {
                        b.removePoints(tailStart, backRemoveCount)
                    }
                }

                // Insert newly-visible points before the current front, in
                // chronological order - inserting at a steadily increasing
                // position (rather than always at 0) keeps them in order:
                // each insert only pushes the *already-inserted* new points
                // (and the untouched old ones after them) back by one.
                var insertPos = 0
                for (var i = newLow; i < overlapStart; i++) {
                    var frontEntry = model.get(i)
                    if (!frontEntry) {
                        continue
                    }
                    var ft = frontEntry.timestamp instanceof Date ? frontEntry.timestamp.getTime() : frontEntry.timestamp
                    var fv = fn(frontEntry)
                    s.insert(insertPos, ft, fv)
                    if (b) {
                        b.insert(insertPos, ft, fv)
                    }
                    insertPos++
                }

                // Append newly-visible points after the current back.
                for (var j = overlapEnd; j < newHigh; j++) {
                    var backEntry = model.get(j)
                    if (!backEntry) {
                        continue
                    }
                    var bt = backEntry.timestamp instanceof Date ? backEntry.timestamp.getTime() : backEntry.timestamp
                    var bv = fn(backEntry)
                    s.append(bt, bv)
                    if (b) {
                        b.append(bt, bv)
                    }
                }
            }


            // Re-renders every fixed slot for the chart's current visible
            // window. Needed in addition to the per-model
            // entriesAddedIdx/entriesRemoved/countChanged triggers below:
            // those only fire when the underlying EnergyLogs model actually
            // receives new data. Panning/zooming to a window that's already
            // fully covered by the model's existing cache (e.g. scrolling
            // back into a range visited earlier in the session, then
            // forward again) never touches the model at all, so without
            // this, rebuild()'s windowed iteration (bounded by
            // d.visibleStartTime/d.visibleWindowMs, see rebuild() above)
            // would keep showing whatever window was rendered last instead
            // of the new one.
            //
            // Called directly (unthrottled) on every
            // visibleStartTime/visibleWindowMs change - not debounced like
            // the data-fetch trigger in rangeSettleTimer - so the line keeps
            // up continuously while panning/zooming instead of only
            // catching up once the gesture settles. This stays cheap
            // because rebuild() itself is already bounded to the visible
            // window rather than the (much larger) cached range.
            //
            // Each rebuild(i, false) call skips its own axis-range update
            // (see rebuild()'s "updateAxis" parameter) - recomputing it
            // once after the loop instead keeps axis-range work at the
            // same O(series count) cost as the rest of this function,
            // instead of O(series count squared).
            function rebuildAll() {
                // "root.series" is almost always far shorter than the fixed
                // d.maxSeriesCount (20) slots reserved in the ChartView
                // above (e.g. a handful of energy-balance/consumption
                // series, not 20) - looping to the full 20 regardless of
                // how many are actually in use wasted a switch-case lookup
                // + two LineSeries.clear() calls per unused slot on every
                // single throttled pan/zoom frame. Clamping to the actual
                // count removes that dead work in the common case.
                //
                // Uses "leftAxisDescriptors()", not "root.series.length"
                // directly: the (at most one) right-axis descriptor isn't
                // one of these by-index slots (see "batterySocSeries" in
                // the ChartView above) and must not consume/shift one.
                var count = Math.min(d.maxSeriesCount, d.leftAxisDescriptors().length)
                for (var i = 0; i < count; i++) {
                    rebuild(i, false)
                }
                rebuildRightAxisSeries(false)
                // Slots between the current and previous series count are
                // stale (still showing data from a longer "root.series"
                // array used before, e.g. before switching tabs) and need
                // clearing exactly once - not every call, since
                // "d.lastSeriesCount" collapses down to "count" right after.
                for (var j = count; j < d.lastSeriesCount; j++) {
                    var staleSlot = slot(j)
                    var staleBorderSlot = borderSlot(j)
                    if (staleSlot) {
                        staleSlot.clear()
                    }
                    if (staleBorderSlot) {
                        staleBorderSlot.clear()
                    }
                    d.slotRenderState[j] = null
                }
                d.lastSeriesCount = count
                d.updateLeftAxisRange()
            }

            function updateSlotProperties(index) {
                var s = slot(index)
                if (!s) {
                    return
                }
                var b = borderSlot(index)
                var desc = d.seriesDescriptor(index)
                var visible = desc ? desc.visible !== false : false
                s.visible = visible
                s.color = desc && desc.color ? desc.color : "transparent"
                // "leftAxisDescriptors()" (which "seriesDescriptor()" above
                // is indexed against) already excludes the right-axis
                // descriptor, so every slot handled here is always
                // axisY: yAxisLeft - no runtime axis switching needed (see
                // "batterySocSeries"'s declaration in the ChartView above).
                s.axisY = yAxisLeft
                if (b) {
                    b.visible = visible
                    b.color = desc && desc.borderColor ? desc.borderColor : (desc && desc.color ? desc.color : "transparent")
                    b.axisY = yAxisLeft
                }
                rebuild(index)
            }

            // Counterpart to updateSlotProperties() above, for the one
            // dedicated right-axis series (see "batterySocSeries"'s
            // declaration in the ChartView above). Never touches "axisY" -
            // it's statically bound to yAxisRight in QML and must stay that
            // way.
            function updateRightAxisSeriesProperties() {
                var s = batterySocSeries
                var b = batterySocBorderSeries
                var desc = d.rightAxisDescriptor()
                var visible = desc ? desc.visible !== false : false
                s.visible = visible
                s.color = desc && desc.color ? desc.color : "transparent"
                if (b) {
                    b.visible = visible
                    b.color = desc && desc.borderColor ? desc.borderColor : (desc && desc.color ? desc.color : "transparent")
                }
                rebuildRightAxisSeries(true)
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
                    // Explicit "null" fallback (not "undefined" - that made
                    // Connections silently fall back to its default target
                    // instead of "no target", producing "no signal of the
                    // target matches" warnings and breaking these handlers
                    // entirely for slots without an active series). The
                    // "Unable to assign QJSValue to QObject*" warning this
                    // produces instead is harmless and pre-existing.
                    target: slotBinding.desc ? slotBinding.desc.model : null

                    // Explicitly invalidate the cached render state before
                    // each full rebuild() here (rather than relying on
                    // rebuild()'s own "same model instance" check): these
                    // events mean the model's *indices* may have shifted
                    // (e.g. entriesAddedIdx(0, ...) for a prepended older
                    // page of data, or entriesRemoved(0, ...) from
                    // EnergyLogs::trimCache()'s front-trim) even though the
                    // model *instance* is unchanged - so the previously
                    // cached [lowIdx, highIdx) no longer refers to the same
                    // entries and must not be used for an incremental diff.
                    function onEntriesAddedIdx(index, count) {
                        d.slotRenderState[slotBinding.seriesIndex] = null
                        seriesBinder.rebuild(slotBinding.seriesIndex)
                    }
                    function onEntriesRemoved(index, count) {
                        d.slotRenderState[slotBinding.seriesIndex] = null
                        seriesBinder.rebuild(slotBinding.seriesIndex)
                    }
                    function onCountChanged() {
                        d.slotRenderState[slotBinding.seriesIndex] = null
                        seriesBinder.rebuild(slotBinding.seriesIndex)
                    }
                }
            }
        }

        // Counterpart to the per-slot Repeater above, for the one dedicated
        // right-axis series (see "batterySocSeries"'s declaration in the
        // ChartView above) - not part of the Repeater's by-index pool since
        // it isn't one of the "d.maxSeriesCount" generic slots.
        Item {
            id: rightAxisSlotBinding
            visible: false
            readonly property var desc: d.rightAxisDescriptor()

            Component.onCompleted: seriesBinder.updateRightAxisSeriesProperties()

            Connections {
                target: root
                function onSeriesChanged() {
                    seriesBinder.updateRightAxisSeriesProperties()
                }
            }

            Connections {
                // See the equivalent Connections block in the Repeater
                // above for why "null" (not "undefined") is used here.
                target: rightAxisSlotBinding.desc ? rightAxisSlotBinding.desc.model : null

                function onEntriesAddedIdx(index, count) {
                    d.slotRenderState[d.maxSeriesCount] = null
                    seriesBinder.rebuildRightAxisSeries(true)
                }
                function onEntriesRemoved(index, count) {
                    d.slotRenderState[d.maxSeriesCount] = null
                    seriesBinder.rebuildRightAxisSeries(true)
                }
                function onCountChanged() {
                    d.slotRenderState[d.maxSeriesCount] = null
                    seriesBinder.rebuildRightAxisSeries(true)
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
            y: chartView.plotArea.y + chartView.plotArea.height + Style.margins
            width: chartView.plotArea.width
            height: d.xLabelsHeight

            Repeater {
                model: d.xTickTimestamps

                delegate: Label {
                    required property var modelData
                    x: xLabelsLayout.width * ((modelData - d.visibleStartTime) / d.visibleWindowMs) - width / 2
                    horizontalAlignment: Text.AlignHCenter
                    font: Style.newExtraSmallFont
                    color: Style.colors.typography_Basic_Default
                    text: Qt.formatTime(new Date(modelData), "hh:mm")
                }
            }

            Repeater {
                model: d.dayNoonTimestamps

                delegate: Label {
                    required property var modelData
                    readonly property real properX: xLabelsLayout.width * ((modelData - d.visibleStartTime) / d.visibleWindowMs) - width / 2
                    x: Math.min(Math.max(properX, 0), parent.width - width)
                    y: axisFontMetrics.height + 2
                    horizontalAlignment: Text.AlignHCenter
                    font: Style.newExtraSmallFont
                    color: Style.colors.typography_Basic_Default
                    text: {
                        const date = new Date(modelData)
                        return date.toLocaleDateString(Qt.locale(), qsTr("d")) +
                                " " +
                                Qt.locale().standaloneMonthName(date.getMonth(), Locale.ShortFormat) +
                                " " +
                                date.getFullYear()
                    }
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
            color: Style.colors.typography_Basic_Default
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
                    color: Style.colors.typography_Basic_Default
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
                    color: Style.colors.typography_Basic_Default
                    // Defensive only: yAxisRight's own "visible" is kept
                    // permanently true (see its declaration above), so it
                    // should never actually be null here anymore - this
                    // guard is just cheap insurance.
                    text: yAxisRight ? (NymeaUtils.floatToLocaleString(yAxisRight.max - index * (yAxisRight.max - yAxisRight.min) / (d.yLabelCount - 1), 0) + "%") : ""
                }
            }
        }

        // -- Pinch (zoom, 3h..24h clamp) and drag (pan) gesture handling --
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
                if (!active) {
                    return
                }
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

            // Only horizontal drags (pan/tooltip-move, both driven purely
            // by translation.x - see onTranslationChanged below) activate
            // this handler; a predominantly-vertical drag is left alone so
            // it falls through to the page's own Flickable (CoStatsView.qml)
            // instead. Without this, DragHandler activates - and takes the
            // exclusive touch grab - on a drag in *any* direction as long
            // as it exceeds the drag threshold, which stole every vertical
            // swipe that happened to start on the chart before the
            // Flickable ever got a chance to recognize it as a scroll.
            yAxis.enabled: false

            // Hot zone half-width (see file doc comment on
            // "selectedTimestampMs"): a drag starting within this many
            // pixels of the selected timestamp's highlight line moves that
            // timestamp instead of panning the visible window.
            readonly property real hotZoneHalfWidth: 24 // 48px touch-friendly

            property real startStartTime
            property real startTimestampMs
            // Decided once, at the start of each gesture (see
            // "onActiveChanged" below) from where the gesture began -
            // "centroid.pressPosition" (not "translation", which is relative
            // and would only tell us how far we've moved, not where we
            // started) - and kept for the rest of that gesture even if the
            // pointer later leaves the hot zone while dragging.
            property bool draggingTooltip: false

            onActiveChanged: {
                if (active) {
                    draggingTooltip = root.selectedTimestampMs >= 0
                            && Math.abs(centroid.pressPosition.x - d.selectedXPixel()) <= hotZoneHalfWidth
                    startStartTime = d.visibleStartTime
                    startTimestampMs = root.selectedTimestampMs
                } else {
                    rangeSettleTimer.restart()
                }
            }

            onTranslationChanged: {
                if (!active) {
                    return
                }
                if (draggingTooltip) {
                    var deltaTimestampMs = (translation.x / chartView.plotArea.width) * d.visibleWindowMs
                    var newTimestampMs = d.clamp(startTimestampMs + deltaTimestampMs, d.visibleStartTime, d.selectedTimestampMaxMs())
                    root.selectedTimestampMs = newTimestampMs
                    var xPixel = d.selectedXPixel()
                    root.pointSelected(new Date(newTimestampMs), Qt.rect(xPixel - 1, chartView.plotArea.y, 2, chartView.plotArea.height))
                } else {
                    var deltaPanMs = -(translation.x / chartView.plotArea.width) * d.visibleWindowMs
                    d.visibleStartTime = startStartTime + deltaPanMs
                }
            }
        }

        // -- Desktop mouse-wheel gesture handling (zoom) --
        // Ctrl+wheel zooms (mirrors PinchHandler above, pivoting on the
        // cursor position instead of a touch centroid). Plain wheel is
        // deliberately NOT used for panning: the chart lives inside a page
        // that itself scrolls vertically with the wheel, so intercepting
        // unmodified wheel events here would break that page scrolling.
        // Panning without Ctrl is still available via click-and-drag
        // (DragHandler above).
        WheelHandler {
            id: wheelHandler
            target: null
            acceptedModifiers: Qt.ControlModifier

            onWheel: (event) => {
                // Zoom: negative angleDelta.y ("scroll down") zooms out,
                // positive ("scroll up") zooms in - matches PinchHandler's
                // "scale > 1 == zoom in" convention via the exponent below.
                var factor = Math.exp(event.angleDelta.y / 960)
                var pivotFraction = d.clamp((event.x - chartView.plotArea.x) / chartView.plotArea.width, 0, 1)
                var timeAtPivot = d.visibleStartTime + pivotFraction * d.visibleWindowMs
                var newWindow = d.clamp(d.visibleWindowMs / factor, d.minWindowMs, d.maxWindowMs)
                d.visibleWindowMs = newWindow
                d.visibleStartTime = timeAtPivot - pivotFraction * newWindow
                rangeSettleTimer.restart()
            }
        }

        // -- Tap-to-select a point (for the caller's tooltip; see
        // "pointSelected" above). A MouseArea is used here (instead of a
        // TapHandler) because QtCharts' ChartView unconditionally grabs all
        // mouse buttons for its own (unused here) pressed/released/clicked
        // signals. Being a sibling declared after "chartView", this
        // MouseArea is hit-tested first and takes the click before
        // ChartView (or the PinchHandler/DragHandler/WheelHandler above,
        // which are hosted on "chartContainer" and are only ever able to
        // grab by stealing once a gesture exceeds their movement/pinch
        // threshold) ever sees it - so a plain click that never moves
        // simply results in "onClicked" firing here, while an actual
        // pan/pinch/wheel gesture is unaffected. Ignores clicks outside the
        // plot area (e.g. on the axis labels).
        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => {
                var plotArea = chartView.plotArea
                if (plotArea.width <= 0) {
                    return
                }
                if (mouse.x < plotArea.x || mouse.x > plotArea.x + plotArea.width
                        || mouse.y < plotArea.y || mouse.y > plotArea.y + plotArea.height) {
                    return
                }
                var fraction = d.clamp((mouse.x - plotArea.x) / plotArea.width, 0, 1)
                var timestamp = new Date(d.visibleStartTime + fraction * d.visibleWindowMs)
                var anchorRect = Qt.rect(mouse.x - 1, plotArea.y, 2, plotArea.height)
                root.selectedTimestampMs = timestamp.getTime()
                root.pointSelected(timestamp, anchorRect)
            }
        }


        // -- Highlight the selected timestamp (see "selectedTimestampMs"
        // above) while its tooltip is open: a vertical line at that x, plus
        // a small circle per visible series where it crosses that line -
        // same size/style as the color swatches in the tooltip's own
        // content (CoChartTooltip.qml) so the two are visually tied
        // together.
        Rectangle {
            x: d.selectedXPixel()
            y: chartView.plotArea.y
            width: 1
            height: chartView.plotArea.height
            color: Style.colors.components_Statistics_Tooltip_line
            visible: d.selectedXPixel() >= 0
        }

        Repeater {
            model: d.selectedPoints()

            delegate: Rectangle {
                required property var modelData

                x: modelData.x - width / 2
                y: modelData.y - height / 2
                width: 12
                height: 12
                radius: width / 2
                color: modelData.color
                border.color: modelData.borderColor
                border.width: 1
            }
        }
    } // chartContainer

    BusyIndicator {
        anchors.centerIn: parent
        running: root.loading
        visible: root.loading
        Material.accent: Style.colors.brand_Basic_Accent
    }
}
