import QtQuick
import QtQuick.Layouts
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
    property alias infoUrl: titleText.push
    property alias helpText: helpText.text
    property alias labelText: labelText.text
    property bool showChildrenIndicator: false
    property alias iconLeft: leftIcon.name
    property alias iconLeftColor: leftIcon.color
    property alias iconRight: rightIcon.name
    property alias iconRightColor: rightIcon.color
    property alias interactive: mouseArea.enabled
    property int status: CoCard.StatusType.NoStatus
    property bool deletable: false

    signal clicked()
    signal deleteClicked()

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

            LabelWithInfo {
                id: titleText
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font: Style.newParagraphFont
                fontColor: Style.colors.typography_Basic_Default
                clip: true
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
            Layout.alignment: Qt.AlignVCenter
            size: 18
            visible: showChildrenIndicator
        }

        ColorIcon {
            id: deleteIcon
            name: Qt.resolvedUrl("qrc:/icons/delete_forever.svg")
            color: Style.colors.system_Danger_Accent
            Layout.alignment: Qt.AlignVCenter
            size: 24
            visible: false
            width: 0
            clip: true

            Behavior on width {
                NumberAnimation {
                    id: deleteWidthAnimation
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }

            // Needed to avoid a visual glitch when hiding the deleteIcon with animation.
            // Without this, the icon is visible in full size for a short moment just before
            // the width reaches zero. (This is also the case when using "visible: width > 0",
            // so that doesn't work, too.)
            onWidthChanged: {
                if (width < 1 && deleteWidthAnimation.running) {
                    visible = false;
                }
            }

            MouseArea {
                id: deleteMouseArea
                anchors.fill: parent
                onClicked: (mouse) => {
                    mouse.accepted = true;
                    deleteIcon.width = 0;
                    root.deleteClicked();
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        onClicked: (mouse) => {
            if (deleteIcon.visible && deleteIcon.contains(mapToItem(deleteIcon, mouse.x, mouse.y))) {
                mouse.accepted = false;
                return;
            }
            if (deleteIcon.visible) {
                deleteIcon.width = 0;
                return;
            }
            parent.clicked();
        }
        onPressAndHold: {
            if (root.deletable) {
                deleteIcon.visible = true;
                deleteIcon.width = deleteIcon.size;
            }
        }
    }
}
