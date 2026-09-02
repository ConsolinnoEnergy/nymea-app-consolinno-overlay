// #TODO copyright notice

import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtCharts
import Nymea
import NymeaApp.Utils
import Qt5Compat.GraphicalEffects

import "../components"
import "../delegates"
import "../utils/VersionUtils.js" as VersionUtils

MainViewBase {
    id: root

    contentY: flickable.contentY + topMargin

    headerButtons: []

    function batteryIconForEnergyFlow(batteryLevel, charging) {
        let batteryLevelForIcon = NymeaUtils.pad(Math.round(batteryLevel / 10) * 10, 3);
        let chargingSelector = charging ? "-charging" : "";
        return Qt.resolvedUrl("qrc:/icons/battery/battery2-" + batteryLevelForIcon + chargingSelector + ".svg");
    }

    function hemsVersionOk(){
        var minSysVersion = Configuration.minSysVersion;
        // Checks if System version is less or equal to minSysVersion
        if ([-1].includes(VersionUtils.compareSemanticVersions(engine.jsonRpcClient.experiences.Hems, minSysVersion))) {
            return false;
        }
        return true;
    }

    function avoidZeroCompensationActive(battery) {
        if (!battery) { return false; }
        if (battery.thingClass.interfaces.indexOf("controllablebattery") === 0) { return false; }
        const batteryConfig = hemsManager.batteryConfigurations.getBatteryConfiguration(battery.id);
        if (!batteryConfig) { return false; }
        return batteryConfig.avoidZeroFeedInActive && batteryConfig.avoidZeroFeedInEnabled;
    }

    EnergyManager {
        id: energyManager
        engine: _engine && !_engine.thingManager.fetchingData ? _engine : null
    }

    DashboardDataProvider {
        id: dataProvider
        engine: _engine
        rootMeter: root.rootMeter
    }

    ThingsProxy {
        id: producerThings
        engine: _engine
        shownInterfaces: ["smartmeterproducer"]
    }

    ThingsProxy {
        id: batteryThings
        engine: _engine
        shownInterfaces: ["energystorage"]
    }

    ThingsProxy {
        id: heatingThings
        engine: _engine
        shownInterfaces: ["heatpump", "heatingrod"]
    }

    ThingsProxy {
        id: evChargerThings
        engine: _engine
        shownInterfaces: ["evcharger"]
    }

    ThingsProxy {
        id: otherConsumerThings
        engine: _engine
        shownInterfaces: ["smartmeterconsumer"]
        hiddenInterfaces: ["heatpump", "heatingrod", "evcharger"]
    }

    ThingsProxy {
        id: dynamicPricingThings
        engine: _engine
        shownInterfaces: ["dynamicelectricitypricing"]
    }

    ThingsProxy {
        id: gridSupportThings
        engine: _engine
        shownInterfaces: ["gridsupport"]
    }

    ThingsProxy {
        id: electricVehicleThings
        engine: _engine
        shownInterfaces: ["electricvehicle"]
    }
    ThingsProxy {
        id: energyMetersProxy
        engine: _engine
        shownInterfaces: ["energymeter"]
    }

    Settings {
        id: shownPopupsSetting
        category: "shownPopups"
        property string shownVersions: "[]"

        function getShownVersions() {
            try { return JSON.parse(shownVersions); } catch(e) { return []; }
        }
        function addVersion(version) {
            var list = getShownVersions();
            list.push(version);
            console.log("Adding version to shown popups:", version, "List after adding:", list);
            shownVersions = JSON.stringify(list);
        }
        function hasVersion(version) {
            return getShownVersions().indexOf(version) !== -1;
        }
    }

    Settings {
        id: incompatibilityWarningSettings
        category: "incompatibilityWarning"
        property alias collapsed: incompatibilityWarning.collapsed
    }

    readonly property Thing gridSupport: gridSupportThings.count > 0 ? gridSupportThings.get(0) : null
    readonly property Thing rootMeter: engine.thingManager.fetchingData ?
                                           null :
                                           engine.thingManager.things.getThing(energyManager.rootMeterId)
    readonly property Thing dynamicPricingThing: dynamicPricingThings.count > 0 ? dynamicPricingThings.get(0) : null
    property bool lpcActive: (gridSupport && gridSupport.stateByName("isLpcActive") !== null) ?
                                 gridSupport.stateByName("isLpcActive").value :
                                 false
    property bool lppActive: (gridSupport && gridSupport.stateByName("isLppActive") !== null) ?
                                 gridSupport.stateByName("isLppActive").value :
                                 false
    property double lppPowerLimit: gridSupport ? gridSupport.stateByName("lppValue").value : 0
    property double lpcPowerLimit: gridSupport ? gridSupport.stateByName("lpcValue").value : 0

    property bool anyInverterLppActive: {
        if (!lppActive) { return false; }
        for (let i = 0; i < producerThings.count; ++i) {
            let inverter = producerThings.get(i);
            let config = hemsManager.pvConfigurations.getPvConfiguration(inverter.id);
            if (config !== null && config.controllableLocalSystem) {
                return true;
            }
        }
        return false;
    }

    readonly property bool anyInverterNotConnected: {
        for (let i = 0; i < producerThings.count; ++i) {
            let producer = producerThings.get(i);
            if (!ThingUtils.isConnected(producer)) {
                return true;
            }
        }
        return false;
    }

    property bool anyAvoidZeroCompensationActive: {
        for (let i = 0; i < batteryThings.count; ++i) {
            let battery = batteryThings.get(i);
            if (avoidZeroCompensationActive(battery)) {
                return true;
            }
        }
        return false;
    }

    readonly property bool anyBatteryNotConnected: {
        for (let i = 0; i < batteryThings.count; ++i) {
            let battery = batteryThings.get(i);
            if (!ThingUtils.isConnected(battery)) {
                return true;
            }
        }
        return false;
    }

    property bool anyTargetSocPvSurplusExceeded: {
        for (let i = 0; i < batteryThings.count; ++i) {
            let battery = batteryThings.get(i);
            if (ThingUtils.targetSocPvSurplusExceeded(battery,
                                                      hemsManager.batteryConfigurations.getBatteryConfiguration(battery.id))) {
                return true;
            }
        }
        return false;
    }

    readonly property bool anyConsumerNotConnected: {
        for (let i = 0; i < heatingThings.count; ++i) {
            let consumer = heatingThings.get(i);
            if (!ThingUtils.isConnected(consumer)) {
                return true;
            }
        }
        for (let i = 0; i < evChargerThings.count; ++i) {
            let consumer = evChargerThings.get(i);
            if (!ThingUtils.isConnected(consumer)) {
                return true;
            }
        }
        for (let i = 0; i < otherConsumerThings.count; ++i) {
            let consumer = otherConsumerThings.get(i);
            if (!ThingUtils.isConnected(consumer)) {
                return true;
            }
        }
        return false;
    }

    property bool anyPvSurplusRuntimeExceeded: {
        for (let i = 0; i < heatingThings.count; ++i) {
            let thing = heatingThings.get(i);
            if (hemsManager.conEMSState.runtimeExceededThings.includes(thing.id)) {
                return true;
            }
        }
        for (let i = 0; i < otherConsumerThings.count; ++i) {
            let thing = otherConsumerThings.get(i);
            if (hemsManager.conEMSState.runtimeExceededThings.includes(thing.id)) {
                return true;
            }
        }
        return false;
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: dashboardRoot.implicitHeight
        visible: !unconfiguredHemsView.visible

        NumberAnimation {
            id: flickableContentYAnimation
            target: flickable
            property: "contentY"
            duration: 700
            easing.type: Easing.InOutQuart
            onFinished: {
                flickable.returnToBounds();
            }

            function setTargetY(targetY) {
                to = Math.min(targetY - root.topMargin - 10,
                              flickable.contentHeight - flickable.height);
            }
        }

        Item {
            anchors.fill: parent

            Rectangle {
                id: background
                anchors.fill: parent
                color: Style.colors.typography_Background_Default

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop{
                            position: 0.0
                            color: Qt.rgba(
                                Style.colors.components_Dashboard_Background_gradient_top.r,
                                Style.colors.components_Dashboard_Background_gradient_top.g,
                                Style.colors.components_Dashboard_Background_gradient_top.b,
                                Style.colors.components_Dashboard_Background_gradient_top.a * 0.5
                            )
                        }
                        GradientStop{
                            position: 1.0
                            color: Qt.rgba(
                                Style.colors.components_Dashboard_Background_gradient_bottom.r,
                                Style.colors.components_Dashboard_Background_gradient_bottom.g,
                                Style.colors.components_Dashboard_Background_gradient_bottom.b,
                                Style.colors.components_Dashboard_Background_gradient_bottom.a * 0.5
                            )
                        }
                    }
                }
            }

            Item {
                id: dashboardRoot
                anchors.fill: parent
                anchors.leftMargin: Style.margins
                anchors.rightMargin: Style.margins

                implicitHeight: dashboardLayout.implicitHeight + anchors.margins * 2

                ColumnLayout {
                    id: dashboardLayout
                    anchors.fill: parent
                    spacing: Style.margins

                    // Dummy series definition for the CoStatsLineChart test card
                    // below. "visible" is toggled by CoStatsChartLegend.
                    property var chartTestSeries: [
                        {
                            name: "Erzeugung",
                            color: "#3AA757",
                            visible: true,
                            axis: "left",
                            model: dummyProductionLog,
                            valueFunction: function (entry) { return entry.value }
                        },
                        {
                            name: "Akku SoC",
                            color: "#3A7FA7",
                            visible: true,
                            axis: "right",
                            model: dummyBatteryLog,
                            valueFunction: function (entry) { return entry.value }
                        }
                    ]

                    Item {
                        id: spacerTopMargin
                        height: root.topMargin
                        Layout.fillWidth: true
                    }

                    CoFrostyCard {
                        Layout.fillWidth: true
                        contentBottomMargin: 16

                        headerText: "Zeitraum"

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: Style.margins
                            anchors.rightMargin: Style.margins
                            spacing: Style.margins

                            CoPeriodSelector {
                                id: periodSelector
                                Layout.fillWidth: true
                            }

                            Button {
                                Layout.fillWidth: true
                                text: "01.08.26"
                                onClicked: {
                                    periodSelector.setReferenceDate(new Date(2026, 7, 1))
                                }
                            }

                            Button {
                                Layout.fillWidth: true
                                text: "11.05.26"
                                onClicked: {
                                    periodSelector.setReferenceDate(new Date(2026, 4, 11))
                                }
                            }

                            Button {
                                Layout.fillWidth: true
                                text: "24.12.26"
                                onClicked: {
                                    periodSelector.setReferenceDate(new Date(2026, 11, 24))
                                }
                            }

                            Button {
                                Layout.fillWidth: true
                                text: "24.12.25"
                                onClicked: {
                                    periodSelector.setReferenceDate(new Date(2025, 11, 24))
                                }
                            }
                        }
                    }

                    CoFrostyCard {
                        Layout.fillWidth: true
                        contentBottomMargin: 16

                        headerText: "Chart Test"

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: Style.margins
                            anchors.rightMargin: Style.margins
                            spacing: Style.margins

                            CoStatsChartLegend {
                                Layout.fillWidth: true
                                series: dashboardLayout.chartTestSeries
                                onSeriesVisibilityToggled: (index, visible) => {
                                    var updated = dashboardLayout.chartTestSeries.slice()
                                    updated[index] = Object.assign({}, updated[index], { visible: visible })
                                    dashboardLayout.chartTestSeries = updated
                                }
                            }

                            CoStatsLineChart {
                                id: statsChart
                                Layout.fillWidth: true
                                Layout.preferredHeight: 300

                                selectedDay: periodSelector.referenceDate
                                percentAxisVisible: true
                                loading: dummyProductionLog.loading || dummyBatteryLog.loading

                                series: dashboardLayout.chartTestSeries

                                onVisibleRangeChanged: (startTime, endTime) => {
                                    console.log("CoStatsLineChart demo: visibleRangeChanged", startTime, endTime)
                                    dummyDataGenerator.reseedIfNeeded(startTime, endTime)
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Style.margins

                                // Test buttons: since pinch-zoom cannot be
                                // reliably simulated on a desktop dev machine
                                // without touch hardware, these jump the
                                // chart's visible window directly to 24h/12h/
                                // 6h for manual testing of the zoomed views.
                                Button {
                                    Layout.fillWidth: true
                                    text: "24h"
                                    onClicked: statsChart.setVisibleWindowHours(24)
                                }
                                Button {
                                    Layout.fillWidth: true
                                    text: "12h"
                                    onClicked: statsChart.setVisibleWindowHours(12)
                                }
                                Button {
                                    Layout.fillWidth: true
                                    text: "6h"
                                    onClicked: statsChart.setVisibleWindowHours(6)
                                }
                            }
                        }
                    }

                    // Dummy stack definitions for the CoStatsBarChart test card
                    // below. "visible" is toggled by CoStatsChartLegend.
                    property var chartTestBarCategories: ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
                    property var chartTestBarSourceSeries: [
                        { name: "Produktion", color: "#F5C242", borderColor: "#B79131", visible: true, values: [30, 20, 28, 18, 30, 22, 30] },
                        { name: "Von Batterie", color: "#F06BB0", borderColor: "#B45084", visible: true, values: [8, 10, 9, 6, 9, 10, 9] }
                    ]
                    property var chartTestBarConsumerSeries: [
                        { name: "Netzbezug", color: "#E0575B", borderColor: "#A84144", visible: true, values: [10, 8, 12, 6, 10, 6, 9] },
                        { name: "Netzeinspeisung", color: "#3FA9F5", borderColor: "#2F7EB7", visible: true, values: [8, 6, 9, 4, 8, 8, 8] }
                    ]

                    CoFrostyCard {
                        Layout.fillWidth: true
                        contentBottomMargin: 16

                        headerText: "Bar Chart Test"

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: Style.margins
                            anchors.rightMargin: Style.margins
                            spacing: Style.margins

                            CoStatsBarChart {
                                id: statsBarChart
                                Layout.fillWidth: true
                                Layout.preferredHeight: 300

                                categories: dashboardLayout.chartTestBarCategories
                                stacks: [
                                    { series: dashboardLayout.chartTestBarSourceSeries },
                                    { series: dashboardLayout.chartTestBarConsumerSeries }
                                ]
                            }

                            Label {
                                Layout.fillWidth: true
                                text: "Quellen"
                                font: Style.smallFont
                            }

                            CoStatsChartLegend {
                                Layout.fillWidth: true
                                series: dashboardLayout.chartTestBarSourceSeries
                                onSeriesVisibilityToggled: (index, visible) => {
                                    var updated = dashboardLayout.chartTestBarSourceSeries.slice()
                                    updated[index] = Object.assign({}, updated[index], { visible: visible })
                                    dashboardLayout.chartTestBarSourceSeries = updated
                                }
                            }

                            Label {
                                Layout.fillWidth: true
                                text: "Verbraucher"
                                font: Style.smallFont
                            }

                            CoStatsChartLegend {
                                Layout.fillWidth: true
                                series: dashboardLayout.chartTestBarConsumerSeries
                                onSeriesVisibilityToggled: (index, visible) => {
                                    var updated = dashboardLayout.chartTestBarConsumerSeries.slice()
                                    updated[index] = Object.assign({}, updated[index], { visible: visible })
                                    dashboardLayout.chartTestBarConsumerSeries = updated
                                }
                            }
                        }
                    }

                    // ---- Dummy data generator for the CoStatsLineChart test above ----
                    // Mimics the shape of an EnergyLogs-derived model (count, get(index),
                    // entriesAddedIdx/entriesRemoved) with made-up sine-wave data. Only
                    // used for manual testing of CoStatsLineChart; not real data.
                    QtObject {
                        id: dummyProductionLog
                        property var entries: []
                        property int count: entries.length
                        property bool loading: false
                        signal entriesAddedIdx(int index, int count)
                        signal entriesRemoved(int index, int count)
                        function get(index) { return entries[index] }
                    }

                    QtObject {
                        id: dummyBatteryLog
                        property var entries: []
                        property int count: entries.length
                        property bool loading: false
                        signal entriesAddedIdx(int index, int count)
                        signal entriesRemoved(int index, int count)
                        function get(index) { return entries[index] }
                    }

                    QtObject {
                        id: dummyDataGenerator

                        property date loadedStart
                        property date loadedEnd

                        function generate(centerDate) {
                            var dayMs = 24 * 3600000
                            var rangeStart = new Date(centerDate.getTime() - dayMs)
                            var rangeEnd = new Date(centerDate.getTime() + 2 * dayMs)

                            dummyProductionLog.loading = true
                            dummyBatteryLog.loading = true

                            var productionEntries = []
                            var batteryEntries = []
                            var stepMs = 15 * 60000
                            var i = 0
                            for (var t = rangeStart.getTime(); t <= rangeEnd.getTime(); t += stepMs) {
                                var hourOfDay = (new Date(t).getHours() + new Date(t).getMinutes() / 60)
                                var production = Math.max(0, Math.sin((hourOfDay - 6) / 12 * Math.PI)) * (4 + Math.sin(i / 9) * 1.5)
                                var soc = 50 + Math.sin(i / 40) * 45
                                productionEntries.push({ timestamp: new Date(t), value: production })
                                batteryEntries.push({ timestamp: new Date(t), value: Math.max(0, Math.min(100, soc)) })
                                i++
                            }

                            // Simulate a short network delay, like a real data fetch would have.
                            dummyLoadDelayTimer.pendingProduction = productionEntries
                            dummyLoadDelayTimer.pendingBattery = batteryEntries
                            dummyLoadDelayTimer.pendingStart = rangeStart
                            dummyLoadDelayTimer.pendingEnd = rangeEnd
                            dummyLoadDelayTimer.restart()
                        }

                        function reseedIfNeeded(startTime, endTime) {
                            if (loadedStart && startTime >= loadedStart && endTime <= loadedEnd)
                                return
                            generate(startTime)
                        }
                    }

                    Timer {
                        id: dummyLoadDelayTimer
                        interval: 400
                        property var pendingProduction: []
                        property var pendingBattery: []
                        property date pendingStart
                        property date pendingEnd
                        onTriggered: {
                            dummyProductionLog.entries = pendingProduction
                            dummyBatteryLog.entries = pendingBattery
                            dummyDataGenerator.loadedStart = pendingStart
                            dummyDataGenerator.loadedEnd = pendingEnd
                            dummyProductionLog.entriesAddedIdx(0, pendingProduction.length)
                            dummyBatteryLog.entriesAddedIdx(0, pendingBattery.length)
                            dummyProductionLog.loading = false
                            dummyBatteryLog.loading = false
                        }
                    }

                    Component.onCompleted: dummyDataGenerator.generate(periodSelector.referenceDate)

                    CoNotification {
                        id: incompatibilityWarning
                        Layout.fillWidth: true
                        visible: !hemsVersionOk()
                        type: CoNotification.Type.Warning
                        actionType: CoNotification.ActionType.Collapsible
                        title: qsTr("Pending software update")
                        collapsed: false
                        message: qsTr("
Your %3 app has been updated to version <strong>%1</strong> and is more up-to-date than the firmware (<strong>%2</strong>) on your %5 device.<br/><br/>
Your %5 device will be updated during the course of the day. Until the update is complete, the new functions may be temporarily unavailable.<br/><br/>
If this message is still displayed, please contact our service team.<br/>
<ul>
    %6
    <li>Email: <a href=\'mailto:%4\'>%4</a></li>
</ul>
<br/>Best regards<br/><br/>
Your %3 Team")
                        .arg(appVersion)
                        .arg(engine.jsonRpcClient.experiences.Hems)
                        .arg(Configuration.appName)
                        .arg(Configuration.serviceEmail)
                        .arg(Configuration.deviceName)
                        .arg(Configuration.serviceTel !== "" ? qsTr("<li>Phone: <a href='tel:%1'>%1</a></li>").arg(Configuration.serviceTel) : "")
                    }

                    CoNotification {
                        id: lppWarning
                        Layout.fillWidth: true
                        visible: anyInverterLppActive
                        type: CoNotification.Type.Warning
                        title: qsTr("Feed-in curtailment")
                        message: qsTr("The feed-in is <b>limited temporarily</b> to <b>%1 kW</b> due to a control command from the grid operator.").arg(UiUtils.convertToKw(lppPowerLimit))
                    }

                    CoNotification {
                        id: lpcWarning
                        Layout.fillWidth: true
                        visible: lpcActive
                        type: CoNotification.Type.Warning
                        title: qsTr("Grid-supportive control")
                        message: qsTr("Due to a control order from the network operator, the total power of controllable devices is <b>temporarily limited</b> to <b>%1 kW.</b> If, for example, you are currently charging your electric car, the charging process may not be carried out at the usual power level.").arg(UiUtils.convertToKw(lpcPowerLimit))
                    }

                    CoNotification {
                        id: avoidZeroCompensationWarning
                        Layout.fillWidth: true
                        visible: anyAvoidZeroCompensationActive
                        type: CoNotification.Type.Warning
                        title: qsTr("Avoid zero compensation active")
                        message: qsTr("Battery charging is limited while the controller is active. <u>More Information</u>")
                        clickable: true
                        onClicked: {
                            pageStack.push("/ui/info/AvoidZeroCompensationInfo.qml", {stack: pageStack});
                        }
                    }

                    CoNotification {
                        id: releaseNotes
                        Layout.fillWidth: true
                        property bool dismissed: false
                        visible: !dismissed && !shownPopupsSetting.hasVersion(appVersion)
                        type: CoNotification.Type.Information
                        actionType: CoNotification.ActionType.Dismissable
                        title: qsTr("The app has been updated.")
                        message: qsTr('CHANGENOTIFICATION_PLACEHOLDER').arg(appVersion)
                        messageTextFormat: Text.RichText

                        onDismiss: {
                            dismissed = true
                            shownPopupsSetting.addVersion(appVersion)
                        }
                    }

                    CoFrostyCard {
                        Layout.fillWidth: true
                        contentBottomMargin: 16

                        headerText: qsTr("Live status")

                        Canvas {
                            id: flowCanvas
                            anchors.fill: liveStatusLayout
                            renderStrategy: Canvas.Cooperative

                            property real lineAnimationProgress: 0
                            NumberAnimation {
                                target: flowCanvas
                                property: "lineAnimationProgress"
                                duration: 700
                                loops: Animation.Infinite
                                from: 2
                                to: 0
                                readonly property bool isMobile: Qt.platform.os === "android" || Qt.platform.os === "ios"
                                running: flowCanvas.visible && (!isMobile || Qt.application.state === Qt.ApplicationActive)
                            }
                            onLineAnimationProgressChanged: requestPaint()

                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.save();

                                ctx.strokeStyle = Style.colors.components_Dashboard_Flow;
                                ctx.setLineDash([0.001, 2]);
                                ctx.lineCap = "round";

                                const powerThreshold = 30;
                                if (Math.abs(dataProvider.flowSolarToBattery) > powerThreshold &&
                                        liveStatusPVCard.visible &&
                                        liveStatusBatteryCard.visible) {
                                    const startX = liveStatusPVCard.x + liveStatusPVCard.width / 2;
                                    const startY = liveStatusPVCard.y + liveStatusPVCard.height - 10;
                                    const endX = liveStatusBatteryCard.x + liveStatusBatteryCard.width / 2;
                                    const endY = liveStatusBatteryCard.y + 10;
                                    drawLine(ctx, startX, startY, endX, endY, dataProvider.flowSolarToBattery);
                                }
                                if (Math.abs(dataProvider.flowSolarToConsumers) > powerThreshold &&
                                        liveStatusPVCard.visible) {
                                    const startX = liveStatusPVCard.x + liveStatusPVCard.width - 10;
                                    const startY = liveStatusPVCard.y + liveStatusPVCard.height - 10;
                                    const endX = liveStatusConsumptionCard.x + 10;
                                    const endY = liveStatusConsumptionCard.y + 10;
                                    drawLine(ctx, startX, startY, endX, endY, dataProvider.flowSolarToConsumers);
                                }
                                if (Math.abs(dataProvider.flowSolarToGrid) > powerThreshold &&
                                        liveStatusPVCard.visible) {
                                    const startX = liveStatusPVCard.x + liveStatusPVCard.width - 10;
                                    const startY = liveStatusPVCard.y + liveStatusPVCard.height /2;
                                    const endX = liveStatusGridCard.x + 10;
                                    const endY = liveStatusGridCard.y + liveStatusGridCard.height / 2;
                                    drawLine(ctx, startX, startY, endX, endY, dataProvider.flowSolarToGrid);
                                }
                                if (Math.abs(dataProvider.flowBatteryToConsumers) > powerThreshold &&
                                        liveStatusBatteryCard.visible) {
                                    const startX = liveStatusBatteryCard.x + liveStatusBatteryCard.width - 10;
                                    const startY = liveStatusBatteryCard.y + liveStatusBatteryCard.height / 2;
                                    const endX = liveStatusConsumptionCard.x + 10;
                                    const endY = liveStatusConsumptionCard.y + liveStatusConsumptionCard.height / 2;
                                    drawLine(ctx, startX, startY, endX, endY, dataProvider.flowBatteryToConsumers);
                                }
                                if (Math.abs(dataProvider.flowGridToBattery) > powerThreshold &&
                                        liveStatusBatteryCard.visible) {
                                    const startX = liveStatusGridCard.x + 10;
                                    const startY = liveStatusGridCard.y + liveStatusGridCard.height - 10;
                                    const endX = liveStatusBatteryCard.x + liveStatusBatteryCard.width - 10;
                                    const endY = liveStatusBatteryCard.y + 10;
                                    drawLine(ctx, startX, startY, endX, endY, dataProvider.flowGridToBattery);
                                }
                                if (Math.abs(dataProvider.flowGridToConsumers) > powerThreshold) {
                                    const startX = liveStatusGridCard.x + liveStatusGridCard.width / 2;
                                    const startY = liveStatusGridCard.y + liveStatusGridCard.height - 10;
                                    const endX = liveStatusConsumptionCard.x + liveStatusConsumptionCard.width / 2;
                                    const endY = liveStatusConsumptionCard.y + 10;
                                    drawLine(ctx, startX, startY, endX, endY, dataProvider.flowGridToConsumers);
                                }
                            }

                            function lineWidth(value) {
                                const valueAbs = Math.abs(value);
                                const minValue = 200;
                                const maxValue = 5000;
                                const minWidth = 3;
                                const maxWidth = 12;
                                if (valueAbs < minValue) {
                                    return minWidth;
                                } else if (valueAbs < maxValue) {
                                    return minWidth + (maxWidth - minWidth) * ((valueAbs - minValue) / (maxValue - minValue))
                                } else {
                                    return maxWidth;
                                }
                            }

                            function drawLine(ctx, startX, startY, endX, endY, value) {
                                ctx.beginPath();
                                ctx.lineWidth = lineWidth(value);
                                ctx.lineDashOffset = value >= 0 ? lineAnimationProgress : -lineAnimationProgress;
                                ctx.moveTo(startX, startY);
                                ctx.lineTo(endX, endY);
                                ctx.stroke();
                                ctx.closePath();
                            }
                        }

                        GridLayout {
                            id: liveStatusLayout
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            rowSpacing: 0
                            columnSpacing: 0

                            CoInfoCard {
                                id: liveStatusPVCard
                                Layout.fillWidth: true
                                Layout.row: 0
                                Layout.column: 0
                                visible: producerThings.count > 0
                                text: qsTr("Solar")
                                value: UiUtils.powerDisplayValue(Math.abs(dataProvider.currentPowerProduction))
                                unit: UiUtils.powerDisplayUnit(dataProvider.currentPowerProduction)
                                compactLayout: true
                                icon: Qt.resolvedUrl("qrc:/icons/solar_power.svg")
                                showWarningIndicator: anyInverterLppActive && !showErrorIndicator
                                showErrorIndicator: anyInverterNotConnected
                                onClicked: {
                                    flickableContentYAnimation.setTargetY(invertersGroup.y);
                                    flickableContentYAnimation.start();
                                }
                            }

                            CoInfoCard {
                                id: liveStatusGridCard
                                Layout.fillWidth: true
                                Layout.row: 0
                                Layout.column: 2
                                value: UiUtils.powerDisplayValue(Math.abs(dataProvider.currentPowerRootMeter))
                                unit: UiUtils.powerDisplayUnit(dataProvider.currentPowerRootMeter)
                                text: dataProvider.currentPowerRootMeter < 0 ?
                                          qsTr("Feed-in") :
                                          dataProvider.currentPowerRootMeter > 0 ?
                                              qsTr("Grid import") :
                                              qsTr("Grid")
                                compactLayout: true
                                showWarningIndicator: lpcActive && !showErrorIndicator
                                showErrorIndicator: !ThingUtils.isConnected(root.rootMeter)
                                icon: dataProvider.currentPowerRootMeter < 0 ?
                                          Qt.resolvedUrl("/icons/input_circle.svg") :
                                          Qt.resolvedUrl("/icons/output_circle.svg")
                                onClicked: {
                                    pageStack.push(
                                                "/ui/devicepages/RootMeterDevicePage.qml",
                                                {
                                                    "thing": root.rootMeter,
                                                    "gridSupport": gridSupport
                                                });
                                }
                            }

                            CoInfoCard {
                                id: liveStatusBatteryCard
                                Layout.fillWidth: true
                                Layout.row: 2
                                Layout.column: 0
                                visible: batteryThings.count > 0
                                text: qsTr("Battery")
                                value: UiUtils.powerDisplayValue(Math.abs(dataProvider.currentPowerBatteries))
                                unit: UiUtils.powerDisplayUnit(dataProvider.currentPowerBatteries)
                                secondaryValue: Math.round(dataProvider.totalBatteryLevel)
                                secondaryUnit: "%"
                                compactLayout: true
                                showInfoIndicator: anyTargetSocPvSurplusExceeded && !showWarningIndicator && !showErrorIndicator
                                showWarningIndicator: anyAvoidZeroCompensationActive && !showErrorIndicator
                                showErrorIndicator: anyBatteryNotConnected
                                icon: batteryIconForEnergyFlow(dataProvider.totalBatteryLevel,
                                                               dataProvider.currentPowerBatteries > 0)
                                onClicked: {
                                    flickableContentYAnimation.setTargetY(batteriesGroup.y);
                                    flickableContentYAnimation.start();
                                }
                            }

                            CoInfoCard {
                                id: liveStatusConsumptionCard
                                Layout.fillWidth: true
                                Layout.row: 2
                                Layout.column: 2
                                text: qsTr("Consumption")
                                value: UiUtils.powerDisplayValue(Math.abs(dataProvider.currentPowerTotalConsumption))
                                unit: UiUtils.powerDisplayUnit(dataProvider.currentPowerTotalConsumption)
                                compactLayout: true
                                showInfoIndicator: anyPvSurplusRuntimeExceeded && !showErrorIndicator
                                showErrorIndicator: anyConsumerNotConnected
                                icon: Qt.resolvedUrl("qrc:/icons/electric_bolt.svg")
                                onClicked: {
                                    flickableContentYAnimation.setTargetY(consumptionGroup.y);
                                    flickableContentYAnimation.start();
                                }
                            }

                            Item {
                                id: liveStatusSpacer

                                property int space: Window.width < 390 ? 32 : 64

                                Layout.row: 1
                                Layout.column: 1
                                Layout.preferredWidth: (batteryThings.count > 0 || producerThings.count > 0) ? space : 0
                                Layout.preferredHeight: space
                            }
                        }
                    }

                    CoFrostyCard {
                        Layout.fillWidth: true
                        contentBottomMargin: 16

                        headerText: qsTr("Energy status")

                        CoInfoCardContainer {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            CoInfoCard {
                                Layout.fillWidth: true
                                text: qsTr("Self-sufficiency")
                                value: dataProvider.kpiValid ? dataProvider.selfSufficiencyRate.toFixed(0) : "—"
                                unit: "%"
                                icon: Qt.resolvedUrl("qrc:/icons/house_with_shield.svg")
                                clickable: false
                            }

                            CoInfoCard {
                                Layout.fillWidth: true
                                text: qsTr("Self-consumption")
                                value: dataProvider.kpiValid ? dataProvider.selfConsumptionRate.toFixed(0) : "—"
                                unit: "%"
                                icon: Qt.resolvedUrl("qrc:/icons/attribution.svg")
                                clickable: false
                            }

                            CoInfoCard {
                                Layout.fillWidth: true
                                property Thing thing: dynamicPricingThing
                                readonly property State currentMarketPriceState: thing ? thing.stateByName("currentTotalCost") : null
                                readonly property double currentMarketPrice: currentMarketPriceState ? currentMarketPriceState.value.toFixed(2) : 0
                                visible: dynamicPricingThing ? true : false
                                text: thing ? thing.name : ""
                                unit: "ct/kWh"
                                value: {
                                    let v = currentMarketPrice;
                                    let decimals = 0;
                                    if (Math.abs(v) < 10.0) {
                                        decimals = 2;
                                    } else if (Math.abs(v) < 100.0) {
                                        decimals = 1;
                                    } else {
                                        decimals = 0;
                                    }
                                    return v.toLocaleString(Qt.locale(), 'f', decimals);
                                }
                                icon: Qt.resolvedUrl("/icons/euro.svg")
                                onClicked: {
                                    pageStack.push("/ui/devicepages/PageWraper.qml",
                                                   { "thing": thing });
                                }
                            }
                        }
                    }

                    CoFrostyCard {
                        id: invertersGroup
                        Layout.fillWidth: true
                        contentBottomMargin: 16
                        headerText: qsTr("Inverters")
                        visible: producerThings.count > 0

                        CoInfoCardContainer {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            Repeater {
                                model: producerThings

                                delegate: CoPowerThingInfoCard {
                                    Layout.fillWidth: true
                                    thing: producerThings.get(index)
                                    icon: UiUtils.thingToIcon(thing)
                                    showWarningIndicator: lppActive &&
                                                          (hemsManager.pvConfigurations.getPvConfiguration(thing.id) !== null ?
                                                               hemsManager.pvConfigurations.getPvConfiguration(thing.id).controllableLocalSystem :
                                                               false) &&
                                                          !showErrorIndicator
                                    showErrorIndicator: !ThingUtils.isConnected(thing)
                                    onClicked: {
                                        pageStack.push(
                                                    "/ui/devicepages/InverterDevicePage.qml",
                                                    {
                                                        "thing": thing,
                                                        "showLppWarning": showWarningIndicator,
                                                        "gridSupport": gridSupport
                                                    });
                                    }
                                }
                            }
                        }
                    }

                    CoFrostyCard {
                        id: batteriesGroup
                        Layout.fillWidth: true
                        contentBottomMargin: 16
                        headerText: qsTr("Batteries")
                        visible: batteryThings.count > 0

                        CoInfoCardContainer {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            Repeater {
                                model: batteryThings

                                delegate: CoBatteryInfoCard {
                                    Layout.fillWidth: true

                                    property Thing battery: batteryThings.get(index)
                                    readonly property State currentPowerState: battery ? battery.stateByName("currentPower") : null
                                    readonly property double currentPower: currentPowerState ? Number(currentPowerState.value) : 0
                                    readonly property State socState: battery ? battery.stateByName("batteryLevel") : null
                                    readonly property double soc: socState ? Number(socState.value) : 0

                                    icon: UiUtils.thingToIcon(battery)
                                    text: battery.name
                                    powerValue: currentPower
                                    socValue: Math.round(soc)
                                    showInfoIndicator: ThingUtils.targetSocPvSurplusExceeded(battery,
                                                                                             hemsManager.batteryConfigurations.getBatteryConfiguration(battery.id)) &&
                                                       !showWarningIndicator &&
                                                       !showErrorIndicator
                                    showWarningIndicator: avoidZeroCompensationActive(battery) && !showErrorIndicator
                                    showErrorIndicator: !ThingUtils.isConnected(battery)
                                    onClicked: {
                                        pageStack.push("/ui/optimization/BatteryConfigView.qml", { "thing": battery });
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        id: consumptionGroup
                        Layout.fillWidth: true
                        spacing: Style.margins

                        CoFrostyCard {
                            id: heatingGroup
                            Layout.fillWidth: true
                            contentBottomMargin: 16
                            headerText: qsTr("Heating")
                            visible: heatingThings.count > 0

                            CoInfoCardContainer {
                                anchors.left: parent.left
                                anchors.right: parent.right

                                Repeater {
                                    model: heatingThings

                                    delegate: CoPowerThingInfoCard {
                                        Layout.fillWidth: true
                                        thing: heatingThings.get(index)
                                        icon: UiUtils.thingToIcon(thing)
                                        showInfoIndicator: hemsManager.conEMSState.runtimeExceededThings.includes(thing.id) &&
                                                           !showErrorIndicator
                                        showErrorIndicator: !ThingUtils.isConnected(thing)
                                        onClicked: {
                                            if (thing.thingClass.interfaces.indexOf("heatpump") >= 0) {
                                                pageStack.push(
                                                            "/ui/optimization/HeatingConfigView.qml",
                                                            {
                                                                "thing": thing
                                                            });
                                            } else if (thing.thingClass.interfaces.indexOf("heatingrod") >= 0) {
                                                pageStack.push(
                                                            "/ui/devicepages/HeatingElementDevicePage.qml",
                                                            {
                                                                "thing": thing
                                                            });
                                            } else {
                                                console.error("Neither heatpump nor heatingrod interface found in thing interfaces:",
                                                              thing.thingClass.interfaces);
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        CoFrostyCard {
                            Layout.fillWidth: true
                            contentBottomMargin: 16
                            headerText: qsTr("Mobility")
                            visible: evChargerThings.count > 0

                            CoInfoCardContainer {
                                anchors.left: parent.left
                                anchors.right: parent.right

                                Repeater {
                                    model: evChargerThings

                                    delegate: CoPowerThingInfoCard {
                                        Layout.fillWidth: true
                                        thing: evChargerThings.get(index)
                                        icon: UiUtils.thingToIcon(thing)
                                        showErrorIndicator: !ThingUtils.isConnected(thing)
                                        onClicked: {
                                            // Check if these states are provided by the thing
                                            let pluggedIn = thing.stateByName("pluggedIn");
                                            let maxChargingCurrent = thing.stateByName("maxChargingCurrent");
                                            let phaseCount = thing.stateByName("phaseCount");

                                            // If yes, you can use the optimization else you have to
                                            // resort to the EvChargerThingPage
                                            if (pluggedIn !== null &&
                                                    maxChargingCurrent !== null &&
                                                    phaseCount !== null) {
                                                let carThingId =
                                                    hemsManager.chargingConfigurations.getChargingConfiguration(thing.id).carThingId;
                                                pageStack.push(
                                                            "../optimization/ChargingConfigView.qml",
                                                            {
                                                                "thing": thing,
                                                                "carThing": electricVehicleThings.getThing(carThingId)
                                                            });
                                            } else {
                                                pageStack.push(
                                                            "/ui/devicepages/EvChargerThingPage.qml",
                                                            {
                                                                "thing": thing
                                                            });
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        CoFrostyCard {
                            Layout.fillWidth: true
                            contentBottomMargin: 16
                            headerText: qsTr("Other consumers")

                            CoInfoCardContainer {
                                anchors.left: parent.left
                                anchors.right: parent.right

                                Repeater {
                                    model: otherConsumerThings

                                    delegate: CoPowerThingInfoCard {
                                        Layout.fillWidth: true
                                        thing: otherConsumerThings.get(index)
                                        icon: UiUtils.thingToIcon(thing)
                                        showInfoIndicator: hemsManager.conEMSState.runtimeExceededThings.includes(thing.id) &&
                                                           !showErrorIndicator
                                        showErrorIndicator: !ThingUtils.isConnected(thing)
                                        visible: {
                                            if (thing.thingClass.interfaces.indexOf("hideable") >= 0) {
                                                var hiddenState = thing.stateByName("hidden")
                                                return !hiddenState || hiddenState.value !== true
                                            }
                                            return true
                                        }
                                        onClicked: {
                                            if (thing.thingClass.interfaces.indexOf("powersocket") >= 0) {
                                                pageStack.push(
                                                            "/ui/devicepages/SwitchableConsumerDevicePage.qml",
                                                            {
                                                                "thing": thing
                                                            });
                                            } else {
                                                pageStack.push(
                                                            "/ui/devicepages/SimpleConsumerDevicePage.qml",
                                                            {
                                                                "thing": thing
                                                            });
                                            }
                                        }
                                    }
                                }

                                CoInfoCard {
                                    Layout.fillWidth: true
                                    text: qsTr("Unallocated consumption")
                                    value: UiUtils.powerDisplayValue(Math.abs(dataProvider.currentPowerUnallocatedConsumption))
                                    unit: UiUtils.powerDisplayUnit(dataProvider.currentPowerUnallocatedConsumption)
                                    icon: Qt.resolvedUrl("qrc:/icons/interests.svg")
                                    clickable: false
                                }
                            }
                        }
                    }

                    Item {
                        id: spacerBottomMargin
                        height: root.bottomMargin
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    UnconfiguredHemsView {
        id: unconfiguredHemsView
        anchors {
            left: parent.left
            right: parent.right
            margins: app.margins
        }
        anchors.verticalCenter: parent.verticalCenter
        visible: !engine.thingManager.fetchingData && energyMetersProxy.count === 0
    }
}
