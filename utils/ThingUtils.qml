pragma Singleton

import QtQuick
import Nymea 1.0

Item {
    id: root

    property var hemsManager: null

    function targetSocPvSurplusExceeded(battery, batteryConfiguration) {
        if (!battery) { return false; }
        if (!batteryConfiguration) { return false; }
        if (battery.thingClass.interfaces.indexOf("battery") === 0) { return false; }
        const batteryLevelState = battery.stateByName("batteryLevel");
        if (!batteryLevelState) { return false; }
        const batteryLevel = Math.round(batteryLevelState.value);
        const targetSocPvSurplus = batteryConfiguration.targetSocPvSurplus;
        if (!targetSocPvSurplus || targetSocPvSurplus.length === 0) { return false; }
        return batteryLevel > targetSocPvSurplus[0];
    }

    function isConnected(thing) {
        // If thing is invalid or has no connected state, assume connected
        // to avoid showing "not connected" warnings for things that may
        // be conncted.
        if (!thing) { return true; }
        const connectedState = thing.stateByName("connected");
        if (!connectedState) { return true; }
        return connectedState.value === true;
    }
}
