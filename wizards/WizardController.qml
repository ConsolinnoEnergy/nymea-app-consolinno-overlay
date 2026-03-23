/* WizardController.qml
 *
 * Non-visual component that encapsulates the full HEMS setup wizard logic.
 * Instantiate this wherever wizard navigation is needed and call startSetup().
 *
 * Required context properties: pageStack, _engine
 * Required properties: hemsManager
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import Nymea 1.0
import Qt.labs.settings 1.1

Item {
    id: root

    visible: false
    width: 0
    height: 0

    // ---- Public API --------------------------------------------------------

    // Emitted once the wizard has fully completed and all wizard pages
    // have been popped. The caller can connect to this to do any further
    // navigation (e.g. pop back to dashboard from a settings page).
    signal wizardDone()

    // Resets all wizard state and starts the wizard from the beginning.
    // AuthorisationView is shown only when no energy meters are present.
    function startSetup() {
        d.resetWizardSettings()
        d.initialManualWizardSettings()
        d.resetBlackoutProtectionSettings()
        d.setup(false)
    }

    // Starts the wizard in manual re-run mode (e.g. from DeviceOverview).
    // AuthorisationView is always shown regardless of energy meter count.
    function startManualSetup() {
        d.resetManualWizardSettings()
        d.setup(true)
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
        property bool energyMeterWizardSkipped: false



        function pushPage(comp, properties) {
            var page = pageStack.push(comp, properties)
            if (!firstWizardPage) {
                firstWizardPage = page
            }
            return page
        }

        function exitWizard() {
            console.info("WizardController: exiting wizard")
            pageStack.pop(firstWizardPage, StackView.Immediate)
            pageStack.pop()
            firstWizardPage = null
            root.wizardDone()
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
            console.info("WizardController: setup(). Energy meters:", energyMetersProxy.count)

            if ((energyMetersProxy.count === 0 && !wizardSettings.authorisation)
                    || !manualWizardSettings.authorisation) {
                var page = pushPage("/ui/wizards/AuthorisationView.qml")
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

            if ((!wizardSettings.modBusDone) || !manualWizardSettings.modBusDone) {
                var page = pushPage("/ui/system/ConsolinnoModbusRtuSettingsPage.qml")
                page.done.connect(function (skip, abort, back) {
                    if (back) {
                        energyMeterWizardSkipped = false
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

            if ((energyMetersProxy.count === 0 && !energyMeterWizardSkipped)
                    || (energyMetersProxy.count === 0 && !manualWizardSettings.energymeter)) {
                var page = pushPage("/ui/wizards/SetupEnergyMeterWizard.qml")
                page.done.connect(function (skip, abort) {
                    if (abort) {
                        exitWizard()
                        return
                    }
                    if (skip) {
                        energyMeterWizardSkipped = true
                        manualWizardSettings.energymeter = true
                        setup(true)
                        return
                    }
                    manualWizardSettings.energymeter = true
                    pageStack.pop()
                    pageStack.pop()
                    setup(true)
                })
                return
            }

            if ((!wizardSettings.solarPanelDone) || !manualWizardSettings.solarPanelDone) {
                var page = pushPage("/ui/wizards/SetupSolarInverterWizard.qml")
                page.done.connect(function (skip, abort, back) {
                    if (back) {
                        energyMeterWizardSkipped = false
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

            if ((!wizardSettings.evChargerDone) || !manualWizardSettings.evChargerDone) {
                var page = pushPage("/ui/wizards/SetupEVChargerWizard.qml")
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

            if ((!wizardSettings.heatPumpDone) || !manualWizardSettings.heatPumpDone) {
                var page = pushPage("/ui/wizards/SetupHeatPumpWizard.qml")
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

            if ((!wizardSettings.heatingElementDone) || (!manualWizardSettings.heatingElementDone)) {
                var page = pushPage("/ui/wizards/SetupHeatingElementWizard.qml")
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
                return
            }

            if (!blackoutProtectionSetting.blackoutProtectionDone) {
                var page = pushPage("../optimization/BlackoutProtectionView.qml", {
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

            if ((!wizardSettings.installerData) || !manualWizardSettings.installerData) {
                var page = pushPage("/ui/wizards/InstallerDataView.qml", {
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
                var page = pushPage("/ui/wizards/WizardComplete.qml")
                page.done.connect(function (skip, abort) {
                    exitWizard()
                })
            }
        }
    }



    // ---- Core wizard logic -------------------------------------------------

}
