import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3
import Nymea 1.0

Row {
    property alias text: label.text
    property alias push: infoButton.push

    Layout.fillWidth: true
    spacing: 8

    Label {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        font: Style.newParagraphFontBold
        color: Style.colors.components_Forms_Fields_Field_label
    }

    InfoButton {
        id: infoButton
        visible: typeof push === "string" && push !== ""
        anchors.verticalCenter: parent.verticalCenter
    }
}
