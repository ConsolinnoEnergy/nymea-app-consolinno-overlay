import QtQuick 2.0
import QtCharts 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
import "qrc:/ui/components"

Page {
    id: root

    header: NymeaHeader {
        backButtonVisible: true
        onBackPressed: {
            pageStack.pop()
        }
    }

    Loader{
        anchors.fill: parent
        Layout.preferredHeight: parent / 2
        property bool isWraper: true
        source: "qrc:/ui/mainviews/energy/ConsolinnoDynamicElectricPricingHistory.qml"
    }
}
