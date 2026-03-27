import QtQuick 2.0
import QtQuick.Layouts 1.2
import Nymea 1.0

import "../components"

Item {
    id: root
    property alias text: card.text
    property alias helpText: card.helpText
    property alias labelText: card.labelText
    property alias showChildrenIndicator: card.showChildrenIndicator
    property alias iconLeft: card.iconLeft
    property alias iconRight: card.iconRight

    signal clicked()
    signal dragStarted()

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
        anchors.topMargin: Style.smallMargins
        anchors.bottomMargin: Style.smallMargins
        anchors.leftMargin: Style.margins
        anchors.rightMargin: Style.margins
        spacing: Style.margins

        CoCard {
            id: card
            Layout.fillWidth: true
        }

        Rectangle {
            id: divider
            Layout.fillHeight: true
            width: 2
            color: Style.colors.typography_Basic_Divider
        }

        ColorIcon {
            id: dragHandleIcon
            name: Qt.resolvedUrl("qrc:/icons/drag_handle.svg")
            color: Style.colors.brand_Basic_Icon
            Layout.alignment:  Qt.AlignVCenter
            size: 24
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: root
        hoverEnabled: true
        onClicked: (mouse) => {
            if (!dragHandleIcon.contains(mapToItem(dragHandleIcon, mouse.x, mouse.y))) {
                console.warn("--- clicked");
                root.clicked();
            }
        }
        onPressed: (mouse) => {
            if (dragHandleIcon.contains(mapToItem(dragHandleIcon, mouse.x, mouse.y))) {
                console.warn("--- dragStarted");
                root.dragStarted();
            }
        }
    }
}
