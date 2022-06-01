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
        text: qsTr("Charging mode ")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }
    InfoTextInterface{
        anchors.fill: parent
        summaryText: qsTr("In the charging mode you set how the energy manager should charge the vehicle.")
        body: ColumnLayout{
            Layout.fillWidth: true
            id: bodyItem
            Label{
                Layout.fillWidth: true
                text: qsTr("PV optimized: ")
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
                text: qsTr("The energy manager tries to maximize the consumption of the solar power. The charging time and the charging current are planned in such a way that as much of the solar power as possible can be consumed.
If the own electricity is not sufficient to reach the charging target, it is supplemented with grid electricity.")
            }

        }

    }

}

