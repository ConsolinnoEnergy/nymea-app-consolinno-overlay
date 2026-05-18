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

    function powerDisplayValue() {
    }
}
