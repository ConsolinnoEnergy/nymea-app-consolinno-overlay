import QtQuick
import QtQuick.Controls
import Nymea

Button {
    id: pill

    required property color pillColor
    required property color pillAccentColor

    topPadding: 4
    bottomPadding: 4
    leftPadding: 8
    rightPadding: 8

    checkable: true
    checked: true

    font: Style.newSmallFont

    contentItem: Text {
        text: pill.text
        color: pill.checked ?
                   Style.colors.components_Statistics_Legend_pill_text :
                   Style.colors.components_Statistics_Legend_pill_text_unselected
        font: pill.font

        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        width: parent.width - pill.leftInset - pill.rightInset
        height: parent.height - pill.topInset - pill.bottomInset
        radius: height / 2
        color: pill.checked ? pill.pillColor : Style.colors.typography_Background_Default;
        border.width: 1
        border.color: pill.checked ? pill.pillAccentColor : pill.pillColor

        Rectangle {
            width: parent.width
            height: parent.height
            radius: height / 2
            color: Style.colors.typography_States_Pressed
            visible: pill.pressed && !pill.flat
        }

        Rectangle {
            x: -4
            y: -4
            width: parent.width + 8
            height: parent.height + 8
            radius: height / 2
            visible: pill.enabled && pill.hovered
            color: "transparent"
            border.width: 4
            border.color: Style.colors.typography_States_Hover_pressed_outline
        }
    }
}
