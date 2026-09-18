import QtQuick
import QtQuick.Layouts
import Nymea

// Modal picker overlay opened from CoPeriodSelector's ListView. Shows a
// resolution-appropriate picker (day calendar / week wheels / month wheels
// / year wheel) depending on sampleRate, and reports the chosen date via
// dateChosen() when the user taps Accept. Rejecting (or the close button)
// discards any in-progress selection.
CoOverlay {
    id: root

    title: {
        if (root.sampleRate === EnergyLogs.SampleRate1Week)
            return qsTr("Choose week")
        if (root.sampleRate === EnergyLogs.SampleRate1Month)
            return qsTr("Choose month")
        if (root.sampleRate === EnergyLogs.SampleRate1Year)
            return qsTr("Choose year")
        return qsTr("Choose day")
    }

    // ── Public API ────────────────────────────────────────────────────────
    property int sampleRate: EnergyLogs.SampleRate1Day
    property date selectedDate: new Date()
    property date minDate: new Date(2017, 0, 1)

    signal dateChosen(date date)

    onAboutToShow: {
        switch (root.sampleRate) {
        case EnergyLogs.SampleRate1Week:
            stack.currentIndex = 1
            break
        case EnergyLogs.SampleRate1Month:
            stack.currentIndex = 2
            break
        case EnergyLogs.SampleRate1Year:
            stack.currentIndex = 3
            break
        default:
            stack.currentIndex = 0
        }

        dayContent.selectedDate = root.selectedDate
        weekContent.selectedDate = root.selectedDate
        monthContent.selectedDate = root.selectedDate
        yearContent.selectedDate = root.selectedDate

        dayContent.resetToSelection()
        weekContent.resetToSelection()
        monthContent.resetToSelection()
        yearContent.resetToSelection()
    }

    onAccepted: {
        var result
        switch (root.sampleRate) {
        case EnergyLogs.SampleRate1Week:
            result = weekContent.resultDate
            break
        case EnergyLogs.SampleRate1Month:
            result = monthContent.resultDate
            break
        case EnergyLogs.SampleRate1Year:
            result = yearContent.resultDate
            break
        default:
            result = dayContent.selectedDate
        }
        root.dateChosen(result)
    }

    StackLayout {
        id: stack
        anchors.fill: parent
        anchors.margins: Style.margins
        anchors.topMargin: Style.bigMargins

        CoDayPickerContent {
            id: dayContent
            Layout.fillWidth: true
            Layout.fillHeight: true
            minDate: root.minDate
        }

        CoWeekPickerContent {
            id: weekContent
            Layout.fillWidth: true
            Layout.fillHeight: true
            minDate: root.minDate
        }

        CoMonthPickerContent {
            id: monthContent
            Layout.fillWidth: true
            Layout.fillHeight: true
            minDate: root.minDate
        }

        CoYearPickerContent {
            id: yearContent
            Layout.fillWidth: true
            Layout.fillHeight: true
            minDate: root.minDate
        }
    }
}
