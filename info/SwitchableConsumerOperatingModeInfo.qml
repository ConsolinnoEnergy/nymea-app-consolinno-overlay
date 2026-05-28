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
    property bool pvSurplusModeAvailable: false

    header: ConsolinnoHeader {
        id: header
        text: qsTr("Operating mode")
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
                Layout.topMargin: Style.smallMargins + 10
                font.bold: true
                text: qsTr("PV surplus")
                visible: root.pvSurplusModeAvailable
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.smallMargins
                text: qsTr("The consumer is operated using solar power only. PV surplus is allocated to devices according to your selected priority.")
                visible: root.pvSurplusModeAvailable
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.smallMargins + 10
                font.bold: true
                text: qsTr("Always on")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.smallMargins
                text: qsTr("The consumer is permanently switched on.")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.smallMargins + 10
                font.bold: true
                text: qsTr("Off")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.smallMargins
                text: qsTr("The consumer is permanently switched off.")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.smallMargins + 10
                font.bold: true
                text: qsTr("No control")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.smallMargins
                text: qsTr("The consumer is not controlled by the %1.").arg(Configuration.deviceName)
            }
        }
    }
}
