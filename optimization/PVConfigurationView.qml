import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts
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
                id: icons
                property PvConfiguration pvConfiguration: hemsManager.pvConfigurations.getPvConfiguration(model.PvThingId)
                property Thing pvThing: engine.thingManager.things.getThing(model.PvThingId)


                Layout.fillWidth: true
                iconName: Configuration.inverterIcon !== "" ? "../images/" + Configuration.inverterIcon : "/icons/weathericons/weather-clear-day.svg";
                progressive: true
                text: pvThing.name
                onClicked: pageStack.push("PVOptimization.qml", { hemsManager: hemsManager, pvConfiguration: pvConfiguration, thing: pvThing })


                Image {
                    id: icon
                    height: 24
                    width: 24
                    source: icons.iconName
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    z: 2
                }

                ColorOverlay {
                    anchors.fill: icon
                    source: icon
                    color: Style.consolinnoMedium
                    z: 3
                }

            }
        }
     }

}
