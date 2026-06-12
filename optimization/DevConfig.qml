import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import "../components"
import "../devicepages"

GenericConfigPage {
    id: root

    title: qsTr("Dev Config")
    headerOptionsVisible: false
    overrideBack: true

    // True when any of the four config sections has local unsaved edits.
    // Updated imperatively from each Save button's enabled binding via the
    // refreshDirty() helper, so we don't have to duplicate the comparison
    // expressions here.
    property bool hasUnsavedChanges: false

    onBackRequested: {
        if (hasUnsavedChanges) {
            discardDialog.open();
        } else {
            pageStack.pop();
        }
    }

    // Walks all sections and updates `hasUnsavedChanges`. Called from each
    // section's onDirtyChanged.
    function refreshDirty() {
        if (pvSurplusCard.dirty) { hasUnsavedChanges = true; return; }
        for (var i = 0; i < chargingRepeater.count; i++) {
            var c = chargingRepeater.itemAt(i);
            if (c && c.dirty) { hasUnsavedChanges = true; return; }
        }
        for (var j = 0; j < batteryRepeater.count; j++) {
            var b = batteryRepeater.itemAt(j);
            if (b && b.dirty) { hasUnsavedChanges = true; return; }
        }
        for (var k = 0; k < heatingRepeater.count; k++) {
            var h = heatingRepeater.itemAt(k);
            if (h && h.dirty) { hasUnsavedChanges = true; return; }
        }
        hasUnsavedChanges = false;
    }

    Dialog {
        id: discardDialog
        modal: true
        anchors.centerIn: parent
        title: qsTr("Unsaved changes")
        standardButtons: Dialog.Discard | Dialog.Cancel

        Label {
            text: qsTr("You have unsaved changes. Discard them?")
            wrapMode: Text.WordWrap
            width: discardDialog.availableWidth
        }

        onDiscarded: pageStack.pop()
    }

    content: [
        Flickable {
            anchors.fill: parent
            contentHeight: mainColumn.implicitHeight
                           + mainColumn.anchors.topMargin
                           + mainColumn.anchors.bottomMargin
                           + root.navigationFooterHeight
            clip: true

            ColumnLayout {
                id: mainColumn
                anchors { left: parent.left; right: parent.right; top: parent.top }
                anchors.margins: Style.margins
                spacing: Style.margins

                // ── Charging ─────────────────────────────────────────────────
                Repeater {
                    id: chargingRepeater
                    model: hemsManager.chargingConfigurations

                    delegate: Item {
                        id: chargingDelegate

                        readonly property var cfg: hemsManager.chargingConfigurations.getChargingConfiguration(model.evChargerThingId)
                        property int localDurationMinAfterTurnOn: cfg ? cfg.durationMinAfterTurnOn : 0
                        property int localSwitchDelayPhase: cfg ? cfg.switchDelayPhase : 0
                        property int localDesiredPhaseCount: cfg ? cfg.desiredPhaseCount : 3

                        readonly property bool dirty: cfg
                                                      && (localDurationMinAfterTurnOn !== cfg.durationMinAfterTurnOn
                                                          || localSwitchDelayPhase !== cfg.switchDelayPhase
                                                          || localDesiredPhaseCount !== cfg.desiredPhaseCount)
                        onDirtyChanged: root.refreshDirty()

                        Layout.fillWidth: true
                        implicitHeight: chargingCard.implicitHeight

                        CoFrostyCard {
                            id: chargingCard
                            anchors.left: parent.left
                            anchors.right: parent.right
                            contentTopMargin: Style.smallMargins
                            headerText: qsTr("Charging") + (hemsManager.chargingConfigurations.count > 1 ? " (" + model.evChargerThingId + ")" : "")

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: Style.smallMargins

                                CoInputField {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Desired phase count")
                                    unit: "s"
                                    text: chargingDelegate.localDesiredPhaseCount.toString()
                                    textField.validator: IntValidator { bottom: 0; top: 3 }
                                    textField.inputMethodHints: Qt.ImhDigitsOnly
                                    textField.onEditingFinished: chargingDelegate.localDesiredPhaseCount = parseInt(textField.text) || 3
                                }

                                CoInputField {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Min. runtime after turn-on")
                                    unit: "s"
                                    text: chargingDelegate.localDurationMinAfterTurnOn.toString()
                                    textField.validator: IntValidator { bottom: 0; top: 86400 }
                                    textField.inputMethodHints: Qt.ImhDigitsOnly
                                    textField.onEditingFinished: chargingDelegate.localDurationMinAfterTurnOn = parseInt(textField.text) || 0
                                }

                                CoInputField {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Phase switch delay")
                                    unit: "s"
                                    text: chargingDelegate.localSwitchDelayPhase.toString()
                                    textField.validator: IntValidator { bottom: 0; top: 86400 }
                                    textField.inputMethodHints: Qt.ImhDigitsOnly
                                    textField.onEditingFinished: chargingDelegate.localSwitchDelayPhase = parseInt(textField.text) || 0
                                }

                                Button {
                                    Layout.fillWidth: true
                                    text: qsTr("Save")
                                    enabled: chargingDelegate.dirty
                                    onClicked: hemsManager.setChargingConfiguration(model.evChargerThingId, {
                                        "desiredPhaseCount": chargingDelegate.localDesiredPhaseCount, localDesiredPhaseCount,
                                        "durationMinAfterTurnOn": chargingDelegate.localDurationMinAfterTurnOn,
                                        "switchDelayPhase": chargingDelegate.localSwitchDelayPhase
                                    })
                                }
                            }
                        }
                    }
                }

                // ── PV Surplus Dev Config ─────────────────────────────────────
                CoFrostyCard {
                    id: pvSurplusCard
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("PV Surplus Dev Config")

                    property DevConfigPvSurplus pvCfg: hemsManager.devConfigPvSurplus

                    property int localFilterTimeConstant: pvCfg ? pvCfg.filterTimeConstant : 600
                    property int localPostSwitchTimeout: pvCfg ? pvCfg.postSwitchTimeout : 60
                    property real localPidKp: pvCfg ? pvCfg.pidKp : 0.05
                    property real localPidKi: pvCfg ? pvCfg.pidKi : 0.0
                    property real localPidKd: pvCfg ? pvCfg.pidKd : 0.0
                    property real localPidSetpoint: pvCfg ? pvCfg.pidSetpoint : 0.0

                    readonly property bool dirty: pvCfg
                                                  && (localFilterTimeConstant !== pvCfg.filterTimeConstant
                                                      || localPostSwitchTimeout !== pvCfg.postSwitchTimeout
                                                      || localPidKp !== pvCfg.pidKp
                                                      || localPidKi !== pvCfg.pidKi
                                                      || localPidKd !== pvCfg.pidKd
                                                      || localPidSetpoint !== pvCfg.pidSetpoint)
                    onDirtyChanged: root.refreshDirty()

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Style.smallMargins

                        CoInputField {
                            Layout.fillWidth: true
                            labelText: qsTr("Filter time constant")
                            unit: "s"
                            text: pvSurplusCard.localFilterTimeConstant.toString()
                            textField.validator: IntValidator { bottom: 0; top: 86400 }
                            textField.inputMethodHints: Qt.ImhDigitsOnly
                            textField.onEditingFinished: pvSurplusCard.localFilterTimeConstant = parseInt(textField.text) || 0
                        }

                        CoInputField {
                            Layout.fillWidth: true
                            labelText: qsTr("Post-switch timeout")
                            unit: "s"
                            text: pvSurplusCard.localPostSwitchTimeout.toString()
                            textField.validator: IntValidator { bottom: 0; top: 86400 }
                            textField.inputMethodHints: Qt.ImhDigitsOnly
                            textField.onEditingFinished: pvSurplusCard.localPostSwitchTimeout = parseInt(textField.text) || 0
                        }

                        CoInputField {
                            Layout.fillWidth: true
                            labelText: qsTr("PID Kp")
                            text: pvSurplusCard.localPidKp.toString()
                            textField.validator: DoubleValidator { bottom: -1000; top: 1000; decimals: 6; notation: DoubleValidator.StandardNotation; locale: "C" }
                            textField.inputMethodHints: Qt.ImhFormattedNumbersOnly
                            textField.onEditingFinished: pvSurplusCard.localPidKp = parseFloat(textField.text) || 0
                        }

                        CoInputField {
                            Layout.fillWidth: true
                            labelText: qsTr("PID Ki")
                            text: pvSurplusCard.localPidKi.toString()
                            textField.validator: DoubleValidator { bottom: -1000; top: 1000; decimals: 6; notation: DoubleValidator.StandardNotation; locale: "C" }
                            textField.inputMethodHints: Qt.ImhFormattedNumbersOnly
                            textField.onEditingFinished: pvSurplusCard.localPidKi = parseFloat(textField.text) || 0
                        }

                        CoInputField {
                            Layout.fillWidth: true
                            labelText: qsTr("PID Kd")
                            text: pvSurplusCard.localPidKd.toString()
                            textField.validator: DoubleValidator { bottom: -1000; top: 1000; decimals: 6; notation: DoubleValidator.StandardNotation; locale: "C" }
                            textField.inputMethodHints: Qt.ImhFormattedNumbersOnly
                            textField.onEditingFinished: pvSurplusCard.localPidKd = parseFloat(textField.text) || 0
                        }

                        CoInputField {
                            Layout.fillWidth: true
                            labelText: qsTr("PID setpoint")
                            unit: "W"
                            text: pvSurplusCard.localPidSetpoint.toString()
                            textField.validator: DoubleValidator { bottom: -1000000; top: 1000000; decimals: 3; notation: DoubleValidator.StandardNotation; locale: "C" }
                            textField.inputMethodHints: Qt.ImhFormattedNumbersOnly
                            textField.onEditingFinished: pvSurplusCard.localPidSetpoint = parseFloat(textField.text) || 0
                        }

                        Button {
                            Layout.fillWidth: true
                            text: qsTr("Save")
                            enabled: pvSurplusCard.dirty
                            onClicked: hemsManager.setDevConfigPvSurplus({
                                "filterTimeConstant": pvSurplusCard.localFilterTimeConstant,
                                "postSwitchTimeout": pvSurplusCard.localPostSwitchTimeout,
                                "pidKp": pvSurplusCard.localPidKp,
                                "pidKi": pvSurplusCard.localPidKi,
                                "pidKd": pvSurplusCard.localPidKd,
                                "pidSetpoint": pvSurplusCard.localPidSetpoint
                            })
                        }
                    }
                }

                // ── Battery ───────────────────────────────────────────────────
                Repeater {
                    id: batteryRepeater
                    model: hemsManager.batteryConfigurations

                    delegate: Item {
                        id: batteryDelegate

                        readonly property var cfg: hemsManager.batteryConfigurations.getBatteryConfiguration(model.batteryThingId)
                        property real localBatteryPowerMargin: cfg ? cfg.batteryPowerMargin : 100.0
                        property real localBatteryPowerRateLimit: cfg ? cfg.batteryPowerRateLimit : 50.0
                        property int localTaperSoC: cfg ? cfg.taperSoC : 5

                        readonly property bool dirty: cfg
                                                      && (localBatteryPowerMargin !== cfg.batteryPowerMargin
                                                          || localBatteryPowerRateLimit !== cfg.batteryPowerRateLimit
                                                          || localTaperSoC !== cfg.taperSoC)
                        onDirtyChanged: root.refreshDirty()

                        Layout.fillWidth: true
                        implicitHeight: batteryCard.implicitHeight

                        CoFrostyCard {
                            id: batteryCard
                            anchors.left: parent.left
                            anchors.right: parent.right
                            contentTopMargin: Style.smallMargins
                            headerText: qsTr("Battery") + (hemsManager.batteryConfigurations.count > 1 ? " (" + model.batteryThingId + ")" : "")

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: Style.smallMargins

                                CoInputField {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Battery power margin")
                                    unit: "W"
                                    text: batteryDelegate.localBatteryPowerMargin.toString()
                                    textField.validator: DoubleValidator { bottom: 0; top: 100000; decimals: 3; notation: DoubleValidator.StandardNotation; locale: "C" }
                                    textField.inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    textField.onEditingFinished: batteryDelegate.localBatteryPowerMargin = parseFloat(textField.text) || 0
                                }

                                CoInputField {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Battery power rate limit")
                                    unit: "W"
                                    text: batteryDelegate.localBatteryPowerRateLimit.toString()
                                    textField.validator: DoubleValidator { bottom: 0; top: 100000; decimals: 3; notation: DoubleValidator.StandardNotation; locale: "C" }
                                    textField.inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    textField.onEditingFinished: batteryDelegate.localBatteryPowerRateLimit = parseFloat(textField.text) || 0
                                }

                                CoInputField {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Taper SoC")
                                    unit: "%"
                                    text: batteryDelegate.localTaperSoC.toString()
                                    textField.validator: IntValidator { bottom: 0; top: 100 }
                                    textField.inputMethodHints: Qt.ImhDigitsOnly
                                    textField.onEditingFinished: batteryDelegate.localTaperSoC = parseInt(textField.text) || 0
                                }

                                Button {
                                    Layout.fillWidth: true
                                    text: qsTr("Save")
                                    enabled: batteryDelegate.dirty
                                    onClicked: hemsManager.setBatteryConfiguration(model.batteryThingId, {
                                        "batteryPowerMargin": batteryDelegate.localBatteryPowerMargin,
                                        "batteryPowerRateLimit": batteryDelegate.localBatteryPowerRateLimit,
                                        "taperSoC": batteryDelegate.localTaperSoC
                                    })
                                }
                            }
                        }
                    }
                }

                // ── Heating ───────────────────────────────────────────────────
                Repeater {
                    id: heatingRepeater
                    model: hemsManager.heatingConfigurations

                    delegate: Item {
                        id: heatingDelegate

                        readonly property var cfg: hemsManager.heatingConfigurations.getHeatingConfiguration(model.heatPumpThingId)
                        property real localMeanSgr2: cfg ? cfg.meanSgr2 : 500.0
                        property real localMeanSgr3: cfg ? cfg.meanSgr3 : 1500.0
                        property int localDurationMinDwell: cfg ? cfg.durationMinDwell : 600

                        readonly property bool dirty: cfg
                                                      && (localMeanSgr2 !== cfg.meanSgr2
                                                          || localMeanSgr3 !== cfg.meanSgr3
                                                          || localDurationMinDwell !== cfg.durationMinDwell)
                        onDirtyChanged: root.refreshDirty()

                        Layout.fillWidth: true
                        implicitHeight: heatingCard.implicitHeight

                        CoFrostyCard {
                            id: heatingCard
                            anchors.left: parent.left
                            anchors.right: parent.right
                            contentTopMargin: Style.smallMargins
                            headerText: qsTr("Heating") + (hemsManager.heatingConfigurations.count > 1 ? " (" + model.heatPumpThingId + ")" : "")

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: Style.smallMargins

                                CoInputField {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Mean SGR-2 power")
                                    unit: "W"
                                    text: heatingDelegate.localMeanSgr2.toString()
                                    textField.validator: DoubleValidator { bottom: 0; top: 100000; decimals: 3; notation: DoubleValidator.StandardNotation; locale: "C" }
                                    textField.inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    textField.onEditingFinished: heatingDelegate.localMeanSgr2 = parseFloat(textField.text) || 0
                                }

                                CoInputField {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Mean SGR-3 power")
                                    unit: "W"
                                    text: heatingDelegate.localMeanSgr3.toString()
                                    textField.validator: DoubleValidator { bottom: 0; top: 100000; decimals: 3; notation: DoubleValidator.StandardNotation; locale: "C" }
                                    textField.inputMethodHints: Qt.ImhFormattedNumbersOnly
                                    textField.onEditingFinished: heatingDelegate.localMeanSgr3 = parseFloat(textField.text) || 0
                                }

                                CoInputField {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Min. dwell duration")
                                    unit: "s"
                                    text: heatingDelegate.localDurationMinDwell.toString()
                                    textField.validator: IntValidator { bottom: 0; top: 86400 }
                                    textField.inputMethodHints: Qt.ImhDigitsOnly
                                    textField.onEditingFinished: heatingDelegate.localDurationMinDwell = parseInt(textField.text) || 0
                                }

                                Button {
                                    Layout.fillWidth: true
                                    text: qsTr("Save")
                                    enabled: heatingDelegate.dirty
                                    onClicked: hemsManager.setHeatingConfiguration(model.heatPumpThingId, {
                                        "meanSgr2": heatingDelegate.localMeanSgr2,
                                        "meanSgr3": heatingDelegate.localMeanSgr3,
                                        "durationMinDwell": heatingDelegate.localDurationMinDwell
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    ]
}
