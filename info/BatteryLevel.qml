import QtQuick
import QtQuick.Controls
import QtQml
import Nymea 1.0

import "../components"
import "../delegates"

Page {
    property var stack
    header: ConsolinnoHeader {
        id: header
        text: qsTr("BatteryLevel")
        backButtonVisible: true
        onBackPressed: stack.pop()
        show_Image: true
    }
    InfoTextInterface{
        anchors.fill: parent
        summaryText: qsTr("The energy manager requires information on the battery level for the optimized charging process. This information is not transmitted by the vehicle and must therefore be entered manually.")
    }
}

