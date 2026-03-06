import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

Row {
    property alias text: label.text
    property alias push: infoButton.push

    spacing: 5

    Label {
        id: label
        anchors.verticalCenter: parent.verticalCenter
    }

    InfoButton {
        id: infoButton
        anchors.verticalCenter: parent.verticalCenter
    }
}