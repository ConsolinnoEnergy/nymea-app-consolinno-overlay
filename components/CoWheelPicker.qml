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

    // Extra vertical room opened up around the selected row only. Tumbler's
    // row pitch is fixed/uniform (it doesn't derive from the delegate's own
    // height), so the rows themselves can't get individually taller. Instead,
    // each delegate's label is nudged away from center by up to this much,
    // clamped to +-1 row worth of displacement - so only the gap right
    // around the selected row opens up, while rows further out keep their
    // normal, compact spacing relative to each other (they're just carried
    // along by the same constant offset). Being a plain linear function of
    // Tumbler.displacement (which is continuous, not integral, mid-scroll),
    // this stays smooth throughout the selection-change animation.
    readonly property real dividerGap: Style.margins

    readonly property var currentValue: values.length > 0 ? values[currentIndex] : undefined

    // Selects the entry matching 'value', if present. No-op otherwise.
    // Animates the wheel to the new position, like a user-driven scroll -
    // use selectValueImmediate() instead for programmatic resets that
    // should not visibly animate (e.g. restoring a value after the model
    // was rebuilt).
    function selectValue(value) {
        var index = values.indexOf(value)
        if (index >= 0)
            currentIndex = index
    }

    // Like selectValue(), but jumps to the position instantly without the
    // usual scroll animation. SnapPosition (not "Immediate" - that mode
    // doesn't exist on Tumbler/PathView, and silently resolves to
    // undefined/0, causing an incorrect jump) positions the view exactly
    // like a settled/snapped selection would, without animating there.
    function selectValueImmediate(value) {
        var index = values.indexOf(value)
        if (index >= 0)
            positionViewAtIndex(index, Tumbler.SnapPosition)
    }

    model: values
    wrap: false
    visibleItemCount: 7
    implicitHeight: rowHeight * visibleItemCount
    implicitWidth: 80

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
            anchors.horizontalCenter: parent.horizontalCenter
            // Push the label away from center as the row moves off the
            // middle position - see dividerGap's comment above for why.
            // Note the minus sign: Tumbler.displacement is positive for
            // rows *above* center and negative for rows *below* it (the
            // opposite of screen-y direction), so it must be negated to
            // push rows away from (rather than into) the center.
            y: (parent.height - height) / 2
               - root.dividerGap * Math.max(-1, Math.min(1, delegateItem.displacement))
            text: root.textForValue(delegateItem.modelData)
            font: Style.newParagraphFont
            color: Style.colors.typography_Basic_Default
            opacity: delegateItem.isCurrent ? 1 : Math.max(0.33, 1 - Math.abs(delegateItem.displacement) * 0.33)
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.currentIndex = delegateItem.index
        }
    }

    CoDivider {
        y: root.topPadding + root.availableHeight / 2 - root.rowHeight / 2 - root.dividerGap / 2 - Style.smallMargins - 1
        width: parent.width
    }

    CoDivider {
        y: root.topPadding + root.availableHeight / 2 + root.rowHeight / 2 + root.dividerGap / 2 - Style.smallMargins - 1
        width: parent.width
    }
}
