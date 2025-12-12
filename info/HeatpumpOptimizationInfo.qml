import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2


import "../components"
import "../delegates"

Page {
    property var stack
    header: ConsolinnoHeader {
        id: header
        text: qsTr("Optimization")
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
                Layout.topMargin: Style.smallMargins + 10
                font.bold: true
                text: qsTr("Dynamic pricing")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.smallMargins
                text: qsTr("The heat pump is given the command to increase operation if the price is below the defined price limit. If the price limit is changed, it can take up to 15 minutes for the changes to take effect.")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.smallMargins + 10
                font.bold: true
                text: qsTr("PV surplus")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.smallMargins
                text: qsTr("The heat pump is controlled in such a way that the available PV surplus is optimally utilized. If the PV surplus is more than 50% of the nominal output of the heat pump for 15 minutes, the heat pump is set to the \"increased\" operating state.")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.smallMargins + 10
                font.bold: true
                text: qsTr("Off")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.smallMargins
                text: qsTr("The heat pump is not optimized.")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.smallMargins + 20
                text: qsTr("Please note:")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: 0
                text: qsTr("The operating state is implemented by the heat pump depending on the respective temperature conditions.")
            }
        }
    }
}
