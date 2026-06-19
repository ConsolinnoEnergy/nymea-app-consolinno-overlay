import QtQuick
import QtQuick.Controls
import QtQml
import Nymea 1.0
import QtQuick.Layouts

import "../../components"
import "../../delegates"


Page {
    id: root
    bottomPadding: 0
    property int navigationFooterHeight: 0

    header: null

    CoHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        blurSource: bodyFlickable
        text: qsTr("Service %1").arg(Configuration.appBranding)
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Flickable {
        id: bodyFlickable
        anchors.fill: parent
        topMargin: header.height
        clip: true
        contentHeight: contentColumn.implicitHeight +
                       contentColumn.anchors.topMargin +
                       contentColumn.anchors.bottomMargin + root.navigationFooterHeight

        Component.onCompleted: Qt.callLater(() => contentY = -topMargin)

        ColumnLayout {
            id: contentColumn
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: app.margins

            RowLayout{
                Label{
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: qsTr("If there are problems with the %1, please refer to our service adress: ").arg(Configuration.deviceName)
                    wrapMode: Text.WordWrap
                }

            }

            RowLayout{
                Label{
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: qsTr("%1").arg(Configuration.serviceEmail)
                }

            }
        }
    }
}
