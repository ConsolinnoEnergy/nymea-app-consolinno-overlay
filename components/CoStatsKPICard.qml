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
    implicitWidth: 300

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
            elide: Text.ElideRight
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
                elide: Text.ElideRight
            }
        }
    }
}
