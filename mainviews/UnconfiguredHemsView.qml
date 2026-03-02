import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.15
import Nymea 1.0
import Qt.labs.settings 1.1

import "../wizards"
import "../components"

EmptyViewPlaceholder {
    id: root

    property HemsManager hemsManager

    title: qsTr("Your %1 is not set up yet.").arg(Configuration.deviceName)
    text: qsTr("Please complete the setup wizard or manually configure your devices.")
    imageSource: "/ui/images/leaf.svg"
    buttonText: qsTr("Start setup")
    onButtonClicked: {
        d.resetWizardSettings()
        d.initialManualWizardSettings()
        d.resetBlackoutProtectionSettings()
        d.setup(false)
    }

    ThingsProxy {
        id: energyMetersProxy
        engine: _engine
        shownInterfaces: ["energymeter"]
    }

    Settings {
        id: wizardSettings
        category: "setupWizard"
        property bool modBusDone: false
        property bool solarPanelDone: false
        property bool evChargerDone: false
        property bool heatPumpDone: false
        property bool heatingElementDone: false
        property bool authorisation: false
        property bool installerData: false
    }

    Settings {
        id: manualWizardSettings
        category: "manualSetupWizard"
        property bool modBusDone: true
        property bool solarPanelDone: true
        property bool evChargerDone: true
        property bool heatPumpDone: true
        property bool heatingElementDone: true
        property bool authorisation: true
        property bool installerData: true
        property bool energymeter: true
    }

    Settings {
        id: blackoutProtectionSetting
        category: "blackoutProtectionSetting"
        property bool blackoutProtectionDone: true
        property bool blackoutBackPage: false
    }

    QtObject {
        id: d
        property var firstWizardPage: null

        property bool energyMeterWiazrdSkipped: false
        property bool manualEnergyWizardBack: false

        function pushPage(comp, properties) {
            var page = pageStack.push(comp, properties)
            if (!d.firstWizardPage) {
                d.firstWizardPage = page
            }
            return page
        }


        function exitWizard() {
            console.info("exiting wizard")
            pageStack.pop(d.firstWizardPage, StackView.Immediate)
            pageStack.pop()
        }

        function resetWizardSettings() {
            wizardSettings.modBusDone = false
            wizardSettings.solarPanelDone = false
            wizardSettings.evChargerDone = false
            wizardSettings.heatPumpDone = false
            wizardSettings.heatingElementDone = false
            wizardSettings.authorisation = false
            wizardSettings.installerData = false
        }

        function resetManualWizardSettings() {
            manualWizardSettings.modBusDone = false
            manualWizardSettings.solarPanelDone = false
            manualWizardSettings.evChargerDone = false
            manualWizardSettings.heatPumpDone = false
            manualWizardSettings.heatingElementDone = false
            manualWizardSettings.authorisation = false
            manualWizardSettings.installerData = false
            manualWizardSettings.energymeter = false
        }

        function resetBlackoutProtectionSettings() {
            blackoutProtectionSetting.blackoutProtectionDone = false
        }

        function initialManualWizardSettings() {
            manualWizardSettings.modBusDone = true
            manualWizardSettings.solarPanelDone = true
            manualWizardSettings.evChargerDone = true
            manualWizardSettings.heatPumpDone = true
            manualWizardSettings.heatingElementDone = true
            manualWizardSettings.authorisation = true
            manualWizardSettings.installerData = true
            manualWizardSettings.energymeter = true
        }

        function setup(showFinalPage) {

            console.info("Setup. Installed energy meters:", energyMetersProxy.count)

            if ((energyMetersProxy.count === 0 && !wizardSettings.authorisation)
                    || !manualWizardSettings.authorisation) {
                var page = d.pushPage("/ui/wizards/AuthorisationView.qml", { "hemsManager": hemsManager })
                page.done.connect(function (abort, accepted) {
                    if (accepted) {
                        manualWizardSettings.authorisation = true
                        wizardSettings.authorisation = true
                    }
                    if (abort) {
                        exitWizard()
                        return
                    }
                    setup(true)
                })
                return
            }

            if ((!wizardSettings.modBusDone)
                    || !manualWizardSettings.modBusDone) {
                var page = d.pushPage(
                            "/ui/system/ConsolinnoModbusRtuSettingsPage.qml")
                page.done.connect(function (skip, abort, back) {

                    if (back) {
                        energyMeterWiazrdSkipped = false
                        manualWizardSettings.energymeter = false
                        pageStack.pop()
                        return
                    }

                    if (abort) {
                        manualWizardSettings.modBusDone = true
                        exitWizard()
                        return
                    }
                    wizardSettings.modBusDone = true
                    manualWizardSettings.modBusDone = true
                    setup(true)
                })
                wizardSettings.modBusDone = true
                return
            }

            if ((energyMetersProxy.count === 0 && !energyMeterWiazrdSkipped)
                    || (energyMetersProxy.count === 0
                        && !manualWizardSettings.energymeter)) {
                var page = d.pushPage("/ui/wizards/SetupEnergyMeterWizard.qml")
                page.done.connect(function (skip, abort) {

                    console.info("energymeters done", skip, abort)
                    if (abort) {
                        exitWizard()
                        return
                    }
                    if (skip) {
                        energyMeterWiazrdSkipped = true
                        manualWizardSettings.energymeter = true
                        setup(true)
                        return
                    }

                    manualWizardSettings.energymeter = true
                    // since SetupEnergyMeter is not an add loop I need to pop twice
                    pageStack.pop()
                    pageStack.pop()
                    setup(true)
                })
                return
            }

            if ((!wizardSettings.solarPanelDone)
                    || !manualWizardSettings.solarPanelDone) {
                var page = d.pushPage(
                            "/ui/wizards/SetupSolarInverterWizard.qml")
                page.done.connect(function (skip, abort, back) {

                    if (back) {
                        energyMeterWiazrdSkipped = false
                        manualWizardSettings.modBusDone = false
                        pageStack.pop()
                        return
                    }

                    if (abort) {
                        manualWizardSettings.solarPanelDone = true
                        exitWizard()
                        return
                    }
                    wizardSettings.solarPanelDone = true
                    manualWizardSettings.solarPanelDone = true
                    setup(true)
                })
                wizardSettings.solarPanelDone = true
                return
            }

            if ((!wizardSettings.evChargerDone)
                    || !manualWizardSettings.evChargerDone) {
                var page = d.pushPage("/ui/wizards/SetupEVChargerWizard.qml")
                page.done.connect(function (skip, abort, back) {
                    if (back) {
                        manualWizardSettings.solarPanelDone = false
                        pageStack.pop()
                        return
                    }

                    if (abort) {
                        manualWizardSettings.evChargerDone = true
                        exitWizard()
                        return
                    }
                    wizardSettings.evChargerDone = true
                    manualWizardSettings.evChargerDone = true
                    setup(true)
                })

                page.countChanged.connect(function () {
                    blackoutProtectionSetting.blackoutProtectionDone = false
                })

                wizardSettings.evChargerDone = true
                return
            }

            if ((!wizardSettings.heatPumpDone)
                    || !manualWizardSettings.heatPumpDone) {
                var page = d.pushPage("/ui/wizards/SetupHeatPumpWizard.qml")
                page.done.connect(function (skip, abort, back) {

                    if (back) {
                        manualWizardSettings.evChargerDone = false
                        pageStack.pop()
                        return
                    }

                    if (abort) {
                        manualWizardSettings.heatPumpDone = true
                        exitWizard()
                        return
                    }

                    wizardSettings.heatPumpDone = true
                    manualWizardSettings.heatPumpDone = true
                    setup(true)
                })

                page.countChanged.connect(function () {
                    blackoutProtectionSetting.blackoutProtectionDone = false
                })

                wizardSettings.heatPumpDone = true
                return
            }

            if((!wizardSettings.heatingElementDone) || (!manualWizardSettings.heatingElementDone)) {
                var page = d.pushPage("/ui/wizards/SetupHeatingElementWizard.qml")
                page.done.connect(function (skip, abort, back) {
                    if (back) {
                        manualWizardSettings.heatPumpDone = false
                        pageStack.pop()
                        return
                    }
                    if (abort) {
                        manualWizardSettings.heatingElementDone = true
                        exitWizard()
                        return
                    }
                    wizardSettings.heatingElementDone = true
                    manualWizardSettings.heatingElementDone = true
                    setup(true)
                })
                page.countChanged.connect(function () {
                    blackoutProtectionSetting.blackoutProtectionDone = false
                })

                wizardSettings.heatingElementDone = true
                return;
            }


            if (!blackoutProtectionSetting.blackoutProtectionDone) {
                var page = d.pushPage(
                            "../optimization/BlackoutProtectionView.qml", {
                                "hemsManager": hemsManager,
                                "directionID": 1
                            })
                page.done.connect(function (skip, abort, back) {

                    if (back) {
                        manualWizardSettings.heatingElementDone = false
                        pageStack.pop()
                        return
                    }

                    if (abort) {

                        blackoutProtectionSetting.blackoutProtectionDone = true
                        exitWizard()
                        return
                    }

                    blackoutProtectionSetting.blackoutBackPage = true
                    blackoutProtectionSetting.blackoutProtectionDone = true
                    setup(true)
                })

                return
            }

            if ((!wizardSettings.installerData)
                    || !manualWizardSettings.installerData) {
                var page = d.pushPage("/ui/wizards/InstallerDataView.qml", {
                                          "hemsManager": hemsManager,
                                          "directionID": 0
                                      })
                page.done.connect(function (saved, skip, back) {

                    if (back) {

                        if (blackoutProtectionSetting.blackoutBackPage) {
                            blackoutProtectionSetting.blackoutProtectionDone = false
                            blackoutProtectionSetting.blackoutBackPage = false
                        } else {
                            manualWizardSettings.heatingElementDone = false
                        }

                        pageStack.pop()
                        return
                    }
                    manualWizardSettings.installerData = true
                    wizardSettings.installerData = true
                    setup(true)
                })
                return
            }

            if (showFinalPage) {
                var page = d.pushPage("/ui/wizards/WizardComplete.qml", {
                                          "hemsManager": hemsManager
                                      })
                page.done.connect(function (skip, abort) {

                    exitWizard()
                })
            }
        }
    }



}
