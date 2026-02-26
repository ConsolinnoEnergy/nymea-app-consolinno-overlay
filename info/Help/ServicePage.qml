import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQml
import Nymea 1.0
import QtQuick.Layouts

import "../../components"
import "../../delegates"


Page {

    header: ConsolinnoHeader {
        id: header
        text: qsTr("Service %1").arg(Configuration.appBranding)
        backButtonVisible: true
        onBackPressed: pageStack.pop()
        show_Image: false
    }

    ColumnLayout{
        id: serviceConsolinnoColumnLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins


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
