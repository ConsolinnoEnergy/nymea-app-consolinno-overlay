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
        text: qsTr("Dashboard")
        backButtonVisible: true
        onBackPressed: stack.pop()
        show_Image: true

    }

    InfoTextInterface{
        anchors.fill: parent
        summaryText: false
        body: ColumnLayout {
            Layout.fillWidth: true
            id: bodyItem
            Label{
                Layout.fillWidth: true
                id: dashboardTitle
                text: qsTr("Energy flow")
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                font.bold: true
                font.pixelSize: 17
            }
            Label{
                id: dashboardDescription
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("The dashboard illustrates the energy flow in your house. The lines indicate by their thickness and direction where the current is flowing. At the top you can see the energy sources: Electricity can come from either their grid connection (red) or solar production (yellow). If more solar power is produced than consumed, it is fed into the grid (grid connection changes color from red to blue). At the bottom, your consumers and their current consumption are displayed.")
            }

            Label{
                Layout.fillWidth: true
                Layout.topMargin: 15
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                font.bold: true
                id: consumptionTitle
                text: qsTr("Consumption of the last 24 hours")
            }
            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                id: consumptionDescription
                text: qsTr("In the middle of the dashboard you can see the consumption of the last 24 hours. The yellow area shows your produced energy. If more energy is produced than consumed, power is fed into the grid visible on the blue area. If more energy is consumed than produced, then energy is drawn from the grid visible on the blue area. The other colored areas represent the energy consumption of the different devices such as a wallbox or a heat pump.")
            }
            Label{
                Layout.fillWidth: true
                Layout.topMargin: 15
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                font.bold: true
                id: interactionTitle
                text: qsTr("Interaction")
            }
            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                id: interactionDescription
                text: qsTr("By tapping on the consumers, you can access the settings, e.g. the charging of the e-car. If you tap on the evaluation of the last 24 hours, further statistics are displayed.")
            }


        }




    }
}

