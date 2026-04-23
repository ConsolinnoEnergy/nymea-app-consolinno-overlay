import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0

Row {
    property alias text: label.text
    property alias push: infoButton.push
    property alias font: label.font
    property alias fontColor: label.color
    property alias wrapMode: label.wrapMode
    readonly property real naturalWidth: label.implicitWidth + (infoButton.visible ? spacing + infoButton.width : 0)

    Layout.fillWidth: true
    spacing: 8

    Label {
        id: label
        anchors.verticalCenter: parent.verticalCenter
        font: Style.newParagraphFontBold
        color: Style.colors.components_Forms_Fields_Field_label
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        width: Math.min(implicitWidth,
                        parent.width - (infoButton.visible ? infoButton.width + parent.spacing : 0))
    }

    InfoButton {
        id: infoButton
        visible: typeof push === "string" && push !== ""
        anchors.verticalCenter: parent.verticalCenter
        push: ""
    }
}
