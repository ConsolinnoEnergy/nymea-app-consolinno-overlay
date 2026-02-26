import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import "qrc:/ui/mainviews/energy/"
import "qrc:/ui/components/"
import Nymea 1.0

MainViewBase {
    id: root

    contentY: flickable.contentY + topMargin

    headerButtons: []

    EnergyManager {
        id: energyManager
        engine: _engine
    }

    property var totalColors: Configuration.totalColors
    property var consumersColors: Configuration.consumerColors

    property bool isDynamicPrice: true

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

    ThingsProxy {
        id: electrics
        engine: _engine
        shownInterfaces: ["dynamicelectricitypricing"]
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

                ConsolinnoDynamicElectricPricingHistory {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    isDynamicPrice: root.isDynamicPrice
                    thing: electrics.count > 0 ? electrics.get(0) : null
                    visible: electrics.count > 0
                }

                ConsolinnoPowerBalanceHistory {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    visible: rootMeter != null || producers.count > 0
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
                    energyManager: energyManager
                    totalColors: root.totalColors
                    visible: rootMeter != null
                }

                CoKpiStats {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: energyManager
                    visible: rootMeter != null
                }

                ConsolinnoConsumerStats {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    energyManager: energyManager
                    visible: consumers.count > 0
                    consumerColors: root.consumersColors
                    consumers: consumers
                }

                Item {
                    id: spacer
                    Layout.fillWidth: true
                    Layout.preferredHeight: root.bottomMargin
                    height: root.bottomMargin
                }
            }

        }
    }
}
