// #TODO copyright notice

pragma ComponentBehavior: Bound

import QtQuick
import Nymea

// ConsumerConsumptionLogs
//
// Encapsulates everything needed to back the Statistik page's Verbrauch/
// Consumers tab:
//   - Consumer Thing discovery via ThingsProxy (root meter and manually-
//     hidden consumers excluded), mirroring the equivalent
//     "energyManager"/"consumers" setup in DetailedGraphsPage.qml.
//   - Per-consumer power logs, batched into a single "Energy.GetThingPowerLogs"
//     JSON-RPC call via ThingPowerLogsLoader (same pattern as
//     ConsumerStats.qml).
//   - The "Other consumption" catch-all bucket (total consumption minus the
//     sum of all known consumers at the same instant), exposed as its own
//     EnergyLogs-like model (count/get(index)/entriesAddedIdx/
//     entriesRemoved) so it plugs directly into CoStatsLineChart's existing
//     per-series model-binding mechanism.
//
// This last point also fixes a real bug: computing "Other consumption" as a
// one-off JS function (as CoStatsView.qml used to do) only recomputes when
// the *chart* re-renders, which single-model "Connections" bindings don't
// trigger for data this derives from multiple, independently-loading
// models. If the total-consumption model finished loading before some
// consumer's power logs arrived, the result was calculated with incomplete
// data and never recomputed once the rest of the data showed up. Here,
// "otherConsumption" listens to *all* of its dependencies (the total-
// consumption model and every discovered consumer's power logs) and only
// recomputes - and only then notifies the outside world via entriesAddedIdx
// - once something it actually depends on changes.
Item {
    id: root

    property Engine engine
    // The model providing overall/total consumption per sample (currently
    // "powerBalanceLogs" in CoStatsView.qml). Must expose the same
    // EnergyLogs-derived contract (count/get(index)/entriesAddedIdx/
    // entriesRemoved) and entries with a "consumption" (Watts) and
    // "timestamp" field.
    property var totalConsumptionLogs: null

    property date startTime
    property date endTime

    readonly property bool fetchingData: consumerPowerLogsLoader.fetchingData
    readonly property int count: consumerPowerLogsRepeater.count
    readonly property alias otherConsumption: otherConsumptionModel

    // Returns the Item delegate for the consumer at "index" - exposes
    // "thing" (Thing) and "logs" (ThingPowerLogs) properties.
    function consumerAt(index) {
        return consumerPowerLogsRepeater.itemAt(index)
    }

    function fetchLogs() {
        consumerPowerLogsLoader.startTime = root.startTime
        consumerPowerLogsLoader.endTime = root.endTime
        consumerPowerLogsLoader.fetchLogs()
    }

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

    ThingPowerLogsLoader {
        id: consumerPowerLogsLoader
        engine: root.engine
        sampleRate: EnergyLogs.SampleRate15Mins
    }
    Repeater {
        id: consumerPowerLogsRepeater
        model: consumers
        delegate: Item {
            id: consumerDelegate
            required property int index
            readonly property Thing thing: consumers.get(consumerDelegate.index)
            readonly property ThingPowerLogs logs: ThingPowerLogs {
                engine: root.engine
                thingId: consumerDelegate.thing ? consumerDelegate.thing.id : ""
                sampleRate: EnergyLogs.SampleRate15Mins
                loader: consumerPowerLogsLoader
            }

            // Rebuild "otherConsumption" whenever this consumer's own power
            // logs change - it is one of the models the catch-all bucket is
            // derived from.
            Connections {
                target: consumerDelegate.logs
                function onEntriesAddedIdx(index, count) { otherConsumptionModel.rebuild() }
                function onEntriesRemoved(index, count) { otherConsumptionModel.rebuild() }
                function onCountChanged() { otherConsumptionModel.rebuild() }
            }
        }
        // Newly discovered consumers (e.g. once ThingManager finishes
        // loading) need an explicit fetch - the loader only auto-fetches
        // reactively while already mid-fetch (see addThingId() in
        // thingpowerlogs.cpp), not when idle.
        onCountChanged: {
            consumerPowerLogsLoader.fetchLogs()
            otherConsumptionModel.rebuild()
        }
    }

    // Rebuild "otherConsumption" whenever the total-consumption model
    // (e.g. "powerBalanceLogs") changes - the other dependency it's
    // derived from.
    Connections {
        target: root.totalConsumptionLogs
        function onEntriesAddedIdx(index, count) { otherConsumptionModel.rebuild() }
        function onEntriesRemoved(index, count) { otherConsumptionModel.rebuild() }
        function onCountChanged() { otherConsumptionModel.rebuild() }
    }

    // EnergyLogs-like model for the "Other consumption" catch-all bucket:
    // total consumption minus the sum of all known consumers at the same
    // instant (looked up via "find()" - binary search by timestamp - since
    // each ThingPowerLogs is fetched/populated independently and may not be
    // index-aligned with "totalConsumptionLogs").
    QtObject {
        id: otherConsumptionModel

        property var _entries: []
        readonly property int count: _entries.length

        signal entriesAddedIdx(int index, int count)
        signal entriesRemoved(int index, int count)

        function get(index) {
            return _entries[index]
        }

        function rebuild() {
            const total = root.totalConsumptionLogs
            const oldCount = _entries.length
            const newEntries = []
            const totalCount = total && total.count !== undefined ? total.count : 0
            for (let i = 0; i < totalCount; i++) {
                const entry = total.get(i)
                if (!entry)
                    continue
                let knownConsumption = 0
                for (let j = 0; j < consumerPowerLogsRepeater.count; j++) {
                    const item = consumerPowerLogsRepeater.itemAt(j)
                    if (!item)
                        continue
                    const consumerEntry = item.logs.find(entry.timestamp)
                    if (consumerEntry)
                        knownConsumption += consumerEntry.currentPower
                }
                newEntries.push({
                    timestamp: entry.timestamp,
                    consumption: Math.max(0, entry.consumption - knownConsumption)
                })
            }
            _entries = newEntries
            if (oldCount > 0)
                entriesRemoved(0, oldCount)
            if (newEntries.length > 0)
                entriesAddedIdx(0, newEntries.length)
        }
    }
}
