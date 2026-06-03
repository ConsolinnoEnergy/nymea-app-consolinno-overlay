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

    content: [
        Flickable {
            anchors.fill: parent
            contentHeight: mainColumn.implicitHeight
                           + mainColumn.anchors.topMargin
                           + mainColumn.anchors.bottomMargin
            clip: true

            ColumnLayout {
                id: mainColumn
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                // ── Charging ─────────────────────────────────────────────────
                Repeater {
                    model: hemsManager.chargingConfigurations

                    delegate: Item {
                        id: chargingDelegate

                        readonly property var cfg: hemsManager.chargingConfigurations.getChargingConfiguration(model.evChargerThingId)
                        property int localDurationMinAfterTurnOn: cfg ? cfg.durationMinAfterTurnOn : 0
                        property int localSwitchDelayPhase: cfg ? cfg.switchDelayPhase : 0

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
                                    enabled: chargingDelegate.cfg
                                             && (chargingDelegate.localDurationMinAfterTurnOn !== chargingDelegate.cfg.durationMinAfterTurnOn
                                                 || chargingDelegate.localSwitchDelayPhase !== chargingDelegate.cfg.switchDelayPhase)
                                    onClicked: hemsManager.setChargingConfiguration(model.evChargerThingId, {
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
                            enabled: pvSurplusCard.pvCfg
                                     && (pvSurplusCard.localFilterTimeConstant !== pvSurplusCard.pvCfg.filterTimeConstant
                                         || pvSurplusCard.localPostSwitchTimeout !== pvSurplusCard.pvCfg.postSwitchTimeout
                                         || pvSurplusCard.localPidKp !== pvSurplusCard.pvCfg.pidKp
                                         || pvSurplusCard.localPidKi !== pvSurplusCard.pvCfg.pidKi
                                         || pvSurplusCard.localPidKd !== pvSurplusCard.pvCfg.pidKd
                                         || pvSurplusCard.localPidSetpoint !== pvSurplusCard.pvCfg.pidSetpoint)
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
                    model: hemsManager.batteryConfigurations

                    delegate: Item {
                        id: batteryDelegate

                        readonly property var cfg: hemsManager.batteryConfigurations.getBatteryConfiguration(model.batteryThingId)
                        property real localBatteryPowerMargin: cfg ? cfg.batteryPowerMargin : 100.0
                        property real localBatteryPowerRateLimit: cfg ? cfg.batteryPowerRateLimit : 50.0
                        property int localTaperSoC: cfg ? cfg.taperSoC : 5

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
                                    enabled: batteryDelegate.cfg
                                             && (batteryDelegate.localBatteryPowerMargin !== batteryDelegate.cfg.batteryPowerMargin
                                                 || batteryDelegate.localBatteryPowerRateLimit !== batteryDelegate.cfg.batteryPowerRateLimit
                                                 || batteryDelegate.localTaperSoC !== batteryDelegate.cfg.taperSoC)
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
                    model: hemsManager.heatingConfigurations

                    delegate: Item {
                        id: heatingDelegate

                        readonly property var cfg: hemsManager.heatingConfigurations.getHeatingConfiguration(model.heatPumpThingId)
                        property real localMeanSgr2: cfg ? cfg.meanSgr2 : 500.0
                        property real localMeanSgr3: cfg ? cfg.meanSgr3 : 1500.0
                        property int localDurationMinDwell: cfg ? cfg.durationMinDwell : 600
                        property int localDurationMinAfterTurnOn: cfg ? cfg.durationMinAfterTurnOn : 15

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

                                CoInputField {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Min. runtime after turn-on")
                                    unit: "s"
                                    text: heatingDelegate.localDurationMinAfterTurnOn.toString()
                                    textField.validator: IntValidator { bottom: 0; top: 86400 }
                                    textField.inputMethodHints: Qt.ImhDigitsOnly
                                    textField.onEditingFinished: heatingDelegate.localDurationMinAfterTurnOn = parseInt(textField.text) || 0
                                }

                                Button {
                                    Layout.fillWidth: true
                                    text: qsTr("Save")
                                    enabled: heatingDelegate.cfg
                                             && (heatingDelegate.localMeanSgr2 !== heatingDelegate.cfg.meanSgr2
                                                 || heatingDelegate.localMeanSgr3 !== heatingDelegate.cfg.meanSgr3
                                                 || heatingDelegate.localDurationMinDwell !== heatingDelegate.cfg.durationMinDwell
                                                 || heatingDelegate.localDurationMinAfterTurnOn !== heatingDelegate.cfg.durationMinAfterTurnOn)
                                    onClicked: hemsManager.setHeatingConfiguration(model.heatPumpThingId, {
                                        "meanSgr2": heatingDelegate.localMeanSgr2,
                                        "meanSgr3": heatingDelegate.localMeanSgr3,
                                        "durationMinDwell": heatingDelegate.localDurationMinDwell,
                                        "durationMinAfterTurnOn": heatingDelegate.localDurationMinAfterTurnOn
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
