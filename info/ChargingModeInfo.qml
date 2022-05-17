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
        text: qsTr("Charging mode Info")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }
    InfoTextInterface{
        infotext: qsTr("The energy manager tries to maximize the consumption of the solar power. The charging time and the charging current are planned in such a way that as much of the solar power as possible can be consumed.
If the own electricity is not sufficient to reach the charging target, it is supplemented with grid electricity.")
    }

}

