// #TODO copyright notice

pragma ComponentBehavior: Bound

import QtQuick
import Nymea

// PeriodEnergyLogs
//
// Backs a single Week/Month/Year/year-over-year bar-chart section of the
// Statistics page's Chart card. The backend natively aggregates and stores
// samples at "sampleRate" (Week/Month/Year - see EnergyLogger::addConfig in
// nymea-experience-plugin-energy); this component fetches PowerBalanceLogs
// and per-consumer ThingPowerLogs at that rate and exposes, per category,
// "energy consumed/produced during this category's time range" - computed
// as the delta between the cumulative "total*" counters
// (totalConsumption/totalProduction/totalAcquisition/totalReturn) at the
// range's start and end. This is the same pattern already used elsewhere in
// this app (ConsolinnoPowerBalanceStats.qml/ConsolinnoConsumerStats.qml).
//
// "categoryRanges" defines the categories: an array of N {from, to} Date
// pairs, one per bar. Ranges don't need to be contiguous - e.g. the "same
// calendar month across the last 5 years" year-over-year comparison uses N
// disjoint one-month ranges, one per year, all fetched in a single
// request (covering the earliest "from" to the latest "to" across all
// ranges) and picked out individually afterwards via find() (a
// nearest-neighbour lookup - see deltaSeries()'s doc comment for why that
// matters).
//
// The most recent, still-ongoing category (whose "to" boundary lies in the
// future - e.g. "this week" while the week isn't over yet) has no log entry
// yet for its end boundary; for that one case the live running totals
// (EnergyManager's "total*" properties / ThingPowerLogs.liveEntry()) are
// used instead - mirrors the equivalent "it's today" fallback in
// ConsolinnoPowerBalanceStats.qml/ConsolinnoConsumerStats.qml.
//
// Battery charge/discharge energy: the backend's per-sample "storage"
// field on PowerBalanceLogs is only an *average power* value, which can't
// be split into charging vs. discharging within one category - so it's
// not used here. Instead, "totalToStorage"/"totalFromStorage" are read
// directly off PowerBalanceLogs, the same way as totalConsumption/
// totalProduction/totalAcquisition/totalReturn ("toBatterySeries"/
// "fromBatterySeries" below) - the backend aggregates these across every
// currently-existing energystorage Thing server-side and keeps
// accumulating them even once a battery Thing is later deleted, so unlike
// a per-Thing sum here, history isn't lost when the installation's
// battery setup changes. "hasBatteryEnergyCounters" below reflects
// whether that aggregated series actually carries any battery activity
// for the currently viewed categories.
Item {
    id: root

    property Engine engine
    property int sampleRate: EnergyLogs.SampleRate1Week
    property var categoryRanges: []

    readonly property bool fetchingData: powerBalanceLogs.fetchingData || consumerPowerLogsLoader.fetchingData
    readonly property alias energyManager: consumerThings.energyManager

    // The union range spanning all of "categoryRanges" - computed in
    // fetchLogs() below and also bound onto every per-consumer
    // ThingPowerLogs delegate (see the Repeater below), so
    // EnergyLogs::trimCache() - which relies on each instance's own
    // startTime/endTime, not the shared loader's - actually has something
    // to trim against. Without this, per-consumer log caches grow
    // unboundedly across every period navigation.
    property date _rangeStart
    property date _rangeEnd

    function fetchLogs() {
        if (root.categoryRanges.length === 0) {
            return
        }
        var from = root.categoryRanges[0].from
        var to = root.categoryRanges[0].to
        for (var i = 1; i < root.categoryRanges.length; i++) {
            if (root.categoryRanges[i].from < from) {
                from = root.categoryRanges[i].from
            }
            if (root.categoryRanges[i].to > to) {
                to = root.categoryRanges[i].to
            }
        }

        root._rangeStart = from
        root._rangeEnd = to

        powerBalanceLogs.startTime = from
        powerBalanceLogs.endTime = to
        powerBalanceLogs.fetchLogs()

        consumerPowerLogsLoader.startTime = from
        consumerPowerLogsLoader.endTime = to
        consumerPowerLogsLoader.fetchLogs()
    }

    ConsumerThings {
        id: consumerThings
        engine: root.engine
    }

    PowerBalanceLogs {
        id: powerBalanceLogs
        engine: root.engine
        sampleRate: root.sampleRate
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
                startTime: root._rangeStart
                endTime: root._rangeEnd
            }
        }
        // Newly discovered consumers (e.g. once ThingManager finishes
        // loading) need an explicit fetch - the loader only auto-fetches
        // reactively while already mid-fetch (see addThingId() in
        // thingpowerlogs.cpp), not when idle.
        onCountChanged: root.fetchLogs()
    }

    // Whether the backend's aggregated battery totals (see file doc
    // comment above) actually carry any activity for the currently viewed
    // categories - callers use this to decide whether to show "To
    // battery"/"From battery" series at all, rather than show a
    // misleading all-zero bar for installations without any battery
    // history.
    readonly property bool hasBatteryEnergyCounters: {
        var to = root.toBatterySeries()
        var from = root.fromBatterySeries()
        return to.some(function (v) { return v > 0 }) || from.some(function (v) { return v > 0 })
    }

    // ---- Generic per-category delta computation ----

    // Returns one delta value per entry in "categoryRanges": "field" (e.g.
    // "totalConsumption") on "model" at range.to, minus the same field at
    // range.from. Falls back to "liveValue()" - a function returning the
    // current running total - for the single still-ongoing category (see
    // file doc comment above). Returned in kWh - the backend's cumulative
    // "total*" counters are already reported in that unit (see the note
    // near the end of this function).
    //
    // Two things this guards against, mirroring the equivalent logic in
    // ConsolinnoPowerBalanceStats.qml/ConsolinnoConsumerStats.qml:
    // - A category that lies entirely in the future (both boundaries after
    //   "now") isn't "still ongoing" - it must be 0, not the live running
    //   total (which is the *lifetime* total, not this category's).
    // - model.find() is a nearest-neighbour lookup, not an exact-match one:
    //   for a timestamp within the model's currently loaded range but not
    //   exactly present, it snaps to whichever loaded entry is closest -
    //   which can be a wrong/unrelated entry while a fetch for this exact
    //   range is still in flight (e.g. only partially caught up after
    //   several quick period changes). So a computed value is only trusted
    //   once a previous-boundary entry was actually found, or fetching has
    //   fully settled - otherwise this returns 0 for now and lets the next
    //   recompute (once fetchingData goes false) fill it in correctly.
    function deltaSeries(model, field, liveValue) {
        var now = new Date()
        var fetching = root.fetchingData // dependency + guard, see above
        model.count // establish a binding dependency: recompute whenever new samples arrive
        return root.categoryRanges.map(function (range) {
            if (range.from.getTime() > now.getTime()) {
                // Entirely in the future - nothing happened here yet.
                return 0
            }
            var ongoing = range.to.getTime() > now.getTime()
            var previousEntry = model.find(range.from)
            var entry = ongoing ? null : model.find(range.to)
            var value
            if (entry) {
                value = entry[field]
            } else if (ongoing && liveValue) {
                value = liveValue()
            }
            if (value === undefined || value === null) {
                return 0
            }
            if (!previousEntry && fetching) {
                // Can't trust this yet - see guard explanation above.
                return 0
            }
            if (previousEntry) {
                value -= previousEntry[field]
            }
            // NOT divided by 1000 here: unlike the Day view's instantaneous
            // power fields (Watts, on PowerBalanceLogEntry.consumption/
            // production/... - see computeEnergyBalanceLineSeries() in
            // CoStatsView.qml), these "total*" cumulative counters are
            // already reported in kWh by the backend (see
            // EnergyManagerImpl - its own debug logging explicitly labels
            // them "kWh"), matching the precedent in
            // ConsolinnoPowerBalanceStats.qml/ConsolinnoConsumerStats.qml,
            // which also don't divide them. Dividing again here made every
            // Week/Month/Year/YoY bar-chart value 1000x too small.
            return Math.max(0, value)
        })
    }


    function totalConsumptionSeries() {
        return root.deltaSeries(powerBalanceLogs, "totalConsumption", function () { return root.energyManager.totalConsumption })
    }
    function totalProductionSeries() {
        return root.deltaSeries(powerBalanceLogs, "totalProduction", function () { return root.energyManager.totalProduction })
    }
    function totalAcquisitionSeries() {
        return root.deltaSeries(powerBalanceLogs, "totalAcquisition", function () { return root.energyManager.totalAcquisition })
    }
    function totalReturnSeries() {
        return root.deltaSeries(powerBalanceLogs, "totalReturn", function () { return root.energyManager.totalReturn })
    }

    // Read directly off the backend's aggregated "totalToStorage"/
    // "totalFromStorage" counters (see file doc comment above) - no longer
    // a per-Thing sum.
    function toBatterySeries() {
        return root.deltaSeries(powerBalanceLogs, "totalToStorage", function () { return root.energyManager.totalToStorage })
    }
    function fromBatterySeries() {
        return root.deltaSeries(powerBalanceLogs, "totalFromStorage", function () { return root.energyManager.totalFromStorage })
    }

    // Consumption covered by own production (whether used directly or via
    // the battery - "fromBatterySeries" is subtracted out here so it isn't
    // double-counted once as part of "self-consumption" and once again as
    // its own series; see "hasBatteryEnergyCounters" above for when it's
    // actually non-zero).
    function selfConsumptionSeries() {
        var totalConsumption = root.totalConsumptionSeries()
        var fromGrid = root.totalAcquisitionSeries()
        var fromBattery = root.fromBatterySeries()
        return totalConsumption.map(function (value, i) {
            return Math.max(0, value - fromGrid[i] - fromBattery[i])
        })
    }

    // One entry per discovered consumer Thing: {thing, values}.
    function consumerSeries() {
        var result = []
        for (var i = 0; i < consumerPowerLogsRepeater.count; i++) {
            var item = consumerPowerLogsRepeater.itemAt(i)
            if (!item || !item.thing) {
                continue
            }
            result.push({
                thing: item.thing,
                values: root.deltaSeries(item.logs, "totalConsumption", function () {
                    var live = item.logs.liveEntry()
                    return live ? live.totalConsumption : undefined
                })
            })
        }
        return result
    }

    // Total consumption minus the sum of all known consumers, per category
    // - the "Other consumption" catch-all bucket (see
    // ConsumerConsumptionLogs.qml's "otherConsumption" for the Day/line-
    // chart equivalent of this same idea).
    function otherConsumptionSeries() {
        var total = root.totalConsumptionSeries()
        var known = root.consumerSeries()
        return total.map(function (value, i) {
            var knownSum = known.reduce(function (sum, series) { return sum + series.values[i] }, 0)
            return Math.max(0, value - knownSum)
        })
    }
}
