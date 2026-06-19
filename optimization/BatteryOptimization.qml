import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import NymeaApp.Utils 1.0
import "../components"
import "../delegates"


Page {
    id: root
    bottomPadding: 0
    property int navigationFooterHeight: 0
    property BatteryConfiguration batteryConfiguration
    property Thing thing
    property int directionID: 0
    property bool isSetup: false
    signal done()

    readonly property bool applyEnabled: maxElectricalPower.inputValid

    function applyChanges() {
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
        if (hemsControlledBattery.visible) {
            config.fullymanagableBattery = hemsControlledBattery.checked;
            if (hemsControlledBattery.checked) {
                config.maxSoC = maxSoc.value;
                config.minSoC = minSoc.value;
            }
        }

        hemsManager.setBatteryConfiguration(batteryConfiguration.batteryThingId, config);
        if (directionID !== 1) {
            pageStack.pop();
        }
        root.done();
    }

    header: null

    CoHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        blurSource: bodyFlickable
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
            anchors.margins: app.margins

            CoFrostyCard {
                Layout.fillWidth: true
                contentTopMargin: Style.smallMargins
                headerText: thing.name

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoInputField {
                        id: maxElectricalPower
                        property bool inputValid: !visible || textField.acceptableInput
                        Layout.fillWidth: true
                        visible: !thing.thingClass.interfaces.includes("controllablebattery")
                        labelText: qsTr("Maximal electrical power")
                        compact: true
                        unit: qsTr("kW")
                        helpText:
                            qsTr("The value must not be below %1.")
                        .arg(NymeaUtils.floatToLocaleString(maxElectricalPowerValidator.bottom))
                        feedbackText: qsTr("The value is outside the valid range.")
                        textField.text: (+batteryConfiguration.maxElectricalPower).toLocaleString()
                        textField.maximumLength: 10
                        textField.validator: DoubleValidator  {
                            id: maxElectricalPowerValidator
                            bottom: 0.5
                        }
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
                        visible: (thing.thingClass.interfaces.includes("limitablesoc") ||
                                  thing.thingClass.interfaces.includes("limitableconsumer")) &&
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

                    CoSwitch {
                        id: hemsControlledBattery
                        Layout.fillWidth: true
                        text: qsTr("HEMS-controlled battery")
                        infoUrl: "HemsControlledBatteryInfo.qml"
                        visible: thing.thingClass.interfaces.includes("fullymanagedbattery")

                        Component.onCompleted: {
                            checked = batteryConfiguration.fullymanagableBattery;
                        }
                    }

                    CoSlider {
                        id: maxSoc
                        Layout.fillWidth: true
                        visible: hemsControlledBattery.visible && hemsControlledBattery.checked
                        labelText: qsTr("Maximum SoC")
                        valueText: value + " %"
                        stepSize: 1
                        from: 0
                        to: 100

                        onValueChanged: {
                            if (minSoc.value > value) {
                                minSoc.value = value;
                            }
                        }

                        Component.onCompleted: {
                            value = batteryConfiguration.maxSoC;
                        }
                    }

                    CoSlider {
                        id: minSoc
                        Layout.fillWidth: true
                        visible: hemsControlledBattery.visible && hemsControlledBattery.checked
                        labelText: qsTr("Minimum SoC")
                        valueText: value + " %"
                        stepSize: 1
                        from: 0
                        to: 100

                        onValueChanged: {
                            if (maxSoc.value < value) {
                                maxSoc.value = value;
                            }
                        }

                        Component.onCompleted: {
                            value = batteryConfiguration.minSoC;
                        }
                    }
                }
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
        }
    }

    property Component navbarControls: batteryOptimizationNavbarControls

    Component {
        id: batteryOptimizationNavbarControls
        CoNavbarButton {
            text: qsTr("Apply changes")
            enabled: root.applyEnabled
            onClicked: root.applyChanges()
        }
    }
}
