import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

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