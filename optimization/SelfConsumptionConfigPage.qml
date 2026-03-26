import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtQml 2.2
import Nymea 1.0

import "qrc:/ui/components"

import "../components"
import "../delegates"
import "../devicepages"

GenericConfigPage {
    id: root

    property SelfConsumptionConfiguration selfConsumptionConfiguration: hemsManager.selfConsumptionConfiguration
    readonly property bool selfConsumptionSupported: hemsManager.selfConsumptionSupported

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    title: qsTr("Self-consumption")
    headerOptionsVisible: false

    // Enable save button when values change
    function enableSave() {
        if (!selfConsumptionConfiguration) return;
        var configTargetPower = selfConsumptionConfiguration.selfConsumptionTargetPower
        var configKp = selfConsumptionConfiguration.selfConsumptionKp
        var configKi = selfConsumptionConfiguration.selfConsumptionKi
        var configKd = selfConsumptionConfiguration.selfConsumptionKd

        // Get the text field values, defaulting to current config values if empty
        var fieldTargetPower = targetPowerField.text !== "" ? parseFloat(targetPowerField.text) : configTargetPower
        var fieldKp = kpField.text !== "" ? parseFloat(kpField.text) : configKp
        var fieldKi = kiField.text !== "" ? parseFloat(kiField.text) : configKi
        var fieldKd = kdField.text !== "" ? parseFloat(kdField.text) : configKd

        // Handle NaN cases
        if (isNaN(fieldTargetPower)) fieldTargetPower = configTargetPower
        if (isNaN(fieldKp)) fieldKp = configKp
        if (isNaN(fieldKi)) fieldKi = configKi
        if (isNaN(fieldKd)) fieldKd = configKd

        saveButton.enabled = selfConsumptionConfiguration.selfConsumptionEnabled !== selfConsumptionEnabledSwitch.checked ||
                             fieldTargetPower !== configTargetPower ||
                             fieldKp !== configKp ||
                             fieldKi !== configKi ||
                             fieldKd !== configKd
    }

    // Feature not supported notification
    CoNotification {
        Layout.fillWidth: true
        Layout.bottomMargin: 15
        type: CoNotification.Type.Info
        visible: !selfConsumptionSupported
        title: qsTr("Feature not available")
        message: qsTr("Self-consumption optimization is not supported by your backend. Please update your system.")
    }

    content: [
        Flickable {
            anchors.fill: parent
            contentHeight: columnLayoutContainer.implicitHeight +
                          columnLayoutContainer.anchors.topMargin +
                          columnLayoutContainer.anchors.bottomMargin
            topMargin: 0
            clip: true

            ColumnLayout {
                id: columnLayoutContainer
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.margins: app.margins

                visible: selfConsumptionSupported

                // Main Enable Switch
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.smallMargins

                    Label {
                        text: qsTr("Self-consumption optimization")
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                    }

                    ConsolinnoSwitch {
                        id: selfConsumptionEnabledSwitch
                        height: 18
                        spacing: 1
                        checked: selfConsumptionConfiguration.selfConsumptionEnabled

                        onClicked: {
                            enableSave()
                        }

                        Component.onCompleted: {
                            checked = selfConsumptionConfiguration.selfConsumptionEnabled
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.smallMargins
                    wrapMode: Text.WordWrap
                    font.pixelSize: app.smallFont
                    color: Style.subTextColor
                    text: qsTr("Optimizes battery usage to maximize self-consumption of locally produced energy.")
                }

                // Controller Parameters Section
                Label {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.margins * 2
                    text: qsTr("Controller parameters")
                    font.weight: Font.Bold
                    visible: selfConsumptionEnabledSwitch.checked
                }

                // Target Power
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.smallMargins
                    visible: selfConsumptionEnabledSwitch.checked

                    Label {
                        text: qsTr("Target power")
                        Layout.fillWidth: true
                    }

                    ConsolinnoTextField {
                        id: targetPowerField
                        Layout.preferredWidth: 100
                        horizontalAlignment: Text.AlignRight
                        validator: RegExpValidator {
                            regExp: /^-?\d*\.?\d+$/
                        }
                        text: selfConsumptionConfiguration ? selfConsumptionConfiguration.selfConsumptionTargetPower : "0"

                        onTextChanged: {
                            enableSave()
                        }
                    }

                    Label {
                        text: "W"
                        Layout.leftMargin: 5
                    }
                }

                // Kp (Proportional gain)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.smallMargins
                    visible: selfConsumptionEnabledSwitch.checked

                    Label {
                        text: qsTr("Kp (Proportional)")
                        Layout.fillWidth: true
                    }

                    ConsolinnoTextField {
                        id: kpField
                        Layout.preferredWidth: 100
                        horizontalAlignment: Text.AlignRight
                        validator: RegExpValidator {
                            regExp: /^-?\d*\.?\d+$/
                        }
                        text: selfConsumptionConfiguration ? selfConsumptionConfiguration.selfConsumptionKp : "0"

                        onTextChanged: {
                            enableSave()
                        }
                    }
                }

                // Ki (Integral gain)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.smallMargins
                    visible: selfConsumptionEnabledSwitch.checked

                    Label {
                        text: qsTr("Ki (Integral)")
                        Layout.fillWidth: true
                    }

                    ConsolinnoTextField {
                        id: kiField
                        Layout.preferredWidth: 100
                        horizontalAlignment: Text.AlignRight
                        validator: RegExpValidator {
                            regExp: /^-?\d*\.?\d+$/
                        }
                        text: selfConsumptionConfiguration ? selfConsumptionConfiguration.selfConsumptionKi : "0"

                        onTextChanged: {
                            enableSave()
                        }
                    }
                }

                // Kd (Derivative gain)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.smallMargins
                    visible: selfConsumptionEnabledSwitch.checked

                    Label {
                        text: qsTr("Kd (Derivative)")
                        Layout.fillWidth: true
                    }

                    ConsolinnoTextField {
                        id: kdField
                        Layout.preferredWidth: 100
                        horizontalAlignment: Text.AlignRight
                        validator: RegExpValidator {
                            regExp: /^-?\d*\.?\d+$/
                        }
                        text: selfConsumptionConfiguration ? selfConsumptionConfiguration.selfConsumptionKd : "0"

                        onTextChanged: {
                            enableSave()
                        }
                    }
                }

                // Info Label
                Label {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.smallMargins
                    wrapMode: Text.WordWrap
                    font.pixelSize: app.smallFont
                    color: Style.subTextColor
                    text: qsTr("PID controller parameters control the response behavior of the self-consumption optimization. Default values are recommended for most installations.")
                    visible: selfConsumptionEnabledSwitch.checked
                }

                // Error Handling Connections
                Connections {
                    target: hemsManager
                    onSetSelfConsumptionConfigReply: {
                        if (commandId === d.pendingCallId) {
                            d.pendingCallId = -1
                            var error = data["hemsError"] || "HemsErrorNoError"
                            let errorProps = {}
                            switch (error) {
                            case "HemsErrorNoError":
                                saveButton.enabled = false
                                return
                            case "HemsErrorInvalidParameter":
                                errorProps.text = qsTr("Could not save configuration. One of the parameters is invalid.")
                                break
                            case "HemsErrorNotSupported":
                                errorProps.text = qsTr("Self-consumption optimization is not supported by your backend.")
                                break
                            default:
                                errorProps.errorCode = error
                            }
                            var comp = Qt.createComponent("../components/ErrorDialog.qml")
                            var popup = comp.createObject(app, {props: errorProps})
                            popup.open()
                        }
                    }
                }

                // Reload fields when configuration changes from backend
                Connections {
                    target: hemsManager
                    onSelfConsumptionConfigChanged: {
                        selfConsumptionEnabledSwitch.checked = selfConsumptionConfiguration.selfConsumptionEnabled
                        targetPowerField.text = selfConsumptionConfiguration.selfConsumptionTargetPower
                        kpField.text = selfConsumptionConfiguration.selfConsumptionKp
                        kiField.text = selfConsumptionConfiguration.selfConsumptionKi
                        kdField.text = selfConsumptionConfiguration.selfConsumptionKd
                    }
                }

                // Save Button
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 20
                    visible: selfConsumptionSupported

                    Button {
                        id: saveButton
                        Layout.fillWidth: true
                        text: qsTr("Save")
                        enabled: false

                        onClicked: {
                            var configData = {
                                "selfConsumptionEnabled": selfConsumptionEnabledSwitch.checked,
                                "selfConsumptionTargetPower": parseInt(targetPowerField.text) || 0,
                                "selfConsumptionKp": parseFloat(kpField.text) || 0.0,
                                "selfConsumptionKi": parseFloat(kiField.text) || 0.0,
                                "selfConsumptionKd": parseFloat(kdField.text) || 0.0
                            }
                            d.pendingCallId = hemsManager.setSelfConsumptionConfig(configData)
                            saveButton.enabled = false
                        }
                    }
                }

                // Reset to defaults button
                Button {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.smallMargins
                    text: qsTr("Reset to defaults")
                    visible: selfConsumptionSupported && selfConsumptionEnabledSwitch.checked
                    onClicked: {
                        selfConsumptionEnabledSwitch.checked = true
                        targetPowerField.text = "0"
                        kpField.text = "0.1"
                        kiField.text = "0.1"
                        kdField.text = "0"
                        enableSave()
                    }
                }
            }
        }
    ]
}