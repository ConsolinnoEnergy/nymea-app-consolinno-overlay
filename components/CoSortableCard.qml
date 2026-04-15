import QtQuick 2.0
import QtQuick.Layouts 1.2
import Nymea 1.0

import "../components"

Item {
    property alias text: card.text
    property alias helpText: card.helpText
    property alias labelText: card.labelText
    property alias showChildrenIndicator: card.showChildrenIndicator
    property alias iconLeft: card.iconLeft
    property alias iconRight: card.iconRight
    property alias card: card
    property bool dragging: false

    readonly property real dragHandleStartX: width - 2 * Style.margins - dragHandleIcon.width

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin

    Rectangle {
        anchors.fill: parent
        color: dragging ? Style.colors.typography_Background_Default : "transparent"

        Rectangle {
            anchors.fill: parent
            color: dragging ? Style.colors.typography_States_Pressed : "transparent"
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
            interactive: false
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
}
