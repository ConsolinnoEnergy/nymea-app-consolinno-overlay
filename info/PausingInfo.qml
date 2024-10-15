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
        text: qsTr("Pausing")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }
    InfoTextInterface{
        anchors.fill: parent
//        summaryText: qsTr("In the charging mode you set how the energy manager should charge the vehicle.")
        body: ColumnLayout {
            Layout.fillWidth: true
            id: bodyItem
            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("Some vehicles cannot handle an interruption in the charging process, i.e. charging can no longer be continued after an interruption in the charging process if, for example, the electricity price falls below the price limit again after a pause. If problems occur, the option <font color=\"#87BD26\">'Charging with minimum power'</font> should be selected. With this setting, charging continues at minimum power even if the price limit is exceeded.")
            }

        }

    }

}

