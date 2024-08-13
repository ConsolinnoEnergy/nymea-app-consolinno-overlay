import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2


import "../components"
import "../delegates"

Page {
    id: energyroot
    property var stack
    header: ConsolinnoHeader {
        id: header
        text: qsTr("Energymanager")
        backButtonVisible: true
        onBackPressed: stack.pop()
        show_Image: true
    }


    InfoTextInterface{

        anchors.fill: parent
        summaryText: qsTr("The energy manager regulates the heat pump to maximize the consumption of its own solar power. If you switch off the optimization, the energy manager no longer affects the control of the heat pump.")
        body: ColumnLayout {
            Layout.fillWidth: true
            id: bodyItem
                Label{
                    Layout.fillWidth: true
                    text: qsTr("Optimization of the heat pump")
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

                    text: qsTr("The heat pump is controlled via SG-ready states so that the available PV surplus is optimally utilized. A certain amount of PV surplus must be available for a certain period of time (currently 15 minutes) for an SG ready state to be switched.")

                }

                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins +10
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width

                    text: qsTr("If the PV surplus is more than 50 % of the nominal output of the heat pump, SG ready state 3 is switched for at least 30 minutes (recommendation for increased operation, the heat pump decides whether this is possible depending on the current temperature range).")

                }

                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins +10
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width

                    text: qsTr("If the PV surplus is more than 80 % of the nominal output of the heat pump, then SG ready state 4 is switched for at least 30 minutes (definitive start-up command, if this is possible within the scope of the control settings).")

                }

                Label {
                    Layout.fillWidth: true
                    leftPadding: app.margins +10
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width
                    Layout.topMargin: 8
                    text: qsTr("The operating status indicates the control of the heat pump:")
                }

                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins -2
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width
                    font.bold: true

                    text: qsTr(" <ul style = 'list-style-type:circle;'> <li>Off (= EVU block)</li>: ")

                }
                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins +35
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.topMargin: 0
                    Layout.preferredWidth: app.width
                    text: qsTr("Start-up block, is not used for optimization")

                }

                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins -2
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width
                    font.bold: true

                    text: qsTr("<ul style = 'list-style-type:circle;'> <li>Standard</li>: ")

                }
                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins +35
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width
                    text: qsTr("Standard status, optimizer makes no specification")

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
                    text: qsTr("Recommendation for increased operation, the heat pump decides whether this is possible depending on the current temperature range.")

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
                    text: qsTr("Definitive start-up command, if this is possible within the scope of the control settings")

                }

                Label {
                    Layout.fillWidth: true
                    leftPadding: app.margins +10
                    rightPadding: app.margins +10
                    Layout.topMargin: 16;
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width
                    text: qsTr("Please note that the schedule is subject to a certain inaccuracy due to the prediction of the PV production. If sufficient PV production was not predicted, the heat pump may not be switched to increased operation despite sunshine. Or vice versa, if the forecast assumes sufficient PV surplus, but in reality there is less PV surplus, there may be grid consumption.")
                }

        }

        infofooter: [
            {headline: qsTr("Charging Mode"), Link: "ChargingModeInfo"},
            {headline: qsTr("Battery Level"), Link: "BatteryLevel"},

        ]



    }
}
