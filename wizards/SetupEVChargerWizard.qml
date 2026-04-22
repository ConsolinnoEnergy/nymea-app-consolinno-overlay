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

    headerTitle: qsTr("Setup wallbox")
    filterInterface: "evcharger"
    shownInterfaces: ["evcharger"]
    deviceIcon: "/icons/ev_station.svg"
    emptyListText: qsTr("There is no wallbox set up yet.")
    addDeviceLabel: qsTr("Add wallboxes:")
    integratedDevicesLabel: qsTr("Integrated wallbox")
    successMessage: qsTr("The following wallbox has been found and set up:")
    errorMessage: qsTr("An unexpected error happened during the setup. Please verify the wallbox is installed correctly and try again.")
    limitPopupText: qsTr("At the moment, %1 can only control one EV charger. Support for multiple EV chargers is planned for future releases.").arg(Configuration.deviceName)
    deviceLimit: 1
    supportsPairing: false

    onSuccessHandler: function(thing) {
        if (thing) {
            var page = pageStack.push("../optimization/EvChargerOptimization.qml", {
                thing: thing,
                chargingConfiguration: hemsManager.chargingConfigurations.getChargingConfiguration(thing.id),
                directionID: 1
            });
            page.done.connect(function() {
                pageStack.pop(root);
            });
        } else {
            pageStack.pop(root);
        }
    }
}
