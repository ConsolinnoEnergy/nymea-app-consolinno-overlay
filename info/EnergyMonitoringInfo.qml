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
    header: ConsolinnoHeader {
        id: header
        text: qsTr("Energy Monitoring")
        backButtonVisible: true
        onBackPressed: stack.pop()
        show_Image: true
    }

    InfoTextInterface {
        anchors.fill: parent
        body: ColumnLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                Layout.preferredWidth: app.width
                Layout.topMargin: 8
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                font.bold: true
                text: qsTr("What data is shared with Energy Monitoring?")
            }

            Label {
                Layout.fillWidth: true
                Layout.preferredWidth: app.width
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                text: qsTr("With this release, consumption and production data from your energy system is transmitted to the Consolinno Cloud. This includes, for example, measured values for solar production, grid consumption, feed-in, and the consumption of connected devices. This data forms the basis for precise energy analysis and enables continuous optimization of the system.")
            }

            Label {
                Layout.fillWidth: true
                Layout.preferredWidth: app.width
                Layout.topMargin: 16
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                font.bold: true
                text: qsTr("What is the benefit for me?")
            }

            Label {
                Layout.fillWidth: true
                Layout.preferredWidth: app.width
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                text: qsTr("The transmitted data enables detailed analysis of your energy flows, long-term trend analysis, and improved control and optimization of your system. You benefit from well-founded recommendations for maximizing self-consumption and reducing costs.")
            }

            Label {
                Layout.fillWidth: true
                Layout.preferredWidth: app.width
                Layout.topMargin: 16
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                font.bold: true
                text: qsTr("Is personal data transmitted?")
            }

            Label {
                Layout.fillWidth: true
                Layout.preferredWidth: app.width
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                text: qsTr("The transmitted energy data is assigned to your system. You can revoke this release at any time. For more information on data protection, please visit www.consolinno.de/hems-datenschutz.")
            }
        }
    }
}