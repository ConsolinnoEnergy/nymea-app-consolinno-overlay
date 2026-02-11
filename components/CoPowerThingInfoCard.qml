import QtQuick 2.0
import Nymea 1.0

CoInfoCard {
    property Thing thing
    readonly property State currentPowerState: thing ? thing.stateByName("currentPower") : null
    readonly property double currentPower: currentPowerState ? currentPowerState.value.toFixed(0) : 0
    text: thing ? thing.name : ""
    value: currentPowerState ? Math.abs(currentPower) : "-" // #TODO do we want the absolute value here?
    unit: "W" // #TODO convert large values to kW?
}