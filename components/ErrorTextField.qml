import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import Nymea 1.0

Item {
    id: root

    property alias warningLabel: warningLabel.text
    property alias text: textField.text
    property alias inputMethodHints: textField.inputMethodHints
    property alias validator: textField.validator
    property alias placeholderText: textField.placeholderText

    property bool acceptableInput: !root.showErrors
    property bool showErrors: false
    property string label: "Label"

    function check() {
        if(!textField.acceptableInput) {
            root.showErrors = true
        } else {
            root.showErrors = false
        }
    }

    implicitHeight: mainColumn.height

    ColumnLayout {
        id: mainColumn

        width: parent.width

        Label {
            Layout.fillWidth: true
            text: qsTr("%1<font color=\"#cd5c5c\">%2</font>".arg(root.label).arg("*"))
            font.pixelSize: 16
            topPadding: 4
            bottomPadding: 4
        }

        NymeaTextField {
            id: textField

            Layout.fillWidth: true
            placeholderText: qsTr("Enter Your Label")
            font.pixelSize: 16
            echoMode: root.hiddenPassword ? TextInput.Password : TextInput.Normal
            error: root.showErrors
            topPadding: 4
            bottomPadding: 4
        }

        Label {
            id: warningLabel

            Layout.fillWidth: true
            text: "Error Text"
            color: Style.red
            font.pixelSize: 12
            visible: root.showErrors
            topPadding: 4
            bottomPadding: 4
        }
    }
}
