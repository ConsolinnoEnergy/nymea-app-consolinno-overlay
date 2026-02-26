import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
//import QtQuick.Controls.Styles 1.4
import QtQml
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root

    property HemsManager hemsManager

    header: NymeaHeader {
        text: qsTr("Charging")
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
            id: configRepeater
            model: hemsManager.chargingConfigurations
            delegate: NymeaItemDelegate {
                id: configDelegate

                property ChargingConfiguration chargingConfiguration: hemsManager.chargingConfigurations.getChargingConfiguration(model.evChargerThingId)
                property Thing thing: engine.thingManager.things.getThing(model.evChargerThingId)



                Layout.fillWidth: true
                iconName: Configuration.evchargerIcon !== "" ? "../images/" + Configuration.evchargerIcon : "/icons/ev-charger.svg";
                progressive: true
                text: thing.name
                onClicked: pageStack.push("EvChargerOptimization.qml", { hemsManager: hemsManager, thing: thing })            


                Image {
                    id: icon
                    height: 24
                    width: 24
                    source: configDelegate.iconName
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
