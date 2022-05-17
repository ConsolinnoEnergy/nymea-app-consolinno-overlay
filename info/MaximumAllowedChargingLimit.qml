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
        text: qsTr("Maximum Allowed Charging Limit info")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }

    InfoTextInterface{
        infotext: qsTr("Please enter here which charging limit you have set in your vehicle or in your vehicle app. This setting also specifies the maximum amount you can charge into the vehicle as a charging target in the charging modes of the energy manager. If you want to specify a higher charging target, you must change the setting in your vehicle and in the app accordingly.")
    }
}
