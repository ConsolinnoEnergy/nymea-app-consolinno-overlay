import QtQuick
import QtQuick.Controls
import QtQml
import Nymea 1.0
import QtQuick.Layouts


import "../components"
import "../delegates"

Page {
    id: energyroot
    property var stack
    header: ConsolinnoHeader {
        id: header
        text: qsTr("Number of phases")
        backButtonVisible: true
        onBackPressed: stack.pop()
        show_Image: true
    }


    InfoTextInterface{

        anchors.fill: parent
        body: ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 8
                font.bold: true
                text: qsTr("3 phases")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 8
                text: qsTr("Higher charging capacity → faster to full")
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins -2
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 8
                lineHeight: 1.3

                text: "<ul style='list-style-type:circle;'><li>" +
                      qsTr("Requires sufficient PV surplus") +
                      "</li><li>" +
                      qsTr("Ideal for stable, high solar radiation or when speed is more important") +
                      "</li></ul>"
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 8
                font.bold: true
                text: qsTr("1 phase")
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins -2
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: -16
                lineHeight: 1.3

                text: "<ul style='list-style-type:circle;'> <li>" +
                      qsTr("Requires less minimum power from the PV system") +
                      "</li><li>" +
                      qsTr("Particularly suitable for variable or low solar radiation") +
                      "</li><li>" +
                      qsTr("Charges the vehicle more slowly") +
                      "</li></ul>"
            }
        }
    }
}
