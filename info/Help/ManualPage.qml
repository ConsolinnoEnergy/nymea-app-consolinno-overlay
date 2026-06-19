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
        text: qsTr("Manual")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    RowLayout{
        anchors {
            left: parent.left
            leftMargin: 16
            right:  parent.right
            rightMargin: 16
            top: parent.top
            topMargin: header.height
            bottom: parent.bottom
            bottomMargin: 16
        }

        Label{
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr('<html><style type="text/css"></style><p>You can find current manuals for %1 in the download area of our <a href="%2">website</a>.</p></html>').arg(Configuration.deviceName).arg(Configuration.downloadMedia)
            wrapMode: Text.WordWrap

            onLinkActivated:{
                Qt.openUrlExternally(link)
            }
        }
    }
}

