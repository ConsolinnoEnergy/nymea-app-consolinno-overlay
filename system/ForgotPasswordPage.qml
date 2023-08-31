import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root

    header: NymeaHeader {
        text: qsTr("Forgot Password?")
        backButtonVisible: true
        onBackPressed: pageStack.pop();
    }

    BusyOverlay {
        id: busyIndicator

        anchors.fill: parent
        shown: false
    }

    Item {
        id: contentRoot

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom

            leftMargin: Style.screenMargins
            rightMargin: Style.screenMargins
            bottomMargin: Style.screenMargins
        }

        opacity: busyIndicator.shown ? 0.5 : 1

        Label {
            id: descriptionLabel

            width: parent.width
            anchors {
                bottom: emailRootItem.top
                bottomMargin: 48
            }
            text: qsTr("Please enter the email address with which you created an account. We will send you a new automatically generated password.")
            font.pixelSize: Style.majorFontSize
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Item {
            id: emailRootItem

            width: parent.width
            height: parent.height / 2
            anchors.centerIn: parent

            ErrorTextField {
                id: emailTextField

                width: parent.width
                anchors {
                    bottom: noAccountLabel.visible ? noAccountLabel.top : getPasswordButton.top
                    bottomMargin: 32
                }
                label: qsTr("Email")
                placeholderText: qsTr("Enter your email")
                warningLabel: qsTr("You need to enter your email")
                inputMethodHints: Qt.ImhEmailCharactersOnly
                validator: RegExpValidator {
                    regExp: /[a-z0-9]+@[a-z]+\.[a-z]{2,3}/
                }
            }

            Label {
                id: noAccountLabel

                text: qsTr("The HEMS account does not exist for ") + emailTextField.text + qsTr(".") + qsTr("Please enter the email that was used for creating the account")
                width: parent.width
                anchors {
                    bottom: getPasswordButton.top
                    bottomMargin: 32
                }
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Style.majorFontSize
                color: Style.red
                visible: false
            }

            Button {
                id: getPasswordButton

                width: parent.width
                anchors.centerIn: parent
                text: qsTr("Get Password")

                onClicked: {
                    emailTextField.check()

                    if(emailTextField.acceptableInput) {
//                        busyIndicator.shown = true
                        pageStack.push(Qt.resolvedUrl("/ui/system/PasswordResetSuccessPage.qml"),{email: emailTextField.text})
                    }
                }
            }
        }
    }
}
