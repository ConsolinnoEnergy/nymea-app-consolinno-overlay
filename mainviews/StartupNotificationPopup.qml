import QtQuick 2.8
import QtQuick.Window 2.15
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"

Dialog {
    id: startUpNotificationPopup
    property alias text: containerLabel.text
    Layout.margins: Style.margins
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: parent.width * 0.9
    parent: parent
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    contentItem: Label {
        id: containerLabel
        Layout.topMargin: app.margins
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        wrapMode: Text.WordWrap
    }
}

