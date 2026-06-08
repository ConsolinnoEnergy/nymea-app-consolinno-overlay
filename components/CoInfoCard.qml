import QtQuick 2.0
import QtQuick.Layouts 1.2
import Nymea 1.0

import "../components"

Item {
    id: root
    property alias icon: icon.name
    property alias text: titleText.text
    property alias value: valueText.text
    property alias unit: unitText.text
    property alias secondaryValue: secondaryValueText.text
    property alias secondaryUnit: secondaryUnitText.text
    property bool compactLayout: false
    property bool showWarningIndicator: false
    property bool showErrorIndicator: false
    property bool clickable: true

    signal clicked()

    implicitHeight: gridLayout.implicitHeight + gridLayout.anchors.topMargin + gridLayout.anchors.bottomMargin
    implicitWidth: compactLayout ? 150 : 300

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

    GridLayout {
        id: gridLayout
        anchors.fill: parent
        anchors.topMargin: Style.smallMargins
        anchors.bottomMargin: Style.smallMargins
        anchors.leftMargin: Style.margins
        anchors.rightMargin: Style.margins

        ColumnLayout {
            id: columnLayout
            Layout.row: 0
            Layout.column: 0
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            Layout.fillWidth: compactLayout
            Layout.preferredWidth: compactLayout ? -1 : gridLayout.width / 2

            spacing: Style.smallMargins

            RowLayout {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                spacing: Style.extraSmallMargins

                Item {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                    implicitHeight: icon.implicitHeight
                    implicitWidth: icon.implicitWidth

                    ColorIcon {
                        id: icon
                        anchors.centerIn: secondaryValueItem.visible ? undefined : parent
                        anchors.top: secondaryValueItem.visible ? parent.top : undefined
                        anchors.bottom: secondaryValueItem.visible ?  parent.bottom : undefined
                        anchors.right: secondaryValueItem.visible ?  parent.right : undefined

                        size: 24
                        color: Style.colors.brand_Basic_Icon_accent
                    }
                }

                Item {
                    id: secondaryValueItem
                    Layout.fillWidth: true
                    Layout.preferredWidth: 0
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                    visible: secondaryValueText.text !== ""

                    implicitHeight: secondaryValueText.paintedHeight
                    implicitWidth: secondaryValueText.paintedWidth + secondaryUnitText.paintedWidth

                    Text {
                        id: secondaryValueText
                        anchors {
                            top: parent.top
                            bottom: parent.bottom
                        }
                        x: 0

                        verticalAlignment: Text.AlignVCenter
                        font: Style.newH4Font
                        color: Style.colors.components_Dashboard_Info_card_value
                        text: ""
                    }

                    Text {
                        id: secondaryUnitText
                        anchors {
                            baseline: secondaryValueText.baseline
                            bottom: parent.bottom
                            left: secondaryValueText.right
                            leftMargin: 3
                        }

                        verticalAlignment: Text.AlignVCenter
                        font: Style.newExtraSmallFontBold
                        color: Style.colors.components_Dashboard_Info_card_value
                        text: ""
                    }
                }
            }


            Text {
                id: titleText
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: root.compactLayout ? 1 : 2
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                font: Style.newParagraphFontBold
                color: Style.colors.components_Dashboard_Info_card_title
            }
        }

        Item {
            id: valueItem
            Layout.row: compactLayout ? 1 : 0
            Layout.column: compactLayout ? 0 : 1
            Layout.fillWidth: compactLayout
            Layout.preferredWidth: compactLayout ? -1 : gridLayout.width / 2
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

            implicitHeight: valueText.paintedHeight
            implicitWidth: valueText.paintedWidth + unitText.paintedWidth

            Text {
                id: valueText
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
                x: (valueItem.width - width - unitText.width) / 2

                verticalAlignment: Text.AlignVCenter
                font: Style.newH2Font
                color: Style.colors.components_Dashboard_Info_card_value
            }

            Text {
                id: unitText
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: valueText.right
                    leftMargin: 3
                }

                verticalAlignment: Text.AlignVCenter
                font: Style.newParagraphFontBold
                color: Style.colors.components_Dashboard_Info_card_value
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
