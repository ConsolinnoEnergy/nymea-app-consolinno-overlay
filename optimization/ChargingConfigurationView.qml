import QtQuick 2.12
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
//import QtQuick.Controls.Styles 1.4
import QtQml 2.2
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
                iconName: Configuration.evchargerIcon !== "" ? "../images/" + Configuration.evchargerIcon : "../images/ev-charger.svg";
                progressive: true
                text: thing.name
                onClicked: pageStack.push("EvChargerOptimization.qml", { hemsManager: hemsManager, thing: thing })


                Image {
                    id: icon
                    height: 25
                    width: 25
                    source: configDelegate.iconName
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    z: 2
                }

                ColorOverlay {
                    anchors.fill: icon
                    source: icon
                    color: Style.buttonColor
                    z: 3
                }

            }
        }
    }

}
