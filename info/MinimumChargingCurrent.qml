import QtQuick
import QtQuick.Controls
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts
import "../components"
import "../delegates"

Page {
    property var stack
    header: ConsolinnoHeader {
        id: header
        show_Image: true
        text: qsTr("Minimum Charging Current ")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }

    InfoTextInterface{
        anchors.fill: parent
        summaryText: qsTr("The minimum current defines the minimum charging current with which the vehicle must be charged.")
        body: ColumnLayout{
            Label{
                Layout.fillWidth: true
                text: qsTr("Charging interruptions: ")
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
                text: qsTr("For some vehicles, the charging process is not continued again after a break or interruption. This can be the case in the charging mode 'PV-optimized charging' or 'solar power only' if there is not enough solar power available. Setting a minimum current ensures that the vehicle is charged with the minimum current even if no solar power is available, and thus no interruption occurs. The minimum charging current should be selected as low as possible.")

            }

        }
        infofooter: [
            {headline: qsTr("Target charge"), Link: "TargetChargeInfo"},
            {headline: qsTr("Maximum allowed charging limit"), Link: "MaximumAllowedChargingLimit"},

        ]



    }
}
