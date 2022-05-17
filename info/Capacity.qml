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

    header: NymeaHeader {
        id: header
        text: qsTr("Capacity info")
        backButtonVisible: true
        onBackPressed: stack.pop()

    }

    InfoTextInterface{
        //infotext: qsTr("Please enter the battery capacity of your vehicle. You will find this in your vehicle registration document.")
        summaryText: qsTr("A summary which I can define as I want")
        body: ColumnLayout {
            Layout.fillWidth: true
            id: bodyItem
                Label{
                    Layout.fillWidth: true
                    text: "Like a Label here. I can also add References like in the footer"

                }
                Label{
                    Layout.fillWidth: true
                    Layout.topMargin: 5
                    text: "or here"

                }
                Label{
                    Layout.fillWidth: true
                    Layout.topMargin: 5
                    text: "even here"

                }
                Label{
                    Layout.fillWidth: true
                    Layout.topMargin: 5
                    text: "And also here. I can also add References like in the footer below"

                }


        }

        footer: [
            {headline: "Charging Mode", Link: "ChargingModeInfo"},
            {headline: "Battery Level", Link: "BatteryLevel"},
        ]



    }
}
