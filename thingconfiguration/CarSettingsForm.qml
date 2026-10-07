import QtQuick
import QtQuick.Layouts
import Nymea

import "../components"

// Shared "Setup car" form used by both AddGenericCar.qml (adding a new car)
// and CarInventory.qml's carData page (editing an existing car). Bundles the
// input fields together with the settings paramTypeId mapping needed to
// persist them via ThingManager.setThingSettings().
ColumnLayout {
    id: root
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: 0

    // Existing thing to prefill the fields from. Leave null when adding a
    // new car.
    property Thing thing: null

    readonly property string name: nameInput.text
    readonly property bool isValid: nameInput.text !== ""

    readonly property string _capacityParamTypeId: "57f36386-dd71-4ab0-8d2f-8c74a391f90d"
    readonly property string _minChargingCurrentParamTypeId: "0c55516d-4285-4d02-8926-1dae03649e18"

    // Returns the settings array ready to be passed to
    // ThingManager.setThingSettings().
    function settings() {
        return [
            { paramTypeId: _capacityParamTypeId, value: capacityInput.value },
            { paramTypeId: _minChargingCurrentParamTypeId, value: minChargingCurrentInput.value }
        ];
    }

    CoInputField {
        id: nameInput
        Layout.fillWidth: true
        labelText: qsTr("Name")
        text: thing ? thing.name : ""
    }

    CoInputStepper {
        id: capacityInput
        from: 0
        to: 2147483647 // Workaround for "no upper limit"
        labelText: qsTr("Capacity")
        value: thing ? thing.stateByName("capacity").value : 0
        infoUrl: "Capacity.qml"
        unit: "kWh"
    }

    CoSlider {
        id: minChargingCurrentInput
        Layout.fillWidth: true
        labelText: qsTr("Minimum charging current")
        infoUrl: "MinimumChargingCurrent.qml"
        from: 6
        to: 16
        stepSize: 1
        value: thing ? thing.stateByName("minChargingCurrent").value : 6
        valueText: value + " A"
    }
}
