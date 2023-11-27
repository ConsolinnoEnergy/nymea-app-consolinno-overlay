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
            return "UNSET"
        case 1:
            return "RUNNING"
        case 2:
            return "BUSY"
        case 10:
            return "RESTARTING"
        case 11:
            return "SHUTDOWN"
        case 80:
            return "ERROR"
        default:
            return "UNKOWN"
        }
    }

    property HemsManager hemsManager
    property ConEMSState conState: hemsManager.conEMSState

    Timer {
        interval: 6000
        running: true
        repeat: true
        onTriggered: {
            setHeartbeatValue()
        }
    }

    function setHeartbeatValue() {
        var last_seen = Math.ceil(new Date().getTime(
                                      ) / 1000 - conState.timestamp / 1000)
        heartbeatValue.text = Math.ceil(
                    new Date().getTime(
                        ) / 1000 - conState.timestamp / 1000) + " s ago"
        heartbeatValue.color = last_seen < 10 ? "green" : "red"
    }

    Connections {
        target: hemsManager
        onConEMSStateChanged: {
            opStatusValue.text = intToOperatingStateString(
                        conState.currentState.operating_state)
        }
    }

    header: ConsolinnoHeader {
        id: header
        text: qsTr("ConEMS State")
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: app.margins

        RowLayout {
            Layout.topMargin: 15
            Label {
                id: heartbeatLabel
                text: "Last heartbeat:"
            }
            Label {
                id: heartbeatValue
                Component.onCompleted: {
                    setHeartbeatValue()
                }
            }
        }

        RowLayout {
            Layout.topMargin: 15

            Label {
                id: opStatusLabel
                text: "Operating status:"
            }
            Label {
                id: opStatusValue
                text: intToOperatingStateString(
                          conState.currentState.operating_state)
            }
        }
    }
}
