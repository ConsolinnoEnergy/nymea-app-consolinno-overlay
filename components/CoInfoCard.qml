import QtQuick 2.0
import QtQuick.Layouts 1.2
import Nymea 1.0

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
    implicitWidth: compactLayout ? 150 : 300

    Rectangle {
        id: background
        anchors.fill: parent
        radius: 8 // #TODO value from new style?
        color: Style.colors.typography_Background_Default

        Rectangle {
            id: backgroundInteractionOverlay
            anchors.fill: parent
            visible: root.clickable
            radius: 8 // #TODO value from new style?
            color: mouseArea.pressed ? Style.colors.typography_States_Pressed : "transparent"
            border.width: mouseArea.containsMouse ? 4 : 0
            border.color: mouseArea.containsMouse ? Style.colors.typography_States_Pressed : "transparent"
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
            Layout.fillWidth: compactLayout
            Layout.preferredWidth: compactLayout ? -1 : gridLayout.width / 2

            spacing: 8 // #TODO use value from new design

            ColorIcon {
                id: icon
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                size: 24 // #TODO use value from new style
                color: Style.colors.brand_Basic_Icon_accent
            }

            Text {
                id: titleText
                // #TODO font from new style
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: root.compactLayout ? 1 : 2
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }
        }

        Text {
            id: valueText
            // #TODO font from new style

            Layout.row: compactLayout ? 1 : 0
            Layout.column: compactLayout ? 0 : 1
            Layout.fillWidth: compactLayout
            Layout.preferredWidth: compactLayout ? -1 : gridLayout.width / 2
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
                          Style.colors.system_Warning_Status_border :
                          showErrorIndicator ?
                              Style.colors.system_Danger_Status_light_border :
                              "transparent"
        color: showWarningIndicator ?
                   Style.colors.system_Warning_Status_light :
                   showErrorIndicator ?
                       Style.colors.system_Danger_Status_light :
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
