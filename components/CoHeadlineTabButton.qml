import QtQuick
import QtQuick.Controls
import Nymea

// CoHeadlineTabButton
//
// Simplified variant of CoTabButton for headline-style tab switchers (e.g.
// the "Energiebilanz"/"Verbrauch" chart tab switcher): no pill background,
// no border, no hover/press feedback - just a text label whose font grows
// and whose color changes when selected. Meant to be used inside a CoTabBar
// with a transparent background (see CoTabBar's "backgroundColor" property)
// and left-aligned rather than evenly stretched across the available width.
Button {
    id: tabButton

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    checkable: true

    // Control internally always resizes contentItem to (width - padding)
    // (see QQuickControlPrivate::resizeContent), regardless of any Layout
    // settings - so without an explicit implicitWidth/Height tied to the
    // label's own natural size, the button (and thus its Text) can end up
    // sized by its Layout container instead of by its text content, which
    // is wrong for a left-aligned, non-stretched switcher like this one.
    // No Behavior needed here: since the label's font size below is
    // animated, label.implicitWidth already changes smoothly frame by
    // frame, so this binding follows along automatically.
    implicitWidth: label.implicitWidth
    // Fixed to the larger (selected/H2) font's line height rather than
    // following label.implicitHeight - the latter would shrink while
    // animating towards the smaller (unselected/H5) font, making the whole
    // CoTabBar (and thus the page layout below it) briefly shorter and
    // visibly shift during the transition.
    implicitHeight: maxFontMetrics.height

    FontMetrics {
        id: maxFontMetrics
        font.family: Style.newH2Font.family
        font.pixelSize: Style.newH2Font.pixelSize
        font.weight: Style.newH2Font.weight
    }

    contentItem: Text {
        id: label
        text: tabButton.text
        color: tabButton.checked ?
                   Style.colors.typography_Headlines_H2 :
                   Style.colors.typography_Headlines_H3

        // Font family/weight are identical between newH2Font and
        // newH5Font (only size/letter-spacing differ), so only those two
        // are animated - interpolating pixelSize directly (rather than
        // swapping the whole "font" property, which cannot be animated as
        // one value) avoids both the instant size jump and the transient
        // eliding that happened while the surrounding button was still
        // resizing towards the new, already-final text.
        font.family: Style.newH2Font.family
        font.weight: Style.newH2Font.weight
        font.pixelSize: tabButton.checked ? Style.newH2Font.pixelSize : Style.newH5Font.pixelSize
        font.letterSpacing: tabButton.checked ? Style.newH2Font.letterSpacing : Style.newH5Font.letterSpacing
        Behavior on font.pixelSize { NumberAnimation { duration: Style.animationDuration; easing.type: Easing.InOutQuad } }
        Behavior on font.letterSpacing { NumberAnimation { duration: Style.animationDuration; easing.type: Easing.InOutQuad } }

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    // No background shape at all - fully transparent, no hover/press
    // rectangles (unlike CoTabButton).
    background: Item {}
}
