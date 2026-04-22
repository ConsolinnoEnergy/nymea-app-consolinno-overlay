import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
            if (directionID == 1) {
                pageStack.pop();
            } else {
                root.done(false, false, true);
            }
        }
    }

    property UserConfiguration userconfig: hemsManager.userConfigurations.getUserConfiguration("528b3820-1b6d-4f37-aea7-a99d21d42e72")

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.margins

        Flickable {
            Layout.fillHeight: true
            Layout.fillWidth: true
            contentHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
            clip: true

            ColumnLayout {
                id: layout
                anchors.fill: parent
                spacing: Style.margins

                CoFrostyCard {
                    Layout.fillWidth: true
                    contentTopMargin: 8
                    headerText: qsTr("Contact (optional)")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoCard {
                            Layout.fillWidth: true
                            text: qsTr("To be available for the customer in case of questions or problems, enter your contact data here. The data will only be sent to the customer's app.")
                        }

                        CoInputField {
                            id: nameField
                            Layout.fillWidth: true
                            labelText: qsTr("Name")
                            text: userconfig.installerName
                        }

                        CoInputField {
                            id: companyField
                            Layout.fillWidth: true
                            labelText: qsTr("Workplace")
                            text: userconfig.installerWorkplace
                            textField.placeholderText: qsTr("Company")
                        }

                        CoInputField {
                            id: emailField
                            Layout.fillWidth: true
                            labelText: qsTr("E-mail")
                            text: userconfig.installerEmail
                            textField.placeholderText: qsTr("Example@mail.com")
                        }

                        CoInputField {
                            id: numberField
                            Layout.fillWidth: true
                            labelText: qsTr("Phone number")
                            text: userconfig.installerPhoneNr
                            textField.placeholderText: qsTr("+1 ")
                        }
                    }
                }
            }
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Next")
            onClicked:{
                hemsManager.setUserConfiguration(
                            {
                                installerName: nameField.text,
                                installerEmail: emailField.text,
                                installerPhoneNr: numberField.text,
                                installerWorkplace: companyField.text
                            });
                root.done(true, false, false);
            }
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Skip")
            secondary: true
            onClicked:{
                root.done(false, true, false);
            }
        }
    }
}
