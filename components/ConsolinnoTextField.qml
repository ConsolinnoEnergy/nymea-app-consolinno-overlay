import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea 1.0
import Qt5Compat.GraphicalEffects

TextField {
  id: root
  placeholderTextColor: Style.textfield

  background: Rectangle {
    color: "transparent"

    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      height: root.focus || mouseArea.containsMouse ? 2 : 1
      color: root.focus ? Material.accentColor : Style.textfield
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        preventStealing: true
        acceptedButtons: Qt.NoButton
    }
  }
}
