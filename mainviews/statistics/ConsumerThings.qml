// #TODO copyright notice

import QtQuick
import Nymea

// ConsumerThings
//
// Consumer Thing discovery for the Statistik page's Verbrauch/Consumers
// tab: root meter and manually-hidden consumers excluded, mirroring the
// equivalent "energyManager"/"consumers" setup in DetailedGraphsPage.qml.
// Shared between the Day line-chart data provider (ConsumerConsumptionLogs.qml)
// and the Week/Month/Year/year-over-year bar-chart data provider
// (PeriodEnergyLogs.qml), so the discovery logic only exists once.
Item {
    id: root

    property Engine engine

    // The ThingsProxy itself, for direct use as a Repeater/ListView model.
    readonly property alias things: consumers
    // Exposed so callers needing the running "total*" live counters (e.g.
    // PeriodEnergyLogs.qml's still-ongoing-category fallback) don't need a
    // second EnergyManager instance of their own.
    readonly property alias energyManager: energyManager

    EnergyManager {
        id: energyManager
        engine: root.engine && !root.engine.thingManager.fetchingData ? root.engine : null
    }
    readonly property var hiddenConsumerIds: {
        const ids = []
        for (let i = 0; i < hiddenConsumers.count; ++i) {
            ids.push(hiddenConsumers.get(i).id)
        }
        return ids
    }
    ThingsProxy {
        id: hiddenConsumers
        engine: root.engine
        shownInterfaces: ["smartmeterconsumer", "energymeter"]
        stateFilter: { "hidden": true }
    }
    ThingsProxy {
        id: consumers
        engine: root.engine
        shownInterfaces: ["smartmeterconsumer", "energymeter"]
        hideTagId: "hiddenInEnergyView"
        hiddenThingIds: [energyManager.rootMeterId].concat(root.hiddenConsumerIds)
    }
}
