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
        text: qsTr("Tariff-controlled charging")
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
                Layout.topMargin: Style.margins
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("Two price limits can be set:")
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins - 2
                rightPadding: app.margins + 10
                Layout.topMargin: Style.margins
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                font.bold: true
                text: "<ul style='list-style-type:circle;'><li>" + qsTr("\"Charging\" price limit") + "</li>"
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins + 35
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.topMargin: Style.smallMargins
                Layout.preferredWidth: app.width
                text: qsTr("This is the price below which the battery is charged from the grid.")
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins - 2
                rightPadding: app.margins + 10
                Layout.topMargin: Style.margins
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                font.bold: true
                text: "<ul style='list-style-type:circle;'><li>" + qsTr("\"Block discharging\" price limit") + "</li>"
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins + 35
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.topMargin: Style.smallMargins
                Layout.preferredWidth: app.width
                text: qsTr("This value determines the price up to which discharging is blocked.\n\nIf discharging is not to be blocked, simply set this value to the same value as the \"Charging\" price limit.")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.bigMargins
                font.bold: true
                text: qsTr("Definition of price limits")
            }

            Label {
                Layout.fillWidth: true
                leftPadding: app.margins + 10
                rightPadding: app.margins + 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                Layout.topMargin: Style.smallMargins
                text: qsTr("The price limits are calculated relative to the current average price, e. g. average price –10 %.\nThis means: The price limit corresponds to the current average price minus 10 %.")
            }
        }
    }
}

