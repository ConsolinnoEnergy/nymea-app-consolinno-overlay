import QtQuick 2.9
import QtQuick.Controls 2.3
import Nymea 1.0

MouseArea {
    id: root
    implicitHeight: 40
    implicitWidth: 200
    height: implicitHeight
    width: implicitWidth

    property alias text: textLabel.text
    property color color: "#81b832"

    Rectangle {
        anchors.fill: parent
        radius: 12
        gradient: Gradient {
            GradientStop { position: 0; color: root.color }
            GradientStop { position: 0.25; color: root.color }
            GradientStop { position: 0.75; color: "#333333" }
            GradientStop { position: 1; color: "#333333" }
        }
    }

    Label {
        id: textLabel
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        color: "white"
    }
}
