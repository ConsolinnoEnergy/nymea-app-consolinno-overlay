import QtQuick
import QtQuick.Controls
import QtQml
import Nymea 1.0
import QtQuick.Layouts

import "../components"
import "../delegates"

Page {
    property var stack
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
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.smallMargins
                text: qsTr("The heating element is operated using solar power only. PV surplus is allocated to devices according to your selected priority.")
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
                text: qsTr("The heating element is not controlled by the %1.").arg(Configuration.deviceName)
            }
        }
    }
}
