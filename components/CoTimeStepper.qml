import QtQuick
import Nymea

import "../components"

CoInputStepper {
    id: root

    property alias overlayTitle: timePickerOverlay.title
    property alias overlayDescription: timePickerOverlay.description

    unit: qsTr("hh:mm")
    compact: true
    stepSize: 1
    clickable: true
    editable: false

    readonly property int currentHours: Math.floor(value / 4)
    readonly property int currentMinutes: (value % 4) * 15

    spinbox.textFromValue: function(value, locale) {
        var h = Math.floor(value / 4);
        var m = (value % 4) * 15;
        return (h < 10 ? "0" : "") + h + ":" + (m < 10 ? "0" : "") + m;
    }
    spinbox.valueFromText: function(text, locale) {
        var parts = text.split(":")
        if (parts.length !== 2) { return 0 }
        return (parseInt(parts[0]) || 0) * 4 + Math.round((parseInt(parts[1]) || 0) / 15);
    }
    spinbox.validator: RegularExpressionValidator {
        regularExpression: /^([0-1][0-9]|2[0-4]):(00|15|30|45)$/
    }

    onClicked: timePickerOverlay.open()

    CoTimePickerOverlay {
        id: timePickerOverlay
        initialHours: root.currentHours
        initialMinutes: root.currentMinutes

        onTimeChosen: function (hours, minutes) {
            const newValue = (hours * 60 + minutes) / 15
            if (newValue < root.from) {
                root.value = root.from
            } else if (newValue > root.to) {
                root.value = root.to
            } else {
                root.value = newValue
            }
        }
    }
}