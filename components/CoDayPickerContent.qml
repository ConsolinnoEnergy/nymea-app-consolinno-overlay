import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

// Calendar-style day picker: a month header with prev/next navigation, a
// localized weekday row and a grid of day cells (today and the selected day
// highlighted), built on top of Qt Quick Controls' MonthGrid/DayOfWeekRow.
// Used by CoPeriodPickerOverlay when sampleRate is "Day".
ColumnLayout {
    id: root

    spacing: Style.margins

    property date selectedDate: new Date()

    // Which month/year the grid currently displays - independent from
    // selectedDate so the user can browse to a different month before
    // picking a day. Call resetToSelection() (done by the parent overlay
    // whenever it is (re-)opened) to snap navigation back to selectedDate's
    // month.
    property int displayMonth: selectedDate.getMonth()
    property int displayYear: selectedDate.getFullYear()

    readonly property date todayStart: {
        var result = new Date()
        result.setHours(0, 0, 0, 0)
        return result
    }

    function resetToSelection() {
        displayMonth = selectedDate.getMonth()
        displayYear = selectedDate.getFullYear()
    }

    function isSameDay(a, b) {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate()
    }

    function goToPreviousMonth() {
        if (displayMonth === 0) {
            displayMonth = 11
            displayYear -= 1
        } else {
            displayMonth -= 1
        }
    }

    function goToNextMonth() {
        if (displayMonth === 11) {
            displayMonth = 0
            displayYear += 1
        } else {
            displayMonth += 1
        }
    }

    Label {
        // Full localized date incl. weekday - LongFormat guarantees correct
        // day/month/year ORDER per locale (a fixed "d. MMMM yyyy" pattern
        // would hardcode the German day-first convention and read wrong
        // e.g. in en_US).
        text: root.selectedDate.toLocaleDateString(Qt.locale(), Locale.LongFormat)
        font: Style.newSmallFontBold
        color: Style.foregroundColor
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.smallMargins

        Label {
            // Locale.standaloneMonthName() expects a 0-based month (0-11,
            // matching JS Date), UNLIKE the C++ QLocale API (which is
            // 1-12) - no "+1" here.
            text: Qt.locale().standaloneMonthName(root.displayMonth, Locale.LongFormat) + " " + root.displayYear
            font: Style.newSmallFont
            color: Style.subTextColor
        }

        Item { Layout.fillWidth: true }

        CoIconButton {
            width: 32
            height: 32
            icon: Qt.resolvedUrl("qrc:/icons/chevron_backward.svg")
            onClicked: root.goToPreviousMonth()
        }

        CoIconButton {
            width: 32
            height: 32
            icon: Qt.resolvedUrl("qrc:/icons/chevron_forward.svg")
            onClicked: root.goToNextMonth()
        }
    }

    DayOfWeekRow {
        Layout.fillWidth: true
        locale: Qt.locale()
        font: Style.newSmallFont
    }

    MonthGrid {
        id: grid
        Layout.fillWidth: true
        Layout.fillHeight: true
        month: root.displayMonth
        year: root.displayYear
        locale: Qt.locale()

        delegate: Item {
            id: dayDelegate
            required property var model

            width: grid.width / 7
            height: width

            readonly property bool isCurrentMonth: model.month === grid.month
            readonly property bool isSelected: isCurrentMonth && root.isSameDay(model.date, root.selectedDate)
            readonly property bool isFuture: model.date > root.todayStart

            Rectangle {
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height) - Style.smallMargins
                height: width
                radius: width / 2
                color: dayDelegate.isSelected ? Style.colors.components_Datepicker_Selection_background : "transparent"
                border.width: model.today && !dayDelegate.isSelected ? 1 : 0
                border.color: Style.colors.components_Datepicker_Today
            }

            Label {
                anchors.centerIn: parent
                text: model.day
                opacity: dayDelegate.isCurrentMonth ? (dayDelegate.isFuture ? Style.numbers.components_Disabled_opacity : 1) : 0
                color: dayDelegate.isSelected ? Style.colors.components_Datepicker_Selection_text
                                               : (model.today ? Style.colors.components_Datepicker_Today : Style.foregroundColor)
                font: dayDelegate.isSelected || model.today ? Style.newSmallFontBold : Style.newSmallFont
            }

            MouseArea {
                anchors.fill: parent
                enabled: dayDelegate.isCurrentMonth && !dayDelegate.isFuture
                onClicked: root.selectedDate = dayDelegate.model.date
            }
        }
    }
}
