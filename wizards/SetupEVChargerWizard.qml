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

    headerTitle: qsTr("Setup EV charger")
    filterInterface: "evcharger"
    shownInterfaces: ["evcharger"]
    deviceIcon: "/icons/ev_station.svg"
    emptyListText: qsTr("There is no EV charger set up yet.")
    addDeviceLabel: qsTr("Add EV charger")
    integratedDevicesLabel: qsTr("Integrated EV chargers")
    successMessage: qsTr("The following EV charger has been found and set up:")
    errorMessage: qsTr("An unexpected error happened during the setup. Please verify the EV charger is installed correctly and try again.")
    limitPopupText: qsTr("You have reached the maximum number of 3 EV chargers.")
    deviceLimit: 3
    supportsPairing: false

    onSuccessHandler: function(thing) {
        if (thing) {
            var page = pageStack.push("../optimization/EvChargerOptimization.qml", {
                thing: thing,
                calledFromAssistant: true
            });
            page.done.connect(function() {
                pageStack.pop(root);
            });
        } else {
            pageStack.pop(root);
        }
    }
}
