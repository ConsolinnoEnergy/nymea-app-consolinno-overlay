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

    // Earliest selectable date, passed down from CoPeriodPickerOverlay (which
    // in turn gets it from CoPeriodSelector's settable "minDate" property;
    // defaults to 2017-01-01 since there is currently no backend signal for
    // "data available since"). Only the year is used here, since the month
    // picker's year wheel is year-level granularity.
    property date minDate: new Date(2017, 0, 1)
    readonly property int minYear: minDate.getFullYear()
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
        font: Style.newH2Font
        color: Style.colors.typography_Basic_Default
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.margins: Style.smallMargins
        Layout.alignment: Qt.AlignCenter
        spacing: Style.largeMargins

        CoWheelPicker {
            id: monthPicker
            values: {
                var result = []
                for (var m = 0; m < 12; m++)
                    result.push(m)
                return result
            }
            // QLocale month names are 0-based in QML (Locale.standaloneMonthName
            // expects 0-11, matching JS Date), unlike the C++ QLocale API
            // (1-12) - our values are already 0-based JS Date month indices.
            textForValue: function(value) { return Qt.locale().standaloneMonthName(value, Locale.ShortFormat) }
        }

        CoWheelPicker {
            id: yearPicker
            values: {
                var result = []
                for (var y = root.minYear; y <= root.maxYear; y++)
                    result.push(y)
                return result
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
    // the overlay - see CoWeekPickerContent for the bug this fixes.
    Item {
        Layout.fillWidth: true
    }
}
