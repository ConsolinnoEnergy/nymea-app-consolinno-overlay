import QtQuick
import QtQuick.Controls
import Nymea

// Vertical, snapping "wheel" picker built on Qt Quick Controls' Tumbler,
// with the neighbors above/below the centered value faded out. Used by
// CoPeriodPickerOverlay for the Week/Month/Year selection columns (e.g.
// picking a year or an ISO week number), each as one CoWheelPicker instance
// side by side.
//
// NOTE: this used to be a hand-rolled ListView with
// ListView.StrictlyEnforceRange, but that has an inherent boundary bug: the
// first/last model item can never be scrolled all the way to the center
// (there's no more content before/after it to make room), leaving a gap and
// making the picker look like an entry is missing. Tumbler's PathView-based
// implementation does not have this problem, so use it directly instead of
// working around that bug (e.g. via header/footer spacers).
Tumbler {
    id: root

    // The list of raw values to choose from (e.g. an array of years or week
    // numbers). Each is passed through textForValue() to produce its label.
    property var values: []
    // Formats a single entry of 'values' into display text. Defaults to a
    // plain string conversion; override for custom formatting (e.g. "KW 20").
    property var textForValue: function(value) { return value.toString() }

    // Height of a single row, and how many rows are visible at once -
    // deliberately compact (small font, tight rows) to match the reference
    // design, rather than stretching to fill all available layout height.
    readonly property real rowHeight: Style.newSmallFontBold.pixelSize + Style.smallMargins

    readonly property var currentValue: values.length > 0 ? values[currentIndex] : undefined

    // Selects the entry matching 'value', if present. No-op otherwise.
    function selectValue(value) {
        var index = values.indexOf(value)
        if (index >= 0)
            currentIndex = index
    }

    model: values
    wrap: false
    visibleItemCount: 7
    implicitHeight: rowHeight * visibleItemCount

    delegate: Item {
        id: delegateItem

        required property int index
        required property var modelData

        // Tumbler.displacement is 0 for the centered (current) item and
        // +-1, +-2, ... for each row away from center.
        readonly property real displacement: Tumbler.displacement
        readonly property bool isCurrent: Math.abs(displacement) < 0.01

        width: root.width
        height: root.rowHeight

        Label {
            anchors.centerIn: parent
            text: root.textForValue(delegateItem.modelData)
            font: delegateItem.isCurrent ? Style.newSmallFontBold : Style.newSmallFont
            color: delegateItem.isCurrent ? Style.foregroundColor : Style.subTextColor
            opacity: delegateItem.isCurrent ? 1 : Math.max(0.25, 1 - Math.abs(delegateItem.displacement) * 0.25)
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.currentIndex = delegateItem.index
        }
    }

    // Hairlines above/below the centered selection row, matching the visual
    // reference (a subtle "window" indicating the currently picked value).
    Rectangle {
        y: root.topPadding + root.availableHeight / 2 - root.rowHeight / 2
        width: parent.width
        height: 1
        color: Style.subTextColor
        opacity: 0.3
    }

    Rectangle {
        y: root.topPadding + root.availableHeight / 2 + root.rowHeight / 2
        width: parent.width
        height: 1
        color: Style.subTextColor
        opacity: 0.3
    }
}
