import QtQuick 2.0
import QtQuick.Layouts 1.2
import Nymea 1.0


Item {
    id: root
    property alias icon: icon.name
    property bool isChecked: false

    signal clicked()
    signal pressAndHold()

    height: 42
    width: 42

    Rectangle {
        id: background
        anchors.fill: parent
        radius: parent.width / 2
        color: {
            if (root.isChecked) {
                return Style.colors.components_Forms_Buttons_Button_secondary_is_current;
            } else if (mouseArea.containsMouse) {
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
            visible: !root.isChecked && mouseArea.containsMouse && !mouseArea.pressed
            color: Style.colors.typography_Background_Default
        }
    }

    ColorIcon {
        id: icon
        anchors.centerIn: parent
        size: 26
        color: root.isChecked ? Style.colors.typography_Basic_Default_inverted : Style.colors.brand_Basic_Icon
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: parent.clicked()
        onPressAndHold: parent.pressAndHold()
    }
}
