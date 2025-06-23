import QtQuick 2.9
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Nymea 1.0

Button {
    id: root

    property color backgroundColor

    Layout.fillWidth: true

    contentItem: Label {
        text: root.text
        anchors.fill: parent
        color: (Configuration.branding === "consolinno") ? Configuration.buttonTextColor : Style.consolinnoExtraDark
        font.pixelSize: 13
        font.letterSpacing: 2
        font.capitalization: Font.AllUppercase
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        visible: root.backgroundColor.length > 0
        color: root.backgroundColor
    }
}
