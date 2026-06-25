import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import "../components"

Page {
    id: root

    background: Rectangle { color: Style.colors.typography_Background_Default }

    property bool backButtonVisible: true
    property string headerLabel: ""
    property real headerHeight: header.height

    header: null
    footer: null

    CoHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        text: root.headerLabel
        backButtonVisible: root.backButtonVisible
        wrapMode: Text.WordWrap
        onBackPressed:{
            pageStack.pop()
        }
    }
}

