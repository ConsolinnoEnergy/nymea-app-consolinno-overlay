import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import "qrc:/ui/mainviews/energy/"
import "qrc:/ui/components/"
import Nymea 1.0

Page {
    id: root

    header: NymeaHeader {
        //text: qsTr("History")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    property EnergyManager energyManager: null
    property var consumersColors: []

    readonly property Thing rootMeter: engine.thingManager.fetchingData ? null : engine.thingManager.things.getThing(energyManager.rootMeterId)

    ThingsProxy {
        id: consumers
        engine: _engine
        shownInterfaces: ["smartmeterconsumer", "energymeter"]
        hideTagId: "hiddenInEnergyView"
        hiddenThingIds: [energyManager.rootMeterId]
    }

    ThingsProxy {
        id: producers
        engine: _engine
        shownInterfaces: ["smartmeterproducer"]
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: app.margins / 2
        contentHeight: energyGrid.childrenRect.height
        visible: !engine.thingManager.fetchingData && engine.jsonRpcClient.experiences.hasOwnProperty("Energy")
        topMargin: root.topMargin

        // GridLayout directly in a flickable causes problems at initialisation
        Item {
            width: parent.width
            height: energyGrid.implicitHeight


            GridLayout {
                id: energyGrid
                width: parent.width
                property int rawColumns: Math.floor(flickable.width / 300)
                columns: Math.max(1, rawColumns - (rawColumns % 2))
                rowSpacing: 0
                columnSpacing: 0


                CurrentConsumptionBalancePieChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: root.energyManager
                    visible: producers.count > 0
                }
                CurrentProductionBalancePieChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: root.energyManager
                    visible: producers.count > 0
                }

                PowerConsumptionBalanceHistory {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    visible: producers.count > 0
                }

                PowerProductionBalanceHistory {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    visible: producers.count > 0
                }

                ConsumersPieChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: root.energyManager
                    visible: consumers.count > 0
                    //colors: root.consumersColors
                    consumers: consumers
                }

                ConsumersHistory {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    visible: consumers.count > 0
                    //colors: root.consumersColors
                    consumers: consumers
                }

                PowerBalanceStats {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: root.energyManager
                    visible: rootMeter != null
                }

                ConsumerStats {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: root.energyManager
                    visible: consumers.count > 0
                    //colors: root.consumersColors
                    consumers: consumers
                }
            }
        }
    }

}
