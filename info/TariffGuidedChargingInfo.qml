import QtQuick 2.12
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
        show_Image: true
        text: qsTr("Tariff guided charging")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }
    InfoTextInterface{
        anchors.fill: parent
        body: ColumnLayout {
            Layout.fillWidth: true
            id: bodyItem

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                Layout.topMargin: 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("Two price limits can be defined:")
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins - 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                textFormat: Text.MarkdownText
                text: qsTr("- The first price limit is the value below which the battery will charge from the grid (indicated by the green bar).")
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins - 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                textFormat: Text.MarkdownText
                text: qsTr("- The second price limit defines up to which price discharging should be blocked (indicated by the grey bar).")
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins - 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                textFormat: Text.MarkdownText
                text: qsTr("- If discharging should not be blocked, this value can simply be set to the same value as the charging limit.")
            }
        }
    }
}

