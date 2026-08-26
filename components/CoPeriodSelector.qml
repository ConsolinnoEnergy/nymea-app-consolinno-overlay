import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea
import "../mainviews/energy"
import "../components"

// Period selector control: 4 tab buttons (Day/Week/Month/Year) on top, below
// a horizontal, swipeable ListView showing the currently selected period,
// flanked by two chevron buttons to step to the previous/next period.
//
// - "referenceDate"/"fromTimestamp"/"toTimestamp" are publicly readable so
//   parent views (e.g. a chart below) can bind directly to them.
// - setReferenceDate(date) allows setting the period from the outside (e.g.
//   when the user instead scrolls/zooms the chart itself).
// - Switching between Day/Week/Month/Year keeps the last selected position
//   and only re-interprets it for the new granularity (e.g. "May 2025" ->
//   the week containing May 1st), instead of jumping back to today.
// - Navigation into the future is limited to the current period ("today").
Item {
    id: root

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    // ── Public API ────────────────────────────────────────────────────────
    property int sampleRate: EnergyLogs.SampleRate1Day

    readonly property date referenceDate: d.periodStart(d.selectedInstant, root.sampleRate)
    readonly property int fromTimestamp: Math.floor(referenceDate.getTime() / 1000)
    readonly property int toTimestamp: Math.floor(d.addPeriods(referenceDate, root.sampleRate, 1).getTime() / 1000) - 1

    // Called when the currently displayed period should be set from outside
    // (e.g. the chart below was scrolled/zoomed by the user). Clamped to
    // "today" at the latest, same as interactive swiping/tapping.
    function setReferenceDate(date) {
        var isFuture = d.periodStart(date, root.sampleRate) > d.todayStart
        d.selectedInstant = isFuture ? d.todayStart : date
        d.syncListViewFromSelection()
    }

    // ── Private state & date-math helpers ───────────────────────────────────
    QtObject {
        id: d

        // Only the calendar position of this instant matters; it gets
        // re-normalized to a period start via periodStart() for whichever
        // sampleRate is currently active. This is what allows switching
        // between Day/Week/Month/Year to keep the same "position" instead
        // of resetting back to today.
        property date selectedInstant: new Date()

        // Absolute offset (in units of root.sampleRate, relative to today's
        // period) that ListView index 0 currently represents. Adjusted
        // during recentering so the ListView model can stay a small,
        // fixed-size window instead of an actually infinite model.
        property int windowAnchorOffset: -windowCenterIndex

        // Guards against recursion while we reposition the ListView
        // programmatically (sampleRate change, setReferenceDate(), recentering).
        property bool updatingListView: false

        readonly property date todayStart: periodStart(new Date(), root.sampleRate)
        readonly property int selectedOffset: periodsBetween(todayStart, periodStart(selectedInstant, root.sampleRate), root.sampleRate)

        // Normalizes 'date' to the start of the period (day/week/month/year)
        // that contains it. Weeks start on Monday (ISO 8601).
        function periodStart(date, sampleRate) {
            var result = new Date(date)
            result.setHours(0, 0, 0, 0)
            if (sampleRate === EnergyLogs.SampleRate1Week) {
                var dayOfWeek = (result.getDay() + 6) % 7 // JS getDay() is Sunday-based, shift to Monday-based
                result.setDate(result.getDate() - dayOfWeek)
            } else if (sampleRate === EnergyLogs.SampleRate1Month) {
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

        // ISO 8601 week number (Monday-based weeks, week 1 contains the year's first Thursday).
        function isoWeekNumber(date) {
            var target = new Date(date)
            target.setHours(0, 0, 0, 0)
            var dayNumber = (target.getDay() + 6) % 7
            target.setDate(target.getDate() - dayNumber + 3) // nearest Thursday
            var firstThursday = new Date(target.getFullYear(), 0, 4)
            var firstDayNumber = (firstThursday.getDay() + 6) % 7
            firstThursday.setDate(firstThursday.getDate() - firstDayNumber + 3)
            return 1 + Math.round((target.getTime() - firstThursday.getTime()) / (7 * 86400000))
        }

        function formatPeriod(date, sampleRate) {
            if (sampleRate === EnergyLogs.SampleRate1Week) {
                var endDate = new Date(date)
                endDate.setDate(endDate.getDate() + 6)
                // Source string in English per project convention; translators
                // provide the localized abbreviation (e.g. German "KW").
                return qsTr("Week %1, %2 – %3").arg(isoWeekNumber(date))
                                                .arg(date.toLocaleDateString(Qt.locale(), Locale.ShortFormat))
                                                .arg(endDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat))
            } else if (sampleRate === EnergyLogs.SampleRate1Month) {
                return date.toLocaleDateString(Qt.locale(), "MMMM yyyy")
            } else if (sampleRate === EnergyLogs.SampleRate1Year) {
                return date.getFullYear().toString()
            }
            // Locale-aware full date (day/month order follows Qt.locale()),
            // matching StatsBase.dayLongLabel's approach.
            return date.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
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
            syncListViewFromSelection()
        }

        // Repositions the ListView's currentIndex to reflect d.selectedInstant,
        // re-centering the window around it if necessary. Used whenever the
        // selection changes programmatically (as opposed to interactive
        // swiping, which is handled by listView.onCurrentIndexChanged).
        function syncListViewFromSelection() {
            updatingListView = true
            windowAnchorOffset = selectedOffset - windowCenterIndex
            listView.currentIndex = windowCenterIndex
            updatingListView = false
            listView.updateCurrentLabelWidth()

            // Switching sampleRate changes the label (and thus width) of
            // EVERY delegate at once (day-format -> week-format text etc).
            // ListView caches each delegate's x position and does not
            // automatically re-flow neighboring, currently-off-viewport
            // items when their widths change this way in bulk - even
            // forceLayout() alone is not sufficient. Only forceLayout()
            // followed by re-centering via positionViewAtIndex() actually
            // rebuilds the neighbor chain around the current item (this is
            // effectively what happens implicitly when the window is
            // resized, which is why resizing "fixes" it). Deferred until
            // the width bindings have settled.
            Qt.callLater(function() {
                listView.forceLayout()
                listView.positionViewAtIndex(listView.currentIndex, ListView.Center)
            })
        }
    }

    // Size of the (fixed) ListView model window. Large enough that normal
    // swiping/tapping rarely needs to trigger a recenter.
    readonly property int windowSize: 41
    readonly property int windowCenterIndex: (windowSize - 1) / 2
    // How close to either edge of the window triggers a silent recenter.
    readonly property int recenterMargin: 8

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: Style.smallMargins

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
                onClicked: {
                    root.sampleRate = EnergyLogs.SampleRate1Day;
                    d.resetToToday();
                }
            }

            CoTabButton {
                id: weekButton
                Layout.fillWidth: true
                text: qsTr("Week")
                onClicked: {
                    root.sampleRate = EnergyLogs.SampleRate1Week;
                    d.resetToToday();
                }
            }

            CoTabButton {
                id: monthButton
                Layout.fillWidth: true
                text: qsTr("Month")
                onClicked: {
                    root.sampleRate = EnergyLogs.SampleRate1Month;
                    d.resetToToday();
                }
            }

            CoTabButton {
                id: yearButton
                Layout.fillWidth: true
                text: qsTr("Year")
                onClicked: {
                    root.sampleRate = EnergyLogs.SampleRate1Year;
                    d.resetToToday();
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
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
                model: root.windowSize
                snapMode: ListView.SnapOneItem
                highlightRangeMode: ListView.StrictlyEnforceRange

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

                function updateCurrentLabelWidth() {
                    currentLabelMetrics.text = d.formatPeriod(d.periodStart(d.selectedInstant, root.sampleRate), root.sampleRate)
                    currentLabelWidth = currentLabelMetrics.width + Style.margins
                }

                preferredHighlightBegin: (width - currentLabelWidth) / 2
                preferredHighlightEnd: preferredHighlightBegin + currentLabelWidth
                clip: true

                // Set declaratively (not in Component.onCompleted): assigning
                // currentIndex imperatively after construction would run
                // AFTER the ListView's own internal initial currentIndex(0)
                // change already fired once the model becomes valid. Our
                // onCurrentIndexChanged below would then wrongly treat that
                // transient "0" as a real navigation and apply the recenter
                // adjustment a second time, corrupting windowAnchorOffset.
                // A declarative initial value avoids that spurious step.
                currentIndex: root.windowCenterIndex

                Component.onCompleted: updateCurrentLabelWidth()

                onWidthChanged: {
                    // Component.onCompleted (and even Qt.callLater from
                    // there) can still fire while this view's width is still
                    // 0, since the surrounding Layout only assigns the final
                    // width in a later layout pass. StrictlyEnforceRange does
                    // NOT retroactively recenter once width becomes valid, so
                    // without this the "today" item can end up positioned at
                    // contentX 0 (or worse) instead of centered. Re-run the
                    // positioning (deferred, since delegate geometry also
                    // needs to have settled) as soon as we get a real width.
                    if (width > 0)
                        Qt.callLater(function() {
                            positionViewAtIndex(currentIndex, ListView.Center)
                        })
                }

                onCurrentIndexChanged: {
                    if (d.updatingListView)
                        return

                    var newOffset = d.windowAnchorOffset + currentIndex
                    if (newOffset > 0) {
                        // Never allow scrolling past the current period into the future.
                        d.updatingListView = true
                        currentIndex -= newOffset
                        d.updatingListView = false
                        return
                    }

                    d.selectedInstant = d.addPeriods(d.todayStart, root.sampleRate, newOffset)
                    updateCurrentLabelWidth()

                    // Silently recenter the window if we're getting close to an edge,
                    // without changing what's visually displayed (same dates, just
                    // reindexed), so no animation/jump is visible to the user.
                    if (currentIndex < root.recenterMargin || currentIndex > root.windowSize - 1 - root.recenterMargin) {
                        d.updatingListView = true
                        d.windowAnchorOffset += currentIndex - root.windowCenterIndex
                        currentIndex = root.windowCenterIndex
                        d.updatingListView = false
                        // Reindexing changes every delegate's periodOffset (and
                        // therefore label/width) at once - see the comment on
                        // syncListViewFromSelection() for why both calls are
                        // needed in that situation.
                        Qt.callLater(function() {
                            forceLayout()
                            positionViewAtIndex(currentIndex, ListView.Center)
                        })
                    }
                }

                delegate: Item {
                    readonly property int periodOffset: d.windowAnchorOffset + index
                    readonly property bool isFuture: periodOffset > 0
                    readonly property date periodDate: d.addPeriods(d.todayStart, root.sampleRate, periodOffset)

                    // Each delegate is sized to its own label content, since
                    // different sample rates (and even different months,
                    // e.g. "Mai" vs "September") produce very differently
                    // sized labels. A shared fixed width would either clip
                    // longer labels or add excessive spacing around shorter
                    // ones.
                    width: label.implicitWidth + Style.margins
                    height: label.implicitHeight + Style.smallMargins

                    opacity: isFuture ? 0.3 : (ListView.isCurrentItem ? 1 : 0.5)

                    Label {
                        id: label
                        anchors.centerIn: parent
                        text: d.formatPeriod(periodDate, root.sampleRate)
                        font: parent.ListView.isCurrentItem ? Style.newSmallFontBold : Style.smallFont
                        color: Style.foregroundColor
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: !isFuture
                        onClicked: listView.currentIndex = index
                    }
                }
            }

            // ── Prev/next chevron buttons ─────────────────────────────────
            CoIconButton {
                width: 36
                height: 36
                icon: Qt.resolvedUrl("qrc:/icons/chevron_backward.svg")
                onClicked: listView.decrementCurrentIndex()
            }

            CoIconButton {
                width: 36
                height: 36
                enabled: d.selectedOffset < 0
                icon: Qt.resolvedUrl("qrc:/icons/chevron_forward.svg")
                onClicked: listView.incrementCurrentIndex()
            }
        }
    }
}
