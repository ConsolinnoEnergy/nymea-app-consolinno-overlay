import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"



Page {
    id: root


    property HemsManager hemsManager

    header: NymeaHeader {
        text: qsTr("PV")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }




    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins

        Repeater {
            id: testrepeater

            model: hemsManager.pvConfigurations
            delegate: NymeaItemDelegate {

                property PvConfiguration pvConfiguration: hemsManager.pvConfigurations.getPvConfiguration(model.PvThingId)
                property Thing pvThing: engine.thingManager.things.getThing(model.PvThingId)


                Layout.fillWidth: true
                iconName: "../images/weathericons/weather-clear-day.svg"
                progressive: true
                text: pvThing.name
                onClicked: pageStack.push("PVOptimization.qml", { hemsManager: hemsManager, pvConfiguration: pvConfiguration, pvThing: pvThing })




            }
        }
     }

}
