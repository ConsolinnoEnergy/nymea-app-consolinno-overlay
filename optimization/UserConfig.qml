import QtQuick 2.0
import QtQuick.Controls 2.15

import Nymea 1.0

import "../components"
import "../delegates"

Page {
    id: root
    property HemsManager hemsManager
    property UserConfiguration userconfig: hemsManager.userConfigurations.getUserConfiguration("528b3820-1b6d-4f37-aea7-a99d21d42e72")


    header: ConsolinnoHeader{
        id: header
        text: userconfig.defaultChargingMode
        onBackPressed: pageStack.pop()
    }

    Button{
        id: testbutton
        text: "Testing stuff"
        onClicked: {
            hemsManager.setUserConfiguration({defaultChargingMode: 2, value: "something else", also: "even more something"})

        }

    }

}
