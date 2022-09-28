import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import Nymea 1.0

ColumnLayout {
    id: root

    property bool signup: true

    // Only used when signup is true
    property int minPasswordLength: 8
    property bool requireSpecialChar: true
    property bool requireNumber: true
    property bool requireUpperCaseLetter: true
    property bool requireLowerCaseLetter: true

    readonly property alias password: passwordTextField.text

    readonly property bool isValidPassword:
        isLongEnough &&
        (hasLower || !requireLowerCaseLetter) &&
        (hasUpper || !requireUpperCaseLetter) &&
        (hasNumbers || !requireNumber) &&
        (hasSpecialChar || !requireSpecialChar)

    readonly property bool isValid: !signup || (isValidPassword && confirmationMatches)

    readonly property bool isLongEnough: passwordTextField.text.length >= minPasswordLength
    readonly property bool hasLower: passwordTextField.text.search(/[a-z]/) >= 0
    readonly property bool hasUpper: passwordTextField.text.search(/[A-Z/]/) >= 0
    readonly property bool hasNumbers: passwordTextField.text.search(/[0-9]/) >= 0
    readonly property bool hasSpecialChar: passwordTextField.text.search(/(?=.*?[$*.\[\]{}()?\-'"!@#%&/\\,><':;|_~`^])/) >= 0
    readonly property bool confirmationMatches: passwordTextField.text === confirmationPasswordTextField.text

    property bool hiddenPassword: true

    property bool showErrors: false

    signal accepted()

    RowLayout {
        Layout.fillWidth: true

        ColumnLayout{
        Layout.fillWidth: true
        spacing: 0

        NymeaTextField {
            id: passwordTextField
            Layout.fillWidth: true
            echoMode: root.hiddenPassword ? TextInput.Password : TextInput.Normal
            placeholderText: root.signup ? qsTr("Pick a password") : qsTr("Password")

            error: root.showErrors && !root.isValidPassword
            onAccepted: {
                if (!root.signup) {
                    root.accepted()
                } else {
                    confirmationPasswordTextField.focus = true
                }
            }

        }

        Label{
            id: tip
            wrapMode: Text.WordWrap
            font.pixelSize: 12
            Layout.fillWidth: true
            visible: root.signup && !root.isValidPassword
            text:{
                // add text and check if it condition is met
                var texts = []
                var checks = []
                texts.push(qsTr("Minimum %1 characters").arg(root.minPasswordLength))
                checks.push(root.isLongEnough)
                if (root.requireLowerCaseLetter) {
                    texts.push(qsTr("Lowercase letters"))
                    checks.push(root.hasLower)
                }
                if (root.requireUpperCaseLetter) {
                    texts.push(qsTr("Uppercase letters"))
                    checks.push(root.hasUpper)
                }
                if (root.requireNumber) {
                    texts.push(qsTr("Numbers"))
                    checks.push(root.hasNumbers)
                }
                if (root.requireSpecialChar) {
                    texts.push(qsTr("Special characters"))
                    checks.push(root.hasSpecialChar)
                }



                // add the texts in red
                // Label will check everytime, if a condition is satisfied the condition text will vanish
                var entry = "<font color=\"%1\">".arg(Style.red)
                for (var i = 0; i < texts.length; i++) {

                    if (!checks[i]){
                        entry += texts[i] + ", "
                    }
                }
                // end color red
                entry += "</font>"
                return entry


            }

        }



        }
        ColorIcon {
            Layout.preferredHeight: Style.iconSize
            Layout.preferredWidth: Style.iconSize
            name: "../images/eye.svg"
            color: root.hiddenPassword ? Style.iconColor : Style.accentColor
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.hiddenPassword = !root.hiddenPassword
                }
            }
        }
    }

    RowLayout {
        visible: root.signup

        NymeaTextField {
            id: confirmationPasswordTextField
            Layout.fillWidth: true
            echoMode: root.hiddenPassword ? TextInput.Password : TextInput.Normal
            placeholderText: qsTr("Confirm password")
            error: root.showErrors && (!root.isValidPassword || !root.confirmationMatches)

            onAccepted: root.accepted()
        }
    }
}
