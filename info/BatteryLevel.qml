import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0

import "../components"
import "../delegates"

Page {
    property var stack
    header: NymeaHeader {
        id: header
        text: qsTr("BatteryLevel info")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }
    InfoTextInterface{
        infotext: qsTr("The energy manager requires information on the battery level for the optimized charging process. This information is not transmitted by the vehicle and must therefore be entered manually.")
    }
}

