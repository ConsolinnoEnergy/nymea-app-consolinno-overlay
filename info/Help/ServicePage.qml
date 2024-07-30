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
                text: qsTr("If there are problems with the Leaflet, please refer to our service adress: ")
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
