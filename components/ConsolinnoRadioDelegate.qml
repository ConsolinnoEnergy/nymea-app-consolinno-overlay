import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.15
import Nymea 1.0


RadioDelegate {
    id: control

    text: control.text
    property int value: control.value
    property string description: control.description
    property int size: control.size
    checked: control.checked
    hoverEnabled: true
    Layout.fillWidth: true

    contentItem: ColumnLayout {
        spacing: 0

        Label {
            id: mainText
            rightPadding: control.indicator.width + control.spacing
            text: control.text
            opacity: enabled ? 1.0 : 0.3
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        Label {
            id: descriptionText
            visible: control.description.length > 1
            text: control.description
            font.pixelSize: 12
            wrapMode: Text.Wrap
            verticalAlignment: Text.AlignVCenter
        }
    }

    indicator: Rectangle {
        id: outterCircle
        implicitWidth: control.size
        implicitHeight: control.size
        x: control.width - width - control.rightPadding
        y: parent.height / 2 - height / 2
        radius: 13
        color: "transparent"
        border.color: control.checked ? Style.accentColor : Style.secondaryDark
        border.width: 2

        Rectangle {
            width: parent.implicitWidth - 10
            height: parent.implicitHeight - 10
            x: parent.width / 2 - width / 2
            y: parent.height / 2 - height / 2
            radius: 7
            color: control.down ? Style.secondaryDark : Style.accentColor
            visible: control.checked
        }
    }
}
