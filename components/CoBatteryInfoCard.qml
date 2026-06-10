import QtQuick 2.0
import QtQuick.Layouts 1.2
import Nymea 1.0

import "../components"

Item {
    id: root
    property alias icon: icon.name
    property alias text: titleText.text
    property double socValue: 0
    property double powerValue: 0
    property bool showWarningIndicator: false
    property bool showErrorIndicator: false
    property bool clickable: true

    signal clicked()

    implicitHeight: rowLayout.implicitHeight + rowLayout.anchors.topMargin + rowLayout.anchors.bottomMargin
    implicitWidth: 300

    Rectangle {
        id: background
        anchors.fill: parent
        radius: Style.cornerRadius
        color: Style.colors.typography_Background_Default

        Rectangle {
            id: backgroundInteractionOverlay
            anchors.fill: parent
            visible: root.clickable
            radius: Style.cornerRadius
            color: mouseArea.pressed ? Style.colors.typography_States_Pressed : "transparent"
            border.width: 4
            border.color: "transparent"
            ColorAnimation on border.color {
                id: borderColorAnimation
                duration: 300
            }
            Connections {
                target: mouseArea
                function onContainsMouseChanged() {
                    borderColorAnimation.stop();
                    borderColorAnimation.to = mouseArea.containsMouse ? Style.colors.typography_States_Hover_pressed_outline : "transparent";
                    borderColorAnimation.start();
                }
                function onPressed(mouse) {
                    borderColorAnimation.complete();
                }
            }
        }
    }

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        anchors.topMargin: Style.smallMargins
        anchors.bottomMargin: Style.smallMargins
        anchors.leftMargin: Style.margins
        anchors.rightMargin: Style.margins
        spacing: Style.margins

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.preferredWidth: (rowLayout.width - rowLayout.spacing) / 2

            spacing: Style.smallMargins

            ColorIcon {
                id: icon
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                size: 24
                color: Style.colors.brand_Basic_Icon_accent
            }

            Text {
                id: titleText
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: 2
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                font: Style.newParagraphFontBold
                color: Style.colors.components_Dashboard_Info_card_title
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.preferredWidth: (rowLayout.width - rowLayout.spacing) / 2
            spacing: Style.extraSmallMargins

            RowLayout {
                Layout.fillWidth: true
                spacing: Style.extraSmallMargins

                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: paintedWidth
                    font: Style.newSmallFont
                    color: Style.colors.components_Dashboard_Info_card_value
                    text: qsTr("SoC")
                }

                Text {
                    Layout.minimumWidth: paintedWidth
                    horizontalAlignment: Text.AlignRight
                    font: Style.newSmallFont
                    color: Style.colors.components_Dashboard_Info_card_value
                    text: root.socValue + " %"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Style.colors.typography_Basic_Divider
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Style.extraSmallMargins

                Text {
                    Layout.fillWidth: true
                    Layout.minimumWidth: paintedWidth
                    font: Style.newSmallFont
                    color: Style.colors.components_Dashboard_Info_card_value
                    text: Math.round(root.powerValue) > 0 ?
                              qsTr("Charging") :
                              Math.round(root.powerValue) < 0 ?
                                  qsTr("Discharging") :
                                  qsTr("Idle")
                }

                Text {
                    Layout.minimumWidth: paintedWidth
                    horizontalAlignment: Text.AlignRight
                    font: Style.newSmallFont
                    color: Style.colors.components_Dashboard_Info_card_value
                    text: Math.round(Math.abs(root.powerValue)) + " W" // #TODO kW for larger values
                }
            }
        }
    }

    Rectangle {
        id: indicator
        anchors {
            top: parent.top
            left: parent.left
            topMargin: 11
            leftMargin: 11
        }

        visible: showWarningIndicator || showErrorIndicator
        width: 17
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
                root.clicked();
            }
        }
    }
}
