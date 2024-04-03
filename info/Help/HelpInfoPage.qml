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
        text: qsTr("Help")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
        show_Image: false
    }

    ColumnLayout{
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: app.margins
            rightMargin: app.margins
            topMargin: app.margins
        }

        RowLayout{
            Label{
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: 20
                text: qsTr("Under 'Manual' you will find current instructions for the app.")
                wrapMode: Text.WordWrap
            }
        }

        RowLayout{
            Label{
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: 10
                text: qsTr("If you have any problems with your system, please contact the installer. Under 'Installation contact' the installer's details are stored (if he has entered them in the app).")
                wrapMode: Text.WordWrap
            }
        }

        RowLayout{
            Label{
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: 10
                text: qsTr("If there is a problem with the Leaflet itself, then contact Consolinno's service.")
                wrapMode: Text.WordWrap
            }
        }
    }
}
