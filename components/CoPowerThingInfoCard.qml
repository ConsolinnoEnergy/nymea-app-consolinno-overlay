import QtQuick
import Nymea 1.0

CoInfoCard {
    property Thing thing
    readonly property State currentPowerState: thing ? thing.stateByName("currentPower") : null
    readonly property double currentPower: currentPowerState ? Number(currentPowerState.value) : 0
    text: thing.name
    value: currentPowerState ?
               UiUtils.powerDisplayValue(Math.abs(currentPower)) :
               "-"
    unit: currentPowerState ? UiUtils.powerDisplayUnit(currentPower) : "W"
}
