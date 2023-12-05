import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0

Item {
    id: root

    property alias text: switchElement.text
    property alias checked: switchElement.checked
    property alias warningText: warningText.text

    implicitHeight: contentColumn.height

    ColumnLayout {
        id: contentColumn

        width: parent.width
        spacing: Style.smallMargins

        SwitchDelegate {
            id: switchElement

            Layout.fillWidth: true
            padding: 0
            topPadding: 0
            bottomPadding: 0

            contentItem: Label {
                   text: switchElement.text
                   elide: Text.ElideRight
                   verticalAlignment: Text.AlignVCenter
                   horizontalAlignment: Text.AlignLeft
               }
        }

        Label {
            id: warningText

            Layout.fillWidth: true
            font: Style.smallFont
            wrapMode: Text.WordWrap
            color: Style.darkGray
        }
    }
}
