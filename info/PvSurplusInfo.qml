import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2


import "../components"
import "../delegates"

Page {
    id: energyroot
    property var stack
    header: ConsolinnoHeader {
        id: header
        text: qsTr("Energymanager")
        backButtonVisible: true
        onBackPressed: stack.pop()
        show_Image: true
    }


    InfoTextInterface{
        anchors.fill: parent
        summaryText: qsTr("The energy manager sends the heat pump the current PV surplus. The heat pump tries to use the surplus as much as possible and runs in increased operation if this is feasible.")
        body: ColumnLayout {
            Layout.fillWidth: true
            id: bodyItem
            Label{
                Layout.fillWidth: true
                text: qsTr("Optimization of the heat pump")
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                font.bold: true
                font.pixelSize: 17

            }
            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width

                text: qsTr("Various heat pump settings play a role here, such as the set minimum output, switch-on and switch-off delay, as well as the permitted temperature increase. If the heat pump consumes less surplus than expected, ask your installer to check the settings.");
            }
        }
    }
}
