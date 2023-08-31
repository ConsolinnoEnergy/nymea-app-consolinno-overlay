import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root

    property string email: ""

    header: NymeaHeader {
        text: qsTr("Password Sent")
        backButtonVisible: true
        onBackPressed: pageStack.pop();
    }

    Item {
        id: contentRoot

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom

            leftMargin: 16
            rightMargin: 16
            bottomMargin: 16
        }

        Label {
            id: descriptionLabel

            width: parent.width
            anchors {
                bottom: loginRootItem.top
                bottomMargin: 48
            }
            text: qsTr("We have sent the password to ") + root.email
            font.pixelSize: Style.majorFontSize
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Item {
            id: loginRootItem

            width: parent.width
            height: parent.height / 2
            anchors.centerIn: parent

            RowLayout {
                id: resendPasswordLayout

                width: parent.width
                anchors {
                    bottom: getPasswordButton.top
                    bottomMargin: 32
                }

                Label {
                    text: qsTr("Did not recieve the password?")
                }

                Label {
                    text: qsTr("Resend Password")
                    color: Style.accentColor
                    font.underline: true

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("/ui/system/ForgotPasswordPage.qml"))
                        }
                    }
                }
            }

            Button {
                id: getPasswordButton

                width: parent.width
                anchors.centerIn: parent
                text: qsTr("Login")

                onClicked: {
                    pageStack.push(Qt.resolvedUrl("qrc:/ui/connection/LoginPage.qml"))
                }
            }
        }
    }
}
