import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0

import "../components"

Item {
    id: root
    property alias checkBox: box
    property alias checked: box.checked
    property alias text: box.text
    property alias feedbackText: notification.text
    property bool showError: false

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
    implicitWidth: layout.implicitWidth + layout.anchors.leftMargin + layout.anchors.rightMargin

    ColumnLayout{
        id: layout
        anchors.fill: parent
        spacing: 0

        CheckBox {
            id: box
            Layout.fillWidth: true
            showError: root.showError
        }

        CoFieldNotification {
            id: notification
            Layout.fillWidth: true
            Layout.leftMargin: box.background.width
            text: ""
            visible: root.enabled && root.showError && text !== ""
        }
    }
}
