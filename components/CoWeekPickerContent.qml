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

    // Earliest year selectable - see CoPeriodPickerOverlay for rationale
    // (no backend signal for "data available since", so a fixed year is used).
    readonly property int minYear: 2017
    readonly property int maxYear: new Date().getFullYear()

    readonly property date resultDate: DateUtils.mondayOfIsoWeek(yearPicker.currentValue, weekPicker.currentValue)

    readonly property date resultWeekEnd: {
        var end = new Date(root.resultDate)
        end.setDate(end.getDate() + 6)
        return end
    }

    function resetToSelection() {
        yearPicker.selectValue(DateUtils.isoWeekYear(root.selectedDate))
        weekPicker.selectValue(DateUtils.isoWeekNumber(root.selectedDate))
    }

    Label {
        text: qsTr("%1, Week %2").arg(yearPicker.currentValue).arg(weekPicker.currentValue)
        font: Style.newSmallFontBold
        color: Style.foregroundColor
    }

    Label {
        text: root.resultDate.toLocaleDateString(Qt.locale(), Locale.ShortFormat) + " – "
              + root.resultWeekEnd.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
        font: Style.newSmallFont
        color: Style.subTextColor
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.margins

        CoWheelPicker {
            id: yearPicker
            Layout.fillWidth: true
            values: {
                var result = []
                for (var y = root.minYear; y <= root.maxYear; y++)
                    result.push(y)
                return result
            }
            onCurrentValueChanged: {
                // Re-clamp the week wheel if the newly picked year has fewer
                // ISO weeks than the currently picked week number (week 53
                // doesn't exist in every year).
                var maxWeek = DateUtils.isoWeeksInYear(currentValue)
                if (weekPicker.currentValue > maxWeek)
                    weekPicker.selectValue(maxWeek)
            }
        }

        CoWheelPicker {
            id: weekPicker
            Layout.fillWidth: true
            values: {
                var count = DateUtils.isoWeeksInYear(yearPicker.currentValue || root.selectedDate.getFullYear())
                var result = []
                for (var w = 1; w <= count; w++)
                    result.push(w)
                return result
            }
            // Source string in English per project convention; translators
            // provide the localized abbreviation (e.g. German "KW").
            textForValue: function(value) { return qsTr("Week %1").arg(value) }
        }
    }
}
