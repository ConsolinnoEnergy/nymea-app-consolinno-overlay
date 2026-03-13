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
        text: qsTr("Anonymisierte Nutzungsdaten")
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
                text: qsTr("Was sind anonymisierte Nutzungsdaten?")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 4
                text: qsTr("Mit dieser Freigabe werden vollständig anonymisierte Nutzungsdaten an Consolinno übermittelt. Diese Daten enthalten keinerlei persönliche Informationen und lassen keinen Rückschluss auf einzelne Personen oder Standorte zu. Alle identifizierenden Merkmale werden vor der Übertragung unwiederbringlich entfernt.")
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
                text: qsTr("Wofür werden diese Daten verwendet?")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 4
                text: qsTr("Die anonymisierten Daten werden ausschließlich für Forschungszwecke sowie zur Verbesserung von Produkten und Dienstleistungen genutzt. Sie helfen dabei, Optimierungsalgorithmen weiterzuentwickeln, die Systemstabilität zu verbessern und neue Funktionen bedarfsgerecht zu gestalten. Ihre Daten leisten damit einen wertvollen Beitrag zur Weiterentwicklung der Energiewende.")
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
                text: qsTr("Werden meine Daten an Dritte weitergegeben?")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 4
                Layout.bottomMargin: 16
                text: qsTr("Nein. Die anonymisierten Nutzungsdaten werden nicht an Dritte verkauft oder zu Werbezwecken verwendet. Sie können diese Freigabe jederzeit widerrufen. Weitere Informationen finden Sie unter www.consolinno.de/hems-datenschutz.")
            }
        }
    }
}
