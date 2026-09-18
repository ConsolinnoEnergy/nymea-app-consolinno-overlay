import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

// Year picker: a single wheel of selectable years, with a header showing
// the resulting year. Used by CoPeriodPickerOverlay when sampleRate is
// "Year".
ColumnLayout {
    id: root

    spacing: Style.margins

    property date selectedDate: new Date()

    // Earliest selectable date, passed down from CoPeriodPickerOverlay (which
    // in turn gets it from CoPeriodSelector's settable "minDate" property;
    // defaults to 2017-01-01 since there is currently no backend signal for
    // "data available since"). Only the year matters here, since this
    // picker's granularity is a single year wheel.
    property date minDate: new Date(2017, 0, 1)
    readonly property int minYear: minDate.getFullYear()
    readonly property int maxYear: new Date().getFullYear()

    readonly property date resultDate: new Date(yearPicker.currentValue, 0, 1)

    function resetToSelection() {
        yearPicker.selectValue(root.selectedDate.getFullYear())
    }

    Label {
        text: root.resultDate.getFullYear().toString()
        font: Style.newH2Font
        color: Style.colors.typography_Basic_Default
    }

    CoWheelPicker {
        id: yearPicker
        Layout.alignment: Qt.AlignCenter
        values: {
            var result = []
            for (var y = root.minYear; y <= root.maxYear; y++)
                result.push(y)
            return result
        }
    }

    // Invisible width anchor - see CoWeekPickerContent for why this is
    // needed once the wheel above no longer has Layout.fillWidth: true.
    Item {
        Layout.fillWidth: true
    }
}
