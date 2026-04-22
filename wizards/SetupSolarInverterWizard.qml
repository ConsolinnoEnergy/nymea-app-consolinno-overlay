import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects
import "qrc:/ui/components"
import Nymea 1.0

import "../components"
import "../delegates"

SetupWizardBase {
    id: root

    headerTitle: qsTr("Setup solar inverter")
    filterInterface: "solarinverter"
    shownInterfaces: ["solarinverter"]
    deviceIcon: "/icons/solar_power.svg"
    emptyListText: qsTr("There is no inverter set up yet.")
    addDeviceLabel: qsTr("Add solar Inverter: ")
    integratedDevicesLabel: qsTr("Integrated solar inverter")
    successMessage: qsTr("The following solar inverter has been found and set up:")
    errorMessage: qsTr("An unexpected error happened during the setup. Please verify the solar inverter is installed correctly and try again.")
    limitPopupText: ""  // No limit for solar inverters
    deviceLimit: 0  // Unlimited
    supportsPairing: true  // SolarInverter supports pairing (OAuth, user/password, etc.)

    onSuccessHandler: function(thing) {
        if (thing) {
            var page = pageStack.push("../optimization/PVOptimization.qml", {
                pvConfiguration: hemsManager.pvConfigurations.getPvConfiguration(thing.id),
                thing: thing,
                directionID: 1
            });
            page.done.connect(function() {
                pageStack.pop(root);
            });
        }
    }
}
