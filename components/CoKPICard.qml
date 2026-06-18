import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Nymea 1.0

import "../components"

Item {
    id: root

    property alias icon: icon.name
    property alias valueText: value.text
    property alias labelText: label.text
    property alias infoUrl: label.push
    property alias infoProperties: label.infoProperties

    implicitHeight: valueLayout.implicitHeight + label.implicitHeight + 2 * Style.extraSmallMargins
    implicitWidth: 100

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
        anchors.topMargin: valueLayout.height
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

    RowLayout {
        id: valueLayout
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        height: icon.size + 2 * Style.extraSmallMargins
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

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: valueLayout.bottom
        width: Math.min(naturalWidth, root.width - 2 * Style.extraSmallMargins)
        height: root.height - valueLayout.height

        Layout.fillWidth: false // overwrite LabelWithInfo default
        font: Style.newSmallFont
        fontColor: Style.colors.typography_Basic_Default
        textLabel.horizontalAlignment: Text.AlignHCenter
        textLabel.verticalAlignment: Text.AlignVCenter
    }
}
