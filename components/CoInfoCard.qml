import QtQuick 2.0
import QtQuick.Layouts 1.2

import "../components"

Item {
    id: root
    property alias icon: icon.name
    property alias text: titleText.text
    property alias value: valueText.text
    property bool compactLayout: false
    // #TODO naming (warning, error), are both needed?
    property bool showWarningIndicator: false
    property bool showErrorIndicator: false
    property bool clickable: true

    signal clicked()

    implicitHeight: gridLayout.implicitHeight + gridLayout.anchors.topMargin + gridLayout.anchors.bottomMargin
    implicitWidth: gridLayout.implicitWidth + gridLayout.anchors.leftMargin + gridLayout.anchors.rightMargin

    Rectangle {
        id: background
        anchors.fill: parent
        radius: 8 // #TODO value from new style?
        color: "#FFFFFF" // #TODO use values from new style

        Rectangle {
            id: backgroundInteractionOverlay
            anchors.fill: parent
            visible: root.clickable
            radius: 8 // #TODO value from new style?
            color: mouseArea.pressed ? "#1F242B2D" : "transparent" // #TODO use values from new style
            border.width: mouseArea.containsMouse ? 4 : 0
            border.color: mouseArea.containsMouse ? "#1F242B2D" : "transparent";
        }
    }

    GridLayout {
        id: gridLayout
        anchors.fill: parent
        anchors.topMargin: 8 // #TODO use value from new design
        anchors.bottomMargin: 8 // #TODO use value from new design
        anchors.leftMargin: 16 // #TODO use value from new design
        anchors.rightMargin: 16 // #TODO use value from new design

        ColumnLayout {
            Layout.row: 0
            Layout.column: 0
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.fillWidth: true

            spacing: 8 // #TODO use value from new design

            ColorIcon {
                id: icon
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                size: 24 // #TODO use value from new style
                // #TODO icon color?
            }

            Text {
                id: titleText
                // #TODO font from new style
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Text {
            id: valueText
            // #TODO font from new style

            Layout.row: compactLayout ? 1 : 0
            Layout.column: compactLayout ? 0 : 1
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    Rectangle {
        id: indicator
        anchors {
            top: parent.top
            left: parent.left
            topMargin: 8 // #TODO this is probably not right yet since new design contains paddings
            leftMargin: 8
        }

        visible: showWarningIndicator || showErrorIndicator
        width: 17   // #TODO are these fixed values in new design?
        height: 17
        radius: width / 2
        border.width: 1
        border.color: showWarningIndicator ?
                          "#864A0D" : // #TODO use color from new style
                          showErrorIndicator ?
                              "#AA0A24" : // #TODO use color from new style
                              "transparent"
        color: showWarningIndicator ?
                   "#FFEE89" : // #TODO use color from new style
                   showErrorIndicator ?
                       "#FFC3CD" : // #TODO use color from new style
                       "transparent"
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (root.clickable) {
                root.clicked()
            }
        }
    }
}
