import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import "../components"
import "../delegates"


Page {
    id: root
    property BatteryConfiguration batteryConfiguration
    property Thing thing
    property int directionID: 0
    property bool isSetup: false
    signal done()

    header: NymeaHeader {
        text: qsTr("Battery")
        backButtonVisible: directionID === 1 ? false : true
        onBackPressed: pageStack.pop()
    }

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onSetBatteryConfigurationReply: function(commandId, error) {
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

        CoFrostyCard {
            Layout.fillWidth: true
            contentTopMargin: Style.smallMargins
            headerText: thing.name

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.margins
                anchors.rightMargin: Style.margins
                spacing: 0

                CoInputField {
                    id: maxElectricalPower
                    property bool maxElectricalPowerValid: !visible || textField.acceptableInput
                    Layout.fillWidth: true
                    visible: !thing.thingClass.interfaces.includes("controllablebattery")
                    labelText: qsTr("Maximal electrical power")
                    compactTextField: true
                    unit: qsTr("kW")
                    feedbackText: qsTr("The value is outside the valid range.")
                    textField.text: (+batteryConfiguration.maxElectricalPower).toLocaleString()
                    textField.maximumLength: 10
                    textField.validator: DoubleValidator { bottom: 0.5 }
                }

                CoSwitch {
                    id: gridSupportControl
                    Layout.fillWidth: true
                    text: qsTr("Grid-supportive-control")
                    helpText: qsTr("If the device must be controlled in accordance with § 14a, this setting must be enabled.")
                    visible: thing.thingClass.interfaces.includes("controllablebattery")

                    Component.onCompleted: {
                        checked = batteryConfiguration.controllableLocalSystem;
                    }
                }

                CoSwitch {
                    id: zeroCompensationControl
                    Layout.fillWidth: true
                    text: qsTr("Avoid zero compensation")
                    infoUrl: "AvoidZeroCompensationInfo.qml"
                    visible: thing.thingClass.interfaces.includes("controllablebattery") &&
                             ((hemsManager.availableUseCases & HemsManager.HemsUseCaseAvoidZeroCompensation) !== 0)

                    Component.onCompleted: {
                        checked = batteryConfiguration.avoidZeroFeedInEnabled;
                    }
                }

                CoSwitch {
                    id: blockEVChargingFromBatteryControl
                    Layout.fillWidth: true
                    text: qsTr("Block EV charging from the battery")
                    infoUrl: "BlockEVChargingFromBatteryInfo.qml"
                    visible: thing.thingClass.interfaces.includes("controllablebattery") &&
                             ((hemsManager.availableUseCases & HemsManager.HemsUseCaseBattery) &&
                              (hemsManager.availableUseCases & HemsManager.HemsUseCaseCharging))

                    Component.onCompleted: {
                        checked = (batteryConfiguration.blockBatteryOnGridConsumption & BatteryConfiguration.EvCharger);
                    }
                }
            }
        }

        Item {
            id: spacer
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
            enabled: maxElectricalPower.maxElectricalPowerValid
            text: qsTr("Apply changes")
            onClicked: {
                var blockBatteryOnGridConsumption = batteryConfiguration.blockBatteryOnGridConsumption;
                if (blockEVChargingFromBatteryControl.checked) {
                    blockBatteryOnGridConsumption |= BatteryConfiguration.EvCharger;
                } else {
                    blockBatteryOnGridConsumption &= ~BatteryConfiguration.EvCharger;
                }

                let config = {
                    controllableLocalSystem: gridSupportControl.checked,
                    avoidZeroFeedInEnabled: zeroCompensationControl.checked,
                    blockBatteryOnGridConsumption: blockBatteryOnGridConsumption
                };
                if (maxElectricalPower.visible) {
                    config.maxElectricalPower = Number.fromLocaleString(Qt.locale(), maxElectricalPower.text);
                }

                hemsManager.setBatteryConfiguration(batteryConfiguration.batteryThingId, config);
                if (directionID !== 1) {
                    pageStack.pop();
                }
                root.done();
            }
        }
    }
}
