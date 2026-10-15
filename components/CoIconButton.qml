import QtQuick
import QtQuick.Layouts
import Nymea


Item {
    id: root
    property alias icon: icon.name
    property alias iconSize: icon.size
    property bool isChecked: false

    // MouseArea.containsMouse stays true after a touch release on iOS (no
    // exit event), so hover is tracked via a mouse/stylus-only HoverHandler.
    readonly property bool showHover: hoverHandler.hovered

    signal clicked()
    signal pressAndHold()

    height: 42
    width: 42
    opacity: enabled ? 1 : Style.numbers.components_Disabled_opacity

    Rectangle {
        id: background
        anchors.fill: parent
        radius: parent.width / 2
        color: {
            if (root.isChecked) {
                return Style.colors.components_Forms_Buttons_Button_secondary_is_current;
            } else if (root.showHover || mouseArea.pressed) {
                return Style.colors.typography_States_Pressed;
            } else {
                return "transparent";
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: parent.width - 8
            height: parent.height - 8
            radius: width / 2
            visible: !root.isChecked && root.showHover && !mouseArea.pressed
            color: Style.colors.typography_Background_Default
        }
    }

    ColorIcon {
        id: icon
        anchors.centerIn: parent
        size: 26
        color: root.isChecked ? Style.colors.typography_Basic_Default_inverted : Style.colors.brand_Basic_Icon
    }

    HoverHandler {
        id: hoverHandler
        acceptedDevices: PointerDevice.Mouse | PointerDevice.Stylus
        enabled: root.enabled
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled
        onClicked: parent.clicked()
        onPressAndHold: parent.pressAndHold()
    }
}
