import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

Page {
    id: root

    header: NymeaHeader {
        text: qsTr("Optimization configuration")
        backButtonVisible: true
        onBackPressed:{
            pageStack.pop()
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
        clip: true

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: Style.margins
            spacing: Style.margins

            CoFrostyCard {
                id: systemGroup
                Layout.fillWidth: true
                contentTopMargin: 8
                headerText: qsTr("System")
                visible: blackoutProtectionCard.available ||
                         pvPriorizationCard.available

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoCard {
                        id: blackoutProtectionCard
                        property bool available: (hemsManager.availableUseCases & HemsManager.HemsUseCaseBlackoutProtection) != 0 ||
                                                 settings.showHiddenOptions
                        Layout.fillWidth: true
                        visible: available
                        text: qsTr("Blackout protection")
                        iconLeft: Qt.resolvedUrl("/icons/arming_countdown.svg")
                        showChildrenIndicator: true
                        onClicked: pageStack.push(Qt.resolvedUrl("../optimization/BlackoutProtectionView.qml"))
                    }

                    CoCard {
                        id: pvPriorizationCard
                        property bool available: (hemsManager.availableUseCases & HemsManager.HemsUseCasePv) != 0 ||
                                                 settings.showHiddenOptions
                        Layout.fillWidth: true
                        visible: available
                        text: qsTr("PV device priorization") // #TODO wording
                        iconLeft: Qt.resolvedUrl("/icons/pin.svg")
                        showChildrenIndicator: true
                        onClicked: pageStack.push(Qt.resolvedUrl("../optimization/PVPriorities.qml"))
                    }
                }
            }

            CoFrostyCard {
                id: heatingGroup
                Layout.fillWidth: true
                contentTopMargin: 8
                headerText: qsTr("Heating")
                visible: ((hemsManager.availableUseCases & (HemsManager.HemsUseCaseHeating | HemsManager.HemsUseCaseHeatingRod)) != 0 ||
                          settings.showHiddenOptions) &&
                         (heatPumpRepeater.count + heatingRodRepeater.count) > 0

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    Repeater {
                        id: heatPumpRepeater
                        model: hemsManager.heatingConfigurations
                        delegate: CoCard {
                            property HeatingConfiguration heatingConfiguration:
                                hemsManager.heatingConfigurations.getHeatingConfiguration(model.heatPumpThingId)
                            property Thing heatPumpThing:
                                engine.thingManager.things.getThing(model.heatPumpThingId)
                            Layout.fillWidth: true
                            text: heatPumpThing.name
                            iconLeft: Qt.resolvedUrl("/icons/heat_pump.svg")
                            showChildrenIndicator: true
                            onClicked: pageStack.push(Qt.resolvedUrl("../optimization/HeatingOptimization.qml"),
                                                      {
                                                          heatingConfiguration: heatingConfiguration,
                                                          heatPumpThing: heatPumpThing
                                                      })
                        }
                    }

                    Repeater {
                        id: heatingRodRepeater
                        model: hemsManager.heatingElementConfigurations
                        delegate: CoCard {
                            property HeatingElementConfiguration heatingRodConfiguration:
                                hemsManager.heatingElementConfigurations.getHeatingElementConfiguration(model.heatingRodThingId)
                            property Thing heatingRodThing:
                                engine.thingManager.things.getThing(model.heatingRodThingId)
                            Layout.fillWidth: true
                            text: heatingRodThing.name
                            iconLeft: Qt.resolvedUrl("/icons/water_heater.svg")
                            showChildrenIndicator: true
                            onClicked: pageStack.push(Qt.resolvedUrl("../optimization/HeatingElementOptimization.qml"),
                                                      {
                                                          heatingElementConfiguration: heatingRodConfiguration,
                                                          heatRodThing: heatingRodThing
                                                      })
                        }
                    }
                }
            }

            CoFrostyCard {
                id: wallboxGroup
                Layout.fillWidth: true
                contentTopMargin: 8
                headerText: qsTr("Charging")
                visible: ((hemsManager.availableUseCases & HemsManager.HemsUseCaseCharging) != 0 ||
                          settings.showHiddenOptions) &&
                         wallboxRepeater.count > 0

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    Repeater {
                        id: wallboxRepeater
                        model: hemsManager.chargingConfigurations
                        delegate: CoCard {
                            property ChargingConfiguration chargingConfiguration:
                                hemsManager.chargingConfigurations.getChargingConfiguration(model.evChargerThingId)
                            property Thing wallboxThing:
                                engine.thingManager.things.getThing(model.evChargerThingId)
                            Layout.fillWidth: true
                            text: wallboxThing.name
                            iconLeft: Qt.resolvedUrl("/icons/ev_station.svg")
                            showChildrenIndicator: true
                            onClicked: pageStack.push(Qt.resolvedUrl("../optimization/EvChargerOptimization.qml"),
                                                      { thing: wallboxThing })
                        }
                    }
                }
            }

            CoFrostyCard {
                id: batteryGroup
                Layout.fillWidth: true
                contentTopMargin: 8
                headerText: qsTr("Battery")
                visible: ((hemsManager.availableUseCases & HemsManager.HemsUseCaseBattery) != 0 ||
                          settings.showHiddenOptions) &&
                         batteryRepeater.count > 0

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    Repeater {
                        id: batteryRepeater
                        model: hemsManager.batteryConfigurations
                        delegate: CoCard {
                            property BatteryConfiguration batteryConfiguration:
                                hemsManager.batteryConfigurations.getBatteryConfiguration(model.batteryThingId)
                            property Thing batteryThing:
                                engine.thingManager.things.getThing(model.batteryThingId)
                            Layout.fillWidth: true
                            text: batteryThing.name
                            iconLeft: Qt.resolvedUrl("/icons/battery/battery-060.svg")
                            showChildrenIndicator: true
                            onClicked: pageStack.push(Qt.resolvedUrl("../optimization/BatteryOptimization.qml"),
                                                      {
                                                          thing: batteryThing,
                                                          batteryConfiguration:batteryConfiguration
                                                      })
                        }
                    }
                }
            }

            CoFrostyCard {
                id: inverterGroup
                Layout.fillWidth: true
                contentTopMargin: 8
                headerText: qsTr("PV")
                visible: ((hemsManager.availableUseCases & HemsManager.HemsUseCasePv) != 0 ||
                          settings.showHiddenOptions) &&
                         inverterRepeater.count > 0

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    Repeater {
                        id: inverterRepeater
                        model: hemsManager.pvConfigurations
                        delegate: CoCard {
                            property PvConfiguration inverterConfiguration:
                                hemsManager.pvConfigurations.getPvConfiguration(model.PvThingId)
                            property Thing inverterThing:
                                engine.thingManager.things.getThing(model.PvThingId)
                            Layout.fillWidth: true
                            text: inverterThing.name
                            iconLeft: Qt.resolvedUrl("/icons/solar_power.svg")
                            showChildrenIndicator: true
                            onClicked: pageStack.push(Qt.resolvedUrl("../optimization/PVOptimization.qml"),
                                                      {
                                                          pvConfiguration: inverterConfiguration,
                                                          thing: inverterThing
                                                      })
                        }
                    }
                }
            }
        }
    }

    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: !systemGroup.visible &&
                 !heatingGroup.visible &&
                 !wallboxGroup.visible &&
                 !batteryGroup.visible &&
                 !inverterGroup.visible
        title: qsTr("No optimizations available")
        text: qsTr("Optimizations will be available once the required things have been added to the system.")
        buttonVisible: false
    }
}
