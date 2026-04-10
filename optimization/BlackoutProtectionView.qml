import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root
    property int directionID: 0

    signal done(bool skip, bool abort, bool back)

    header: NymeaHeader {
        text: qsTr("Blackout protection")
        backButtonVisible: true
        onBackPressed:{
            if (directionID == 0) {
                pageStack.pop();
            } else {
                root.done(false, false, true);
            }
        }
    }

    property int phaseLimit: 25
    property int configuredPhaseLimit: 25

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onHousholdPhaseLimitChanged: function(housholdPhaseLimit) {
            configuredPhaseLimit = housholdPhaseLimit;
        }

        onSetHousholdPhaseLimitReply: function(commandId, error) {
            if (commandId == d.pendingCallId) {
                d.pendingCallId = -1;
                var props = {};
                switch (error) {
                case "HemsErrorNoError":
                    pageStack.pop();
                    return;
                case "HemsErrorInvalidPhaseLimit":
                    props.text = qsTr("Invalid phase limit.");
                    break;
                default:
                    props.errorCode = error;
                }
                var comp = Qt.createComponent("../components/ErrorDialog.qml");
                var popup = comp.createObject(app, props);
                popup.open();
            }
        }
    }

    Component.onCompleted: {
        phaseLimit = hemsManager.housholdPhaseLimit;
        configuredPhaseLimit = hemsManager.housholdPhaseLimit;
        const comboIndex = currentCombo.comboBox.indexOfValue(configuredPhaseLimit);
        if (comboIndex !== -1) {
            currentCombo.comboBox.currentIndex = comboIndex;
            currentInput.textField.text = "16";
        } else {
            // Last item is "user defined" current.
            currentCombo.comboBox.currentIndex = currentCombo.comboBox.count -1;
            currentInput.textField.text = configuredPhaseLimit.toString();
        }
    }

    ListModel {
        id: blackoutProtectionModel
        ListElement { name: qsTr("25 A"); current: 25 }
        ListElement { name: qsTr("35 A"); current: 35 }
        ListElement { name: qsTr("40 A"); current: 40 }
        ListElement { name: qsTr("50 A"); current: 50 }
        ListElement { name: qsTr("63 A"); current: 63 }
        ListElement { name: qsTr("User defined"); current: 0 }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.margins

        CoFrostyCard {
            Layout.fillWidth: true
            contentTopMargin: Style.smallMargins
            headerText: qsTr("Blackout protection")

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.margins
                anchors.rightMargin: Style.margins
                spacing: 0

                CoComboBox {
                    id: currentCombo
                    Layout.fillWidth: true
                    labelText: qsTr("Blackout protection per phase") // #TODO wording
                    helpText: qsTr("Select the maximum current that this installation can safely handle.") // #TODO wording
                    model: blackoutProtectionModel
                    textRole: "name"
                    valueRole: "current"
                    onCurrentValueChanged: {
                        if (comboBox.currentValue > 0) {
                            root.phaseLimit = comboBox.currentValue;
                        } else {
                            if (currentInput.textField.acceptableInput) {
                                root.phaseLimit = parseInt(currentInput.textField.text);
                            }
                        }
                    }
                }


                CoInputField {
                    id: currentInput
                    Layout.fillWidth: true
                    visible: currentCombo.comboBox.currentValue === 0
                    labelText: qsTr("User defined current") // #TODO wording
                    helpText: qsTr("Enter a value between 16 and 100 A.") // #TODO wording
                    unit: "A"
                    textField.inputMethodHints: Qt.ImhDigitsOnly
                    textField.validator: RegularExpressionValidator {
                        regularExpression: /^(1[6-9]|[2-9][0-9]|100)$/
                    }
                    textField.onTextChanged: {
                        if (visible && textField.acceptableInput) {
                            root.phaseLimit = parseInt(textField.text)
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: savebutton
            Layout.fillWidth: true
            enabled: {
                if (currentCombo.comboBox.currentValue === 0 &&
                        !currentInput.textField.acceptableInput) {
                    return false;
                }
                return phaseLimit > 15;
            }
            text: qsTr("Save")

            onClicked: {
                if (directionID === 0) {
                    d.pendingCallId = hemsManager.setHousholdPhaseLimit(root.phaseLimit);
                } else if (directionID === 1) {
                    hemsManager.setHousholdPhaseLimit(root.phaseLimit);
                    root.done(false, false, false);
                }
            }
        }
    }
}
