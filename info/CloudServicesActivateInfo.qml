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
        text: qsTr("Cloud-Dienste aktivieren")
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
                text: qsTr("Was bedeutet diese Einstellung?")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 4
                text: qsTr("Diese Einstellung ermöglicht ausschließlich die Verbindung zu den autorisierten Cloud-Diensten des Systems. Darüber werden Funktionen wie Datenabgleich, sichere Fernzugriffe und Systemaktualisierungen bereitgestellt. Das System verbindet sich dabei nur mit den ausdrücklich vorgesehenen Diensten des Herstellers – nicht mit externen oder beliebigen Cloud-Anbietern.")
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
                text: qsTr("Welche Daten werden übertragen?")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 4
                text: qsTr("Die Verbindung ermöglicht grundlegende Kommunikation zwischen dem System und den Consolinno-Servern. Welche Datenkategorien konkret geteilt werden, legen Sie über die einzelnen Freigaben darunter fest. Ohne Ihre ausdrückliche Zustimmung werden keine weitergehenden Daten übermittelt.")
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
                text: qsTr("Kann ich die Verbindung jederzeit deaktivieren?")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 4
                Layout.bottomMargin: 16
                text: qsTr("Ja. Sie können die Cloud-Verbindung jederzeit deaktivieren. Das System arbeitet danach vollständig im lokalen Betrieb weiter. Einige Funktionen, die eine aktive Cloud-Verbindung erfordern, stehen in diesem Fall nicht zur Verfügung.")
            }
        }
    }
}
