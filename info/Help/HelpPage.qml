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
        text: qsTr("Help")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
        show_Image: true

    }


    HemsManager {
        id: hemsManager
        engine: _engine
    }

    ColumnLayout{
        id: helpOptionsColumnLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins

        RowLayout{
            VerticalDivider
            {
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.fillWidth: true
                dividerColor: Material.accent
            }
        }


        RowLayout{
            ConsolinnoItemDelegate{
                id: manual
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                text: qsTr("Manual")
                Layout.fillWidth: true
                onClicked:{

                    pageStack.push("ManualPage.qml")


                }
            }
        }

        RowLayout{
            VerticalDivider
            {
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.fillWidth: true
                dividerColor: Material.accent
            }
        }

        RowLayout{
            ConsolinnoItemDelegate{
                id: contact
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                text: qsTr("Installer contact")
                Layout.fillWidth: true
                onClicked:{

                    pageStack.push("ContactPage.qml", {hemsManager: hemsManager})

                }
            }
        }

        RowLayout{
            VerticalDivider
            {
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.fillWidth: true
                dividerColor: Material.accent
            }
        }

        RowLayout{
            ConsolinnoItemDelegate{
                id: service
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.fillWidth: true
                text: qsTr("%1 Service").arg(Configuration.appBranding)
                onClicked:{

                    pageStack.push("ServicePage.qml")

                }
            }

        }

        RowLayout{
            Label{
                id: infoManual
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: 20
                Layout.fillWidth: true
                text: qsTr("Under 'Manual' you will find current instructions for the app.")
                wrapMode: Text.WordWrap
            }

        }

        RowLayout{
            Label{
                id: infoDevice
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: 10
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("If you have any problems with your system, please contact the installer. Under 'Installation contact' the installer's details are stored (if he has entered them in the app).")

            }

        }

        RowLayout{
            Label{
                id: infoLeaflet
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: 10
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("If there is a problem with the %1 itself, then contact %2 Service.").arg(Configuration.deviceName).arg(Configuration.appBranding)
            }

        }







    }


}
