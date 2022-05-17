import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0

import "../components"
import "../delegates"

Page {
    property var stack
    header: NymeaHeader {
        id: header
        text: qsTr("Targetcharge Info")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }

    InfoTextInterface{
        infotext: qsTr("With the charging target, you specify how full you want to charge the battery. Note that the charging limit set in the vehicle cannot be exceeded. For example, if you have preset a charging limit of 80%, you cannot charge more than 80% with the energy manager, as the vehicle automatically shuts down the charging process. To ensure that the energy manager takes this limit into account, enter the charging limit in the vehicle profile.")
    }
}

