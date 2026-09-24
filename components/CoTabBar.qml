import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

Item {
    id: root

    default property alias content: tabButtonLayout.data

    implicitWidth: tabButtonLayout.implicitWidth
    implicitHeight: tabButtonLayout.implicitHeight

    Rectangle {
        id: tabButtonBackground
        anchors.fill: tabButtonLayout
        anchors.margins: 4
        color: Style.colors.typography_Background_Default
        radius: height / 2
    }

    RowLayout {
        id: tabButtonLayout
        anchors.fill: parent
        spacing: 0
    }
}
