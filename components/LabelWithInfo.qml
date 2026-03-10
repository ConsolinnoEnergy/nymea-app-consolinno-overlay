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
        width: parent.width - infoButton.width - parent.spacing
        wrapMode: Text.WordWrap
    }

    InfoButton {
        id: infoButton
    }
}