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
        text: qsTr("Heating Element")
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

            model: hemsManager.heatingElementConfigurations
            delegate: NymeaItemDelegate {

                property HeatingElementConfiguration heatingElementConfiguration: hemsManager.heatingElementConfigurations.getHeatingElementConfiguration(model.heatingRodThingId)
                property Thing heatingElementThing: engine.thingManager.things.getThing(model.heatingRodThingId)

                Layout.fillWidth: true
                iconName: "../images/sensors/water.svg"
                progressive: true
                text: heatingElementThing.name
                onClicked: pageStack.push("HeatingElementOptimization.qml", { hemsManager: hemsManager, heatingElementConfiguration: heatingElementConfiguration, thing: heatingElementThing })
            }
        }
    }
}
