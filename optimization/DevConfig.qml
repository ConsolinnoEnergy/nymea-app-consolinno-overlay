import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import "../components"

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

                                CoInputStepper {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Min. Laufzeit nach Einschalten (s)")
                                    unit: "s"
                                    from: 0
                                    to: 3600
                                    stepSize: 1
                                    value: chargingDelegate.localDurationMinAfterTurnOn
                                    onValueModified: function(v) { chargingDelegate.localDurationMinAfterTurnOn = v }
                                }

                                CoInputStepper {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Phasenwechsel-Verzögerung (s)")
                                    unit: "s"
                                    from: 0
                                    to: 600
                                    stepSize: 1
                                    value: chargingDelegate.localSwitchDelayPhase
                                    onValueModified: function(v) { chargingDelegate.localSwitchDelayPhase = v }
                                }

                                Button {
                                    Layout.fillWidth: true
                                    text: qsTr("Speichern")
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

                        CoInputStepper {
                            Layout.fillWidth: true
                            labelText: qsTr("Filter-Zeitkonstante (s)")
                            unit: "s"
                            from: 0
                            to: 3600
                            stepSize: 1
                            value: pvSurplusCard.localFilterTimeConstant
                            onValueModified: function(v) { pvSurplusCard.localFilterTimeConstant = v }
                        }

                        CoInputStepper {
                            Layout.fillWidth: true
                            labelText: qsTr("Post-Switch-Timeout (s)")
                            unit: "s"
                            from: 0
                            to: 600
                            stepSize: 1
                            value: pvSurplusCard.localPostSwitchTimeout
                            onValueModified: function(v) { pvSurplusCard.localPostSwitchTimeout = v }
                        }

                        CoInputStepper {
                            Layout.fillWidth: true
                            labelText: qsTr("PID Kp")
                            floatingPoint: true
                            decimals: 4
                            from: -10
                            to: 10
                            stepSize: 0.001
                            value: pvSurplusCard.localPidKp
                            onValueModified: function(v) { pvSurplusCard.localPidKp = v }
                        }

                        CoInputStepper {
                            Layout.fillWidth: true
                            labelText: qsTr("PID Ki")
                            floatingPoint: true
                            decimals: 4
                            from: -10
                            to: 10
                            stepSize: 0.001
                            value: pvSurplusCard.localPidKi
                            onValueModified: function(v) { pvSurplusCard.localPidKi = v }
                        }

                        CoInputStepper {
                            Layout.fillWidth: true
                            labelText: qsTr("PID Kd")
                            floatingPoint: true
                            decimals: 4
                            from: -10
                            to: 10
                            stepSize: 0.001
                            value: pvSurplusCard.localPidKd
                            onValueModified: function(v) { pvSurplusCard.localPidKd = v }
                        }

                        CoInputStepper {
                            Layout.fillWidth: true
                            labelText: qsTr("PID Sollwert (W)")
                            unit: "W"
                            floatingPoint: true
                            decimals: 1
                            from: -100000
                            to: 100000
                            stepSize: 10
                            value: pvSurplusCard.localPidSetpoint
                            onValueModified: function(v) { pvSurplusCard.localPidSetpoint = v }
                        }

                        Button {
                            Layout.fillWidth: true
                            text: qsTr("Speichern")
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

                                CoInputStepper {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Battery Power Margin (W)")
                                    unit: "W"
                                    floatingPoint: true
                                    decimals: 1
                                    from: 0
                                    to: 10000
                                    stepSize: 10
                                    value: batteryDelegate.localBatteryPowerMargin
                                    onValueModified: function(v) { batteryDelegate.localBatteryPowerMargin = v }
                                }

                                CoInputStepper {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Battery Power Rate Limit (W)")
                                    unit: "W"
                                    floatingPoint: true
                                    decimals: 1
                                    from: 0
                                    to: 10000
                                    stepSize: 1
                                    value: batteryDelegate.localBatteryPowerRateLimit
                                    onValueModified: function(v) { batteryDelegate.localBatteryPowerRateLimit = v }
                                }

                                CoInputStepper {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Taper SoC (%)")
                                    unit: "%"
                                    from: 0
                                    to: 100
                                    stepSize: 1
                                    value: batteryDelegate.localTaperSoC
                                    onValueModified: function(v) { batteryDelegate.localTaperSoC = v }
                                }

                                Button {
                                    Layout.fillWidth: true
                                    text: qsTr("Speichern")
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

                                CoInputStepper {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Mittlere SGR-2-Leistung (W)")
                                    unit: "W"
                                    floatingPoint: true
                                    decimals: 1
                                    from: 0
                                    to: 20000
                                    stepSize: 10
                                    value: heatingDelegate.localMeanSgr2
                                    onValueModified: function(v) { heatingDelegate.localMeanSgr2 = v }
                                }

                                CoInputStepper {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Mittlere SGR-3-Leistung (W)")
                                    unit: "W"
                                    floatingPoint: true
                                    decimals: 1
                                    from: 0
                                    to: 20000
                                    stepSize: 10
                                    value: heatingDelegate.localMeanSgr3
                                    onValueModified: function(v) { heatingDelegate.localMeanSgr3 = v }
                                }

                                CoInputStepper {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Min. Verweildauer (s)")
                                    unit: "s"
                                    from: 0
                                    to: 3600
                                    stepSize: 1
                                    value: heatingDelegate.localDurationMinDwell
                                    onValueModified: function(v) { heatingDelegate.localDurationMinDwell = v }
                                }

                                CoInputStepper {
                                    Layout.fillWidth: true
                                    labelText: qsTr("Min. Laufzeit nach Einschalten (s)")
                                    unit: "s"
                                    from: 0
                                    to: 3600
                                    stepSize: 1
                                    value: heatingDelegate.localDurationMinAfterTurnOn
                                    onValueModified: function(v) { heatingDelegate.localDurationMinAfterTurnOn = v }
                                }

                                Button {
                                    Layout.fillWidth: true
                                    text: qsTr("Speichern")
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
