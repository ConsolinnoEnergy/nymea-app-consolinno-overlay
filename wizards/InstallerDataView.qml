import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.12

import Nymea 1.0
import "../components"
import "../delegates"



Page{
    id: root
    signal done(bool saved, bool skip, bool back)

    header: NymeaHeader {
        text: qsTr("Contact")
        //text: userconfig.installerEmail
        backButtonVisible: true
        onBackPressed: root.done(false, false, true)
    }


    property HemsManager hemsManager
    property UserConfiguration userconfig: hemsManager.userConfigurations.getUserConfiguration("528b3820-1b6d-4f37-aea7-a99d21d42e72")

    ColumnLayout{
        id: mainColumnLayout
        anchors { top: parent.top; left: parent.left; right: parent.right;}

        Label{
            id: privacyText
            Layout.preferredWidth: app.width - 2*app.margins
            Layout.margins: app.margins
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignLeft
            horizontalAlignment: Text.AlignLeft
            text: qsTr("To be available for the customer in case of questions or problems, enter your contact data here. The data will only be sent to the customer's app.")

        }

        ColumnLayout{
            id: nameColum

            Label{
                Layout.preferredWidth: app.width - app.margins
                text: qsTr("Name: ")
                Layout.rightMargin: app.margins
                Layout.leftMargin: app.margins


            }
            TextField{
                id: nameField
                Layout.preferredWidth: app.width - 2*app.margins
                Layout.topMargin: 0
                Layout.rightMargin: app.margins
                Layout.leftMargin: app.margins
                text: userconfig.installerName
                placeholderText: qsTr("Firstname Lastname")
            }
        }

        ColumnLayout{
            id: workplaceColum
            Label{
                Layout.preferredWidth: app.width - 2*app.margins
                Layout.rightMargin: app.margins
                Layout.leftMargin: app.margins
                text: qsTr("Workplace: ")
            }
            TextField{
                id: companyField
                Layout.preferredWidth: app.width - 2*app.margins
                Layout.topMargin: 0
                Layout.rightMargin: app.margins
                Layout.leftMargin: app.margins
                text: userconfig.installerWorkplace
                placeholderText: qsTr("Company")

            }
        }

        ColumnLayout{
            id: emailColum
            Label{
                Layout.preferredWidth: app.width - 2*app.margins
                Layout.rightMargin: app.margins
                Layout.leftMargin: app.margins
                text: qsTr("E-mail: ")
            }
            TextField{
                id: emailField
                Layout.preferredWidth: app.width - 2*app.margins
                Layout.topMargin: 0
                Layout.rightMargin: app.margins
                Layout.leftMargin: app.margins
                text: userconfig.installerEmail
                placeholderText: qsTr("Example@mail.com")

            }
        }

        ColumnLayout{
            id: numberColumn
            Label{
                Layout.preferredWidth: app.width - 2*app.margins
                Layout.rightMargin: app.margins
                Layout.leftMargin: app.margins
                text: qsTr("Phone number: ")
            }
            TextField{
                id: numberField
                Layout.preferredWidth: app.width - 2*app.margins
                Layout.topMargin: 0
                Layout.rightMargin: app.margins
                Layout.leftMargin: app.margins
                text: userconfig.installerPhoneNr
                placeholderText: qsTr("+1 ")

            }
        }

        Button {
            Layout.topMargin: 10
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 300
            text: qsTr("Save")
            onClicked:{
                // TODO:
                // add the setter for the Config
                hemsManager.setUserConfiguration({installerName: nameField.text, installerEmail: emailField.text, installerPhoneNr: numberField.text, installerWorkplace: companyField.text})
                root.done(true, false, false)
            }
        }

        Button {

            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 300
            text: qsTr("Skip")
            onClicked:{
                root.done(false, true, false)
            }
        }




    }


}
