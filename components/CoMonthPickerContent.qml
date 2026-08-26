import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

// Month picker: two side-by-side wheels (month, year), with a header
// showing the resulting "Month Year". Used by CoPeriodPickerOverlay when
// sampleRate is "Month".
ColumnLayout {
    id: root

    spacing: Style.margins

    property date selectedDate: new Date()

    // Earliest year selectable - see CoPeriodPickerOverlay for rationale
    // (no backend signal for "data available since", so a fixed year is used).
    readonly property int minYear: 2017
    readonly property int maxYear: new Date().getFullYear()

    // monthPicker's values are 0-based (JS Date month indices) so this can
    // be passed straight into the Date constructor.
    readonly property date resultDate: new Date(yearPicker.currentValue, monthPicker.currentValue, 1)

    function resetToSelection() {
        monthPicker.selectValue(root.selectedDate.getMonth())
        yearPicker.selectValue(root.selectedDate.getFullYear())
    }

    Label {
        // standaloneMonthName, not toLocaleDateString's "MMMM" token - see
        // CoDayPickerContent for why (nominative vs. date-inflected form).
        // Locale.standaloneMonthName() is 0-based (0-11, matching JS Date),
        // UNLIKE the C++ QLocale API (which is 1-12) - no "+1" here.
        text: Qt.locale().standaloneMonthName(monthPicker.currentValue, Locale.LongFormat) + " " + yearPicker.currentValue
        font: Style.newSmallFontBold
        color: Style.foregroundColor
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.margins

        CoWheelPicker {
            id: monthPicker
            Layout.fillWidth: true
            values: {
                var result = []
                for (var m = 0; m < 12; m++)
                    result.push(m)
                return result
            }
            // QLocale month names are 0-based in QML (Locale.standaloneMonthName
            // expects 0-11, matching JS Date), unlike the C++ QLocale API
            // (1-12) - our values are already 0-based JS Date month indices.
            textForValue: function(value) { return Qt.locale().standaloneMonthName(value, Locale.LongFormat) }
        }

        CoWheelPicker {
            id: yearPicker
            Layout.fillWidth: true
            values: {
                var result = []
                for (var y = root.minYear; y <= root.maxYear; y++)
                    result.push(y)
                return result
            }
        }
    }
}
