import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Nymea

import "../components"

Item {
    id: root

    property alias icon: icon.name
    property alias valueText: value.text
    property alias labelText: label.text

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    implicitWidth: layout.implicitWidth

    Rectangle {
        id: background
        anchors.fill: parent
        color: Style.colors.typography_Background_Default
        border.width: 1
        border.color: Style.colors.components_Statistics_KPI_card_border
        radius: Style.cornerRadius
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.topMargin: Style.smallMargins
        anchors.bottomMargin: Style.smallMargins
        spacing: Style.extraExtraSmallMargins

        Label {
            id: value
            Layout.fillWidth: true
            font: Style.newH3Font
            horizontalAlignment: Text.AlignHCenter
            color: Style.colors.typography_Basic_Default
        }

        RowLayout {
            id: labelLayout
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            spacing: Style.extraSmallMargins

            ColorIcon {
                id: icon
                Layout.alignment: Qt.AlignCenter
                size: 16
                color: Style.colors.brand_Basic_Icon
                visible: typeof name === "string" && name !== ""
            }

            Label {
                id: label
                Layout.alignment: Qt.AlignCenter
                font: Style.newSmallFont
                color: Style.colors.typography_Basic_Default
            }
        }
    }

    // RowLayout {
    //     id: valueLayout
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     anchors.top: parent.top
    //     height: icon.size + 2 * Style.extraSmallMargins
    //     spacing: Style.extraSmallMargins

    //     ColorIcon {
    //         id: icon
    //         Layout.alignment: Qt.AlignCenter
    //         Layout.leftMargin: visible ? Style.extraSmallMargins : 0
    //         Layout.topMargin: Style.extraSmallMargins
    //         Layout.bottomMargin: Style.extraSmallMargins
    //         size: 24
    //         color: Style.colors.brand_Basic_Icon
    //         visible: typeof name === "string" && name !== ""
    //     }

    //     Text {
    //         id: value
    //         Layout.alignment: Qt.AlignCenter
    //         Layout.rightMargin: Style.extraSmallMargins
    //         Layout.leftMargin: icon.visible ? 0 : Style.extraSmallMargins
    //         Layout.topMargin: Style.extraSmallMargins
    //         Layout.bottomMargin: Style.extraSmallMargins
    //         font: Style.newH3Font
    //         color: Style.colors.typography_Basic_Default
    //     }
    // }

    // LabelWithInfo {
    //     id: label

    //     anchors.horizontalCenter: parent.horizontalCenter
    //     anchors.top: valueLayout.bottom
    //     width: Math.min(naturalWidth, root.width - 2 * Style.extraSmallMargins)
    //     height: root.height - valueLayout.height

    //     Layout.fillWidth: false // overwrite LabelWithInfo default
    //     font: Style.newSmallFont
    //     fontColor: Style.colors.typography_Basic_Default
    //     textLabel.horizontalAlignment: Text.AlignHCenter
    //     textLabel.verticalAlignment: Text.AlignVCenter
    // }
}
