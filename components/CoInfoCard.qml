import QtQuick
import QtQuick.Layouts
import Nymea

import "../components"

CoBaseInfoCard {
    id: root

    property alias value: valueText.text
    property alias unit: unitText.text

    Item {
        id: valueItem
        Layout.fillWidth: true
        Layout.fillHeight: true
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
