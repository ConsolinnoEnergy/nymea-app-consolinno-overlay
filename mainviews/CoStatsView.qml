// #TODO copyright notice

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "../components"
import "../utils/DateUtils.js" as DateUtils
import "statistics"

// CoStatsView
//
// New statistics page (replaces DetailedGraphsPage). Structure, top to
// bottom:
//   - "Time period" card: CoPeriodSelector (Day/Week/Month/Year)
//   - "Metrics" card: 4 CoStatsKPICard instances, always reflecting the
//     currently selected period (wired to a real Energy.GetEnergyKPIs call
//     via CoStatsMetricsProvider)
//   - Chart card: a simple 2-item tab switcher (Energiebilanz/Verbrauch)
//     followed by a chart area whose shape depends on the selected sample
//     rate (1 line chart for Day, 1 bar chart for Week, 2 bar charts for
//     Month/Year - a sub-period breakdown plus a year-over-year comparison)
//     and a legend below it.
//
// IMPORTANT: this is currently a UI skeleton for the Chart card. Its
// series below are still generated locally by "d.*" dummy-data functions
// (clearly marked with TODO comments) so the page layout can be reviewed
// before the real backend wiring (Energy.GetPowerBalanceLogs,
// Energy.GetThingPowerLogs, dynamic Thing discovery via ThingsProxy) is
// implemented in a follow-up. See DetailedGraphsPage.qml and its "energy/"
// subcomponents for the equivalent real-data patterns this will eventually
// be based on.

