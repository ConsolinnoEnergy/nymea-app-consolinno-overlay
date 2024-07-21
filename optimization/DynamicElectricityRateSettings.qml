import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.15

import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

Page {
    id: root
    property HemsManager hemsManager
    property int directionID: 0
    property Thing thing: null
    property string thingName: ""
    property string thingValue: ""

    signal done(bool skip, bool abort, bool back);

    ThingClassesProxy {
        id: thing
        engine: _engine
        filterInterface: "dynamicelectricitypricing"
        includeProvidedInterfaces: true
    }

    header: NymeaHeader {
        visible: true
        text: qsTr("Tariff Settings")
        backButtonVisible: true
        onBackPressed: {
            pageStack.pop()
        }

    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: app.margins

        RowLayout{
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: qsTr("Charges")

            }

            TextField {
                text: "12"
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.preferredWidth: 60
                maximumLength: 100
            }

            Label {
                text: qsTr("ct/kWh")
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: qsTr("Includes taxes")
                Layout.fillWidth: true
            }

            Switch {
                id: includeTaxes
            }

        }

        ColumnLayout {
            Label {
                text: qsTr("The electricity price is made up of the current stock market price as well as grid fees, taxes and charges.")
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width

            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Button {
            id: savebutton

            Layout.fillWidth: true
            text: qsTr("Save")
            onClicked: {

                thing.engine.thingManager.addThing(thingValue, thingName, 0)
                pageStack.push(Qt.resolvedUrl("../optimization/DynamicElectricityRateFeedback.qml"), {thingName: thingName } )
            }
        }

    }


}
