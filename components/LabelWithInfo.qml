import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Row {
    property alias text: label.text
    property alias push: infoButton.push

    Layout.fillWidth: true
    spacing: 8

    Label {
        id: label
        anchors.verticalCenter: parent.verticalCenter
    }

    InfoButton {
        id: infoButton
        visible: push !== ""
        anchors.verticalCenter: parent.verticalCenter
    }
}