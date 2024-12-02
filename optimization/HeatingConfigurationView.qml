import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root

    property HemsManager hemsManager

    header: NymeaHeader {
        text: qsTr("Heating")
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
            model: hemsManager.heatingConfigurations
            delegate: NymeaItemDelegate {
                id: delegateIcon
                property HeatingConfiguration heatingConfiguration: hemsManager.heatingConfigurations.getHeatingConfiguration(model.heatPumpThingId)
                property Thing heatPumpThing: engine.thingManager.things.getThing(model.heatPumpThingId)

                Layout.fillWidth: true
                iconName: Configuration.heatpumpIcon !== "" ? "qrc:/ui/images/"+Configuration.heatpumpIcon : "../images/heatpump.svg"
                progressive: true
                text: heatPumpThing.name
                onClicked: pageStack.push("HeatingOptimization.qml", { hemsManager: hemsManager, heatingConfiguration: heatingConfiguration, heatPumpThing: heatPumpThing })

                Image {
                    id: icons
                    height: 24
                    width: 24
                    source: delegateIcon.iconName
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    z: 2
                }

                ColorOverlay {
                    anchors.fill: icons
                    source: icons
                    color: Style.consolinnoMedium
                    z: 3
                }

            }
        }

        Repeater {
            id: heatingRodRepeater

            model: hemsManager.heatingElementConfigurations
            delegate: NymeaItemDelegate {
                id: delegateIconR
                property HeatingElementConfiguration heatingElementConfiguration: hemsManager.heatingElementConfigurations.getHeatingElementConfiguration(model.heatingRodThingId)
                property Thing heatingElementThing: engine.thingManager.things.getThing(model.heatingRodThingId)

                Layout.fillWidth: true
                iconName: Configuration.heatingRodIcon !== "" ? "/ui/images/"+Configuration.heatingRodIcon : "../images/heating_rod.svg"
                progressive: true
                text: heatingElementThing.name
                onClicked: pageStack.push("HeatingElementOptimization.qml", { hemsManager: hemsManager, heatingElementConfiguration: heatingElementConfiguration, heatRodThing: heatingElementThing })

                Image {
                    id: iconsR
                    height: 24
                    width: 24
                    source: delegateIconR.iconName
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    z: 2
                }

                ColorOverlay {
                    anchors.fill: iconsR
                    source: iconsR
                    color: Style.consolinnoMedium
                    z: 3
                }


            }
        }

    }


    Component.onCompleted: {
        // FIXME: directly open if there is only one heatpump to save a click
        //                if (hemsManager.heatingConfigurations.count === 1) {
        //                    onClicked: pageStack.push(heatingConfigurationComponent, { hemsManager: hemsManager,
        //                                                  heatingConfiguration: hemsManager.heatingConfigurations.get(0),
        //                                                  heatPumpThing: engine.thingManager.things.getThing(hemsManager.heatingConfigurations.get(0).heatPumpThingId) })
        //                }
    }

}



