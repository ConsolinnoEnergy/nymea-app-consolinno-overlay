import QtQuick 2.0
import QtCharts 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
import "qrc:/ui/components"

Page {
    id: root

    property Thing thing
    property string marketArea: {
        let area = thing.paramByName("marketArea").value
        let areaNameSplit = area.split(" ");
        return areaNameSplit[1];
    }

    header: NymeaHeader {
        backButtonVisible: true
        text: "%1 %2".arg(thing.name).arg(marketArea)
        onBackPressed: {
            pageStack.pop()
        }
    }

    Component.onCompleted: {
        myLoader.setSource("qrc:/ui/mainviews/energy/ConsolinnoDynamicElectricPricingHistory.qml", { thing: thing })
    }

    Loader{
        id: myLoader
        anchors.fill: parent
        Layout.preferredHeight: parent / 2
    }

}
