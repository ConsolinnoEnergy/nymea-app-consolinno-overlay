import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Nymea 1.0

Frame {
    id: root
    property alias headerText: header.text
    property alias infoUrl: infoButton.push
    property alias infoProperties: infoButton.infoProperties
    default property alias content: body.data
    property int contentBottomMargin: 8
    property int contentTopMargin: 16

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    background: Rectangle {
        id: background
        color: Style.colors.components_Dashboard_Background_accent_dashboard
        radius: Style.largeCornerRadius
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

        implicitHeight: headerLayout.implicitHeight +
                        headerLayout.anchors.topMargin +
                        headerLayout.anchors.bottomMargin +
                        body.implicitHeight +
                        body.anchors.topMargin +
                        body.anchors.bottomMargin
        implicitWidth: Math.max(headerLayout.implicitWidth + headerLayout.anchors.leftMargin + headerLayout.anchors.rightMargin,
                                body.implicitWidth + body.anchors.leftMargin + body.anchors.rightMargin)

        RowLayout {
            id: headerLayout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: Style.smallMargins
            anchors.leftMargin: Style.margins
            anchors.rightMargin: Style.margins
            spacing: 10

            Text {
                id: header
                Layout.fillWidth: true
                color: Style.colors.typography_Headlines_H2
                font: Style.newH2Font
                opacity: root.enabled ? 1 : Style.numbers.components_Disabled_opacity
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }

            InfoButton {
                id: infoButton
                Layout.alignment: Qt.AlignVCenter
                visible: typeof push === "string" && push !== ""
                push: ""
            }
        }


        Item {
            id: body
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: headerLayout.bottom
            anchors.topMargin: contentTopMargin
            anchors.bottomMargin: contentBottomMargin

            height: implicitHeight
            implicitHeight: childrenRect.height
        }
    }
}
