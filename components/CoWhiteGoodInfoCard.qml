import QtQuick 2.0
import QtQuick.Layouts 1.2
import Nymea

import "../components"

CoBaseInfoCard {
    id: root

    property string operationState: ""
    property string startTime: ""
    property string endTime: ""

    property bool needsLayoutBreak: {
        const statusPartsWidth = statusTitle.paintedWidth + statusLayout.columnSpacing + statusText.paintedWidth
        const startTimePartsWidth = startTimeTitle.paintedWidth + startTimeLayout.columnSpacing + startTimeText.paintedWidth
        const endTimePartsWidth = endTimeTitle.paintedWidth + endTimeLayout.columnSpacing + endTimeText.paintedWidth
        const maxPartsWidth = Math.max(statusPartsWidth, startTimePartsWidth, endTimePartsWidth)
        return maxPartsWidth > additionalContentContainer.width
    }

    GridLayout {
        id: statusLayout
        Layout.fillWidth: true
        columns: needsLayoutBreak ? 1 : 2
        rows: needsLayoutBreak ? 2 : 1
        columnSpacing: Style.extraSmallMargins
        rowSpacing: 0

        Text {
            id: statusTitle
            Layout.fillWidth: true
            Layout.minimumWidth: paintedWidth
            font: Style.newSmallFont
            color: Style.colors.components_Dashboard_Info_card_value
            text: qsTr("Status")
        }

        Text {
            id: statusText
            Layout.minimumWidth: paintedWidth
            horizontalAlignment: Text.AlignRight
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            font: Style.newSmallFontBold
            color: Style.colors.components_Dashboard_Info_card_value
            text: root.operationState
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Style.colors.typography_Basic_Divider
    }

    GridLayout {
        id: startTimeLayout
        Layout.fillWidth: true
        columns: needsLayoutBreak ? 1 : 2
        rows: needsLayoutBreak ? 2 : 1
        columnSpacing: Style.extraSmallMargins
        rowSpacing: 0

        Text {
            id: startTimeTitle
            Layout.fillWidth: true
            Layout.minimumWidth: paintedWidth
            font: Style.newSmallFont
            color: Style.colors.components_Dashboard_Info_card_value
            text: qsTr("Start")
        }

        Text {
            id: startTimeText
            Layout.minimumWidth: paintedWidth
            horizontalAlignment: Text.AlignRight
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            font: Style.newSmallFontBold
            color: Style.colors.components_Dashboard_Info_card_value
            text: root.startTime
        }
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Style.colors.typography_Basic_Divider
    }

    GridLayout {
        id: endTimeLayout
        Layout.fillWidth: true
        columns: needsLayoutBreak ? 1 : 2
        rows: needsLayoutBreak ? 2 : 1
        columnSpacing: Style.extraSmallMargins
        rowSpacing: 0

        Text {
            id: endTimeTitle
            Layout.fillWidth: true
            Layout.minimumWidth: paintedWidth
            font: Style.newSmallFont
            color: Style.colors.components_Dashboard_Info_card_value
            text: qsTr("Est. end")
        }

        Text {
            id: endTimeText
            Layout.minimumWidth: paintedWidth
            horizontalAlignment: Text.AlignRight
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            font: Style.newSmallFontBold
            color: Style.colors.components_Dashboard_Info_card_value
            text: root.endTime
        }
    }
}
