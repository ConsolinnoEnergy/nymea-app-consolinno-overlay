import QtQuick
import QtQuick.Layouts
import QtQuick.Window

Item {
    id: root
    property string imgSource
    property int imgHeight

    Layout.fillWidth: true
    Layout.preferredHeight: imgHeight

    Image {
        id: picture
        anchors.fill: parent
        source: imgSource
        sourceSize: Qt.size(parent.width, parent.height)
        fillMode: Image.PreserveAspectFit
        smooth: true
    }
}
