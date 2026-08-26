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

    // Earliest year selectable - see CoPeriodPickerOverlay for rationale
    // (no backend signal for "data available since", so a fixed year is used).
    readonly property int minYear: 2017
    readonly property int maxYear: new Date().getFullYear()

    readonly property date resultDate: new Date(yearPicker.currentValue, 0, 1)

    function resetToSelection() {
        yearPicker.selectValue(root.selectedDate.getFullYear())
    }

    Label {
        text: root.resultDate.getFullYear().toString()
        font: Style.newSmallFontBold
        color: Style.foregroundColor
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
