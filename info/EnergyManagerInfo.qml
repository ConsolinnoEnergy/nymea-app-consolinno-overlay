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
                    text: qsTr("Operating status:")
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

                    text: qsTr("The energy manager controls the heat pump to maximize the consumption of its own solar electricity. The control is carried out by a schedule generated in advance and based on a prediction of the surplus solar power. The schedule contains so-called control recommendations according to the SG-Ready standard.  Depending on the predicted PV surplus, the heat pump will be switched to increased operation or a recommendation for increased operation will be given.")

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

                    text: qsTr(" <ul style = 'list-style-type:circle;'> <li>Standard</li>: ")

                }
                Label{
                    Layout.fillWidth: true
                    leftPadding: app.margins +35
                    rightPadding: app.margins +10
                    wrapMode: Text.WordWrap
                    Layout.topMargin: 0
                    Layout.preferredWidth: app.width
                    text: qsTr("the energy manager does not intervene.")

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
                    text: qsTr("recommendation for increased operation, the heat pump will decide if this is possible depending on the current temperature range.")

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
                    text: qsTr("energy manager switches heat pump to increased operation.")

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
                    text: qsTr("a temporary shutdown by the grid operator to avoid grid overload.")

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



    }
}
