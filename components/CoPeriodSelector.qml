import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea
import "../mainviews/energy"
import "../components"
import "../utils/DateUtils.js" as DateUtils

// Period selector control: 4 tab buttons (Day/Week/Month/Year) on top, below
// a horizontal, swipeable ListView showing the currently selected period,
// flanked by two chevron buttons to step to the previous/next period.
//
// - "referenceDate"/"fromTimestamp"/"toTimestamp" are publicly readable so
//   parent views (e.g. a chart below) can bind directly to them.
// - setReferenceDate(date) allows setting the period from the outside (e.g.
//   when the user instead scrolls/zooms the chart itself).
// - Switching between Day/Week/Month/Year via the tab buttons always jumps
//   back to today (see resetToToday()), rather than keeping the last
//   selected position and re-interpreting it for the new granularity.
// - Navigation into the future is limited to the current period ("today").
// - Navigation into the past is limited to "minDate" (defaults to
//   2017-01-01; overridable once the backend can report how far back data
//   actually is available).
Item {
    id: root

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    // ── Public API ────────────────────────────────────────────────────────
    property int sampleRate: EnergyLogs.SampleRate1Day

    // Earliest selectable date. Defaults to 2017-01-01 since there is
    // currently no backend signal for "data available since" - settable so
    // callers can narrow (or widen) this once such information becomes
    // available.
    property date minDate: new Date(2017, 0, 1)

    readonly property date referenceDate: d.periodStart(d.selectedInstant, root.sampleRate)
    readonly property int fromTimestamp: Math.floor(referenceDate.getTime() / 1000)
    readonly property int toTimestamp: Math.floor(d.addPeriods(referenceDate, root.sampleRate, 1).getTime() / 1000) - 1

    // Called when the currently displayed period should be set from outside
    // (e.g. the chart below was scrolled/zoomed by the user). Clamped to
    // "today" at the latest and "minDate" at the earliest, same as
    // interactive swiping/tapping.
    function setReferenceDate(date) {
        var periodStartDate = d.periodStart(date, root.sampleRate)
        if (periodStartDate > d.todayStart) {
            d.selectedInstant = d.todayStart
        } else if (periodStartDate < d.minDateStart) {
            d.selectedInstant = root.minDate
        } else {
            d.selectedInstant = date
        }
        d.syncListViewFromSelection()
    }

    // Re-clamps the current selection whenever minDate changes (e.g. once
    // set from a backend response), in case it moves past the currently
    // selected period.
    onMinDateChanged: root.setReferenceDate(d.selectedInstant)

    // ── Private state & date-math helpers ───────────────────────────────────
    // Ticks periodically so "d.todayStart" below doesn't freeze at whatever
    // moment this component was created (it otherwise only re-evaluates
    // when "root.sampleRate" changes, not when the calendar day actually
    // advances) - see CoDayPickerContent.qml's identical Timer for the full
    // explanation. Without this, staying on this page across midnight
    // would leave "today" (and thus the future-navigation limit) stuck on
    // the previous day. Declared here (rather than inside "d") since
    // QtObject has no default property to parent a Timer under.
    Timer {
        id: dateRefreshTimer
        property int tick: 0
        interval: 60000
        running: true
        repeat: true
        onTriggered: tick++
    }

    QtObject {
        id: d

        // Only the calendar position of this instant matters; it gets
        // re-normalized to a period start via periodStart() for whichever
        // sampleRate is currently active.
        property date selectedInstant: new Date()

        // Guards against recursion while we reposition the ListView
        // programmatically (sampleRate change, setReferenceDate()).
        property bool updatingListView: false

        readonly property date todayStart: { dateRefreshTimer.tick; return periodStart(new Date(), root.sampleRate) }
        readonly property date minDateStart: periodStart(root.minDate, root.sampleRate)
        readonly property int selectedOffset: periodsBetween(todayStart, periodStart(selectedInstant, root.sampleRate), root.sampleRate)
        // Both <= 0: "today" is offset 0, minDate is the earliest (most
        // negative) offset.
        readonly property int minOffset: periodsBetween(todayStart, minDateStart, root.sampleRate)

        // Total number of valid periods between minDate and today
        // (inclusive of both ends) - the ListView model is sized to this
        // exactly, so index 0 always means minDate and index
        // "periodCount - 1" always means today. No window/recentering: a
        // delegate's periodOffset (index + minOffset) is therefore a
        // CONSTANT mapping that never needs to be reinterpreted, and the
        // model itself prevents swiping/jumping past either boundary since
        // there simply are no delegates beyond it.
        readonly property int periodCount: 1 - minOffset

        // Normalizes 'date' to the start of the period (day/week/month/year)
        // that contains it. Weeks start on Monday (ISO 8601).
        function periodStart(date, sampleRate) {
            if (sampleRate === EnergyLogs.SampleRate1Week) {
                return DateUtils.startOfIsoWeek(date)
            }
            var result = new Date(date)
            result.setHours(0, 0, 0, 0)
            if (sampleRate === EnergyLogs.SampleRate1Month) {
                result.setDate(1)
            } else if (sampleRate === EnergyLogs.SampleRate1Year) {
                result.setMonth(0, 1)
            }
            return result
        }

        // Adds 'count' periods (of the given sampleRate) to 'date'.
        function addPeriods(date, sampleRate, count) {
            return statsHelper.calculateTimestamp(date, sampleRate, count)
        }

        // Number of whole periods between two already period-start-normalized
        // dates. Both dates must have been normalized with the same sampleRate.
        function periodsBetween(fromDate, toDate, sampleRate) {
            if (sampleRate === EnergyLogs.SampleRate1Year) {
                return toDate.getFullYear() - fromDate.getFullYear()
            } else if (sampleRate === EnergyLogs.SampleRate1Month) {
                return (toDate.getFullYear() - fromDate.getFullYear()) * 12 + (toDate.getMonth() - fromDate.getMonth())
            } else if (sampleRate === EnergyLogs.SampleRate1Week) {
                return Math.round((toDate.getTime() - fromDate.getTime()) / (7 * 86400000))
            }
            return Math.round((toDate.getTime() - fromDate.getTime()) / 86400000)
        }

        function formatPeriod(date, sampleRate) {
            if (sampleRate === EnergyLogs.SampleRate1Week) {
                var endDate = new Date(date)
                endDate.setDate(endDate.getDate() + 6)
                const isSameYear = date.getFullYear() === endDate.getFullYear()
                const startDateStr = date.toLocaleDateString(Qt.locale(), qsTr("d")) + " " +
                                Qt.locale().standaloneMonthName(date.getMonth(), Locale.ShortFormat) +
                                   (isSameYear ? "" : (" " + date.getFullYear().toString()))
                const endDateStr = endDate.toLocaleDateString(Qt.locale(), qsTr("d")) + " " +
                                 Qt.locale().standaloneMonthName(endDate.getMonth(), Locale.ShortFormat) + " " +
                                 endDate.getFullYear().toString()
                return qsTr("W%1, %2 – %3").arg(DateUtils.isoWeekNumber(date))
                                                .arg(startDateStr)
                                                .arg(endDateStr)
            } else if (sampleRate === EnergyLogs.SampleRate1Month) {
                return Qt.locale().standaloneMonthName(date.getMonth(), Locale.ShortFormat) + " " +
                        date.getFullYear().toString()
            } else if (sampleRate === EnergyLogs.SampleRate1Year) {
                return date.getFullYear().toString()
            }
            return date.toLocaleDateString(Qt.locale(), qsTr("d")) + " " +
                    Qt.locale().standaloneMonthName(date.getMonth(), Locale.ShortFormat) + " " +
                    date.getFullYear().toString()
        }

        // Jumps the selection back to "today" - used when the sampleRate
        // (Day/Week/Month/Year) is switched. Deliberately does NOT try to
        // re-interpret the previously selected position for the new
        // granularity: that "keep position" behavior was the source of
        // repeated, hard-to-diagnose bugs (stale ListView layout state
        // surviving across sampleRate switches) and today's period is
        // almost always what the user actually wants to see after
        // switching resolution anyway.
        function resetToToday() {
            selectedInstant = new Date()
            // sampleRate just changed (this is only ever called right
            // after it), so every delegate's label/width changed at once -
            // always needs the full relayout, see
            // syncListViewFromSelection()'s "forceFullRelayout" doc.
            syncListViewFromSelection(true)
        }

        // Repositions the ListView's currentIndex to reflect
        // d.selectedInstant. Used whenever the selection changes
        // programmatically (as opposed to interactive swiping, which is
        // handled by listView.onCurrentIndexChanged).
        //
        // The model is sized to exactly span minDate..today (see
        // "periodCount" above), so unlike a windowed model this never
        // needs to reinterpret/recenter anything - "targetIndex" below is
        // simply selectedOffset's fixed position in that range. What it
        // still has to decide is HOW to get there:
        //
        // - "forceFullRelayout" must be true whenever every delegate's
        //   label (and thus width) can have changed at once - i.e. a
        //   sampleRate switch (day-format -> week-format text etc., see
        //   resetToToday()).
        // - Otherwise, a LARGE jump (e.g. the user picked a date years
        //   away in the calendar picker) is also repositioned directly via
        //   positionViewAtIndex() rather than through a plain currentIndex
        //   assignment: with highlightMoveDuration-based animation, Qt
        //   would otherwise visually scroll through every item in between
        //   at a fixed pixel speed, which for a large index distance could
        //   take a very long, confusing time.
        // - A SMALL jump (the common case: this is also called from
        //   setReferenceDate() e.g. when the chart below is panned/zoomed,
        //   firing on every single calendar-day crossing) just moves
        //   currentIndex directly - the cheap path, letting Qt's normal
        //   highlight-tracking animate the one-or-few-item move, with no
        //   relayout needed at all.
        function syncListViewFromSelection(forceFullRelayout) {
            if (forceFullRelayout === undefined) {
                forceFullRelayout = false
            }

            var targetIndex = selectedOffset - minOffset
            var isLargeJump = forceFullRelayout
                    || Math.abs(targetIndex - listView.currentIndex) > root.largeJumpThreshold

            updatingListView = true
            // Update the highlight range (derived from the new selection's
            // label width) BEFORE moving currentIndex, not after: with
            // highlightRangeMode: StrictlyEnforceRange, changing the
            // highlight range can itself nudge currentIndex to whatever
            // item now falls inside it. Doing that *after* we already set
            // currentIndex here would silently move it again - while
            // "updatingListView" is already back to false - landing on the
            // wrong period. (The interactive swipe path below already
            // updates the label first for the same reason.)
            listView.updateCurrentLabelWidth()
            listView.currentIndex = targetIndex
            updatingListView = false

            if (!isLargeJump) {
                return
            }

            // Only a sampleRate switch actually needs forceLayout(): that
            // changes the label/width of EVERY delegate at once, which
            // ListView does not automatically re-flow for
            // currently-off-viewport neighbors otherwise (even
            // forceLayout() alone is not sufficient without the
            // re-centering positionViewAtIndex() call that follows it). A
            // plain large jump within the same sampleRate doesn't change
            // any delegate's label/width - periodOffset is a constant
            // per-index mapping now - so it only needs positionViewAtIndex()
            // to jump the content position there directly, skipping Qt's
            // slow, distance-proportional highlight animation. Deferred
            // until the width bindings have settled.
            Qt.callLater(function() {
                if (forceFullRelayout) {
                    listView.forceLayout()
                }
                listView.positionViewAtIndex(listView.currentIndex, ListView.Center)
            })
        }
    }

    // Jumps larger than this (in index/period units) are repositioned
    // directly via positionViewAtIndex() instead of animated, see
    // syncListViewFromSelection() above.
    readonly property int largeJumpThreshold: 10

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: Style.extraExtraSmallMargins

        StatsBase {
            id: statsHelper
        }

        CoTabBar {
            Layout.fillWidth: true

            ButtonGroup {
                buttons: [dayButton, weekButton, monthButton, yearButton]
            }

            CoTabButton {
                id: dayButton
                Layout.fillWidth: true
                text: qsTr("Day")
                checked: true
                onCheckedChanged: {
                    if (!checked) { return; }
                    root.sampleRate = EnergyLogs.SampleRate1Day;
                    d.resetToToday();
                }
            }

            CoTabButton {
                id: weekButton
                Layout.fillWidth: true
                text: qsTr("Week")
                onCheckedChanged: {
                    if (!checked) { return; }
                    root.sampleRate = EnergyLogs.SampleRate1Week;
                    d.resetToToday();
                }
            }

            CoTabButton {
                id: monthButton
                Layout.fillWidth: true
                text: qsTr("Month")
                onCheckedChanged: {
                    if (!checked) { return; }
                    root.sampleRate = EnergyLogs.SampleRate1Month;
                    d.resetToToday();
                }
            }

            CoTabButton {
                id: yearButton
                Layout.fillWidth: true
                text: qsTr("Year")
                onCheckedChanged: {
                    if (!checked) { return; }
                    root.sampleRate = EnergyLogs.SampleRate1Year;
                    d.resetToToday();
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.extraExtraSmallMargins
            spacing: Style.smallMargins

            ListView {
                id: listView
                Layout.fillWidth: true
                orientation: ListView.Horizontal
                // NOTE: for a horizontal ListView, contentHeight is NOT
                // auto-computed from delegates - it's bound to the view's own
                // height, so using it for Layout.preferredHeight would create
                // a circular binding that resolves to 0. Compute the height
                // from the fonts used by the delegate instead.
                Layout.preferredHeight: Math.max(Style.smallFont.pixelSize, Style.newSmallFontBold.pixelSize) + Style.smallMargins
                model: d.periodCount
                snapMode: ListView.SnapOneItem
                highlightRangeMode: ListView.StrictlyEnforceRange

                // Qt's default highlightMoveVelocity (400px/s) alone makes
                // the highlight-move animation take proportionally longer
                // the farther currentIndex jumps - for a jump of several
                // days via the chevron-navigation-together-with-big-steps
                // case (still below largeJumpThreshold, so still animated)
                // this can end up feeling sluggish. Setting
                // highlightMoveDuration here does NOT switch to a
                // fixed-duration animation (that would make it move at a
                // constant time regardless of distance, i.e. unnaturally
                // fast for big jumps and slow for single steps) - with
                // BOTH properties set, Qt uses highlightMoveVelocity to
                // compute the natural, distance-proportional duration and
                // only CAPS it at highlightMoveDuration if that would be
                // exceeded (see QSmoothedAnimation::recalc()). So single
                // steps keep their natural quick speed, while the few-days
                // jumps below largeJumpThreshold are capped to a brisk,
                // constant-feeling duration instead of scaling up
                // unbounded.
                highlightMoveDuration: 500

                TextMetrics {
                    id: currentLabelMetrics
                    font: Style.newSmallFontBold
                }

                // Width used to center the current delegate via
                // preferredHighlightBegin/End below, computed directly from
                // the current period's formatted label rather than from
                // "currentItem.width" (which would create a binding loop,
                // since the highlight range in turn determines currentItem's
                // position).
                //
                // This is a PLAIN property, updated imperatively (via
                // updateCurrentLabelWidth() below) from the few controlled
                // places where the selection actually changes - rather than
                // a live binding to d.selectedInstant/root.sampleRate. A live
                // binding here created a real binding loop in practice: a
                // width change shifts the highlight range, which can nudge
                // the view's positioning/currentIndex, which updates
                // d.selectedInstant, which would re-evaluate the label text
                // and width again within the same cycle.
                property real currentLabelWidth: 0

                // Also plain (not live bindings) - see "currentLabelWidth"
                // above for the same reasoning. "preferredHighlightBegin"
                // binding directly on "width" (see the removed version
                // below) triggered a genuine "Binding loop detected for
                // property 'preferredHighlightBegin'" warning in practice:
                // StrictlyEnforceRange repositions the view/currentItem
                // whenever the highlight range changes, which - just like
                // "currentItem.width" above - feeds back into this same
                // recalculation within the same evaluation cycle. Updated
                // imperatively alongside "currentLabelWidth" in
                // updateCurrentLabelWidth()/onWidthChanged below instead.
                property real highlightBegin: 0
                property real highlightEnd: 0

                function updateHighlightRange() {
                    highlightBegin = (width - currentLabelWidth) / 2
                    highlightEnd = highlightBegin + currentLabelWidth
                }

                function updateCurrentLabelWidth() {
                    currentLabelMetrics.text = d.formatPeriod(d.periodStart(d.selectedInstant, root.sampleRate), root.sampleRate)
                    currentLabelWidth = currentLabelMetrics.width + Style.margins
                    updateHighlightRange()
                }

                preferredHighlightBegin: highlightBegin
                preferredHighlightEnd: highlightEnd
                clip: true

                // Set declaratively (not in Component.onCompleted): assigning
                // currentIndex imperatively after construction would run
                // AFTER the ListView's own internal initial currentIndex(0)
                // change already fired once the model becomes valid. Our
                // onCurrentIndexChanged below would then wrongly treat that
                // transient "0" as a real navigation. A declarative initial
                // value avoids that spurious step.
                currentIndex: d.periodCount - 1

                Component.onCompleted: updateCurrentLabelWidth()

                onWidthChanged: {
                    // Now that "highlightBegin"/"highlightEnd" are plain
                    // properties (not live bindings on "width" - see their
                    // doc comment above), they need to be recomputed
                    // explicitly whenever "width" actually changes.
                    updateHighlightRange()

                    // Component.onCompleted (and even Qt.callLater from
                    // there) can still fire while this view's width is still
                    // 0, since the surrounding Layout only assigns the final
                    // width in a later layout pass. StrictlyEnforceRange does
                    // NOT retroactively recenter once width becomes valid, so
                    // without this the "today" item can end up positioned at
                    // contentX 0 (or worse) instead of centered. Re-run the
                    // positioning (deferred, since delegate geometry also
                    // needs to have settled) as soon as we get a real width.
                    if (width > 0) {
                        Qt.callLater(function() {
                            positionViewAtIndex(currentIndex, ListView.Center)
                        })
                    }
                }

                onCurrentIndexChanged: {
                    if (d.updatingListView) {
                        return
                    }

                    // The model is sized to exactly span minDate..today
                    // (see "periodCount"/"minOffset" above), so currentIndex
                    // can never land outside that range in the first place
                    // - no clamping or window-recentering needed here
                    // anymore, every index's periodOffset is a constant
                    // mapping.
                    d.selectedInstant = d.addPeriods(d.todayStart, root.sampleRate, currentIndex + d.minOffset)
                    updateCurrentLabelWidth()
                }

                // Steps currentIndex by +/-1, used by the chevron buttons
                // below instead of calling incrementCurrentIndex()/
                // decrementCurrentIndex() directly. Those rely on Qt
                // internally keeping its "move reason" as SetIndex through
                // the next layout pass for the step to be animated - but a
                // residual settle-animation from an earlier interactive
                // swipe (flicking/moving still true at that point) makes
                // that same layout pass silently overwrite it back to
                // Mouse instead, so the step ends up jumping instantly
                // with no visible transition at all. cancelFlick() alone
                // does not reliably prevent this (it only cancels flick
                // deceleration, not every kind of pending settle
                // correction) - forcing a positionViewAtIndex() to the
                // CURRENT index first guarantees the view is fully at
                // rest (moving/flicking false, no pending correction)
                // before the actual step, which is always safe to call
                // here since the button and the view can never be
                // interacted with by the same pointer at the same time -
                // if the view is already at rest (the common case), this
                // is a no-op with no visible effect.
                function stepCurrentIndex(delta) {
                    var newIndex = currentIndex + delta
                    if (newIndex < 0 || newIndex >= count) {
                        return
                    }
                    cancelFlick()
                    positionViewAtIndex(currentIndex, ListView.Center)

                    // Update the highlight range for the item we're about
                    // to select BEFORE moving currentIndex, not after - for
                    // the exact same reason as in syncListViewFromSelection()
                    // above: with highlightRangeMode: StrictlyEnforceRange,
                    // changing the highlight range can itself snap the view
                    // to the new position instantly, which would silently
                    // override the highlight-move animation Qt is about to
                    // start for the currentIndex change right below. This
                    // only becomes visible when the new label's width
                    // actually differs from the current one (e.g. a
                    // single-digit day turning into a double-digit one), so
                    // it was easy to miss - most steps don't change the
                    // label width and animated fine regardless.
                    d.selectedInstant = d.addPeriods(d.todayStart, root.sampleRate, newIndex + d.minOffset)
                    updateCurrentLabelWidth()

                    currentIndex = newIndex
                }

                delegate: Item {
                    readonly property int periodOffset: index + d.minOffset
                    readonly property date periodDate: d.addPeriods(d.todayStart, root.sampleRate, periodOffset)

                    // Each delegate is sized to its own label content, since
                    // different sample rates (and even different months,
                    // e.g. "May" vs "September") produce very differently
                    // sized labels. A shared fixed width would either clip
                    // longer labels or add excessive spacing around shorter
                    // ones.
                    width: label.implicitWidth + Style.margins
                    height: label.implicitHeight + Style.smallMargins

                    opacity: ListView.isCurrentItem ? 1 : 0.33

                    Label {
                        id: label
                        anchors.centerIn: parent
                        text: d.formatPeriod(periodDate, root.sampleRate)
                        font: Style.newSmallFont
                        color: Style.colors.typography_Basic_Default
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: pickerOverlay.open()
                    }
                }
            }

            // ── Prev/next chevron buttons ─────────────────────────────────
            CoIconButton {
                width: 36
                height: 36
                iconSize: 20
                enabled: d.selectedOffset > d.minOffset
                icon: Qt.resolvedUrl("qrc:/icons/chevron_backward.svg")
                onClicked: listView.stepCurrentIndex(-1)
            }

            CoIconButton {
                width: 36
                height: 36
                iconSize: 20
                enabled: d.selectedOffset < 0
                icon: Qt.resolvedUrl("qrc:/icons/chevron_forward.svg")
                onClicked: listView.stepCurrentIndex(1)
            }
        }
    }

    CoPeriodPickerOverlay {
        id: pickerOverlay
        sampleRate: root.sampleRate
        selectedDate: d.periodStart(d.selectedInstant, root.sampleRate)
        minDate: root.minDate
        onDateChosen: (date) => root.setReferenceDate(date)
    }
}
