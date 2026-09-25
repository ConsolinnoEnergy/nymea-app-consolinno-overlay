import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects
import "qrc:/ui/components"
import Nymea

import "../components"
import "../delegates"

SetupWizardBase {
    id: root

    headerTitle: qsTr("Setup energy meter or hybrid inverter")
    filterInterface: "energymeter"
    deviceIcon: "/icons/electric_meter.svg"
    addDeviceLabel: qsTr("Add energy meter or hybrid inverter")
    successMessage: qsTr("The following energy meter or hybrid inverter has been found and set up:")
    errorMessage: qsTr("An unexpected error happened during the setup. Please verify the energy meter or hybrid inverter is installed correctly and try again.")
    deviceLimit: 0          // unlimited
    supportsPairing: false  // no pairing setup method used by energy meter/hybrid inverter thing classes yet
    skipAllowed: false           // mandatory step: no "Next" (skip) button
    showConfiguredDevices: false // preserve original UI: no "already configured" devices list
}
