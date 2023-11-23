import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.2
import QtCharts 2.3
import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"
import "../"

Page {
    id: root

    property HemsManager hemsManager
    property ConEMSState conState: hemsManager.conEMSState

    Connections {
        target: hemsManager
        onConEMSStateChanged: {
            formattedJSON.text = JSON.stringify(conState, undefined, 4)
        }
    }

    header: ConsolinnoHeader {
        id: header
        text: qsTr("ConEMS State")
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors.fill: parent

    }
}
