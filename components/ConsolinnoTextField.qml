import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import QtGraphicalEffects 1.15

TextField {
  id: root
  placeholderTextColor: Style.textfield

  background: Rectangle {
    color: "transparent"

    Rectangle {
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      height: 1
      color: root.focus ? Material.accentColor : Style.textfield
    }
  }
}
