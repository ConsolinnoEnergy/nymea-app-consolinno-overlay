import QtQuick 2.0
import QtQuick.Layouts 1.2
import Nymea

import "../components"

CoBaseInfoCard {
    id: root

    property string operationState: ""
    property string startTime: ""
    property string endTime: ""

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.extraSmallMargins

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: paintedWidth
            font: Style.newSmallFont
            color: Style.colors.components_Dashboard_Info_card_value
            text: qsTr("Status")
        }

        Text {
            Layout.minimumWidth: paintedWidth
            horizontalAlignment: Text.AlignRight
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

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.extraSmallMargins

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: paintedWidth
            font: Style.newSmallFont
            color: Style.colors.components_Dashboard_Info_card_value
            text: qsTr("Start")
        }

        Text {
            Layout.minimumWidth: paintedWidth
            horizontalAlignment: Text.AlignRight
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

    RowLayout {
        Layout.fillWidth: true
        spacing: Style.extraSmallMargins

        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: paintedWidth
            font: Style.newSmallFont
            color: Style.colors.components_Dashboard_Info_card_value
            text: qsTr("Est. end")
        }

        Text {
            Layout.minimumWidth: paintedWidth
            horizontalAlignment: Text.AlignRight
            font: Style.newSmallFontBold
            color: Style.colors.components_Dashboard_Info_card_value
            text: root.endTime
        }
    }
}
