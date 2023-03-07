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
    property var totalColors: []
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



                ConsolinnoPowerBalanceHistory {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    visible: rootMeter != null || producers.count > 0
                    totalColors: root.totalColors
                }

                ConsolinnoCurrentConsumptionBalancePieChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: root.energyManager
                    visible: producers.count > 0
                    totalColors: root.totalColors
                }
                ConsolinnoCurrentProductionBalancePieChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: root.energyManager
                    visible: producers.count > 0
                    totalColors: root.totalColors
                }

                ConsolinnoPowerConsumptionBalanceHistory {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    visible: producers.count > 0
                    totalColors: root.totalColors
                }

                ConsolinnoPowerProductionBalanceHistory {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    visible: producers.count > 0
                    totalColors: root.totalColors
                }

                ConsolinnoConsumersPieChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: root.energyManager
                    visible: consumers.count > 0
                    consumerColors: root.consumersColors
                    consumers: consumers
                }

                ConsolinnoConsumersHistory {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    visible: consumers.count > 0
                    consumerColors: root.consumersColors
                    consumers: consumers
                }

                ConsolinnoPowerBalanceStats {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: root.energyManager
                    totalColors: root.totalColors
                    visible: rootMeter != null
                }

                ConsolinnoConsumerStats {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: root.energyManager
                    visible: consumers.count > 0
                    consumerColors: root.consumersColors
                    consumers: consumers
                }
            }
        }
    }

}
