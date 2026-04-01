import QtQuick 2.0
import QtQuick.Layouts 1.2
import Nymea 1.0

import "../components"

Item {
    id: root

    enum StatusType {
        NoStatus,
        Neutral,
        Success,
        Warning,
        Danger
    }

    property alias text: titleText.text
    property alias helpText: helpText.text
    property alias labelText: labelText.text
    property bool showChildrenIndicator: false
    property alias iconLeft: leftIcon.name
    property alias iconRight: rightIcon.name
    property alias interactive: mouseArea.enabled
    property int status: CoCard.StatusType.NoStatus

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
        anchors.topMargin: Style.smallMargins
        anchors.bottomMargin: Style.smallMargins
        anchors.leftMargin: Style.margins
        anchors.rightMargin: Style.margins
        spacing: Style.margins

        ColorIcon {
            id: leftIcon
            Layout.alignment: Qt.AlignVCenter
            size: 24
            color: Style.colors.brand_Basic_Icon_accent
            name: ""
            visible: name !== ""
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
            name: ""
            visible: name !== ""
        }

        Rectangle {
            id: statusLight
            Layout.alignment: Qt.AlignCenter
            visible: root.status !== CoCard.StatusType.NoStatus
            width: 17
            height: 17
            radius: width / 2
            border.width: 1
            border.color: {
                switch (root.status) {
                case CoCard.StatusType.NoStatus:
                    return "transparent";
                case CoCard.StatusType.Neutral:
                    return Style.colors.system_Neutral_Status_light_border;
                case CoCard.StatusType.Success:
                    return Style.colors.system_Success_Status_light_border;
                case CoCard.StatusType.Warning:
                    return Style.colors.system_Warning_Status_border;
                case CoCard.StatusType.Danger:
                    return Style.colors.system_Danger_Status_light_border;
                }
            }
            color: {
                switch (root.status) {
                case CoCard.StatusType.NoStatus:
                    return "transparent";
                case CoCard.StatusType.Neutral:
                    return Style.colors.system_Neutral_Status_light;
                case CoCard.StatusType.Success:
                    return Style.colors.system_Success_Status_light;
                case CoCard.StatusType.Warning:
                    return Style.colors.system_Warning_Status_light;
                case CoCard.StatusType.Danger:
                    return Style.colors.system_Danger_Status_light;
                }
            }
        }

        ColorIcon {
            id: hasChildrenIcon
            name: Qt.resolvedUrl("qrc:/icons/arrow_forward_ios.svg")
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
