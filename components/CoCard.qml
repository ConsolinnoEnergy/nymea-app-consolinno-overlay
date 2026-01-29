import QtQuick 2.0
import QtQuick.Layouts 1.2

import "../components"

Item {
    property alias text: titleText.text
    property alias helpText: helpText.text
    property alias labelText: labelText.text
    property bool showChildrenIndicator: false
    property alias iconLeft: leftIcon.name
    property alias iconRight: rightIcon.name

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#FFFFFF" // #TODO use values from new style

        Rectangle {
            id: backgroundInteractionOverlay
            anchors.fill: parent
            // #TODO is the transparent part (hover and pressed color) relative to CoInfoCard background or
            // relative to this background (i.e. do we need another (white) background)?
            color: {
                if (mouseArea.pressed) {
                    return "#1E242B2D"; // #TODO use values from new style
                } else if (mouseArea.containsMouse) {
                    return "#0F242B2D"; // #TODO use values from new style
                } else {
                    return "transparent";
                }
            }
        }
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.topMargin: 8 // #TODO use value from new design
        anchors.bottomMargin: 8 // #TODO use value from new design
        anchors.leftMargin: 16 // #TODO use value from new design
        anchors.rightMargin: 16 // #TODO use value from new design
        spacing: 16 // #TODO use value from new design

        ColorIcon {
            id: leftIcon
            Layout.alignment: Qt.AlignVCenter
            size: 24 // #TODO use value from new style
            // #TODO icon color?
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                id: titleText
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                // #TODO font from style
                font.pixelSize: 16
            }

            Text {
                id: helpText
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
                text: ""
                visible: text !== ""
                wrapMode: Text.WordWrap
                // #TODO font from style
                font.pixelSize: 13
            }

            Text {
                id: labelText
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
                text: ""
                visible: text !== ""
                wrapMode: Text.WordWrap
                // #TODO font from style
                font.pixelSize: 10
                color: "#627373" // #TODO use color from style
            }
        }

        ColorIcon {
            id: rightIcon
            Layout.alignment: Qt.AlignVCenter
            size: 24 // #TODO use value from new style
            // #TODO icon color?
        }

        ColorIcon {
            id: hasChildrenIcon
            name: Qt.resolvedUrl("qrc:/icons/next.svg") // #TODO icon from new style
            // #TODO icon color from new style?
            Layout.alignment:  Qt.AlignVCenter
            size: 18
            visible: showChildrenIndicator
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
}
