import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Nymea 1.0

import "../components"

Item {
    property alias checked: toggle.checked
    property alias text: label.text
    property alias infoUrl: label.push
    property alias helpText: helpLabel.text

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin

    Rectangle {
        id: background
        anchors.fill: parent
        color: mouseArea.pressed || toggle.down ?
                   Style.colors.typography_States_Pressed :
                       mouseArea.containsMouse || toggle.hovered ?
                           Style.colors.typography_States_Hover :
                           "transparent"
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
        }
    }
}
