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
        text: qsTr("Battery")
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
            model: hemsManager.batteryConfigurations
            delegate: NymeaItemDelegate {
                id: configDelegate

                property BatteryConfiguration batteryConfiguration: hemsManager.batteryConfigurations.getBatteryConfiguration(model.batteryThingId)
                property Thing thing: engine.thingManager.things.getThing(model.batteryThingId)

                Layout.fillWidth: true
                iconName: Configuration.batteryIcon !== "" ? "../images/" + Configuration.batteryIcon : "../images/battery/battery-080.svg";
                progressive: true
                text: thing.name
                onClicked: pageStack.push("BatteryOptimization.qml", { hemsManager: hemsManager, thing: thing, batteryConfiguration:batteryConfiguration })


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
