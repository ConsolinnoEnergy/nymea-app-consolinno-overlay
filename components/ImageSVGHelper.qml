import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

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
