import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2


import "../components"
import "../delegates"

Page {

    header: NymeaHeader {
        id: header
        text: qsTr("Capacity info")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    InfoTextInterface{
        infotext: qsTr("Please enter the battery capacity of your vehicle. You will find this in your vehicle registration document.")
    }
}
