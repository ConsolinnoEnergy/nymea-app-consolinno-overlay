import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts 1.3

import "../components"
import "../delegates"

Page {
    id: root

    property HemsManager hemsManager
    property Thing heatpumpThing
    property HeatingConfiguration heatingconfig: hemsManager.heatingConfigurations.getHeatingConfiguration(heatpumpThing.id)





    header: NymeaHeader {
        id: header
        text: qsTr("Heatpump")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout{
        id: heatingConfig
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins
        anchors.margins: app.margins

        RowLayout{
            Layout.fillWidth: true

            Label{
                Layout.fillWidth: true
                id: state
                text: qsTr("Operating Mode:")
            }
            Label{
                id: stateValue
                text: hemsManager.heatingConfigurations.getHeatingConfiguration(heatpumpThing.id)
            }
        }

        RowLayout{
            Layout.fillWidth: true

            Label{
                id: optimiziationEnabled
                Layout.fillWidth: true
                text: qsTr("Optimization")
            }

            Switch{
                id: optimizationEnableSwitch
                checked: heatingConfig.optimizationEnabled


            }



        }




    }



}
