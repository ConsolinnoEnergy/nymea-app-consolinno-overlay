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

//            Label {
//                Layout.fillWidth: true
//                leftPadding: app.margins + 10
//                rightPadding: app.margins + 10
//                wrapMode: Text.WordWrap
//                Layout.preferredWidth: app.width
//                Layout.topMargin: Style.smallMargins + 10
//                font.bold: true
//                text: qsTr("Charging Threshold:")
//            }

//            Label {
//                Layout.fillWidth: true
//                leftPadding: app.margins + 10
//                rightPadding: app.margins + 10
//                wrapMode: Text.WordWrap
//                Layout.preferredWidth: app.width
//                Layout.topMargin: 0
//                text: qsTr("The battery will charge from the grid as soon as the electricity price falls below this threshold.")
//            }

//            Label {
//                Layout.fillWidth: true
//                leftPadding: app.margins + 10
//                rightPadding: app.margins + 10
//                wrapMode: Text.WordWrap
//                Layout.preferredWidth: app.width
//                Layout.topMargin: Style.smallMargins + 10
//                font.bold: true
//                text: qsTr("Discharging Threshold:")
//            }

//            Label {
//                Layout.fillWidth: true
//                leftPadding: app.margins + 10
//                rightPadding: app.margins + 10
//                wrapMode: Text.WordWrap
//                Layout.preferredWidth: app.width
//                Layout.topMargin: 0
//                text: qsTr("The battery will only discharge when the electricity price exceeds this threshold. This ensures that discharging happens only when it is worthwhile.")
//            }

//            Label {
//                Layout.fillWidth: true
//                leftPadding: app.margins + 10
//                rightPadding: app.margins + 10
//                wrapMode: Text.WordWrap
//                Layout.preferredWidth: app.width
//                Layout.topMargin: Style.smallMargins + 10
//                font.bold: true
//                text: qsTr("In short:")
//            }

//            Label {
//                Layout.fillWidth: true
//                leftPadding: app.margins + 10
//                rightPadding: app.margins + 10
//                wrapMode: Text.WordWrap
//                Layout.preferredWidth: app.width
//                Layout.topMargin: 0
//                text: qsTr("Charge when electricity is cheap.\nDischarge only when electricity is expensive.")
//            }

//            Label {
//                Layout.fillWidth: true
//                leftPadding: app.margins + 10
//                rightPadding: app.margins + 10
//                wrapMode: Text.WordWrap
//                Layout.preferredWidth: app.width
//                Layout.topMargin: Style.smallMargins + 10
//                text: qsTr("If you do not want to restrict discharging, you can set the discharging threshold to the same value as the charging threshold.")
//            }
        }
    }
}

