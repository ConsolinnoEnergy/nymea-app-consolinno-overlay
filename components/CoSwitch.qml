import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Nymea 1.0

import "../components"

Item {
    id: root
    property alias checked: toggle.checked
    property alias text: label.text
    property alias infoUrl: label.push
    property alias helpText: helpLabel.text

    signal clicked()
    signal toggled()

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin

    Rectangle {
        id: background
        anchors.fill: parent
        color: {
            if (!root.enabled) {
                return "transparent";
            } else if (mouseArea.pressed || toggle.down) {
                return Style.colors.typography_States_Pressed;
            } else if (mouseArea.containsMouse || toggle.hovered) {
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
            toggle.toggle();
        }
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: Style.margins
        spacing: Style.margins

        ColumnLayout {
            Layout.fillWidth: true
            opacity: root.enabled ? 1 : Style.numbers.components_Disabled_opacity

            LabelWithInfo {
                id: label
                Layout.fillWidth: true
            }

            Text {
                id: helpLabel
                Layout.fillWidth: true
                font: Style.newParagraphFont
                color: Style.colors.typography_Basic_Default
                wrapMode: Text.WordWrap
                visible: text !== ""
            }
        }

        Switch {
            id: toggle
            Layout.alignment: Qt.AlignCenter
            onClicked: {
                root.clicked();
            }
            onToggled: {
                root.toggled()
            }
        }
    }
}
