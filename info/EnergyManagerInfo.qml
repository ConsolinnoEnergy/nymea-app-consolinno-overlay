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
        text: qsTr("Energymanager info")
        backButtonVisible: true
        onBackPressed: stack.pop()

    }

    InfoTextInterface{
        summaryText: qsTr("The energy manager regulates the heat pump to maximize the consumption of its own solar power.If you switch off the optimization, the energy manager no longer affects the control of the heat pump.")
        body: ColumnLayout {
            Layout.fillWidth: true
            id: bodyItem
                Label{
                    Layout.fillWidth: true
                    text: qsTr("Operating status: ")
                    leftPadding: app.margins +10
                    rightPadding: app.margins +10

                    font.bold: true
                    font.pixelSize: 17

                }
                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins +10
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width

                    text: qsTr("The energy manager can set the heat pump to increased operation in the case of a power surplus, e.g. on a sunny day, in order to consume the own solar energy. The intervention of the energy manager is visible in the display of the operating status")

                }
                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins -2
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width
                    font.bold: true

                    text: qsTr(" <ul style = 'list-style-type:circle;'> <li>Normal</li>: ")

                }
                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins +35
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.topMargin: 0
                    Layout.preferredWidth: app.width
                    text: qsTr("energy manager does not intervene")

                }

                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins -2
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width
                    font.bold: true

                    text: qsTr("<ul style = 'list-style-type:circle;'> <li>Increased</li>: ")

                }
                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins +35
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width
                    text: qsTr("recommendation for increased operation, the heat pump will decide if this is possible depending on the current temperature range")

                }

                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins -2
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width
                    font.bold: true

                    text: qsTr("<ul style = 'list-style-type:circle;'> <li>High</li>: ")

                }
                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins +35

                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width
                    text: qsTr("energy manager switches heat pump to increased operation")

                }

                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins -2
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width
                    font.bold: true

                    text: qsTr("<ul style = 'list-style-type:circle;'> <li>Off</li>: ")

                }
                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins +35
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width
                    text: qsTr("a temporary shutdown by the network operator to avoid network overload.")

                }


        }

        footer: [
            {headline: "Charging Mode", Link: "ChargingModeInfo"},
            {headline: "Battery Level", Link: "BatteryLevel"},
        ]



    }
}
