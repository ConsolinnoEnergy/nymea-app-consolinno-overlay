import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2

import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"
Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Charging optimization")
        //text: ev_chargerProxy.get(0).id
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Component.onCompleted: {
        chargingOptimizationconfig = hemsManager.chargingOptimizationConfigurations.getChargingOptimizationConfiguration(ev_chargerProxy.get(0).id)
    }

    ThingsProxy {
        id: ev_chargerProxy
        engine: _engine
        shownInterfaces: ["evcharger"]
    }

    property HemsManager hemsManager
    property ChargingOptimizationConfiguration chargingOptimizationconfig
    //TODO: built a page where every possible option is displayed (Similar to AddGenericCar I think)
    // Note there could be multiple Wallboxes, so we need to make it for every Wallbox
    ColumnLayout{

        Switch{
            id: reenableChargePointSwitch
            checked: chargingOptimizationconfig.reenableChargepoint
        }

        Button{
            id: testingButton
            Layout.fillWidth: true
            text: qsTr("Test that")
            onClicked: {
                hemsManager.setChargingOptimizationConfiguration(ev_chargerProxy.get(0).id, {reenableChargepoint: reenableChargePointSwitch.checked})
            }
        }
    }

}
