/* WizardController.qml
 *
 * Non-visual component that encapsulates the full HEMS setup wizard logic.
 * Instantiate this wherever wizard navigation is needed and call startSetup().
 *
 * Required context properties: pageStack, _engine
 * Required properties: hemsManager
 */

import QtQuick 2.15
import Nymea 1.0
import Qt.labs.settings 1.1

Item {
    id: root

    visible: false
    width: 0
    height: 0

    // ---- Public API --------------------------------------------------------

    property HemsManager hemsManager

    // Resets all wizard state and starts the wizard from the beginning.
    function startSetup() {
        _firstWizardPage = null
        _energyMeterWizardSkipped = false
        _resetWizardSettings()
        _initialManualWizardSettings()
        _resetBlackoutProtectionSettings()
        _setup(false)
    }

    // ---- Private state -----------------------------------------------------

    property var _firstWizardPage: null
    property bool _energyMeterWizardSkipped: false

    // ---- Internal data objects ---------------------------------------------

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

    // ---- Private helpers ---------------------------------------------------

    function _pushPage(comp, properties) {
        var page = pageStack.push(comp, properties)
        if (!root._firstWizardPage) {
            root._firstWizardPage = page
        }
        return page
    }

    function _exitWizard() {
        console.info("WizardController: exiting wizard")
        pageStack.pop(root._firstWizardPage, StackView.Immediate)
        pageStack.pop()
        root._firstWizardPage = null
    }

    function _resetWizardSettings() {
        wizardSettings.modBusDone = false
        wizardSettings.solarPanelDone = false
        wizardSettings.evChargerDone = false
        wizardSettings.heatPumpDone = false
        wizardSettings.heatingElementDone = false
        wizardSettings.authorisation = false
        wizardSettings.installerData = false
    }

    function _resetManualWizardSettings() {
        manualWizardSettings.modBusDone = false
        manualWizardSettings.solarPanelDone = false
        manualWizardSettings.evChargerDone = false
        manualWizardSettings.heatPumpDone = false
        manualWizardSettings.heatingElementDone = false
        manualWizardSettings.authorisation = false
        manualWizardSettings.installerData = false
        manualWizardSettings.energymeter = false
    }

    function _resetBlackoutProtectionSettings() {
        blackoutProtectionSetting.blackoutProtectionDone = false
    }

    function _initialManualWizardSettings() {
        manualWizardSettings.modBusDone = true
        manualWizardSettings.solarPanelDone = true
        manualWizardSettings.evChargerDone = true
        manualWizardSettings.heatPumpDone = true
        manualWizardSettings.heatingElementDone = true
        manualWizardSettings.authorisation = true
        manualWizardSettings.installerData = true
        manualWizardSettings.energymeter = true
    }

    // ---- Core wizard logic -------------------------------------------------

    function _setup(showFinalPage) {
        console.info("WizardController: setup(). Energy meters:", energyMetersProxy.count)

        if ((energyMetersProxy.count === 0 && !wizardSettings.authorisation)
                || !manualWizardSettings.authorisation) {
            var page = _pushPage("/ui/wizards/AuthorisationView.qml", { "hemsManager": hemsManager })
            page.done.connect(function (abort, accepted) {
                if (accepted) {
                    manualWizardSettings.authorisation = true
                    wizardSettings.authorisation = true
                }
                if (abort) {
                    _exitWizard()
                    return
                }
                _setup(true)
            })
            return
        }

        if ((!wizardSettings.modBusDone) || !manualWizardSettings.modBusDone) {
            var page = _pushPage("/ui/system/ConsolinnoModbusRtuSettingsPage.qml")
            page.done.connect(function (skip, abort, back) {
                if (back) {
                    _energyMeterWizardSkipped = false
                    manualWizardSettings.energymeter = false
                    pageStack.pop()
                    return
                }
                if (abort) {
                    manualWizardSettings.modBusDone = true
                    _exitWizard()
                    return
                }
                wizardSettings.modBusDone = true
                manualWizardSettings.modBusDone = true
                _setup(true)
            })
            wizardSettings.modBusDone = true
            return
        }

        if ((energyMetersProxy.count === 0 && !_energyMeterWizardSkipped)
                || (energyMetersProxy.count === 0 && !manualWizardSettings.energymeter)) {
            var page = _pushPage("/ui/wizards/SetupEnergyMeterWizard.qml")
            page.done.connect(function (skip, abort) {
                if (abort) {
                    _exitWizard()
                    return
                }
                if (skip) {
                    _energyMeterWizardSkipped = true
                    manualWizardSettings.energymeter = true
                    _setup(true)
                    return
                }
                manualWizardSettings.energymeter = true
                pageStack.pop()
                pageStack.pop()
                _setup(true)
            })
            return
        }

        if ((!wizardSettings.solarPanelDone) || !manualWizardSettings.solarPanelDone) {
            var page = _pushPage("/ui/wizards/SetupSolarInverterWizard.qml")
            page.done.connect(function (skip, abort, back) {
                if (back) {
                    _energyMeterWizardSkipped = false
                    manualWizardSettings.modBusDone = false
                    pageStack.pop()
                    return
                }
                if (abort) {
                    manualWizardSettings.solarPanelDone = true
                    _exitWizard()
                    return
                }
                wizardSettings.solarPanelDone = true
                manualWizardSettings.solarPanelDone = true
                _setup(true)
            })
            wizardSettings.solarPanelDone = true
            return
        }

        if ((!wizardSettings.evChargerDone) || !manualWizardSettings.evChargerDone) {
            var page = _pushPage("/ui/wizards/SetupEVChargerWizard.qml")
            page.done.connect(function (skip, abort, back) {
                if (back) {
                    manualWizardSettings.solarPanelDone = false
                    pageStack.pop()
                    return
                }
                if (abort) {
                    manualWizardSettings.evChargerDone = true
                    _exitWizard()
                    return
                }
                wizardSettings.evChargerDone = true
                manualWizardSettings.evChargerDone = true
                _setup(true)
            })
            page.countChanged.connect(function () {
                blackoutProtectionSetting.blackoutProtectionDone = false
            })
            wizardSettings.evChargerDone = true
            return
        }

        if ((!wizardSettings.heatPumpDone) || !manualWizardSettings.heatPumpDone) {
            var page = _pushPage("/ui/wizards/SetupHeatPumpWizard.qml")
            page.done.connect(function (skip, abort, back) {
                if (back) {
                    manualWizardSettings.evChargerDone = false
                    pageStack.pop()
                    return
                }
                if (abort) {
                    manualWizardSettings.heatPumpDone = true
                    _exitWizard()
                    return
                }
                wizardSettings.heatPumpDone = true
                manualWizardSettings.heatPumpDone = true
                _setup(true)
            })
            page.countChanged.connect(function () {
                blackoutProtectionSetting.blackoutProtectionDone = false
            })
            wizardSettings.heatPumpDone = true
            return
        }

        if ((!wizardSettings.heatingElementDone) || (!manualWizardSettings.heatingElementDone)) {
            var page = _pushPage("/ui/wizards/SetupHeatingElementWizard.qml")
            page.done.connect(function (skip, abort, back) {
                if (back) {
                    manualWizardSettings.heatPumpDone = false
                    pageStack.pop()
                    return
                }
                if (abort) {
                    manualWizardSettings.heatingElementDone = true
                    _exitWizard()
                    return
                }
                wizardSettings.heatingElementDone = true
                manualWizardSettings.heatingElementDone = true
                _setup(true)
            })
            page.countChanged.connect(function () {
                blackoutProtectionSetting.blackoutProtectionDone = false
            })
            wizardSettings.heatingElementDone = true
            return
        }

        if (!blackoutProtectionSetting.blackoutProtectionDone) {
            var page = _pushPage("../optimization/BlackoutProtectionView.qml", {
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
                    _exitWizard()
                    return
                }
                blackoutProtectionSetting.blackoutBackPage = true
                blackoutProtectionSetting.blackoutProtectionDone = true
                _setup(true)
            })
            return
        }

        if ((!wizardSettings.installerData) || !manualWizardSettings.installerData) {
            var page = _pushPage("/ui/wizards/InstallerDataView.qml", {
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
                _setup(true)
            })
            return
        }

        if (showFinalPage) {
            var page = _pushPage("/ui/wizards/WizardComplete.qml", {
                                     "hemsManager": hemsManager
                                 })
            page.done.connect(function (skip, abort) {
                _exitWizard()
            })
        }
    }
}
