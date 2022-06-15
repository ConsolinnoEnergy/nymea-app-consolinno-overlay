import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0

import "../components"
Page {


    Component.onCompleted:{
        simulationSwitch.checked = evProxy.get(0).stateByName("pluggedIn").value
    }

    header: NymeaHeader {
        text: qsTr("car Simulation")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }


    ThingsProxy {
        id: evProxy
        engine: _engine
        shownInterfaces: ["electricvehicle"]
        requiredStateName: "pluggedIn"
    }


    ColumnLayout{

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins
        anchors.margins: app.margins

    RowLayout{
        Layout.fillWidth: true
        Label{
            Layout.fillWidth: true
            text: evProxy.get(0) ? qsTr("switch on") +  evProxy.get(0).id : qsTr("plug in car: ")
        }

        Switch{
            id: simulationSwitch
            onClicked: {
                if (simulationSwitch.checked){
                    evProxy.get(0).executeAction("pluggedIn", [{paramName: "pluggedIn", value: true}])
                }
                else{
                    evProxy.get(0).executeAction("pluggedIn", [{paramName: "pluggedIn", value: false}])
                }

            }



        }
    }

}
}
