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


    function intToOperatingStateString(value) {
        switch (value) {
            case 0:
                return "UNSET";
            case 1:
                return "RUNNING";
            case 2:
                return "BUSY";
            case 10:
                return "RESTARTING";
            case 11:
                return "SHUTDOWN";
            case 80:
                return "ERROR";
            default:
                return "Unknown State";
        }
    }



    property HemsManager hemsManager
    property ConEMSState conState: hemsManager.conEMSState

    Connections {
        target: hemsManager
        onConEMSStateChanged: {
            opStatusLabel.text = intToOperatingStateString(conState.currentState.operating_state)
        }
    }

    header: ConsolinnoHeader {
        id: header
        text: qsTr("ConEMS State")
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors.fill: parent
        ScrollView {
            anchors.fill: parent
            Label {
                id: opStatusLabel
                text: intToOperatingStateString(conState.currentState.operating_state)

            }
        }
    }
}
