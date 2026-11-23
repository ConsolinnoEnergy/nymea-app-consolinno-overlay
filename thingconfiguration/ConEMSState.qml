import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts
import Nymea
import "../components"
import "../optimization"

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

    property ConEMSState conState: hemsManager.conEMSState

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            setHeartbeatValue()
        }
    }

    function setHeartbeatValue() {
        var last_seen = Math.floor((Date.now() - conState.timestamp) / 1000)
        var timestamp = Qt.formatDateTime(new Date(conState.timestamp),
                                          "dd.MM.yyyy hh:mm:ss")
        heartbeatValue.text = timestamp + " (" + last_seen + " s ago)"
        heartbeatValue.color = last_seen < 10 ? "green" : "red"
    }

    Connections {
        target: hemsManager
        onConEMSStateChanged: function(state) {
            opStatusValue.text = intToOperatingStateString(
                        state.currentState.operating_state)
        }
    }

    header: CoHeader {
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
