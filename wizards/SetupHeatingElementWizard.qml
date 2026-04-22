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

    headerTitle: qsTr("Setup heating element")
    filterInterface: "heatingrod"
    shownInterfaces: ["heatingrod"]
    deviceIcon: "/icons/water_heater.svg"
    emptyListText: qsTr("There is no heating element set up yet.")
    addDeviceLabel: qsTr("Add heating element: ")
    integratedDevicesLabel: qsTr("Integrated heating elements")
    successMessage: qsTr("The following heating element has been found and set up:")
    errorMessage: qsTr("An unexpected error happened during the setup. Please verify the heating element is installed correctly and try again.")
    limitPopupText: qsTr("At the moment, %1 can only control one heating element.").arg(Configuration.deviceName)
    deviceLimit: 1
    supportsPairing: false

    onSuccessHandler: function(thing) {
        if (thing) {
            var page = pageStack.push("../optimization/HeatingElementOptimization.qml", {
                heatingConfiguration: hemsManager.heatingConfigurations.getHeatingConfiguration(thing.id),
                heatRodThing: thing,
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
