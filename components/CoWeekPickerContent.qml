import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea
import "../utils/DateUtils.js" as DateUtils

// Week picker: two side-by-side wheels (ISO week-year, ISO week number),
// with a header showing the resulting week and its date range. Used by
// CoPeriodPickerOverlay when sampleRate is "Week".
ColumnLayout {
    id: root

    spacing: Style.margins

    // The Monday of the currently selected week.
    property date selectedDate: new Date()

    // Earliest selectable date, passed down from CoPeriodPickerOverlay (which
    // in turn gets it from CoPeriodSelector's settable "minDate" property;
    // defaults to 2017-01-01 since there is currently no backend signal for
    // "data available since"). Only the year is used here to bound the year
    // wheel's range.
    property date minDate: new Date(2017, 0, 1)
    readonly property int minYear: minDate.getFullYear()
    readonly property int maxYear: { dateRefreshTimer.tick; return new Date().getFullYear() }

    // "tick" above establishes a reactive dependency so "maxYear" doesn't
    // freeze at whatever year this component was created in - see
    // CoDayPickerContent.qml's identical Timer for the full explanation.
    Timer {
        id: dateRefreshTimer
        property int tick: 0
        interval: 60000
        running: true
        repeat: true
        onTriggered: tick++
    }

    readonly property date resultDate: DateUtils.mondayOfIsoWeek(yearPicker.currentValue, weekPicker.currentValue)

    readonly property date resultWeekEnd: {
        var end = new Date(root.resultDate)
        end.setDate(end.getDate() + 6)
        return end
    }

    function resetToSelection() {
        d.restoringSelection = true
        yearPicker.selectValue(DateUtils.isoWeekYear(root.selectedDate))
        weekPicker.selectValue(DateUtils.isoWeekNumber(root.selectedDate))
        // Clear the guard one event-loop turn later, i.e. after
        // yearPicker.onCurrentValueChanged's own Qt.callLater fixup below
        // (queued first, during the selectValue() call above) has had a
        // chance to run and see the guard still set.
        Qt.callLater(function() { d.restoringSelection = false })
    }

    QtObject {
        id: d
        // Set for one event-loop turn while resetToSelection() is
        // reassigning both wheels, so yearPicker.onCurrentValueChanged's
        // deferred week-restore fixup (below) doesn't clobber the week
        // resetToSelection() just set with the stale pre-reset week.
        property bool restoringSelection: false
    }

    Label {
        text: qsTr("CW %1, %2").arg(weekPicker.currentValue).arg(yearPicker.currentValue)
        font: Style.newH2Font
        color: Style.colors.typography_Basic_Default
    }

    Label {
        text: root.resultDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat) + " – "
              + root.resultWeekEnd.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
        font: Style.newSmallFont
        color: Style.colors.typography_Basic_Default
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.margins: Style.smallMargins
        Layout.alignment: Qt.AlignCenter
        spacing: Style.largeMargins

        CoWheelPicker {
            id: weekPicker
            values: {
                var count = DateUtils.isoWeeksInYear(yearPicker.currentValue || root.selectedDate.getFullYear())
                var result = []
                for (var w = 1; w <= count; w++) {
                    result.push(w)
                }
                return result
            }
            // Source string in English per project convention; translators
            // provide the localized abbreviation.
            textForValue: function(value) { return qsTr("CW %1").arg(value) }
        }

        CoWheelPicker {
            id: yearPicker
            values: {
                var result = []
                for (var y = root.minYear; y <= root.maxYear; y++) {
                    result.push(y)
                }
                return result
            }
            onCurrentValueChanged: {
                // weekPicker.values is itself bound to yearPicker.currentValue
                // (below), so changing the year always reassigns weekPicker's
                // Tumbler model - which resets its currentIndex/currentValue
                // to the first entry (week 1), even when the previously
                // picked week is still valid in the new year. Capture the
                // week to restore *before* that recompute happens (this
                // handler runs before the values binding re-evaluates), then
                // reapply it via Qt.callLater once the new values array (and
                // the reset it caused) have settled, clamping to the new
                // year's week count (week 53 doesn't exist in every year).
                //
                // Skipped while resetToSelection() is in progress
                // ("d.restoringSelection"): that function already sets both
                // wheels to their final, correct values synchronously right
                // after triggering this handler, so re-applying "oldWeek"
                // (the stale, pre-reset week) here would overwrite that
                // correct value on the next event-loop turn.
                var oldWeek = weekPicker.currentValue
                var newYear = currentValue
                var wasRestoring = d.restoringSelection
                Qt.callLater(function() {
                    if (wasRestoring) {
                        return
                    }
                    var maxWeek = DateUtils.isoWeeksInYear(newYear)
                    weekPicker.selectValueImmediate(Math.min(oldWeek, maxWeek))
                })
            }
        }
    }

    // Invisible width anchor: a ColumnLayout that is a *direct* StackLayout
    // child (as this one is, in CoPeriodPickerOverlay) does not actually
    // stretch to fill the available width from its own Layout.fillWidth -
    // it only gets stretched if at least one (possibly nested) descendant
    // has an unbounded/"fillWidth" size hint that propagates up. The wheel
    // row above is deliberately compact/centered (no Layout.fillWidth on
    // its CoWheelPickers), so without this it's the only content and the
    // whole picker would shrink to that compact width instead of spanning
    // the overlay - see CoDayPickerContent's always-visible header spacer
    // Item for a case where this already happens incidentally.
    Item {
        Layout.fillWidth: true
    }
}
