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
                text: qsTr("Service Consolinno")
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
                Layout.fillWidth: true
                text: qsTr("Under Manual you will find the the most recent version of the HEMS")
                wrapMode: Text.WordWrap
            }

        }

        RowLayout{
            Label{
                id: infoDevice
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.fillWidth: true
                text: qsTr("In case of problems with your ")

            }

        }







    }


}
