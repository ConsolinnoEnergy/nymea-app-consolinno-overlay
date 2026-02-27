import QtQuick 2.0
import QtQuick.Layouts 1.2
import Nymea 1.0

import "../components"

Item {
    property alias text: titleText.text
    property alias helpText: helpText.text
    property alias labelText: labelText.text
    property bool showChildrenIndicator: false
    property alias iconLeft: leftIcon.name
    property alias iconRight: rightIcon.name

    signal clicked()

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin

    Rectangle {
        id: background
        anchors.fill: parent
        color: mouseArea.containsMouse ? Style.colors.typography_Background_Default : "transparent"

        Rectangle {
            id: backgroundInteractionOverlay
            anchors.fill: parent
            color: {
                if (mouseArea.pressed) {
                    return Style.colors.typography_States_Pressed;
                } else if (mouseArea.containsMouse) {
                    return Style.colors.typography_States_Hover;
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
            size: 24
            color: Style.colors.brand_Basic_Icon_accent
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                id: titleText
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                font: Style.newParagraphFont
                color: Style.colors.typography_Basic_Default
            }

            Text {
                id: helpText
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
                text: ""
                visible: text !== ""
                wrapMode: Text.WordWrap
                font: Style.newSmallFont
                color: Style.colors.typography_Basic_Default
            }

            Text {
                id: labelText
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
                text: ""
                visible: text !== ""
                wrapMode: Text.WordWrap
                font: Style.newExtraSmallFont
                color: Style.colors.typography_Basic_Secondary
            }
        }

        ColorIcon {
            id: rightIcon
            Layout.alignment: Qt.AlignVCenter
            size: 24
            color: Style.colors.brand_Basic_Icon
        }

        ColorIcon {
            id: hasChildrenIcon
            name: Qt.resolvedUrl("qrc:/icons/next.svg")
            color: Style.colors.brand_Basic_Icon
            Layout.alignment:  Qt.AlignVCenter
            size: 18
            visible: showChildrenIndicator
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: parent.clicked()
    }
}
