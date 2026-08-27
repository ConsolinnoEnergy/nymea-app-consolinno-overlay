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

    // Whether the inline month/year wheel picker (opened via the dropdown
    // chevron next to the "Month Year" nav label) is showing instead of the
    // weekday row + calendar grid.
    property bool monthPickerOpen: false

    // Earliest year selectable - see CoPeriodPickerOverlay for rationale
    // (no backend signal for "data available since", so a fixed year is used).
    readonly property int minYear: 2017
    readonly property int maxYear: new Date().getFullYear()

    readonly property date todayStart: {
        var result = new Date()
        result.setHours(0, 0, 0, 0)
        return result
    }

    function resetToSelection() {
        displayMonth = selectedDate.getMonth()
        displayYear = selectedDate.getFullYear()
        monthPickerOpen = false
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
        text: root.selectedDate.toLocaleDateString(Qt.locale(), qsTr("d. MMMM yyyy"))
        font: Style.newH2Font
        color: Style.colors.typography_Basic_Default
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.smallMargins

        Label {
            text: Qt.locale().standaloneMonthName(root.displayMonth, Locale.LongFormat) + " " + root.displayYear
            font: Style.newSmallFont
            color: Style.colors.typography_Basic_Default
        }

        CoIconButton {
            width: 24
            height: 24
            icon: Qt.resolvedUrl("qrc:/icons/keyboard_arrow_down.svg")
            // Flips to point up while the month/year picker is open, as a
            // typical "expanded accordion" affordance.
            rotation: root.monthPickerOpen ? 180 : 0
            Behavior on rotation { NumberAnimation { duration: 150 } }
            onClicked: root.monthPickerOpen = !root.monthPickerOpen
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
        }

        CoIconButton {
            visible: !root.monthPickerOpen
            width: 32
            height: 32
            icon: Qt.resolvedUrl("qrc:/icons/chevron_backward.svg")
            onClicked: root.goToPreviousMonth()
        }

        CoIconButton {
            visible: !root.monthPickerOpen
            width: 32
            height: 32
            icon: Qt.resolvedUrl("qrc:/icons/chevron_forward.svg")
            onClicked: root.goToNextMonth()
        }
    }

    // Inline month/year wheel picker, shown instead of the weekday row and
    // calendar grid while root.monthPickerOpen is true. Lets the user jump
    // to a distant month/year without having to tap the prev/next chevrons
    // repeatedly. Selecting a value updates displayMonth/displayYear live;
    // the calendar grid (and its selectable days) below reflects it once
    // the picker is closed again via the chevron.
    RowLayout {
        Layout.fillWidth: true
        Layout.margins: Style.smallMargins
        Layout.alignment: Qt.AlignCenter
        spacing: Style.largeMargins
        visible: root.monthPickerOpen

        CoWheelPicker {
            id: monthWheel
            values: {
                var result = []
                for (var m = 0; m < 12; m++)
                    result.push(m)
                return result
            }
            // Locale.standaloneMonthName() is 0-based (0-11, matching JS
            // Date), unlike the C++ QLocale API (1-12) - no "+1" here.
            textForValue: function(value) { return Qt.locale().standaloneMonthName(value, Locale.ShortFormat) }
            // currentValue is briefly undefined while the Tumbler is still
            // populating its model on startup - guard against propagating
            // that (would try to assign undefined to the int property).
            // NOTE: must react to currentValueChanged, not currentIndexChanged -
            // currentValue is itself a binding derived from currentIndex, and
            // reading it from an onCurrentIndexChanged handler observes a
            // stale (one-step-behind) value due to signal handler ordering.
            onCurrentValueChanged: if (currentValue !== undefined) root.displayMonth = currentValue
        }

        CoWheelPicker {
            id: yearWheel
            values: {
                var result = []
                for (var y = root.minYear; y <= root.maxYear; y++)
                    result.push(y)
                return result
            }
            // See monthWheel's onCurrentValueChanged above for why this
            // can't be onCurrentIndexChanged.
            onCurrentValueChanged: if (currentValue !== undefined) root.displayYear = currentValue
        }
    }

    // Sync the wheels to the currently displayed month/year whenever the
    // picker is (re-)opened, so it doesn't retain a stale position from a
    // previous open.
    onMonthPickerOpenChanged: {
        if (monthPickerOpen) {
            monthWheel.selectValue(displayMonth)
            yearWheel.selectValue(displayYear)
        }
    }

    DayOfWeekRow {
        Layout.fillWidth: true
        locale: Qt.locale()
        font: Style.newParagraphFont
        visible: !root.monthPickerOpen
        palette.text: Style.colors.typography_Basic_Default
    }

    MonthGrid {
        id: grid
        Layout.fillWidth: true
        visible: !root.monthPickerOpen
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
                color: dayDelegate.isSelected ?
                           Style.colors.components_Datepicker_Selection_text :
                           model.today ?
                                Style.colors.components_Datepicker_Today :
                                Style.colors.typography_Basic_Default
                font: Style.newParagraphFont
            }

            MouseArea {
                anchors.fill: parent
                enabled: dayDelegate.isCurrentMonth && !dayDelegate.isFuture
                onClicked: root.selectedDate = dayDelegate.model.date
            }
        }
    }
}
