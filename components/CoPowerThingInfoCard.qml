import QtQuick 2.0
import Nymea 1.0

CoInfoCard {
    property Thing thing
    readonly property State currentPowerState: thing ? thing.stateByName("currentPower") : null
    readonly property double currentPower: currentPowerState ? Number(currentPowerState.value) : 0
    text: thing.name
    value: currentPowerState ? Math.abs(currentPower).toFixed(0) : "-" // #TODO do we want the absolute value here?
    unit: "W" // #TODO convert large values to kW?
}
