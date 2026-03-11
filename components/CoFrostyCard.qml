import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import Nymea 1.0

Frame {
    property alias headerText: header.text
    default property alias content: body.data
    property int contentBottomMargin: 8 // #TODO use value from style

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    background: Rectangle {
        id: background
        color: Style.colors.components_Dashboard_Background_accent_dashboard
        radius: 24 // #TODO use value from style
    }

    // Mask source must live outside contentRoot so it is not included in the
    // layer texture that the OpacityMask effect samples.
    Item {
        id: roundedRectMask
        width: background.width
        height: background.height
        layer.enabled: true
        visible: false
        Rectangle {
            anchors.fill: parent
            radius: background.radius
        }
    }

    contentItem: Item {
        id: contentRoot
        // Render the entire content area into a layer and clip it to the
        // rounded rectangle mask so every child (including e.g. CoCard hover
        // rectangles) is clipped to the rounded Forsty Card corners.
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: roundedRectMask
        }

        implicitHeight: header.implicitHeight +
                        header.anchors.topMargin +
                        header.anchors.bottomMargin +
                        body.implicitHeight +
                        body.anchors.topMargin +
                        body.anchors.bottomMargin
        implicitWidth: Math.max(header.implicitWidth + header.anchors.leftMargin + header.anchors.rightMargin,
                                body.implicitWidth + body.anchors.leftMargin + body.anchors.rightMargin)

        Text {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 8 // #TODO use value from style
            anchors.leftMargin: 16 // #TODO use value from style
            anchors.rightMargin: 16 // #TODO use value from style
            color: Style.colors.typography_Headlines_H2
            font: Style.newH2Font
        }

        Item {
            id: body
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: header.bottom
            anchors.topMargin: 16 // #TODO use value from new style
            anchors.bottomMargin: contentBottomMargin

            height: implicitHeight
            implicitHeight: childrenRect.height
        }
    }
}
