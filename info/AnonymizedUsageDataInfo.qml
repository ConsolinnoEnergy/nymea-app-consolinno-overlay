import QtQuick 2.15
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
        text: qsTr("Anonymized usage data")
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
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 8
                font.bold: true
                font.pixelSize: 16
                text: qsTr("What are anonymized usage data?")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 4
                text: qsTr("With this release, fully anonymized usage data is transmitted to Consolinno. This data does not contain any personal information and does not allow any conclusions to be drawn about individual persons or locations. All identifying characteristics are irrevocably removed before transmission.")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 16
                font.bold: true
                font.pixelSize: 16
                text: qsTr("What is this data used for?")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 4
                text: qsTr("The anonymized data is used exclusively for research purposes as well as for the improvement of products and services. They help to further develop optimization algorithms, improve system stability and design new functions to meet demand. Your data thus makes a valuable contribution to the further development of the energy transition.")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 16
                font.bold: true
                font.pixelSize: 16
                text: qsTr("Will my data be shared with third parties?")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 4
                Layout.bottomMargin: 16
                text: qsTr("No. The anonymized usage data is not sold to third parties or used for advertising purposes. You can revoke this release at any time. For more information, please visit www.consolinno.de/hems-datenschutz.")
            }
        }
    }
}
