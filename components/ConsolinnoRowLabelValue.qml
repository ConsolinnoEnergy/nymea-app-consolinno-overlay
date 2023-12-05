import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0

Item {
    id: root

    property alias label: label.text
    property alias value: value.text

    implicitHeight: contentColumn.height

    RowLayout {
        id: contentColumn

        width: parent.width
        spacing: Style.smallMargins

        Label {
            id: label

            Layout.fillWidth: false
            Layout.preferredWidth: parent.width * 0.75
        }

        Label {
            id: value

            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
        }
    }
}
