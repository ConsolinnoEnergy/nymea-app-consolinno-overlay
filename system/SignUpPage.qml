/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

Page {
    id: root
    signal backPressed();

    header: NymeaHeader {
        text: qsTr("Welcome to %1!").arg(Configuration.systemName)
        backButtonVisible: true
        onBackPressed: root.backPressed()
    }

    Connections {
        target: engine.jsonRpcClient
        onAuthenticationFailed: {
            var popup = errorDialog.createObject(root)
            popup.text = qsTr("Sorry, that wasn't right. Try again please.")
            popup.open();
        }
        onCreateUserSucceeded: {
            engine.jsonRpcClient.authenticate(usernameTextField.text, passwordTextField.password, "nymea-app (" + PlatformHelper.deviceModel + ")");
        }

        onCreateUserFailed: {
            print("createUser failed")
            var message;
            switch (error) {
            case "UserErrorInvalidUserId":
                if (engine.jsonRpcClient.ensureServerVersion("7.0")) {
                    message = qsTr("The email you've entered isn't valid.")
                } else {
                    message = qsTr("The username you've entered isn't valid.")
                }
                break;
            case "UserErrorDuplicateUserId":
                message = qsTr("The username you've entered is already used.")
                break;
            case "UserErrorBadPassword":
                message = qsTr("The password you've chosen is too weak.")
                break;
            case "UserErrorBackendError":
                message = qsTr("An error happened with the user storage. Please make sure your %1 system is installed correctly.").arg(Configuration.systemName)
                break;
            }
            var popup = errorDialog.createObject(root, {text: message});
            popup.open();
        }
    }

    ColumnLayout {
        id: contentColumn

        anchors.fill: parent

        spacing: Style.margins

        RowLayout {
            Layout.margins: Style.margins
            spacing: Style.margins

            ColorIcon {
                Layout.preferredHeight: Style.iconSize * 2
                Layout.preferredWidth: Style.iconSize * 2
                name: "../images/lock-closed.svg"
                color: Style.accentColor
            }

            Label {
                Layout.fillWidth: true
                text: engine.jsonRpcClient.initialSetupRequired ?
                          qsTr("In order to use your %1 system, please create an account.").arg(Configuration.systemName)
                        : qsTr("In order to use your %1 system, please log in.").arg(Configuration.systemName)
                wrapMode: Text.WordWrap
            }
        }


        ColumnLayout {
            id: loginForm
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
            Layout.alignment: Qt.AlignTop

            property bool showErrors: false

//            Label {
//                text: (engine.jsonRpcClient.ensureServerVersion("6.0") ? qsTr("Username") : qsTr("Your e-mail address"))
//                Layout.fillWidth: true
//                Layout.minimumWidth: implicitWidth
//            }
//            NymeaTextField {
//                id: usernameTextField
//                Layout.fillWidth: true
//                placeholderText: qsTr("Required")
//                inputMethodHints: engine.jsonRpcClient.ensureServerVersion("6.0")
//                                  ? Qt.ImhEmailCharactersOnly | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
//                                  : Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
//                error: loginForm.showErrors && !acceptableInput
//                validator: RegExpValidator {
//                    regExp: /[a-zA-Z0-9_\\.+-@]{3,}/
//                }
//            }

//            Rectangle {
//                id: errorRect

//                Layout.fillHeight: true
//                Layout.fillWidth: true
//                color: "red"
//            }

            ErrorTextField {
                id: usernameTextField
                Layout.fillWidth: true
//                Layout.fillHeight: true
                label: qsTr("Username")
                placeholderText: qsTr("Enter your username")
                inputMethodHints: engine.jsonRpcClient.ensureServerVersion("6.0")
                                  ? Qt.ImhEmailCharactersOnly | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                                  : Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                validator: RegExpValidator {
                    regExp: /[a-zA-Z0-9_\\.+-@]{3,}/
                }
                warningLabel: qsTr("You need to enter your email")
            }

//            Label {
//                text: qsTr("Email")
//                Layout.fillWidth: true
//                //                visible: engine.jsonRpcClient.ensureServerVersion("6.0") && engine.jsonRpcClient.initialSetupRequired
//            }

//            TextField {
//                id: emailTextField
//                Layout.fillWidth: true
//                placeholderText: qsTr("Required")
//                //                visible: engine.jsonRpcClient.ensureServerVersion("6.0") && engine.jsonRpcClient.initialSetupRequired
//            }

            ErrorTextField {
                id: emailTextField
                Layout.fillWidth: true
//                Layout.fillHeight: true
                label: qsTr("Email")
                placeholderText: qsTr("Enter your email")
                warningLabel: qsTr("You need to enter your email")
                inputMethodHints: Qt.ImhEmailCharactersOnly
                validator: RegExpValidator {
                    regExp: /[a-z0-9]+@[a-z]+\.[a-z]{2,3}/
                }
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("%1<font color=\"#cd5c5c\">%2</font>".arg("Password").arg("*"))
            }

            ConsolinnoPasswordTextField {
                id: passwordTextField
                Layout.fillWidth: true
//                minPasswordLength: 8
//                requireLowerCaseLetter: true
//                requireUpperCaseLetter: true
//                requireNumber: true
//                requireSpecialChar: false
                signup: true //engine.jsonRpcClient.initialSetupRequired
                showErrors: loginForm.showErrors
                onAccepted: {
                    if (!signup) {
                        okButton.clicked()
                    }
                }
            }

        }

        Button {
            id: okButton
            Layout.fillWidth: true
            Layout.leftMargin: app.margins; Layout.rightMargin: app.margins; Layout.bottomMargin: app.margins
            text: qsTr("OK")
            onClicked: {
                usernameTextField.check()
                emailTextField.check()
                loginForm.showErrors = true

                if (!usernameTextField.acceptableInput || !passwordTextField.isValid || !emailTextField.acceptableInput) {
                    return;
                } else {
                    errorRect.color = "green"
                }

                //                if (engine.jsonRpcClient.initialSetupRequired) {
                //                    print("create user")
                //                    engine.jsonRpcClient.createUser(usernameTextField.text, passwordTextField.password, displayNameTextField.text, emailTextField.text);
                //                } else {
                //                    print("authenticate", usernameTextField.text, passwordTextField.text, "nymea-app")
                //                    engine.jsonRpcClient.authenticate(usernameTextField.text, passwordTextField.password, "nymea-app (" + PlatformHelper.deviceModel + ")");
                //                }
            }
        }
    }

    Component {
        id: errorDialog
        ErrorDialog {

        }
    }
}
