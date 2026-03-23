import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtCharts
import Nymea 1.0
import NymeaApp.Utils 1.0
import Qt5Compat.GraphicalEffects

import "../components"
import "../delegates"

MainViewBase {
    id: root

    contentY: flickable.contentY + topMargin

    headerButtons: []

    function batteryIconByLevel(batteryLevel) {
        let batteryLevelForIcon = NymeaUtils.pad(Math.round(batteryLevel / 10) * 10, 3);
        return Qt.resolvedUrl("qrc:/icons/battery/battery-" + batteryLevelForIcon + ".svg");
    }

    function thingToIcon(thing) {
        let ifaces = thing.thingClass.interfaces;
        if (ifaces.indexOf("battery") >= 0) {
            let batteryLevelState = thing.stateByName("batteryLevel");
            if (batteryLevelState) {
                let batteryLevel = batteryLevelState.value;
                return batteryIconByLevel(batteryLevel);
            } else {
                return Qt.resolvedUrl("qrc:/icons/battery/battery-060.svg");
            }
        }
        return app.interfacesToIcon(ifaces);
    }

    // #TODO next 2 functions copied from old ConsolinnoView. Oli wanted to extract this into so utils file.
    // Use from there when that is done.
    function compareSemanticVersions(version1, version2) {
        // Returns 0 if version1 == version2
        // Returns 1 if version1 > version2
        // Returns -1 if version1 < version2

        var v1 = version1.split('.').map(function(part) { return parseInt(part); });
        var v2 = version2.split('.').map(function(part) { return parseInt(part); });

        for (var i = 0; i < Math.max(v1.length, v2.length); i++) {
            var num1 = i < v1.length ? v1[i] : 0;
            var num2 = i < v2.length ? v2[i] : 0;

            if (num1 < num2) {
                return -1; // version1 is lower
            } else if (num1 > num2) {
                return 1; // version1 is higher
            }
        }

        return 0; // versions are equal
    }

    function hemsVersionOk(){
        var minSysVersion = Configuration.minSysVersion
        // Checks if System version is less or equal to minSysVersion
        if ([-1].includes(compareSemanticVersions(engine.jsonRpcClient.experiences.Hems, minSysVersion)))
        {
            return false
        }
        return true
    }

    // #TODO move to some utils file
    function convertToKw(numberW){
        return (+(Math.round((numberW / 1000) * 100 ) / 100)).toLocaleString()
    }

    function avoidZeroCompensationActive(battery) {
        if (!battery) { return false; }
        if (battery.thingClass.interfaces.indexOf("controllablebattery") === 0) { return false; }
        const batteryConfig = hemsManager.batteryConfigurations.getBatteryConfiguration(battery.id);
        return batteryConfig.avoidZeroFeedInActive && batteryConfig.avoidZeroFeedInEnabled;
    }

    function adjustAlpha(color, alphaFactor) {
        let newColor = color;
        newColor.a *= alphaFactor;
        return newColor;
    }

    EnergyManager {
        id: energyManager
        engine: _engine
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
        property var shown: []
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
        for (var i = 0; i < producerThings.count; ++i) {
            let inverter = producerThings.get(i);
            let config = hemsManager.pvConfigurations.getPvConfiguration(inverter.id);
            if (config !== null && config.controllableLocalSystem) {
                return true;
            }
        }
        return false;
    }
    property bool anyAvoidZeroCompensationActive: {
        for (var i = 0; i < batteryThings.count; ++i) {
            let battery = batteryThings.get(i);
            if (avoidZeroCompensationActive(battery)) {
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
                            color: adjustAlpha(baseColor, 0.5)
                            property color baseColor: Style.colors.components_Dashboard_Background_gradient_top
                        }
                        GradientStop{
                            position: 1.0
                            color: adjustAlpha(baseColor, 0.5)
                            property color baseColor: Style.colors.components_Dashboard_Background_gradient_bottom
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

                    Item {
                        id: spacerTopMargin
                        height: root.topMargin
                        Layout.fillWidth: true
                    }

                    CoNotification {
                        id: incompatibilityWarning
                        Layout.fillWidth: true
                        visible: !hemsVersionOk()
                        type: CoNotification.Type.Warning
                        collapsible: true
                        title: qsTr("Pending software update")
                        collapsed: false
                        message: qsTr('
                            <p>Your %3 app has been updated to version <strong>%1</strong> and is more up-to-date than the firmware (<strong>%2</strong>) on your %5 device.</p>
                            <p>Your %5 device will be updated during the course of the day. Until the update is complete, the new functions may be temporarily unavailable.</p>
                            <p>If this message is still displayed, please contact our service team.</p>
                            <ul>
                                %6
                                <li>Email: <a href=\'mailto:%4\'>%4</a></li>
                            </ul>
                            <p>Best regards</p>
                            <p>Your %3 Team</p>')
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
                        message: qsTr("The feed-in is <b>limited temporarily</b> to <b>%1 kW</b> due to a control command from the grid operator.").arg(convertToKw(lppPowerLimit))
                    }

                    CoNotification {
                        id: lpcWarning
                        Layout.fillWidth: true
                        visible: lpcActive
                        type: CoNotification.Type.Warning
                        title: qsTr("Grid-supportive control")
                        message: qsTr("Due to a control order from the network operator, the total power of controllable devices is <b>temporarily limited</b> to <b>%1 kW.</b> If, for example, you are currently charging your electric car, the charging process may not be carried out at the usual power level.").arg(convertToKw(lpcPowerLimit))
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
                        visible: shownPopupsSetting.shown.indexOf(appVersion) === -1
                        type: CoNotification.Type.Information
                        dismissable: true
                        title: qsTr("The app has been updated.")
                        message: qsTr('CHANGENOTIFICATION_PLACEHOLDER')
                        messageTextFormat: Text.RichText

                        onDismiss: {
                            console.debug("shonwPopupsSetting.shown: ", shownPopupsSetting.shown, appVersion)
                            var shownPopups = shownPopupsSetting.shown
                            shownPopups.push(appVersion)
                            shownPopupsSetting.shown = shownPopups
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
                                duration: 1000
                                loops: Animation.Infinite
                                from: 2
                                to: 0
                                running: flowCanvas.visible && Qt.application.state === Qt.ApplicationActive
                            }
                            onLineAnimationProgressChanged: requestPaint()

                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.save();

                                ctx.strokeStyle = Style.colors.components_Dashboard_Flow;
                                ctx.setLineDash([0.001, 2]);
                                ctx.lineCap = "round";

                                if (dataProvider.flowSolarToBattery !== 0 &&
                                        liveStatusPVCard.visible &&
                                        liveStatusBatteryCard.visible) {
                                    const startX = liveStatusPVCard.x + liveStatusPVCard.width / 2;
                                    const startY = liveStatusPVCard.y + liveStatusPVCard.height - 10;
                                    const endX = liveStatusBatteryCard.x + liveStatusBatteryCard.width / 2;
                                    const endY = liveStatusBatteryCard.y + 10;
                                    drawLine(ctx, startX, startY, endX, endY, dataProvider.flowSolarToBattery);
                                }
                                if (dataProvider.flowSolarToConsumers !== 0 &&
                                        liveStatusPVCard.visible) {
                                    const startX = liveStatusPVCard.x + liveStatusPVCard.width - 10;
                                    const startY = liveStatusPVCard.y + liveStatusPVCard.height * 3 / 5;
                                    const endX = liveStatusConsumptionCard.x + 30;
                                    const endY = liveStatusConsumptionCard.y + 10;
                                    drawLine(ctx, startX, startY, endX, endY, dataProvider.flowSolarToConsumers);
                                }
                                if (dataProvider.flowSolarToGrid !== 0 &&
                                        liveStatusPVCard.visible) {
                                    const startX = liveStatusPVCard.x + liveStatusPVCard.width - 10;
                                    const startY = liveStatusPVCard.y + liveStatusPVCard.height /2;
                                    const endX = liveStatusGridCard.x + 10;
                                    const endY = liveStatusGridCard.y + liveStatusGridCard.height / 2;
                                    drawLine(ctx, startX, startY, endX, endY, dataProvider.flowSolarToGrid);
                                }
                                if (dataProvider.flowBatteryToConsumers !== 0 &&
                                        liveStatusBatteryCard.visible) {
                                    const startX = liveStatusBatteryCard.x + liveStatusBatteryCard.width - 10;
                                    const startY = liveStatusBatteryCard.y + liveStatusBatteryCard.height / 2;
                                    const endX = liveStatusConsumptionCard.x + 10;
                                    const endY = liveStatusConsumptionCard.y + liveStatusConsumptionCard.height / 2;
                                    drawLine(ctx, startX, startY, endX, endY, dataProvider.flowBatteryToConsumers);
                                }
                                if (dataProvider.flowGridToBattery !== 0 &&
                                        liveStatusBatteryCard.visible) {
                                    const startX = liveStatusGridCard.x + 10;
                                    const startY = liveStatusGridCard.y + liveStatusGridCard.height * 3 / 5;
                                    const endX = liveStatusBatteryCard.x + liveStatusBatteryCard.width - 30;
                                    const endY = liveStatusBatteryCard.y + 10;
                                    drawLine(ctx, startX, startY, endX, endY, dataProvider.flowGridToBattery);
                                }
                                if (dataProvider.flowGridToConsumers !== 0) {
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
                                const minWidth = 2;
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
                                value: Math.abs(dataProvider.currentPowerProduction)
                                unit: "W"
                                compactLayout: true
                                icon: Qt.resolvedUrl("qrc:/icons/solar_power.svg")
                                showWarningIndicator: anyInverterLppActive
                                onClicked: {
                                    flickableContentYAnimation.setTargetY(invertersGroup.y);
                                    flickableContentYAnimation.start();
                                }
                            }

                            CoPowerThingInfoCard {
                                id: liveStatusGridCard
                                Layout.fillWidth: true
                                Layout.row: 0
                                Layout.column: 2
                                text: qsTr("Grid")
                                thing: rootMeter
                                compactLayout: true
                                showWarningIndicator: lpcActive
                                icon: Qt.resolvedUrl("/icons/input_circle.svg")
                                onClicked: {
                                    console.info("Clicked grid card");
                                    pageStack.push(
                                                "/ui/devicepages/GenericSmartDeviceMeterPage.qml",
                                                {
                                                    "thing": thing,
                                                    "isRootmeter": true,
                                                    "isNotify": lpcActive,
                                                    "gridSupportThing": gridSupport
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
                                value: Math.abs(dataProvider.currentPowerBatteries)
                                unit: "W"
                                compactLayout: true
                                showWarningIndicator: anyAvoidZeroCompensationActive
                                icon: batteryIconByLevel(dataProvider.totalBatteryLevel)
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
                                value: Math.abs(dataProvider.currentPowerTotalConsumption)
                                unit: "W"
                                compactLayout: true
                                icon: Qt.resolvedUrl("qrc:/icons/electric_bolt.svg")
                                onClicked: {
                                    flickableContentYAnimation.setTargetY(consumptionGroup.y);
                                    flickableContentYAnimation.start();
                                }
                            }

                            Item {
                                id: liveStatusSpacer
                                Layout.row: 1
                                Layout.column: 1
                                Layout.preferredWidth: (batteryThings.count > 0 || producerThings.count > 0) ? 64 : 0
                                height: 64
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
                                    console.info("Clicked dynamic tariff");
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
                                    icon: thingToIcon(thing)
                                    showWarningIndicator: lppActive &&
                                                          (hemsManager.pvConfigurations.getPvConfiguration(thing.id) !== null ?
                                                               hemsManager.pvConfigurations.getPvConfiguration(thing.id).controllableLocalSystem :
                                                               false)
                                    onClicked: {
                                        console.info("Clicked inverter:", thing.name);
                                        pageStack.push(
                                                    "/ui/devicepages/GenericSmartDeviceMeterPage.qml",
                                                    {
                                                        "thing": thing,
                                                        "isNotify": showWarningIndicator,
                                                        "gridSupportThing": gridSupport
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

                                delegate: CoPowerThingInfoCard {
                                    Layout.fillWidth: true
                                    thing: batteryThings.get(index)
                                    icon: thingToIcon(thing)
                                    showWarningIndicator: avoidZeroCompensationActive(thing)
                                    onClicked: {
                                        console.info("Clicked battery:", thing.name);
                                        let batteryView = thing.thingClass.interfaces.indexOf("controllablebattery") >= 0 ?
                                                "/ui/optimization/BatteryConfigView.qml" :
                                                "/ui/devicepages/GenericSmartDeviceMeterPage.qml";
                                        pageStack.push(batteryView,
                                                       {
                                                           "thing": thing,
                                                           "isBatteryView": true
                                                       });
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
                                        icon: thingToIcon(thing)
                                        onClicked: {
                                            console.info("Clicked heating thing:", thing.name);
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
                                                console.warn("Neither heatpump nor heatingrod interface found in thing interfaces:",
                                                             thing.thingClass.interfaces);
                                                pageStack.push(
                                                            "/ui/devicepages/GenericSmartDeviceMeterPage.qml",
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
                                        icon: thingToIcon(thing)
                                        onClicked: {
                                            console.info("Clicked EV charger thing:", thing.name);
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
                                        icon: thingToIcon(thing)
                                        visible: {
                                            if (thing.thingClass.interfaces.indexOf("hideable") >= 0) {
                                                var hiddenState = thing.stateByName("hidden")
                                                return !hiddenState || hiddenState.value !== true
                                            }
                                            return true
                                        }
                                        onClicked: {
                                            console.info("Clicked thing:", thing.name);
                                            pageStack.push(
                                                        "/ui/devicepages/GenericSmartDeviceMeterPage.qml",
                                                        {
                                                            "thing": thing
                                                        });
                                        }
                                    }
                                }

                                CoInfoCard {
                                    Layout.fillWidth: true
                                    text: qsTr("Unallocated consumption")
                                    value: Math.abs(dataProvider.currentPowerUnallocatedConsumption)
                                    unit: "W"
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
