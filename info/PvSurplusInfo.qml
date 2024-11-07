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
        summaryText: qsTr("The energy manager transmits the current photovoltaic surplus to the heat pump. The heat pump aims to utilize this surplus as efficiently as possible and operates at an increased level, provided this is feasible.")
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

                text: qsTr("Various settings of the heat pump play an essential role in this process, such as the minimum output, the activation and deactivation delay, as well as the permissible temperature increase.");
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width

                text: qsTr("If the heat pump consumes less surplus than expected, please consult your installer to review the settings.");
            }
        }
    }
}
