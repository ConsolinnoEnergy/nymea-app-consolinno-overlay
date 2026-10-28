import QtQuick 2.0
import QtQuick.Layouts 1.2
import Nymea

import "../components"

CoBaseInfoCard {
    id: root

    property double socValue: 0
    property double powerValue: 0

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
            font: Style.newSmallFontBold
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
            font: Style.newSmallFontBold
            color: Style.colors.components_Dashboard_Info_card_value
            text: UiUtils.powerDisplayValue(Math.abs(root.powerValue)) + " " + UiUtils.powerDisplayUnit(root.powerValue)
        }
    }
}
