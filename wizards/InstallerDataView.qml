import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import Nymea 1.0
import "../components"
import "../delegates"



Page{
    id: root
    signal done(bool saved, bool skip, bool back)
    property int directionID: 0

    header: NymeaHeader {
        text: qsTr("Contact")
        //text: userconfig.installerEmail
        backButtonVisible: true
        onBackPressed:{

            if(directionID == 1){
                pageStack.pop()
            } else{
                root.done(false, false, true)
            }


        }
    }


    property HemsManager hemsManager
    property UserConfiguration userconfig: hemsManager.userConfigurations.getUserConfiguration("528b3820-1b6d-4f37-aea7-a99d21d42e72")


    Flickable {
        anchors.fill: parent
        contentHeight: mainColumnLayout.height
        clip: true


        ColumnLayout{
            id: mainColumnLayout
            anchors { top: parent.top; left: parent.left; right: parent.right;}
            Layout.fillWidth: true

            Label{
                id: privacyText
                Layout.fillWidth: true
                Layout.rightMargin: app.margins
                Layout.leftMargin: app.margins
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignLeft
                horizontalAlignment: Text.AlignLeft
                text: qsTr("To be available for the customer in case of questions or problems, enter your contact data here. The data will only be sent to the customer's app.")

            }

            ColumnLayout{
                id: nameColum

                Label{
                    Layout.fillWidth: true
                    text: qsTr("Name: ")
                    Layout.rightMargin: app.margins
                    Layout.leftMargin: app.margins


                }
                ConsolinnoTextField{
                    id: nameField
                    Layout.fillWidth: true
                    Layout.topMargin: 0
                    Layout.rightMargin: Style.margins
                    Layout.leftMargin: Style.margins
                    text: userconfig.installerName
                    placeholderText: qsTr("First name Last name")
                }
            }

            ColumnLayout{
                id: workplaceColum
                Label{
                    Layout.fillWidth: true
                    Layout.rightMargin: app.margins
                    Layout.leftMargin: app.margins
                    text: qsTr("Workplace: ")
                }
                ConsolinnoTextField{
                    id: companyField
                    Layout.fillWidth: true
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
                    Layout.fillWidth: true
                    Layout.rightMargin: app.margins
                    Layout.leftMargin: app.margins
                    text: qsTr("E-mail: ")
                }
                ConsolinnoTextField{
                    id: emailField
                    Layout.fillWidth: true
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
                    Layout.fillWidth: true
                    Layout.rightMargin: app.margins
                    Layout.leftMargin: app.margins
                    text: qsTr("Phone number: ")
                }
                ConsolinnoTextField{
                    id: numberField
                    Layout.fillWidth: true
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
                Layout.preferredWidth: 200
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
                Layout.preferredWidth: 200
                text: qsTr("Skip")
                onClicked:{
                    root.done(false, true, false)
                }
            }
        }
    }
}
