import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0

import "../components"
import "../delegates"

Page {

    header: NymeaHeader {
        id: header
        text: qsTr("Minimum Charging Current info")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    InfoTextInterface{
        infotext: qsTr("For some vehicles, the charging process is not resumed after a pause or interruption. This can be the case in the charging mode 'cost-optimized charging' or 'solar power only' if there is not enough solar power available. Setting a minimum current ensures that the vehicle is charged with the minimum current even if no solar power is available, and thus no interruption occurs. The minimum charging current should be selected as low as possible.")
    }
}
