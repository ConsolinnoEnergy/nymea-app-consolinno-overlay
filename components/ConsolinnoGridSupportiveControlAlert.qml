import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../components"
import "../delegates"

Rectangle {
    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter
    radius: 10
    color: Style.dangerBackground
    border.width: 2
    border.color: Style.dangerAccent
    implicitHeight: alertContainer.implicitHeight + 20

    ColumnLayout {
    id: alertContainer
    anchors.fill: parent
    spacing: 1

    Item {
        Layout.preferredHeight: 10
    }

    RowLayout {
        width: parent.width
        spacing: 2

        Image {
            id: image
            Layout.leftMargin: 11
            Layout.rightMargin: 5
            sourceSize.width: 24
            sourceSize.height: 24
            source: "/icons/dialog-warning-symbolic.svg"
        }

        Label {
            id: attentionLabel
            font.pixelSize: 16
            text: qsTr("Attention")
            font.bold: true
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width - 20
            color: Style.dangerAccent
        }

        ColorOverlay {
            source: image
            anchors.fill: image
            color: Style.dangerAccent
        }
    }

        Label {
            font.pixelSize: 16
            text: qsTr("Existing setup will be overwritten.")
            wrapMode: Text.WordWrap
            Layout.rightMargin: 20
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width - 20
            leftPadding: 40
            color: Style.dangerAccent
        }

        Item {
            Layout.preferredHeight: 10
        }
    }
}

