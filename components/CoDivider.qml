import QtQuick
import Nymea

Item {
    id: root

    implicitHeight: divider.height + 2 * Style.smallMargins
    implicitWidth: 100

    Rectangle {
        id: divider
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: Style.smallMargins
        }
        color: Style.colors.typography_Basic_Divider
        height: 2
    }
}
