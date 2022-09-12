import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

Page {
    id: root

    property HemsManager hemsManager
    property ConEMSState conState: hemsManager.conEMSStates.getConEMSState("f002d80e-5f90-445c-8e95-a0256a0b464e")


    Connections{
        target: hemsManager
        onConEMSStateChanged:
        {
            update_Controller(conState)
            conEMSStates.append({currentState: translate_CurrentState(conState.currentState)})
            if(conEMSStates.count > 200){
                conEMSStates.remove(0)
            }

        }
        // if more controller come -> add an if statement here
        function update_Controller(conState){

            conEMSControllerlistview.model.clear()

            if (conState.chargingControllerActive()){
                conEMSControllerlistview.model.append({name: qsTr("Charging Controller")})
            }

            if (conState.heatpumpControllerActive()){
                conEMSControllerlistview.model.append({name: qsTr("Heat pump Controller")})
            }

        }

        function translate_CurrentState(currentState){
            if (currentState === 0){
                return qsTr("Unknown")
            }else if(currentState === 1){
                return qsTr("Running")
            }else if(currentState === 2){
                return qsTr("Optimizer Busy")
            }else if(currentState === 3){
                return qsTr("Restarting")
            }else if(currentState === 4){
                return qsTr("Error")
            }


        }

        function translate_time(timestamp){
            return timestamp


        }

    }




    header: ConsolinnoHeader{
        id: header
        text: qsTr("ConEMS Observer")
        onBackPressed: pageStack.pop()
    }





    ColumnLayout{
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right


        ListModel{
            id: conEMSStates

        }

        VerticalDivider{
            Layout.fillWidth: true
            Layout.topMargin: app.margins
            dividerColor: Material.accent
        }

        ListView{
                id: listView
                Layout.fillWidth: true
                Layout.preferredHeight: app.height/2
                Layout.leftMargin: app.margins
                clip: true
                ScrollBar.vertical: ScrollBar{}
                model: conEMSStates


                delegate: Label{
                    width: listView.width
                    maximumLineCount: 2
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: Qt.formatDateTime(new Date(), "HH:mm:ss")+ qsTr(":  Current State:  ") + currentState
                    color: {
                        if (currentState === "Error"){
                            return "red"
                        }
                        else if (currentState === "Running" ){
                            return "green"
                        }
                        else{
                            return Material.foreground
                        }
                    }
                }

            }




        VerticalDivider{
            Layout.fillWidth: true
            dividerColor: Material.accent
        }



        Label{

            text: qsTr("Active controller: ")
            Layout.leftMargin: app.margins
            font.pixelSize: 20

        }


        ListView{
                id: conEMSControllerlistview
                Layout.fillWidth: true
                Layout.preferredHeight: app.height/3
                Layout.leftMargin: app.margins
                clip: true
                ScrollBar.vertical: ScrollBar{}
                model: ListModel {
                    id: modelNodes
                }


                delegate: ConsolinnoItemDelegate{
                    id: controller
                    width: conEMSControllerlistview.width - 2*app.margins
                    text: model.name
                    progressive: false

                }

            }















    }

}
