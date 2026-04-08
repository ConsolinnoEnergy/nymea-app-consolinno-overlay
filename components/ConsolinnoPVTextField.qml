import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Nymea 1.0

Item {
    id: root

    property alias label: textLabel.text
    property alias unit: textUnit.text
    property alias maximumLength: textInput.maximumLength
    property alias validator: textInput.validator
    property alias text: textInput.text

    property bool acceptableInput: true

    property string currentLocale: Qt.locale().name
    property string errorMessage: ''

    property real padding: 12

    implicitHeight: inputLayout.height + warningLabel.height + root.padding

    RowLayout {
        id: inputLayout

        width: parent.width
        anchors.centerIn: parent
        spacing: Style.smallMargins

        Label {
            id: textLabel

            Layout.fillWidth: true
            font: Style.font
        }

        ConsolinnoTextField {
            id: textInput

            Layout.fillWidth: false
            Layout.preferredWidth: inputLayout.width * 0.20
            maximumLength: 7
            font: Style.font
            validator: DoubleValidator {
                bottom: -90
                top: 90
                decimals: 4
                notation: "StandardNotation"
            }
        }

        Label {
            id: textUnit

            Layout.fillWidth: false
            Layout.preferredWidth: inputLayout.width * 0.15
            text: qsTr("°")
            font: Style.font
            horizontalAlignment: Text.AlignRight
        }
    }

    Label {
        id: warningLabel

        anchors.top: inputLayout.bottom
        text: root.errorMessage
        color: Style.red
        font: Style.smallFont
        visible: !root.acceptableInput
    }

    function checkValue() {
        if(parseInt(textInput.text) < textInput.validator.bottom || parseInt(textInput.text) > textInput.validator.top) {
            root.errorMessage = qsTr("Please enter a value between ") + textInput.validator.bottom + qsTr(" and ") + textInput.validator.top + qsTr(" ");
            return;
        }
        root.checkLocale();
    }

    function checkLocale() {
        switch(root.currentLocale) {
        case 'en_US':
            root.errorMessage = qsTr('Please enter the value with a dot (.)')
            break;
        case 'de_DE':
            root.errorMessage = qsTr('Please enter the value with a comma (,)')
            break;
        default:
            break;
        }
    }

    function validateValue () {
        root.acceptableInput = textInput.acceptableInput

        if(!root.acceptableInput)
            root.checkValue();
    }
}
