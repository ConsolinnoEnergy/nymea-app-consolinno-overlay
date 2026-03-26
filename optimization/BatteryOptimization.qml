import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"
import "../devicepages"

Page {
    id: root
    property BatteryConfiguration batteryConfiguration
    property Thing thing
    property int directionID: 0
    property bool isSetup: false
    signal done()

    header: NymeaHeader {
        text: thing.name
        backButtonVisible: directionID === 1 ? false : true
        onBackPressed: pageStack.pop()
    }

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onSetBatteryConfigurationReply: {
            if (commandId == d.pendingCallId) {
                d.pendingCallId = -1

                switch (error) {
                case "HemsErrorNoError":
                    pageStack.pop()
                    return;
                case "HemsErrorInvalidParameter":
                    footer.text = qsTr("Could not save configuration. One of the parameters is invalid.");
                    break;
                case "HemsErrorInvalidThing":
                    footer.text = qsTr("Could not save configuration. The thing is not valid.");
                    break;
                default:
                    props.errorCode = error;
                }
                var comp = Qt.createComponent("../components/ErrorDialog.qml")
                var popup = comp.createObject(app, props)
                popup.open();
            }
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: app.margins

        RowLayout{
            Layout.fillWidth: true
            visible: thing.thingClass.interfaces.includes("controllablebattery")

            Label {
                Layout.fillWidth: true
                text: qsTr("Grid-supportive-control")
            }

            ConsolinnoSwitch {
                id: gridSupportControl
                Component.onCompleted: checked = batteryConfiguration.controllableLocalSystem
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: thing.thingClass.interfaces.includes("controllablebattery")

            Text {
                Layout.fillWidth: true
                font: Style.smallFont
                color: Style.consolinnoMedium
                wrapMode: Text.Wrap
                text: qsTr("If the device must be controlled in accordance with § 14a, this setting must be enabled.")
            }
        }

        RowLayout{
            Layout.fillWidth: true
            visible: (hemsManager.availableUseCases & HemsManager.HemsUseCaseAvoidZeroCompensation) !== 0

            LabelWithInfo {
                text: qsTr("Avoid zero compensation")
                push: "AvoidZeroCompensationInfo.qml"
            }

            ConsolinnoSwitch {
                id: zeroCompensationControl
                Component.onCompleted: checked = batteryConfiguration.avoidZeroFeedInEnabled
            }
        }

        RowLayout{
            Layout.fillWidth: true
            visible: thing.thingClass.interfaces.includes("controllablebattery") &&
                     ((hemsManager.availableUseCases & HemsManager.HemsUseCaseBattery) &&
                      (hemsManager.availableUseCases & HemsManager.HemsUseCaseCharging))

            LabelWithInfo {
                text: qsTr("Block EV charging from the battery")
                push: "BlockEVChargingFromBatteryInfo.qml"
            }

            ConsolinnoSwitch {
                id: blockEVChargingFromBatteryControl
                Component.onCompleted: checked = (batteryConfiguration.blockBatteryOnGridConsumption & BatteryConfiguration.EvCharger)
            }
        }

        // Self-consumption Configuration Section
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Style.margins * 2
            visible: hemsManager.selfConsumptionSupported && thing.thingClass.interfaces.includes("controllablebattery") && hemsManager.selfConsumptionConfiguration && hemsManager.selfConsumptionConfiguration.selfConsumptionEnabled

            Label {
                text: qsTr("Self-consumption")
                font.weight: Font.Bold
            }
        }

        // Self-consumption configuration inputs
        ColumnLayout {
            Layout.fillWidth: true
            visible: hemsManager.selfConsumptionSupported && thing.thingClass.interfaces.includes("controllablebattery") && hemsManager.selfConsumptionConfiguration && hemsManager.selfConsumptionConfiguration.selfConsumptionEnabled

            // Capacity (kWh), -1 = not configured
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Style.smallMargins

                Label {
                    text: qsTr("Capacity")
                    Layout.fillWidth: true
                }

                ConsolinnoTextField {
                    id: selfConsumptionCapacityField
                    Layout.preferredWidth: 100
                    horizontalAlignment: Text.AlignRight
                    validator: RegExpValidator {
                        regExp: /^-?\d*\.?\d+$/
                    }
                    text: batteryConfiguration.selfConsumptionCapacity
                }

                Label {
                    text: "kWh"
                    Layout.leftMargin: 5
                }
            }

            // SoC Full (%)
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Style.smallMargins

                Label {
                    text: qsTr("SoC Full")
                    Layout.fillWidth: true
                }

                ConsolinnoTextField {
                    id: selfConsumptionSocFullField
                    Layout.preferredWidth: 100
                    horizontalAlignment: Text.AlignRight
                    validator: RegExpValidator {
                        regExp: /^\d+$/
                    }
                    text: batteryConfiguration.selfConsumptionSocFull
                }

                Label {
                    text: "%"
                    Layout.leftMargin: 5
                }
            }

            // SoC Empty (%)
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Style.smallMargins

                Label {
                    text: qsTr("SoC Empty")
                    Layout.fillWidth: true
                }

                ConsolinnoTextField {
                    id: selfConsumptionSocEmptyField
                    Layout.preferredWidth: 100
                    horizontalAlignment: Text.AlignRight
                    validator: RegExpValidator {
                        regExp: /^\d+$/
                    }
                    text: batteryConfiguration.selfConsumptionSocEmpty
                }

                Label {
                    text: "%"
                    Layout.leftMargin: 5
                }
            }

            // Max Power (W)
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: Style.smallMargins

                Label {
                    text: qsTr("Max Power")
                    Layout.fillWidth: true
                }

                ConsolinnoTextField {
                    id: selfConsumptionMaxPowerField
                    Layout.preferredWidth: 100
                    horizontalAlignment: Text.AlignRight
                    validator: RegExpValidator {
                        regExp: /^\d+$/
                    }
                    text: batteryConfiguration.selfConsumptionMaxPower
                }

                Label {
                    text: "W"
                    Layout.leftMargin: 5
                }
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Label {
            id: footer
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            color: Style.dangerAccent
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont
        }


        Button {
            id: savebutton

            Layout.fillWidth: true
            text: qsTr("Save")
            onClicked: {
                var blockBatteryOnGridConsumption = batteryConfiguration.blockBatteryOnGridConsumption;
                if (blockEVChargingFromBatteryControl.checked) {
                    blockBatteryOnGridConsumption |= BatteryConfiguration.EvCharger;
                } else {
                    blockBatteryOnGridConsumption &= ~BatteryConfiguration.EvCharger;
                }

                var configData = {
                    controllableLocalSystem: gridSupportControl.checked,
                    avoidZeroFeedInEnabled: zeroCompensationControl.checked,
                    blockBatteryOnGridConsumption: blockBatteryOnGridConsumption
                };

                // Include self-consumption config if supported, globally enabled, and battery is controllable
                if (hemsManager.selfConsumptionSupported && thing.thingClass.interfaces.includes("controllablebattery") && hemsManager.selfConsumptionConfiguration && hemsManager.selfConsumptionConfiguration.selfConsumptionEnabled) {
                    configData.selfConsumptionCapacity = parseFloat(selfConsumptionCapacityField.text);
                    if (isNaN(configData.selfConsumptionCapacity)) configData.selfConsumptionCapacity = -1;
                    configData.selfConsumptionSocFull = parseInt(selfConsumptionSocFullField.text) || 95;
                    configData.selfConsumptionSocEmpty = parseInt(selfConsumptionSocEmptyField.text) || 5;
                    configData.selfConsumptionMaxPower = parseInt(selfConsumptionMaxPowerField.text) || 100000;
                }

                hemsManager.setBatteryConfiguration(batteryConfiguration.batteryThingId, configData);
                if (directionID !== 1) {
                    pageStack.pop();
                }
                root.done();
            }
        }
    }
}
