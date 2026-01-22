import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1

Frame {
    property alias headerText: header.text
    default property alias content: body.data

    background: Rectangle {
        color: "#AAF4F6F4" // #TODO use color from new style
        radius: 16 // #TODO use value from style
    }

    contentItem: Item {
        id: contentRoot
        anchors.fill: parent

        Text {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 16 // #TODO use value from style
            anchors.leftMargin: 16 // #TODO use value from style
            anchors.rightMargin: 16 // #TODO use value from style
            anchors.bottomMargin: 16 // #TODO use value from style
            color: "#03693A" // #TODO use color from new style
            // #TODO font from new style
            font.bold: true
            font.pixelSize: 16
        }

        Item {
            id: body
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: header.bottom
            anchors.topMargin: 16
            anchors.leftMargin: 16 // #TODO use value from style
            anchors.rightMargin: 16 // #TODO use value from style
            anchors.bottomMargin: 8 // #TODO use value from style
        }
    }
}
