import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.1
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2

import "../../components"
import "../../delegates"


Page {

    header: ConsolinnoHeader {
        id: header
        text: qsTr("Manual")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
        show_Image: false
    }



    RowLayout{
        anchors {
            left: parent.left
            leftMargin: 16
            right:  parent.right
            rightMargin: 16
            top: parent.top
            bottom: parent.bottom
            bottomMargin: 16
        }

        Label{
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: qsTr('<html><style type="text/css"></style><p>You can find current manuals for Consolinno HEMS in the download area of our <a href="https://consolinno.de/hems/#downloads">Website</a> </p></html>')
            wrapMode: Text.WordWrap

            onLinkActivated:{
                Qt.openUrlExternally(link)
            }
        }
    }
}

