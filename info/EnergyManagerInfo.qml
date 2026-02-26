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
        text: qsTr("Operating mode")
        backButtonVisible: true
        onBackPressed: stack.pop()
        show_Image: true
    }


    InfoTextInterface{

        anchors.fill: parent
        body: ColumnLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 8
                text: qsTr("The operating mode indicates the control of the heat pump:")
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
        }
    }
}
