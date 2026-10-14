// #TODO copyright notice

pragma ComponentBehavior: Bound

import QtQuick
import Nymea

// ConsumerConsumptionLogs
//
// Encapsulates everything needed to back the Statistics page's Consumption/
// Consumers tab's per-consumer series:
//   - Consumer Thing discovery via ThingsProxy (root meter and manually-
//     hidden consumers excluded), mirroring the equivalent
//     "energyManager"/"consumers" setup in DetailedGraphsPage.qml.
//   - Per-consumer power logs, batched into a single "Energy.GetThingPowerLogs"
//     JSON-RPC call via ThingPowerLogsLoader (same pattern as
//     ConsumerStats.qml).
//
// The "Other consumption" catch-all bucket (everything not covered by a
// known consumer Thing) is NOT computed here - it's read directly off the
// backend's "unknownConsumption" field on powerBalanceLogs (see
// CoStatsView.qml's "computeConsumptionConsumerLineSeries").
Item {
    id: root

    property Engine engine

    property date startTime
    property date endTime

    // Forwarded to the internal loader and every per-consumer ThingPowerLogs
    // instance below.
    property int sampleRate: EnergyLogs.SampleRate15Mins

    readonly property bool fetchingData: consumerPowerLogsLoader.fetchingData
    readonly property int count: consumerPowerLogsRepeater.count

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

    ConsumerThings {
        id: consumerThings
        engine: root.engine
    }

    ThingPowerLogsLoader {
        id: consumerPowerLogsLoader
        engine: root.engine
        sampleRate: root.sampleRate
    }
    Repeater {
        id: consumerPowerLogsRepeater
        model: consumerThings.things
        delegate: Item {
            id: consumerDelegate
            required property int index
            readonly property Thing thing: consumerThings.things.get(consumerDelegate.index)
            readonly property ThingPowerLogs logs: ThingPowerLogs {
                engine: root.engine
                thingId: consumerDelegate.thing ? consumerDelegate.thing.id : ""
                sampleRate: root.sampleRate
                loader: consumerPowerLogsLoader
                // Without these, EnergyLogs::trimCache() (which relies on
                // this instance's own startTime/endTime, not the shared
                // loader's) never runs for per-consumer logs - the cached
                // entry list then grows unboundedly across every day
                // navigation (weeks of stale 15-min samples pile up),
                // which in turn makes every legend-pill toggle / tab
                // switch dramatically slower, since CoStatsLineChart
                // re-appends the model's *entire* cached history - not
                // just the visible day - to the chart on every rebuild.
                startTime: root.startTime
                endTime: root.endTime
            }
        }
        // Newly discovered consumers (e.g. once ThingManager finishes
        // loading) need an explicit fetch - the loader only auto-fetches
        // reactively while already mid-fetch (see addThingId() in
        // thingpowerlogs.cpp), not when idle.
        onCountChanged: consumerPowerLogsLoader.fetchLogs()
    }
}
