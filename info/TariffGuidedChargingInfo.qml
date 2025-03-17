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
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                Layout.topMargin: 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("The battery is charged from the grid as soon as the price falls below the price limit.")
                color: "#194D25"
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                Layout.topMargin: 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("It is advisable to choose a price limit below 0 cents. If the electricity exchange price falls below 0 cents, this means that there is surplus electricity in the grid. By charging your battery at these times, you can use this cheap electricity and consume it when electricity is more expensive.")
                color: "#194D25"
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                Layout.topMargin: 10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("In winter, when little to no PV electricity is expected, it can also make sense to charge at a higher price limit. Please note, however, that taxes and fees are added to the exchange price.")
                color: "#194D25"
            }

        }
    }
}

