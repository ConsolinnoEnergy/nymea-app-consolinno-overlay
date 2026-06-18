import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0

Item {
    id: root
    property alias checked: radioButton.checked
    property alias text: label.text
    property alias helpText: helpLabel.text
    property alias radioButton: radioButton
    property alias autoExclusive: radioButton.autoExclusive

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin

    opacity: root.enabled ? 1 : Style.numbers.components_Disabled_opacity
    layer.enabled: !root.enabled

    Rectangle {
        anchors.fill: parent
        color: {
            if (!root.enabled) {
                return "transparent";
            } else if (mouseArea.pressed || radioButton.down) {
                return Style.colors.typography_States_Pressed;
            } else if (mouseArea.containsMouse || radioButton.hovered) {
                return Style.colors.typography_States_Hover;
            } else {
                return "transparent";
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            radioButton.click();
        }
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: Style.margins
        anchors.rightMargin: Style.margins
        anchors.topMargin: Style.smallMargins
        anchors.bottomMargin: Style.smallMargins
        spacing: Style.margins

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                id: label
                Layout.fillWidth: true
                font: Style.newParagraphFont
                color: Style.colors.typography_Basic_Default
                wrapMode: Text.WordWrap
                visible: text !== ""
            }

            Text {
                id: helpLabel
                Layout.fillWidth: true
                font: Style.newSmallFont
                color: Style.colors.typography_Basic_Default
                wrapMode: Text.WordWrap
                visible: text !== ""
            }
        }

        RadioButton {
            id: radioButton
            Layout.alignment: Qt.AlignCenter
        }
    }
}