MainViewBase {
    id: root

    // Reusable legend block for the bar-chart views (Week/Month/Year): a single
    // flat legend for the Energiebilanz tab (no "Quellen"/"Verbraucher" split in
    // that design) plus a "Quellen"/"Verbraucher" grouped legend for the
    // Verbrauch tab, built directly here rather than teaching CoStatsChartLegend
    // a "grouped" mode. Factored out as an inline component since this exact
    // block is otherwise duplicated identically for Week/Month/Year.
    component ChartLegendSection: ColumnLayout {
        id: legendSection

        // "dataSource" is passed explicitly (rather than relying on this inline
        // component implicitly resolving the outer file's "d" id) so the
        // dependency is obvious and unambiguous.
        required property QtObject dataSource
        required property var energyBalanceSeries
        required property var sourceSeries
        required property var consumerSeries

        Layout.fillWidth: true
        spacing: Style.margins

        CoStatsChartLegend {
            Layout.fillWidth: true
            visible: legendSection.dataSource.activeChartTab === 0
            series: legendSection.energyBalanceSeries
            onSeriesVisibilityToggled: (index, visible) => legendSection.dataSource.toggleSeriesVisibility(legendSection.energyBalanceSeries, index, visible)
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: legendSection.dataSource.activeChartTab === 1
            spacing: Style.smallMargins

            Label {
                Layout.fillWidth: true
                text: qsTr("Sources")
                font: Style.newSmallFontBold
                color: Style.colors.typography_Basic_Default
            }
            CoStatsChartLegend {
                Layout.fillWidth: true
                series: legendSection.sourceSeries
                onSeriesVisibilityToggled: (index, visible) => legendSection.dataSource.toggleSeriesVisibility(legendSection.sourceSeries, index, visible)
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("Consumers")
                font: Style.newSmallFontBold
                color: Style.colors.typography_Basic_Default
            }
            CoStatsChartLegend {
                Layout.fillWidth: true
                series: legendSection.consumerSeries
                onSeriesVisibilityToggled: (index, visible) => legendSection.dataSource.toggleSeriesVisibility(legendSection.consumerSeries, index, visible)
            }
        }
    }

    contentY: flickable.contentY + topMargin

    headerButtons: []

    CoStatsMetricsProvider {
        id: kpiProvider
        engine: _engine
    }

    // ---- Real backend data sources for the Chart card (Day/Energiebilanz) ----
    // Producer/battery detection: which optional series to even show/compute
    // (e.g. no point rendering "Production"/"To battery" lines if the
    // installation has neither). Mirrors the equivalent ThingsProxy
    // instances in EnergyView.qml/PowerBalanceHistory.qml.
    ThingsProxy {
        id: producers
        engine: _engine
        shownInterfaces: ["smartmeterproducer"]
    }
    ThingsProxy {
        id: batteries
        engine: _engine
        shownInterfaces: ["energystorage"]
    }

    // Backs the Day view's line chart (both the Energiebilanz and Verbrauch/
    // Sources tabs - they share the same underlying power-balance samples,
    // just extract different fields via "valueFunction"). "startTime"/
    // "endTime" are kept in sync with the chart's own visible window via
    // "onVisibleRangeChanged" below, so panning/zooming re-fetches exactly
    // the range that's actually on screen (plus whatever margin the chart
    // itself requests).
    PowerBalanceLogs {
        id: powerBalanceLogs
        engine: _engine
        sampleRate: EnergyLogs.SampleRate15Mins
    }

    // Backs the Verbrauch/Consumers tab: consumer Thing discovery, per-
    // consumer power logs, and the derived "Other consumption" catch-all
    // bucket - see ConsumerConsumptionLogs.qml for details.
    ConsumerConsumptionLogs {
        id: consumerConsumptionLogs
        engine: _engine
        totalConsumptionLogs: powerBalanceLogs
    }

    // Backs the Week/Month/Year/year-over-year bar charts - one instance
    // per section, since each fetches a different sampleRate and a
    // different set of category ranges (see PeriodEnergyLogs.qml).
    PeriodEnergyLogs {
        id: weekEnergyLogs
        engine: _engine
        sampleRate: EnergyLogs.SampleRate1Day
        categoryRanges: d.weekBarCategoryRanges
    }
    PeriodEnergyLogs {
        id: monthEnergyLogs
        engine: _engine
        sampleRate: EnergyLogs.SampleRate1Week
        categoryRanges: d.monthBarCategoryRanges
    }
    PeriodEnergyLogs {
        id: yearEnergyLogs
        engine: _engine
        sampleRate: EnergyLogs.SampleRate1Month
        categoryRanges: d.yearBarCategoryRanges
    }
    PeriodEnergyLogs {
        id: yoyEnergyLogs
        engine: _engine
        sampleRate: periodSelector.sampleRate === EnergyLogs.SampleRate1Month ? EnergyLogs.SampleRate1Month : EnergyLogs.SampleRate1Year
        categoryRanges: d.yoyBarCategoryRanges
    }

    // Fetches KPIs for the period currently selected in "periodSelector".
    // Guarded by "root.visible" for the same reason as the equivalent guard
    // in CoKpiStats.qml: this view is instantiated eagerly (e.g. inside the
    // navigation drawer's view stack) even when the user has never opened
    // it, so an unconditional fetch at startup would hit "No such method"/
    // "not connected" warnings before the page is ever shown.
    function fetchKpis() {
        if (!root.visible || !_engine || !_engine.jsonRpcClient || !_engine.jsonRpcClient.connected) {
            return
        }
        kpiProvider.fetchKpis(periodSelector.fromTimestamp, periodSelector.toTimestamp)
    }

    // Fetches the Week/Month/Year/year-over-year bar-chart data for the
    // period currently selected in "periodSelector" - same visibility/
    // connection guard as "fetchKpis()" above, for the same reason.
    function fetchBarLogs() {
        if (!root.visible || !_engine || !_engine.jsonRpcClient || !_engine.jsonRpcClient.connected) {
            return
        }
        weekEnergyLogs.fetchLogs()
        monthEnergyLogs.fetchLogs()
        yearEnergyLogs.fetchLogs()
        yoyEnergyLogs.fetchLogs()
    }

    onVisibleChanged: {
        root.fetchKpis()
        root.fetchBarLogs()
    }

    Connections {
        target: _engine ? _engine.jsonRpcClient : null
        function onConnectedChanged() {
            root.fetchKpis()
            root.fetchBarLogs()
        }
    }

    Connections {
        target: periodSelector
        function onFromTimestampChanged() { root.fetchKpis() }
        function onToTimestampChanged() { root.fetchKpis() }
        function onReferenceDateChanged() { root.fetchBarLogs() }
        function onSampleRateChanged() { root.fetchBarLogs() }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: app.margins / 2
        contentHeight: contentColumn.height

        ColumnLayout {
            id: contentColumn
            width: parent.width
            spacing: Style.margins

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.topMargin
            }

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                text: qsTr("History")
                font: Style.newH1Font
                color: Style.colors.typography_Basic_Default
            }

            // ---- "Time period" card ------------------------------------------------
            CoFrostyCard {
                Layout.fillWidth: true
                contentBottomMargin: 16

                headerText: qsTr("Time period")

                CoPeriodSelector {
                    id: periodSelector
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Style.margins
                    anchors.rightMargin: Style.margins
                }
            }

            // ---- "Metrics" card -------------------------------------------------
            CoFrostyCard {
                Layout.fillWidth: true
                contentBottomMargin: 16

                headerText: qsTr("Metrics")
                // #TODO infoUrl?

                GridLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Style.margins
                    anchors.rightMargin: Style.margins
                    columns: 2
                    rowSpacing: Style.margins
                    columnSpacing: Style.margins

                    CoStatsKPICard {
                        Layout.fillWidth: true
                        icon: Qt.resolvedUrl("qrc:/icons/house_with_shield.svg")
                        valueText: d.kpis.selfSufficiencyText
                        labelText: qsTr("Self-sufficiency")
                    }
                    CoStatsKPICard {
                        Layout.fillWidth: true
                        icon: Qt.resolvedUrl("qrc:/icons/attribution.svg")
                        valueText: d.kpis.selfConsumptionText
                        labelText: qsTr("Self-consumption")
                    }
                    CoStatsKPICard {
                        Layout.fillWidth: true
                        icon: Qt.resolvedUrl("qrc:/icons/input_circle.svg")
                        valueText: d.kpis.feedInText
                        labelText: qsTr("Feed-in")
                    }
                    CoStatsKPICard {
                        Layout.fillWidth: true
                        icon: Qt.resolvedUrl("qrc:/icons/output_circle.svg")
                        valueText: d.kpis.gridConsumptionText
                        labelText: qsTr("Grid import")
                    }
                }
            }

            // ---- Chart card -----------------------------------------------------
            // Unlike "Time period"/"Key figures" above, the Figma design does not
            // put this section in a Frosty Card: a full-bleed gray Rectangle (same
            // background color/radius as CoFrostyCard's own background - see
            // CoFrostyCard.qml - but reaching the actual screen edges instead of
            // stopping at the page's side margins) hosts the tab switcher, with a
            // separate white rounded Rectangle nested inside it providing the
            // background for just the chart + legend area.
            Rectangle {
                id: chartSectionBackground
                Layout.fillWidth: true
                // Bleeds past contentColumn's own inset (flickable.anchors.margins)
                // to reach the true screen edges, per design.
                Layout.leftMargin: -flickable.anchors.margins
                Layout.rightMargin: -flickable.anchors.margins
                implicitHeight: chartSectionLayout.implicitHeight + chartSectionLayout.anchors.topMargin + chartSectionLayout.anchors.bottomMargin
                color: Style.colors.components_Dashboard_Background_accent_dashboard
                // No rounded corners: unlike a Frosty Card, this section
                // bleeds all the way to the screen edges, so a radius here
                // would look wrong.

                ColumnLayout {
                    id: chartSectionLayout
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: Style.margins
                    anchors.rightMargin: Style.margins
                    anchors.topMargin: Style.margins
                    anchors.bottomMargin: Style.margins
                    spacing: Style.margins

                    // Headline-style 2-item tab switcher (CoHeadlineTabButton):
                    // left-aligned, transparent background, no hover/press
                    // feedback - just the selected tab's text growing/using
                    // the headline color, per Figma. The Figma design shows
                    // a swipeable 4-tab carousel with chevron navigation
                    // (Energiebilanz/Verbrauch/Photovoltaik/Batterie), but
                    // per product decision only Energiebilanz/Verbrauch are
                    // implemented for now - the other two tabs are
                    // intentionally omitted, not just hidden. With only two
                    // tabs, "previous"/"next" simply means "the other one";
                    // each chevron is only enabled while it would actually
                    // move to a different tab (i.e. disabled at whichever
                    // end is already selected), and clicking it flips the
                    // actual button's "checked" state (rather than setting
                    // d.activeChartTab directly) so the tab switcher's own
                    // visuals - which are bound to "checked", not
                    // "activeChartTab" - stay in sync.
                    CoHeadlineTabBar {
                        Layout.fillWidth: true
                        previousEnabled: d.activeChartTab > 0
                        nextEnabled: d.activeChartTab < 1
                        onPreviousClicked: energyBalanceTabButton.checked = true
                        onNextClicked: consumptionTabButton.checked = true

                        ButtonGroup {
                            buttons: [energyBalanceTabButton, consumptionTabButton]
                        }

                        CoHeadlineTabButton {
                            id: energyBalanceTabButton
                            text: qsTr("Energy balance")
                            checked: true
                            onCheckedChanged: if (checked) d.activeChartTab = 0
                        }
                        CoHeadlineTabButton {
                            id: consumptionTabButton
                            text: qsTr("Consumption")
                            onCheckedChanged: if (checked) d.activeChartTab = 1
                        }
                    }

                    // White rounded rectangle: background for just the chart +
                    // legend area (as opposed to chartSectionBackground above,
                    // which also underlies the tab switcher).
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: chartContentLayout.implicitHeight + chartContentLayout.anchors.margins * 2
                        color: Style.colors.typography_Background_Default
                        radius: Style.largeCornerRadius

                        ColumnLayout {
                            id: chartContentLayout
                            anchors.fill: parent
                            anchors.margins: Style.margins
                            spacing: Style.margins

                            // ---- Day: single line chart, one flat legend ----
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Style.margins
                                visible: periodSelector.sampleRate === EnergyLogs.SampleRate1Day

                                CoStatsLineChart {
                                    id: dayLineChart
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 300

                                    selectedDay: periodSelector.referenceDate
                                    // Right axis is only meaningful once a Battery
                                    // SoC series is actually populated (see the
                                    // reserved, always-invisible entry appended in
                                    // "computeEnergyBalanceLineSeries" below) -
                                    // kept false for now since the backend cannot
                                    // provide this data yet.
                                    percentAxisVisible: false

                                    // Also true while per-consumer power logs are
                                    // being (re)fetched for the Verbrauch/Consumers
                                    // tab - both sources share this one chart/loading
                                    // indicator.
                                    loading: powerBalanceLogs.fetchingData || consumerConsumptionLogs.fetchingData

                                    // Guarded by sampleRate (not just this
                                    // section's own "visible") so that a
                                    // legend-pill toggle made while some
                                    // other period tab (Week/Month/Year) is
                                    // selected doesn't still force this
                                    // hidden chart to rebuild - QML property
                                    // bindings keep evaluating even while an
                                    // Item's "visible" is false, so without
                                    // this guard "series" would still read
                                    // (and re-read on every hiddenSeriesNames
                                    // change) d.energyBalanceLineSeries/
                                    // d.consumptionLineSeries, and
                                    // CoStatsLineChart would still run its
                                    // (expensive) internal rebuild() for
                                    // data nobody can currently see.
                                    series: periodSelector.sampleRate === EnergyLogs.SampleRate1Day
                                            ? (d.activeChartTab === 0 ? d.energyBalanceLineSeries : d.consumptionLineSeries)
                                            : []

                                    // Fetches (or re-fetches) power-balance data and
                                    // per-consumer power data for exactly the range
                                    // currently visible in the chart, whenever it
                                    // settles after a pan/zoom/day change (see
                                    // "visibleRangeChanged" doc comment in
                                    // CoStatsLineChart.qml) - this is the one hook that
                                    // covers both the initial fetch (fires once on
                                    // Component.onCompleted) and subsequent ones.
                                    onVisibleRangeChanged: function (startTime, endTime) {
                                        powerBalanceLogs.startTime = startTime
                                        powerBalanceLogs.endTime = endTime
                                        powerBalanceLogs.fetchLogs()

                                        consumerConsumptionLogs.startTime = startTime
                                        consumerConsumptionLogs.endTime = endTime
                                        consumerConsumptionLogs.fetchLogs()
                                    }

                                    // Reflect back into the period selector when the
                                    // user pans/zooms the chart across a day boundary,
                                    // using the reverse-binding hook CoPeriodSelector
                                    // exposes for exactly this purpose. Two guards are
                                    // needed to avoid QML "binding loop" warnings:
                                    // - Only fire when "visibleDay" actually lands on
                                    //   a different calendar day than the one
                                    //   currently selected above.
                                    // - Even then, defer the actual call via
                                    //   Qt.callLater(): calling setReferenceDate()
                                    //   synchronously here would - still within the
                                    //   same notification chain that changed
                                    //   "visibleDay" - reset the chart's own visible
                                    //   window (via "selectedDay" above), which
                                    //   writes back into the very properties
                                    //   "visibleDay" is computed from. Deferring to
                                    //   the next event loop iteration breaks that
                                    //   reentrant chain.
                                    onVisibleDayChanged: {
                                        if (!DateUtils.isSameDay(visibleDay, periodSelector.referenceDate)) {
                                            Qt.callLater(periodSelector.setReferenceDate, visibleDay)
                                        }
                                    }
                                }

                                CoStatsChartLegend {
                                    Layout.fillWidth: true
                                    visible: d.activeChartTab === 0
                                    series: d.energyBalanceLineSeries
                                    onSeriesVisibilityToggled: (index, visible) => d.toggleSeriesVisibility(d.energyBalanceLineSeries, index, visible)
                                }

                                // Verbrauch: "Quellen"/"Verbraucher" grouped
                                // legend, built directly here (rather than
                                // extending CoStatsChartLegend with a "grouped"
                                // mode) - just two Label+CoStatsChartLegend pairs,
                                // each bound to its own dummy series array.
                                // "consumptionLineSeries" (passed to the chart
                                // above) is simply the concatenation of both
                                // arrays, so toggling either legend group is
                                // automatically reflected in the chart - both
                                // ultimately read the same shared
                                // "hiddenSeriesNames" visibility state.
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    visible: d.activeChartTab === 1
                                    spacing: Style.smallMargins

                                    Label {
                                        Layout.fillWidth: true
                                        text: qsTr("Sources")
                                        font: Style.newSmallFontBold
                                        color: Style.colors.typography_Basic_Default
                                    }
                                    CoStatsChartLegend {
                                        Layout.fillWidth: true
                                        series: d.consumptionSourceLineSeries
                                        onSeriesVisibilityToggled: (index, visible) => d.toggleSeriesVisibility(d.consumptionSourceLineSeries, index, visible)
                                    }

                                    Label {
                                        Layout.fillWidth: true
                                        text: qsTr("Consumers")
                                        font: Style.newSmallFontBold
                                        color: Style.colors.typography_Basic_Default
                                    }
                                    CoStatsChartLegend {
                                        Layout.fillWidth: true
                                        series: d.consumptionConsumerLineSeries
                                        onSeriesVisibilityToggled: (index, visible) => d.toggleSeriesVisibility(d.consumptionConsumerLineSeries, index, visible)
                                    }
                                }
                            }

                            // ---- Week: single bar chart, 7 categories ----
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Style.margins
                                visible: periodSelector.sampleRate === EnergyLogs.SampleRate1Week

                                CoStatsBarChart {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 300

                                    categories: d.weekCategories
                                    // Guarded by sampleRate (see the
                                    // day-view "series" binding above for
                                    // the full rationale) so a legend-pill
                                    // toggle made in a different period tab
                                    // doesn't still force this hidden bar
                                    // chart to rebuild.
                                    stacks: periodSelector.sampleRate === EnergyLogs.SampleRate1Week
                                            ? (d.activeChartTab === 0
                                               ? [{ series: d.weekEnergyBalanceProductionSeries }, { series: d.weekEnergyBalanceConsumptionSeries }]
                                               : [{ series: d.weekConsumptionSourceSeries }, { series: d.weekConsumptionConsumerSeries }])
                                            : []
                                    loading: weekEnergyLogs.fetchingData
                                }


                                ChartLegendSection {
                                    dataSource: d
                                    energyBalanceSeries: d.weekEnergyBalanceProductionSeries.concat(d.weekEnergyBalanceConsumptionSeries)
                                    sourceSeries: d.weekConsumptionSourceSeries
                                    consumerSeries: d.weekConsumptionConsumerSeries
                                }
                            }

                            // ---- Month: sub-period breakdown + year-over-year bar charts ----
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Style.margins
                                visible: periodSelector.sampleRate === EnergyLogs.SampleRate1Month

                                CoStatsBarChart {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 300

                                    categories: d.monthCategories
                                    stacks: periodSelector.sampleRate === EnergyLogs.SampleRate1Month
                                            ? (d.activeChartTab === 0
                                               ? [{ series: d.monthEnergyBalanceProductionSeries }, { series: d.monthEnergyBalanceConsumptionSeries }]
                                               : [{ series: d.monthConsumptionSourceSeries }, { series: d.monthConsumptionConsumerSeries }])
                                            : []
                                    loading: monthEnergyLogs.fetchingData
                                }

                                CoStatsBarChart {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 300

                                    categories: d.yoyCategories
                                    stacks: periodSelector.sampleRate === EnergyLogs.SampleRate1Month
                                            ? (d.activeChartTab === 0
                                               ? [{ series: d.yoyEnergyBalanceProductionSeries }, { series: d.yoyEnergyBalanceConsumptionSeries }]
                                               : [{ series: d.yoyConsumptionSourceSeries }, { series: d.yoyConsumptionConsumerSeries }])
                                            : []
                                    loading: yoyEnergyLogs.fetchingData
                                }

                                ChartLegendSection {
                                    dataSource: d
                                    energyBalanceSeries: d.monthEnergyBalanceProductionSeries.concat(d.monthEnergyBalanceConsumptionSeries)
                                    sourceSeries: d.monthConsumptionSourceSeries
                                    consumerSeries: d.monthConsumptionConsumerSeries
                                }
                            }

                            // ---- Year: sub-period breakdown + year-over-year bar charts ----
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Style.margins
                                visible: periodSelector.sampleRate === EnergyLogs.SampleRate1Year

                                CoStatsBarChart {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 300

                                    categories: d.yearCategories
                                    stacks: periodSelector.sampleRate === EnergyLogs.SampleRate1Year
                                            ? (d.activeChartTab === 0
                                               ? [{ series: d.yearEnergyBalanceProductionSeries }, { series: d.yearEnergyBalanceConsumptionSeries }]
                                               : [{ series: d.yearConsumptionSourceSeries }, { series: d.yearConsumptionConsumerSeries }])
                                            : []
                                    loading: yearEnergyLogs.fetchingData
                                }

                                CoStatsBarChart {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 300

                                    categories: d.yoyCategories
                                    stacks: periodSelector.sampleRate === EnergyLogs.SampleRate1Year
                                            ? (d.activeChartTab === 0
                                               ? [{ series: d.yoyEnergyBalanceProductionSeries }, { series: d.yoyEnergyBalanceConsumptionSeries }]
                                               : [{ series: d.yoyConsumptionSourceSeries }, { series: d.yoyConsumptionConsumerSeries }])
                                            : []
                                    loading: yoyEnergyLogs.fetchingData
                                }

                                ChartLegendSection {
                                    dataSource: d
                                    energyBalanceSeries: d.yearEnergyBalanceProductionSeries.concat(d.yearEnergyBalanceConsumptionSeries)
                                    sourceSeries: d.yearConsumptionSourceSeries
                                    consumerSeries: d.yearConsumptionConsumerSeries
                                }
                            }
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.bottomMargin
            }
        }
    }

    // ---- Dummy data & helpers --------------------------------------------
    //
    // Everything below stands in for real backend wiring and is meant to be
    // replaced wholesale once that is implemented. All "*Series"/"*Categories"
    // properties are plain reactive bindings (readonly property var: <expr>)
    // depending only on "periodSelector"'s current state and the toggle
    // state below - this guarantees every chart/legend always sees
    // internally-consistent, correctly-shaped data no matter which one is
    // currently visible (all of them stay bound/instantiated in the
    // background even while hidden via "visible: false", so their bindings
    // are still evaluated - a plain imperative "recompute on demand"
    // function tied to a signal handler would risk a stale/wrong-shaped
    // read on whichever section is currently invisible).
    QtObject {
        id: d

        property int activeChartTab: 0 // 0 = Energiebilanz, 1 = Verbrauch

        // ---- "Which Thing types are present" flags ----
        // Backed by the "producers"/"batteries" ThingsProxy instances
        // declared above (root level). All series driven by these flags are
        // fully optional - a system without a battery/PV simply omits the
        // corresponding series/legend entries, it is not zero-filled.
        readonly property bool hasProducer: producers.count > 0
        readonly property bool hasBattery: batteries.count > 0

        // ---- Legend visibility toggle state ----
        // Set of series names currently hidden via a legend pill tap,
        // shared across all periods/tabs (toggling "Netzbezug" off is
        // remembered regardless of which period/tab it was toggled from -
        // simpler than per-view toggle state and arguably the more
        // intuitive behavior anyway). Looked up by "name" rather than index
        // since the same series can appear at different indices in
        // different generated arrays.
        property var hiddenSeriesNames: []

        function isSeriesVisible(name) { return d.hiddenSeriesNames.indexOf(name) === -1 }

        // "seriesArray"/"index" identify which pill was tapped; resolved to
        // a stable name before updating "hiddenSeriesNames" so the toggle
        // state doesn't depend on any particular array's current indexing.
        function toggleSeriesVisibility(seriesArray, index, visible) {
            var name = seriesArray[index].name
            var currentIndex = d.hiddenSeriesNames.indexOf(name)
            if (visible && currentIndex !== -1) {
                var updated = d.hiddenSeriesNames.slice()
                updated.splice(currentIndex, 1)
                d.hiddenSeriesNames = updated
            } else if (!visible && currentIndex === -1) {
                d.hiddenSeriesNames = d.hiddenSeriesNames.concat([name])
            }
        }

        // Deterministic pseudo-random value in [min, max), seeded by an
        // arbitrary string. Used instead of Math.random() so the dummy
        // charts don't visibly jump/flicker on every re-render (e.g. when
        // toggling a legend pill re-evaluates unrelated bindings) - the
        // same category+series combination always produces the same value.
        function pseudoRandom(seed, min, max) {
            var hash = 0
            for (var i = 0; i < seed.length; i++) {
                hash = (hash * 31 + seed.charCodeAt(i)) % 1000000007
            }
            var frac = Math.abs(Math.sin(hash))
            return min + frac * (max - min)
        }

        // ---- KPI values ----
        // Backed by "kpiProvider" (CoStatsMetricsProvider, see root.fetchKpis()
        // above), which fetches Energy.GetEnergyKPIs for the period
        // currently selected in "periodSelector". Shows "–" for any value
        // until the first successful response arrives (kpiProvider.valid
        // stays false until then, e.g. also while fetching or if the
        // backend doesn't support this API yet).
        readonly property var kpis: {
            if (!kpiProvider.valid) {
                return {
                    selfSufficiencyText: "–",
                    selfConsumptionText: "–",
                    feedInText: "–",
                    gridConsumptionText: "–"
                }
            }
            return {
                selfSufficiencyText: Math.round(kpiProvider.selfSufficiencyRate) + " %",
                selfConsumptionText: Math.round(kpiProvider.selfConsumptionRate) + " %",
                feedInText: kpiProvider.totalReturn.toFixed(1) + " kWh",
                gridConsumptionText: kpiProvider.totalAcquisition.toFixed(1) + " kWh"
            }
        }

        // ==== Day (line-chart shape) ====
        // Backed directly by "powerBalanceLogs" (see its declaration near
        // the top of the file, kept in sync with the chart's own visible
        // window via "onVisibleRangeChanged"). Sign convention for the
        // per-sample "production"/"acquisition"/"storage" fields matches
        // the real-data precedent in PowerBalanceHistory.qml: production/
        // storage negative = generating/discharging, acquisition positive =
        // importing from grid (negative = exporting).
        //
        // A structurally reserved (but unpopulated/invisible) Battery SoC
        // slot is appended on the right axis, per product decision: the
        // backend cannot report this yet, but the data shape should
        // already account for it so wiring it up later is a drop-in
        // change, not a redesign.
        readonly property var energyBalanceLineSeries: d.computeEnergyBalanceLineSeries()
        function computeEnergyBalanceLineSeries() {
            var series = []
            // PowerBalanceLogs reports consumption/production/acquisition/
            // storage in Watts, but the chart's left axis is in kW, so
            // every valueFunction below divides by 1000.
            if (d.hasProducer) {
                series.push({
                    name: "Production",
                    color: Configuration.inverterColor,
                    visible: d.isSeriesVisible("Production"),
                    axis: "left",
                    model: powerBalanceLogs,
                    valueFunction: function (entry) { return Math.abs(Math.min(0, entry.production)) / 1000 }
                })
                series.push({
                    name: "To grid",
                    color: Configuration.rootMeterReturnColor,
                    visible: d.isSeriesVisible("To grid"),
                    axis: "left",
                    model: powerBalanceLogs,
                    valueFunction: function (entry) { return Math.max(0, -entry.acquisition) / 1000 }
                })
            }
            series.push({
                name: "Consumption",
                color: Configuration.consumedColor,
                visible: d.isSeriesVisible("Consumption"),
                axis: "left",
                model: powerBalanceLogs,
                valueFunction: function (entry) { return entry.consumption / 1000 }
            })
            if (d.hasBattery) {
                series.push({
                    name: "To battery",
                    color: Configuration.batteryChargeColor,
                    visible: d.isSeriesVisible("To battery"),
                    axis: "left",
                    model: powerBalanceLogs,
                    valueFunction: function (entry) { return Math.max(0, entry.storage) / 1000 }
                })
                series.push({
                    name: "From battery",
                    color: Configuration.batteryDischargeColor,
                    visible: d.isSeriesVisible("From battery"),
                    axis: "left",
                    model: powerBalanceLogs,
                    valueFunction: function (entry) { return Math.abs(Math.min(0, entry.storage)) / 1000 }
                })
            }
            series.push({
                name: "From grid",
                color: Configuration.rootMeterAcquisitionColor,
                visible: d.isSeriesVisible("From grid"),
                axis: "left",
                model: powerBalanceLogs,
                valueFunction: function (entry) { return Math.max(0, entry.acquisition) / 1000 }
            })
            // Reserved Battery SoC slot: not rendered (percentAxisVisible
            // is false above) and not assigned any real data yet, but
            // already shaped correctly (axis: "right", 0-100 range) for
            // later use.
            if (d.hasBattery) {
                series.push({
                    name: qsTr("Battery charge level"),
                    color: Configuration.batteriesColor,
                    visible: false,
                    axis: "right",
                    model: d.emptyLogModel,
                    valueFunction: function (entry) { return entry.value }
                })
            }
            return series
        }

        readonly property var consumptionSourceLineSeries: d.computeConsumptionSourceLineSeries()
        function computeConsumptionSourceLineSeries() {
            var series = []
            // "Self-consumption": the part of total consumption covered
            // neither by the battery nor the grid, i.e. directly-used own
            // production. Only meaningful (and only ever non-zero) when a
            // producer is present.
            if (d.hasProducer) {
                series.push({
                    name: "Self-consumption",
                    color: Configuration.inverterColor,
                    visible: d.isSeriesVisible("Self-consumption"),
                    axis: "left",
                    model: powerBalanceLogs,
                    valueFunction: function (entry) {
                        var fromBattery = Math.abs(Math.min(0, entry.storage))
                        var fromGrid = Math.max(0, entry.acquisition)
                        return Math.max(0, entry.consumption - fromBattery - fromGrid) / 1000
                    }
                })
            }
            if (d.hasBattery) {
                series.push({
                    name: "From battery",
                    color: Configuration.batteryDischargeColor,
                    visible: d.isSeriesVisible("From battery"),
                    axis: "left",
                    model: powerBalanceLogs,
                    valueFunction: function (entry) { return Math.abs(Math.min(0, entry.storage)) / 1000 }
                })
            }
            series.push({
                name: "From grid",
                color: Configuration.rootMeterAcquisitionColor,
                visible: d.isSeriesVisible("From grid"),
                axis: "left",
                model: powerBalanceLogs,
                valueFunction: function (entry) { return Math.max(0, entry.acquisition) / 1000 }
            })
            return series
        }

        readonly property var consumptionConsumerLineSeries: d.computeConsumptionConsumerLineSeries()
        function computeConsumptionConsumerLineSeries() {
            var series = []
            // One series per discovered consumer Thing, backed directly by
            // its own ThingPowerLogs instance (see
            // "consumerConsumptionLogs" near the top of the file).
            for (var i = 0; i < consumerConsumptionLogs.count; i++) {
                var item = consumerConsumptionLogs.consumerAt(i)
                if (!item || !item.thing) {
                    continue
                }
                series.push({
                    name: item.thing.name,
                    color: Configuration.consumerColors[i % (Configuration.consumerColors.length - 1)],
                    visible: d.isSeriesVisible(item.thing.name),
                    axis: "left",
                    model: item.logs,
                    valueFunction: function (entry) { return entry.currentPower / 1000 }
                })
            }
            // "Sonstiger Verbrauch"/"Other consumption" is not an optional
            // Thing-backed series like the ones above - it is always
            // present as an explicit catch-all bucket (total consumption
            // minus the sum of all known consumers at the same instant),
            // computed and kept up to date by "consumerConsumptionLogs"
            // (see ConsumerConsumptionLogs.qml - "otherConsumption").
            series.push({
                name: qsTr("Other consumption"),
                color: Configuration.consumerColors[Configuration.consumerColors.length - 1],
                visible: d.isSeriesVisible(qsTr("Other consumption")),
                axis: "left",
                model: consumerConsumptionLogs.otherConsumption,
                valueFunction: function (entry) { return entry.consumption / 1000 }
            })
            return series
        }

        readonly property var consumptionLineSeries: d.consumptionSourceLineSeries.concat(d.consumptionConsumerLineSeries)

        // Generates a single dummy line-chart series entry: a sine-wave
        // shaped, 15-minute-resolution "log" for the 24h window around
        // "referenceDate", wrapped in a plain object that mimics the shape
        // CoStatsLineChart expects from a real EnergyLogs-derived model
        // (count/get(index); entriesAddedIdx/entriesRemoved are not needed
        // here since the dummy data never changes after creation).
        function dummyLineSeriesFor(name, color, referenceDate, min, max, phaseOffset) {
            var entries = []
            var dayStart = new Date(referenceDate)
            dayStart.setHours(0, 0, 0, 0)
            var stepMs = 15 * 60000
            var phase = d.pseudoRandom(name + "|" + (phaseOffset || 0), 0, Math.PI * 2)
            for (var t = 0; t <= 24 * 3600000; t += stepMs) {
                var hourOfDay = t / 3600000
                var value = Math.max(0, Math.sin((hourOfDay / 24) * Math.PI * 2 - Math.PI / 2 + phase)) * (max - min) + min
                entries.push({ timestamp: new Date(dayStart.getTime() + t), value: value })
            }
            return {
                name: name,
                color: color,
                visible: d.isSeriesVisible(name),
                axis: "left",
                model: d.wrapAsLogModel(entries),
                valueFunction: function (entry) { return entry.value }
            }
        }

        // Wraps a plain array of {timestamp, value} entries into the
        // minimal object shape CoStatsLineChart expects from a model.
        function wrapAsLogModel(entries) {
            return {
                count: entries.length,
                get: function (index) { return entries[index] }
            }
        }
        readonly property var emptyLogModel: d.wrapAsLogModel([])

        // ==== Week/Month/Year (bar-chart shape) ====
        // Segment semantics/whether these truly sum additively will need
        // confirming once wired to real Energy.GetPowerBalanceLogs fields -
        // for now, dummy values are simply stacked for layout purposes.
        //
        // Week/Month/Year/year-over-year each get their own dedicated set
        // of category+series properties below (rather than one shared set)
        // since their category counts differ (7/~5/12/up to 5) - sharing
        // would mean whichever section is currently hidden ends up bound
        // to data shaped for a *different* category count, which
        // CoStatsBarChart cannot render.

        readonly property var weekCategories: d.weekdayCategories(periodSelector.referenceDate)
        readonly property var weekBarCategoryRanges: d.weekCategoryRanges(periodSelector.referenceDate)
        readonly property var weekEnergyBalanceProductionSeries: d.computeEnergyBalanceProductionSeries(weekEnergyLogs)
        readonly property var weekEnergyBalanceConsumptionSeries: d.computeEnergyBalanceConsumptionSeries(weekEnergyLogs)
        readonly property var weekConsumptionSourceSeries: d.computeConsumptionSourceStackSeries(weekEnergyLogs)
        readonly property var weekConsumptionConsumerSeries: d.computeConsumptionConsumerStackSeries(weekEnergyLogs)

        readonly property var monthCategories: d.isoWeeksInMonthCategories(periodSelector.referenceDate)
        readonly property var monthBarCategoryRanges: d.monthCategoryRanges(periodSelector.referenceDate)
        readonly property var monthEnergyBalanceProductionSeries: d.computeEnergyBalanceProductionSeries(monthEnergyLogs)
        readonly property var monthEnergyBalanceConsumptionSeries: d.computeEnergyBalanceConsumptionSeries(monthEnergyLogs)
        readonly property var monthConsumptionSourceSeries: d.computeConsumptionSourceStackSeries(monthEnergyLogs)
        readonly property var monthConsumptionConsumerSeries: d.computeConsumptionConsumerStackSeries(monthEnergyLogs)

        readonly property var yearCategories: d.monthsInYearCategories(periodSelector.referenceDate)
        readonly property var yearBarCategoryRanges: d.yearCategoryRanges(periodSelector.referenceDate)
        readonly property var yearEnergyBalanceProductionSeries: d.computeEnergyBalanceProductionSeries(yearEnergyLogs)
        readonly property var yearEnergyBalanceConsumptionSeries: d.computeEnergyBalanceConsumptionSeries(yearEnergyLogs)
        readonly property var yearConsumptionSourceSeries: d.computeConsumptionSourceStackSeries(yearEnergyLogs)
        readonly property var yearConsumptionConsumerSeries: d.computeConsumptionConsumerStackSeries(yearEnergyLogs)

        // Year-over-year comparison chart: shared between the Month and
        // Year views (both compare "the same sub-period across the last
        // ~5 years"), since only one of Month/Year is ever visible at a
        // time and both derive this purely from the current reference
        // date/minDate.
        readonly property var yoyCategories: d.yearOverYearCategories(periodSelector.referenceDate, periodSelector.minDate)
        readonly property var yoyBarCategoryRanges: d.yearOverYearCategoryRanges(periodSelector.referenceDate, periodSelector.minDate, periodSelector.sampleRate)
        readonly property var yoyEnergyBalanceProductionSeries: d.computeEnergyBalanceProductionSeries(yoyEnergyLogs)
        readonly property var yoyEnergyBalanceConsumptionSeries: d.computeEnergyBalanceConsumptionSeries(yoyEnergyLogs)
        readonly property var yoyConsumptionSourceSeries: d.computeConsumptionSourceStackSeries(yoyEnergyLogs)
        readonly property var yoyConsumptionConsumerSeries: d.computeConsumptionConsumerStackSeries(yoyEnergyLogs)

        // "provider" is one of the PeriodEnergyLogs instances declared near
        // the top of this file (weekEnergyLogs/monthEnergyLogs/
        // yearEnergyLogs/yoyEnergyLogs) - each already holds real backend
        // data for exactly the category ranges of the section it backs.
        //
        // "To battery"/"From battery" are deliberately not included here -
        // see PeriodEnergyLogs.qml's file doc comment for why (no
        // cumulative battery energy counter is reliably available at these
        // aggregated sample rates).
        function computeEnergyBalanceProductionSeries(provider) {
            var series = []
            if (d.hasProducer) {
                series.push({ name: "Production", color: Configuration.inverterColor, visible: d.isSeriesVisible("Production"), values: provider.totalProductionSeries() })
                series.push({ name: "To grid", color: Configuration.rootMeterReturnColor, visible: d.isSeriesVisible("To grid"), values: provider.totalReturnSeries() })
            }
            return series
        }

        function computeEnergyBalanceConsumptionSeries(provider) {
            var series = [{ name: "Consumption", color: Configuration.consumedColor, visible: d.isSeriesVisible("Consumption"), values: provider.totalConsumptionSeries() }]
            series.push({ name: "From grid", color: Configuration.rootMeterAcquisitionColor, visible: d.isSeriesVisible("From grid"), values: provider.totalAcquisitionSeries() })
            return series
        }

        function computeConsumptionSourceStackSeries(provider) {
            var series = []
            if (d.hasProducer) {
                series.push({ name: "Self-consumption", color: Configuration.inverterColor, visible: d.isSeriesVisible("Self-consumption"), values: provider.selfConsumptionSeries() })
            }
            series.push({ name: "From grid", color: Configuration.rootMeterAcquisitionColor, visible: d.isSeriesVisible("From grid"), values: provider.totalAcquisitionSeries() })
            return series
        }

        function computeConsumptionConsumerStackSeries(provider) {
            var series = provider.consumerSeries().map(function (entry, i) {
                return {
                    name: entry.thing.name,
                    color: Configuration.consumerColors[i % (Configuration.consumerColors.length - 1)],
                    visible: d.isSeriesVisible(entry.thing.name),
                    values: entry.values
                }
            })
            series.push({
                name: qsTr("Other consumption"),
                color: Configuration.consumerColors[Configuration.consumerColors.length - 1],
                visible: d.isSeriesVisible(qsTr("Other consumption")),
                values: provider.otherConsumptionSeries()
            })
            return series
        }

        // ---- Category label helpers ----

        // "Mo".."So" for the ISO week starting at "mondayDate" (already the
        // Monday of the selected week when sampleRate is Week - for other
        // sample rates this is only used by the (hidden) Week section, so
        // exact alignment doesn't matter there).
        function weekdayCategories(mondayDate) {
            var result = []
            var day = new Date(mondayDate)
            for (var i = 0; i < 7; i++) {
                var isoDay = ((day.getDay() + 6) % 7) + 1 // 1 (Mon) .. 7 (Sun)
                result.push(Qt.locale().dayName(isoDay, Locale.ShortFormat))
                day.setDate(day.getDate() + 1)
            }
            return result
        }

        // One {from, to} day range per weekday, matching "weekdayCategories"
        // 1:1 - backs the real PeriodEnergyLogs fetch (sampleRate=1Day) for
        // the Week bar chart.
        function weekCategoryRanges(mondayDate) {
            var result = []
            var day = new Date(mondayDate)
            for (var i = 0; i < 7; i++) {
                var next = new Date(day)
                next.setDate(next.getDate() + 1)
                result.push({ from: new Date(day), to: next })
                day = next
            }
            return result
        }

        // "CW18", "CW19", ... for every ISO week that overlaps the month
        // containing "referenceDate".
        function isoWeeksInMonthCategories(referenceDate) {
            var first = new Date(referenceDate.getFullYear(), referenceDate.getMonth(), 1)
            var last = new Date(referenceDate.getFullYear(), referenceDate.getMonth() + 1, 0)
            var cursor = new Date(first)
            cursor.setDate(cursor.getDate() - ((cursor.getDay() + 6) % 7)) // back up to that week's Monday
            var result = []
            while (cursor <= last) {
                result.push(qsTr("CW%1").arg(DateUtils.isoWeekNumber(cursor)))
                cursor.setDate(cursor.getDate() + 7)
            }
            return result
        }

        // One {from, to} Monday-to-Monday week range per ISO week, matching
        // "isoWeeksInMonthCategories" 1:1 - backs the real PeriodEnergyLogs
        // fetch (sampleRate=1Week) for the Month bar chart.
        function monthCategoryRanges(referenceDate) {
            var first = new Date(referenceDate.getFullYear(), referenceDate.getMonth(), 1)
            var last = new Date(referenceDate.getFullYear(), referenceDate.getMonth() + 1, 0)
            var cursor = new Date(first)
            cursor.setDate(cursor.getDate() - ((cursor.getDay() + 6) % 7))
            var result = []
            while (cursor <= last) {
                var next = new Date(cursor)
                next.setDate(next.getDate() + 7)
                result.push({ from: new Date(cursor), to: next })
                cursor = next
            }
            return result
        }

        // Short month names (Jan..Dez) for the year containing "referenceDate".
        // Uses standaloneMonthName (not monthName), matching the convention
        // established in CoDayPickerContent/CoMonthPickerContent: some
        // locales inflect a month name differently depending on whether it
        // is used standalone (as here, an axis label) or as part of a full
        // date - standaloneMonthName is 0-based, same as JS Date.
        function monthsInYearCategories(referenceDate) {
            var result = []
            for (var month = 0; month < 12; month++) {
                result.push(Qt.locale().standaloneMonthName(month, Locale.ShortFormat))
            }
            return result
        }

        // One {from, to} calendar-month range per month, matching
        // "monthsInYearCategories" 1:1 - backs the real PeriodEnergyLogs
        // fetch (sampleRate=1Month) for the Year bar chart.
        function yearCategoryRanges(referenceDate) {
            var result = []
            for (var month = 0; month < 12; month++) {
                var from = new Date(referenceDate.getFullYear(), month, 1)
                var to = new Date(referenceDate.getFullYear(), month + 1, 1)
                result.push({ from: from, to: to })
            }
            return result
        }

        // Last 5 years up to and including the year of "referenceDate",
        // clamped to not go below "minDate"'s year (the same lower bound
        // CoPeriodSelector itself enforces for navigation).
        function yearOverYearCategories(referenceDate, minDate) {
            var endYear = referenceDate.getFullYear()
            var startYear = Math.max(minDate.getFullYear(), endYear - 4)
            var result = []
            for (var year = startYear; year <= endYear; year++) {
                result.push(String(year))
            }
            return result
        }

        // One range per year, matching "yearOverYearCategories" 1:1. What
        // exactly is compared "the same sub-period" across those years
        // depends on which view this comparison chart is shown in:
        //  - Year view: the sub-period is the whole year - each range spans
        //    Jan 1 to Jan 1 of the next year (sampleRate=1Year).
        //  - Month view: the sub-period is the one calendar month currently
        //    selected (e.g. August) - each range only covers that single
        //    month within its year (sampleRate=1Month), even though the
        //    fetch this backs (see PeriodEnergyLogs.fetchLogs()) still
        //    covers the entire multi-year span in one request; the other
        //    11 months per year are simply never looked up.
        function yearOverYearCategoryRanges(referenceDate, minDate, activeSampleRate) {
            var endYear = referenceDate.getFullYear()
            var startYear = Math.max(minDate.getFullYear(), endYear - 4)
            var result = []
            for (var year = startYear; year <= endYear; year++) {
                if (activeSampleRate === EnergyLogs.SampleRate1Month) {
                    var from = new Date(year, referenceDate.getMonth(), 1)
                    var to = new Date(year, referenceDate.getMonth() + 1, 1)
                    result.push({ from: from, to: to })
                } else {
                    result.push({ from: new Date(year, 0, 1), to: new Date(year + 1, 0, 1) })
                }
            }
            return result
        }
    }
}
