import QtQuick
import QtQuick.Layouts
import Nymea

import "../components"

// Shared "Setup car" form used by both AddGenericCar.qml (adding a new car)
// and CarInventory.qml's carData page (editing an existing car). Bundles the
// input fields together with the lookup needed to build the settings array
// for ThingManager.setThingSettings().
ColumnLayout {
    id: root
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: 0

    // Existing thing to prefill the fields from. Leave null when adding a
    // new car.
    property Thing thing: null

    // Thing class the settings paramTypeIds are looked up on. Defaults to
    // the thing's class, but must be set explicitly when adding a new car
    // (no thing exists yet at that point).
    property ThingClass thingClass: thing ? thing.thingClass : null

    readonly property string name: nameInput.text
    readonly property bool isValid: nameInput.text !== ""

    QtObject {
        id: d

        function settingParamTypeId(settingName) {
            if (!root.thingClass || !root.thingClass.settingsTypes) {
                return null;
            }
            var paramType = root.thingClass.settingsTypes.findByName(settingName);
            return paramType ? paramType.id : null;
        }
    }

    // Returns the settings array ready to be passed to
    // ThingManager.setThingSettings(). Settings that don't exist on
    // thingClass (yet) are omitted instead of being sent with an invalid
    // paramTypeId.
    function settings() {
        var result = [];
        var capacityParamTypeId = d.settingParamTypeId("capacity");
        if (capacityParamTypeId) {
            result.push({ paramTypeId: capacityParamTypeId, value: capacityInput.value });
        }
        var minChargingCurrentParamTypeId = d.settingParamTypeId("minChargingCurrent");
        if (minChargingCurrentParamTypeId) {
            result.push({ paramTypeId: minChargingCurrentParamTypeId, value: minChargingCurrentInput.value });
        }
        return result;
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
