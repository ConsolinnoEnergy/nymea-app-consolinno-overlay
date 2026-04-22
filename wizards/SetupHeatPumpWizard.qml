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

    headerTitle: qsTr("Setup heat pump")
    filterInterface: "heatpump"
    shownInterfaces: ["heatpump", "smartgridheatpump", "simpleheatpump"]
    deviceIcon: "/icons/heat_pump.svg"
    emptyListText: qsTr("There is no heat pump set up yet.")
    addDeviceLabel: qsTr("Add heat pumps:")
    integratedDevicesLabel: qsTr("Integrated heat pumps")
    successMessage: qsTr("The following heat pump has been found and set up:")
    errorMessage: qsTr("An unexpected error happened during the setup. Please verify the heat pump is installed correctly and try again.")
    limitPopupText: qsTr("At the moment, %1 can only control one heatpump. Support for multiple heatpumps is planned for future releases.").arg(Configuration.deviceName)
    deviceLimit: 1
    supportsPairing: false

    onSuccessHandler: function(thing) {
        if (thing) {
            var page = pageStack.push("../optimization/HeatingOptimization.qml", {
                heatingConfiguration: hemsManager.heatingConfigurations.getHeatingConfiguration(thing.id),
                heatPumpThing: thing,
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
