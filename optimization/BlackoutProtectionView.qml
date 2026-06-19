import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root
    bottomPadding: 0
    property int navigationFooterHeight: 0
    property int directionID: 0

    signal done(bool skip, bool abort, bool back)

    header: null

    CoHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        blurSource: bodyFlickable
        text: qsTr("System")
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

    readonly property bool applyEnabled: {
        if (currentCombo.comboBox.currentValue === 0 &&
                !currentInput.textField.acceptableInput) {
            return false;
        }
        return phaseLimit > 15;
    }

    function applyChanges() {
        if (directionID === 0) {
            d.pendingCallId = hemsManager.setHousholdPhaseLimit(root.phaseLimit);
        } else if (directionID === 1) {
            hemsManager.setHousholdPhaseLimit(root.phaseLimit);
            root.done(false, false, false);
        }
    }

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

    Flickable {
        id: bodyFlickable
        anchors.fill: parent
        topMargin: header.height
        clip: true
        contentHeight: contentColumn.implicitHeight +
                       contentColumn.anchors.topMargin +
                       contentColumn.anchors.bottomMargin + root.navigationFooterHeight
        Component.onCompleted: Qt.callLater(() => contentY = -topMargin)

        ColumnLayout {
            id: contentColumn
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: Style.margins

            CoFrostyCard {
                Layout.fillWidth: true
                contentTopMargin: Style.smallMargins
                headerText: qsTr("Blackout protection")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoComboBox {
                        id: currentCombo
                        Layout.fillWidth: true
                        labelText: qsTr("Blackout protection per phase")
                        helpText: qsTr("Select the maximum current that this installation can safely handle.")
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
                        labelText: qsTr("User defined current")
                        unit: "A"
                        compact: true
                        helpText:
                            qsTr("The value must be between %1 and %2.")
                        .arg(currentInputValidator.bottom)
                        .arg(currentInputValidator.top)
                        feedbackText: qsTr("The value is outside the valid range.")
                        textField.inputMethodHints: Qt.ImhDigitsOnly
                        textField.validator: IntValidator {
                            id: currentInputValidator
                            bottom: 16
                            top: 100
                        }
                        textField.onTextChanged: {
                            if (visible && textField.acceptableInput) {
                                root.phaseLimit = parseInt(textField.text)
                            }
                        }
                    }
                }
            }
        }
    }

    property Component navbarControls: blackoutNavbarControls

    Component {
        id: blackoutNavbarControls
        CoNavbarButton {
            text: qsTr("Apply changes")
            enabled: root.applyEnabled
            onClicked: root.applyChanges()
        }
    }
}
