import QtQuick
import QtQuick.Controls
import Nymea

Button {
    id: tabButton

    topPadding: Style.extraSmallMargins
    bottomPadding: Style.extraSmallMargins
    leftPadding: Style.smallMargins
    rightPadding: Style.smallMargins

    checkable: true

    font: Style.newSmallFont

    contentItem: Text {
        text: tabButton.text
        color: tabButton.checked ?
                   Style.colors.components_Navigation_Tabs_Text_selected :
                   Style.colors.components_Navigation_Tabs_Text
        font: tabButton.font

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        width: parent.width - tabButton.leftInset - tabButton.rightInset
        height: parent.height - tabButton.topInset - tabButton.bottomInset
        radius: height / 2
        color: tabButton.checked ? Style.colors.components_Navigation_Tabs_Selected : "transparent"
        border.width: tabButton.checked ? 1 : 0
        border.color: Style.colors.components_Navigation_Tabs_Selected_Border

        Rectangle {
            width: parent.width
            height: parent.height
            radius: height / 2
            color: Style.colors.typography_States_Pressed
            visible: tabButton.pressed && !tabButton.flat
        }

        Rectangle {
            x: -4
            y: -4
            width: parent.width + 8
            height: parent.height + 8
            radius: height / 2
            visible: tabButton.enabled && tabButton.hovered
            color: "transparent"
            border.width: 4
            border.color: Style.colors.typography_States_Hover_pressed_outline
        }
    }
}
