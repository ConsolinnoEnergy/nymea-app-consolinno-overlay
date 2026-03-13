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
        text: qsTr("Energie-Monitoring")
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
                text: qsTr("Was wird beim Energie-Monitoring geteilt?")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 4
                text: qsTr("Mit dieser Freigabe werden Verbrauchs- und Erzeugungsdaten Ihrer Energieanlage an die Consolinno-Cloud übermittelt. Dazu gehören beispielsweise Messwerte zur Solarproduktion, zum Netzbezug, zur Einspeisung sowie zum Verbrauch angeschlossener Geräte. Diese Daten bilden die Grundlage für eine präzise Energieanalyse und ermöglichen eine kontinuierliche Optimierung des Systems.")
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
                text: qsTr("Welchen Nutzen hat das für mich?")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 4
                text: qsTr("Die übermittelten Daten ermöglichen detaillierte Auswertungen Ihrer Energieflüsse, langfristige Verlaufsanalysen sowie eine verbesserte Steuerung und Optimierung Ihrer Anlage. Sie profitieren von fundierten Empfehlungen zur Eigenverbrauchsmaximierung und Kostenreduktion.")
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
                text: qsTr("Werden personenbezogene Daten übertragen?")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 4
                Layout.bottomMargin: 16
                text: qsTr("Die übermittelten Energiedaten sind Ihrer Anlage zugeordnet. Sie können diese Freigabe jederzeit widerrufen. Weitere Informationen zum Datenschutz finden Sie unter www.consolinno.de/hems-datenschutz.")
            }
        }
    }
}
