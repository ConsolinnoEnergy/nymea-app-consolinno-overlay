pragma Singleton

import QtQuick
import NymeaApp.Utils 1.0

Item {
    id: root

    function energyDisplayValue(energyState) {
        return energyState ?
                    NymeaUtils.floatToLocaleString((+energyState.value), 2) :
                    "-";
    }

    function powerDisplayValue(powerValue) {
        return Math.abs(powerValue) >= 1000 ?
                    NymeaUtils.floatToLocaleString(powerValue / 1000, 2) :
                    NymeaUtils.floatToLocaleString(powerValue, 0);
    }

    function powerDisplayUnit(powerValue) {
        return Math.abs(powerValue) >= 1000 ? "kW" : "W";
    }
}
