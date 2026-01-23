import QtQuick 2.0
import QtQuick.Layouts 1.2

import "../components"
//import "../../nymea-app/nymea-app/ui/components" // #TODO can we have this import easier?

Item {
    property alias icon: icon.name
    property alias text: titleText.text
    property alias value: valueText.text
    property bool compactLayout: false
    // #TODO naming (warning, error), are both needed?
    property bool showWarningIndicator: false
    property bool showErrorIndicator: false

    implicitHeight: gridLayout.implicitHeight + gridLayout.anchors.topMargin + gridLayout.anchors.bottomMargin
    implicitWidth: gridLayout.implicitWidth + gridLayout.anchors.leftMargin + gridLayout.anchors.rightMargin

    Rectangle { // background
        anchors.fill: parent
        radius: 8
        color: "#FFFFFF" // #TODO use value from new style
        border.width: 0
    }

    Rectangle {
        id: indicator
        x: 8 // #TODO this is probably not right yet since new design contains paddings
        y: 8
        visible: showWarningIndicator || showErrorIndicator
        width: 23   // #TODO are these fixed values in new design?
        height: 23
        radius: width / 2
        border.width: 1
        border.color: showWarningIndicator ?
                          "#864A0D" : // #TODO use color from new style
                          showErrorIndicator ?
                              "#AA0A24" : // #TODO use color from new style
                              "transparent"
        color: showWarningIndicator ?
                   "FFEE89" : // #TODO use color from new style
                   showErrorIndicator ?
                       "FFC3CD" : // #TODO use color from new style
                       "transparent"
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
}
