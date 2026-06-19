import QtQuick
import QtQuick.Controls
import Nymea 1.0

// Wrapper around a regular Button intended for use on a frosted/translucent
// surface (e.g. the navbar controls strip).
//
// The Button style fades its whole layer to Style.numbers.components_Disabled_opacity
// when disabled. On a frosted background that semi-transparent button reveals
// the blurred content sitting behind the navbar, which makes the button look
// like it's painted on top of the page rather than on a control surface.
//
// CoNavbarButton paints an opaque, button-shaped underlay behind the Button
// while it is disabled. The underlay is a sibling of the Button (NOT a child)
// so it stays outside the disabled-state offscreen layer; the Button keeps
// its Figma-defined disabled opacity but composites against the underlay
// instead of the frosted backdrop.
Item {
    id: root

    property alias text: button.text
    property alias enabled: button.enabled
    property alias flat: button.flat
    property alias iconLeft: button.iconLeft
    property alias iconRight: button.iconRight
    property alias font: button.font
    property color underlayColor: Style.colors.typography_Background_Default

    signal clicked()

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    Rectangle {
        anchors.fill: button
        anchors.topMargin: button.topInset
        anchors.bottomMargin: button.bottomInset
        anchors.leftMargin: button.leftInset
        anchors.rightMargin: button.rightInset
        radius: height / 2
        color: root.underlayColor
        visible: !button.enabled
    }

    Button {
        id: button
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
