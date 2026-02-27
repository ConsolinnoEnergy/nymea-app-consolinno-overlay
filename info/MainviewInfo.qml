import QtQuick
import QtQuick.Controls
import QtQml
import Nymea 1.0
import QtQuick.Layouts


import "../components"
import "../delegates"

Page {
    id: root
    property var stack
    property string dotStyle: '\u25CF'

    header: ConsolinnoHeader {
        id: header
        text: qsTr("Dashboard")
        backButtonVisible: true
        onBackPressed: stack.pop()
        show_Image: true

    }

    ColumnLayout{
        anchors.fill: parent
        ColumnLayout {
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
                textFormat: Text.RichText
                text: qsTr("The dashboard illustrates the energy flow in your house. The lines indicate by their thickness and direction where the current is flowing. At the top you can see the energy sources: Electricity can come from either their grid connection <span style='color: %2'>%1</span> or solar production <span style='color: %3'>%1</span>. If more solar power is produced than consumed, it is fed into the grid (grid connection changes color from <span style='color: %4'>%1</span> to <span style='color: %5'>%1</span>). At the bottom, your consumers and their current consumption are displayed.").arg(dotStyle).arg(Configuration.rootMeterAcquisitionColor).arg(Configuration.inverterColor).arg(Configuration.rootMeterAcquisitionColor).arg(Configuration.rootMeterReturnColor)
            }

            Label{
                Layout.fillWidth: true
                Layout.topMargin: 15
                leftPadding: Style.margins +10
                rightPadding: Style.margins +10
                font.bold: true
                id: consumptionTitle
                text: qsTr("Consumption of the last 24 hours")
            }
            Label{
                Layout.fillWidth: true
                leftPadding: Style.margins +10
                rightPadding: Style.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                id: consumptionDescription
                textFormat: Text.RichText
                text: qsTr("In the middle of the dashboard you can see the consumption of the last 24 hours. The <span style='color: %2'>%1</span> area shows your produced energy. If more energy is produced than consumed, power is fed into the grid visible on the <span style='color: %3'>%1</span> area. If more energy is consumed than produced, then energy is drawn from the grid visible on the <span style='color: %4'>%1</span> area. The other colored areas represent the energy consumption of the different devices such as a wallbox or a heat pump.").arg(dotStyle).arg(Configuration.inverterColor).arg(Configuration.rootMeterReturnColor).arg(Configuration.rootMeterAcquisitionColor)
            }
            Label{
                Layout.fillWidth: true
                Layout.topMargin: 15
                leftPadding: Style.margins +10
                rightPadding: Style.margins +10
                font.bold: true
                id: interactionTitle
                text: qsTr("Interaction")
            }
            Label{
                Layout.fillWidth: true
                leftPadding: Style.margins +10
                rightPadding: Style.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                id: interactionDescription
                text: qsTr("By tapping on the consumers, you can access the settings, e.g. the charging of the e-car. If you tap on the evaluation of the last 24 hours, further statistics are displayed.")
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }
}

