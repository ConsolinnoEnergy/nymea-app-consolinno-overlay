import QtQuick
import QtQuick.Controls
import QtQml
import Nymea 1.0
import QtQuick.Layouts


import "../components"
import "../delegates"

Page {
    id: root
    bottomPadding: 0
    property int navigationFooterHeight: 0
    property var stack

    header: ConsolinnoHeader {
        id: header
        text: qsTr("Capacity")
        backButtonVisible: true
        onBackPressed: stack.pop()
        show_Image: true

    }

    InfoTextInterface{
        navigationFooterHeight: root.navigationFooterHeight
        anchors.fill: parent
        summaryText: qsTr("Please enter the battery capacity of your vehicle. You will find this in your vehicle registration document.")
        body: ColumnLayout {

        }

        infofooter: [
            {headline: qsTr("Charging Mode"), Link: "ChargingModeInfo"},
            {headline: qsTr("Battery Level"), Link: "BatteryLevel"},
        ]



    }
}
