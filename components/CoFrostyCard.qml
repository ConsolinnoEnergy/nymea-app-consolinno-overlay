import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0

Frame {
    property alias headerText: header.text
    default property alias content: body.data

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    // #TODO remove again
    Component.onCompleted: {
        console.warn("---", width, height, implicitWidth, implicitHeight);
        console.warn("--- header", header.width, header.height, header.implicitWidth, header.implicitHeight);
        console.warn("--- body", body.width, body.height, body.implicitWidth, body.implicitHeight);
    }

    background: Rectangle {
        color: Style.colors.components_Dashboard_Background_accent_dashboard
        radius: 16 // #TODO use value from style
    }

    contentItem: Item {
        id: contentRoot
        implicitHeight: header.implicitHeight +
                        header.anchors.topMargin +
                        header.anchors.bottomMargin +
                        body.implicitHeight +
                        body.anchors.topMargin +
                        body.anchors.bottomMargin
        implicitWidth: Math.max(header.implicitWidth + header.anchors.leftMargin + header.anchors.rightMargin,
                                body.implicitWidth + body.anchors.leftMargin + body.anchors.rightMargin)

        // #TODO remove again
        Component.onCompleted: {
            console.warn("-----", width, height, implicitWidth, implicitHeight);
        }

        Text {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 8 // #TODO use value from style
            anchors.leftMargin: 16 // #TODO use value from style
            anchors.rightMargin: 16 // #TODO use value from style
            anchors.bottomMargin: 16 // #TODO use value from style
            color: Style.colors.typography_Headlines_H2
            // #TODO font from new style
            font.bold: true
            font.pixelSize: 16
        }

        Item {
            id: body
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.topMargin: 8 // #TODO use value from new style
            anchors.bottomMargin: 0
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            // #TODO this probably does not work in all cases
            implicitHeight: children.length > 0 ? children[0].implicitHeight : 0
        }
    }
}
