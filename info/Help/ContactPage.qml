import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material 2.1
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts

import "../../components"
import "../../delegates"



Page {

    header: ConsolinnoHeader {
        id: header
        text: qsTr("Contact")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
        show_Image: false

    }

    property HemsManager hemsManager
    property UserConfiguration userconfig: hemsManager.userConfigurations.getUserConfiguration("528b3820-1b6d-4f37-aea7-a99d21d42e72")

    ColumnLayout{
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins


        RowLayout{
            id: nameColum
            Label{
                text: qsTr("Name: ")
                Layout.rightMargin: app.margins
                Layout.leftMargin: app.margins
            }

            Label{
                id: installerName
                text: userconfig.installerName
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
            id: workplaceColum
            Label{
                Layout.preferredWidth: app.width - installerWorkplace.contentWidth - 5*app.margins
                Layout.rightMargin: app.margins
                Layout.leftMargin: 3*app.margins
                text: qsTr("Workplace: ")
                color: Material.accent
            }

            Label{
                id: installerWorkplace
                text: userconfig.installerWorkplace
            }

        }

        RowLayout{
            id: emailColum
            Label{
                Layout.preferredWidth: app.width - installerEmail.contentWidth - 5*app.margins
                Layout.rightMargin: app.margins
                Layout.leftMargin: 3*app.margins
                text: qsTr("E-mail: ")
                color: Material.accent
            }

            Label{
                id: installerEmail
                text:  userconfig.installerEmail
            }

        }

        RowLayout{
            id: numberColumn
            Label{
                Layout.preferredWidth: app.width - installerNumber.contentWidth - 5*app.margins
                Layout.rightMargin: app.margins
                Layout.leftMargin: 3*app.margins
                text: qsTr("Phone number: ")
                color: Material.accent
            }

            Label{
                id: installerNumber
                text: userconfig.installerPhoneNr
            }

        }

    }



}
