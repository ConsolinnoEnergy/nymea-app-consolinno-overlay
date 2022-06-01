import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2


import "../components"
import "../delegates"

Page {
    id: root
    property var stack

    header: ConsolinnoHeader {
        id: header
        text: qsTr("Capacity")
        backButtonVisible: true
        onBackPressed: stack.pop()
        show_Image: true

    }

    InfoTextInterface{
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
