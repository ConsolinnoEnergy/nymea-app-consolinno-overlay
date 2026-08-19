import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Nymea 1.0

ColumnLayout {
    id: root

    property bool signup: true

    // Only used when signup is true
    property int minPasswordLength: 8
    property bool requireSpecialChar: false
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
            // ESUI-1615: Qt.ImhNoTextHandles used to be set here as a workaround for
            // QTBUG-146020 (QIOSTapRecognizer crashing on iOS when a field loses focus
            // while a dispatch_async block showing the edit menu is still pending), but
            // it also disabled the native edit menu entirely - including Paste - since
            // Qt's password fields rely on that same overlay for clipboard operations.
            // The crash is now guarded against natively via a runtime swizzle in
            // PlatformHelperIOS (see platformintegration/ios/platformhelperios.mm in
            // nymea-app), so this field can safely use the normal input handles again.
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
                var entry = "<font color=\"%1\">".arg(Material.accent)
                for (var i = 0; i < texts.length; i++) {

                    if (!checks[i] && (i === texts.length - 1)){
                        entry += texts[i] + ". "
                    }else if(!checks[i]){
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
            name: "/icons/eye.svg"
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
            // ESUI-1615: see comment on passwordTextField above - Qt.ImhNoTextHandles
            // removed now that the underlying QTBUG-146020 crash is guarded natively.
            placeholderText: qsTr("Confirm password")
            error: root.showErrors && (!root.isValidPassword || !root.confirmationMatches)

            onAccepted: root.accepted()
        }
    }
}
