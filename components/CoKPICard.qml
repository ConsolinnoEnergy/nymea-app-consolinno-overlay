import QtQuick 2.0
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import Nymea 1.0

import "../components"

Item {
    id: root

    property alias icon: icon.name
    property alias valueText: value.text
    property alias labelText: label.text
    property alias infoUrl: label.push

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin

    Rectangle {
        id: background
        anchors.fill: parent
        color: Style.colors.typography_Background_Accent

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: roundedRectMask
        }
    }

    Rectangle {
        id: backgroundLabel
        anchors.fill: parent
        anchors.topMargin: valueLayout.height + layout.spacing
        color: Style.colors.typography_Background_Accent_secondary

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: backgroundLabelMaskSource
        }
    }

    Item {
        id: roundedRectMask
        width: background.width
        height: background.height
        layer.enabled: true
        visible: false
        Rectangle {
            anchors.fill: parent
            radius: Style.cornerRadius
        }
    }

    ShaderEffectSource {
        id: backgroundLabelMaskSource
        sourceItem: roundedRectMask
        sourceRect: Qt.rect(0, roundedRectMask.height / 2, roundedRectMask.width, roundedRectMask.height / 2)
    }


    ColumnLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 0

        RowLayout {
            id: valueLayout
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            spacing: Style.extraSmallMargins

            ColorIcon {
                id: icon
                Layout.alignment: Qt.AlignCenter
                Layout.leftMargin: visible ? Style.extraSmallMargins : 0
                Layout.topMargin: Style.extraSmallMargins
                Layout.bottomMargin: Style.extraSmallMargins
                size: 24
                color: Style.colors.brand_Basic_Icon
                visible: typeof name === "string" && name !== ""
            }

            Text {
                id: value
                Layout.alignment: Qt.AlignCenter
                Layout.rightMargin: Style.extraSmallMargins
                Layout.leftMargin: icon.visible ? 0 : Style.extraSmallMargins
                Layout.topMargin: Style.extraSmallMargins
                Layout.bottomMargin: Style.extraSmallMargins
                font: Style.newH3Font
                color: Style.colors.typography_Basic_Default
            }
        }

        LabelWithInfo {
            id: label
            Layout.fillWidth: true
            Layout.margins: Style.extraSmallMargins
            font: Style.newParagraphFont
            fontColor: Style.colors.typography_Basic_Default

        }
    }
}
