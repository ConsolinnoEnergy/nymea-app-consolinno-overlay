// #TODO copyright notice

import QtQuick 2.15
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.3
import Nymea 1.0
import NymeaApp.Utils 1.0
import Qt.labs.settings 1.1
import QtGraphicalEffects 1.15

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
            if (Configuration.batteryIcon !== ""){ // #TODO check if whitelabel customers really don't want the SoC represented by the battery icon
                return Qt.resolvedUrl("qrc:/ui/images/" + Configuration.batteryIcon);
            } else {
                let batteryLevelState = thing.stateByName("batteryLevel");
                if (batteryLevelState) {
                    let batteryLevel = batteryLevelState.value;
                    return batteryIconByLevel(batteryLevel);
                } else {
                    return Qt.resolvedUrl("qrc:/icons/battery/battery-060.svg");
                }
            }
        }

        for (var i = 0; i < ifaces.length; i++) {
            let iface = ifaces[i];
            let icon = ""

            switch (iface) {
            case "pvsurplusheatpump":
            case "smartgridheatpump":
            case "heatpump":
                if (Configuration.heatpumpIcon !== ""){
                    icon = "qrc:/ui/images/" + Configuration.heatpumpIcon;
                } else {
                    icon = "qrc:/icons/heatpump.svg";
                }
                break;
            case "heatingrod":
                if (Configuration.heatingRodIcon !== ""){
                    icon = "qrc:/ui/images/" + Configuration.heatingRodIcon;
                } else {
                    icon = "qrc:/icons/heating_rod.svg";
                }
                break;
            case "energystorage":
                if (Configuration.batteryIcon !== ""){
                    icon = "qrc:/ui/images/" + Configuration.batteryIcon;
                } else {
                    icon = "qrc:/icons/battery/battery-060.svg";
                }
                break;
            case "evcharger":
                if (Configuration.evchargerIcon !== ""){
                    icon = "qrc:/ui/images/" + Configuration.evchargerIcon;
                } else {
                    icon = "qrc:/icons/ev-charger.svg";
                }
                break;
            case "solarinverter":
                if (Configuration.inverterIcon !== ""){
                    icon = "qrc:/ui/images/" + Configuration.inverterIcon;
                } else {
                    icon = "qrc:/icons/weathericons/weather-clear-day.svg";
                }
                break;
            default:
                icon = app.interfaceToIcon(iface)
            }

            if (icon !== "") {
                return Qt.resolvedUrl(icon);
            }
        }
        console.warn("thingToIcon: unable to determine icon for thing",
                     thing.name);
        return Qt.resolvedUrl("qrc:/icons/select-none.svg");
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

    EnergyManager {
        id: energyManager
        engine: _engine
    }

    HemsManager {
        id: hemsManager
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

    Settings {
        id: shownPopupsSetting
        category: "shownPopups"
        property var shown: []
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
        topMargin: root.topMargin
        bottomMargin: root.bottomMargin

        NumberAnimation {
            id: flickableContentYAnimation
            target: flickable
            property: "contentY"
            duration: 700
            easing.type: Easing.InOutQuart
            onFinished: {
                flickable.returnToBounds();
            }
        }

        Item {
            anchors.fill: parent

            Rectangle {
                id: background
                anchors.fill: parent
                color: "#FFFFFF" // #TODO color from new style

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop{ position: 0.0; color: "#80BDD786" } // #TODO color from new style
                        GradientStop{ position: 1.0; color: "#8083BC32" } // #TODO color from new style
                    }
                }
            }

            Item {
                id: dashboardRoot
                anchors.fill: parent
                anchors.margins: 16 // #TODO use value from new style

                implicitHeight: dashboardLayout.implicitHeight + anchors.margins * 2

                ColumnLayout {
                    id: dashboardLayout
                    anchors.fill: parent
                    spacing: 16 // #TODO use value from new style

                    CoNotification {
                        id: incompatibilityWarning
                        Layout.fillWidth: true
                        visible: !hemsVersionOk()
                        type: CoNotification.Type.Warning
                        title: qsTr("Pending software update")
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
                                running: flowCanvas.visible
                                // #TODO use this?
//                                         && Qt.application.state === Qt.ApplicationActive
                            }
                            onLineAnimationProgressChanged: requestPaint()

                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.save();

                                ctx.strokeStyle = Style.colors.components_Dashboard_Flow;
                                ctx.setLineDash([0.001, 2]);
                                ctx.lineCap = "round";

                                if (dataProvider.flowSolarToBattery !== 0) {
                                    const startX = liveStatusPVCard.x + liveStatusPVCard.width / 2;
                                    const startY = liveStatusPVCard.y + liveStatusPVCard.height - 10;
                                    const endX = liveStatusBatteryCard.x + liveStatusBatteryCard.width / 2;
                                    const endY = liveStatusBatteryCard.y + 10;
                                    drawLine(ctx, startX, startY, endX, endY, dataProvider.flowSolarToBattery);
                                }
                                if (dataProvider.flowSolarToConsumers !== 0) {
                                    const startX = liveStatusPVCard.x + liveStatusPVCard.width - 10;
                                    const startY = liveStatusPVCard.y + liveStatusPVCard.height * 3 / 5;
                                    const endX = liveStatusConsumptionCard.x + 20;
                                    const endY = liveStatusConsumptionCard.y + 10;
                                    drawLine(ctx, startX, startY, endX, endY, dataProvider.flowSolarToConsumers);
                                }
                                if (dataProvider.flowSolarToGrid !== 0) {
                                    const startX = liveStatusPVCard.x + liveStatusPVCard.width - 10;
                                    const startY = liveStatusPVCard.y + liveStatusPVCard.height * 2 / 5;
                                    const endX = liveStatusGridCard.x + 10;
                                    const endY = liveStatusGridCard.y + liveStatusGridCard.height * 2 / 5;
                                    drawLine(ctx, startX, startY, endX, endY, dataProvider.flowSolarToGrid);
                                }
                                if (dataProvider.flowBatteryToConsumers !== 0) {
                                    const startX = liveStatusBatteryCard.x + liveStatusBatteryCard.width - 10;
                                    const startY = liveStatusBatteryCard.y + liveStatusBatteryCard.height * 3 / 5;
                                    const endX = liveStatusConsumptionCard.x + 10;
                                    const endY = liveStatusConsumptionCard.y + liveStatusConsumptionCard.height * 3 / 5;
                                    drawLine(ctx, startX, startY, endX, endY, dataProvider.flowBatteryToConsumers);
                                }
                                if (dataProvider.flowGridToBattery !== 0) {
                                    const startX = liveStatusGridCard.x + 10;
                                    const startY = liveStatusGridCard.y + liveStatusGridCard.height * 3 / 5;
                                    const endX = liveStatusBatteryCard.x + liveStatusBatteryCard.width - 20;
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
                            rowSpacing: 0
                            columnSpacing: 0

                            CoInfoCard {
                                id: liveStatusPVCard
                                Layout.fillWidth: true
                                Layout.row: 0
                                Layout.column: 0
                                text: qsTr("Solar") // #TODO English name
                                value: Math.abs(dataProvider.currentPowerProduction)
                                unit: "W"
                                compactLayout: true
                                icon: Qt.resolvedUrl("qrc:/icons/weathericons/weather-clear-day.svg") // #TODO icon
                                showWarningIndicator: anyInverterLppActive
                                onClicked: {
                                    flickableContentYAnimation.to = invertersGroup.y - 50;
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
                                icon: {
                                    if (Configuration.gridIcon !== "") {
                                        return Qt.resolvedUrl("/ui/images/" + Configuration.gridIcon)
                                    } else {
                                        return Qt.resolvedUrl("/icons/grid.svg")
                                    }
                                }
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
                                text: qsTr("Battery") // #TODO English name
                                value: Math.abs(dataProvider.currentPowerBatteries)
                                unit: "W"
                                compactLayout: true
                                showWarningIndicator: anyAvoidZeroCompensationActive
                                icon: {
                                    if (Configuration.batteryIcon !== ""){
                                        return Qt.resolvedUrl("qrc:/ui/images/" + Configuration.batteryIcon);
                                    } else {
                                        return batteryIconByLevel(dataProvider.totalBatteryLevel);
                                    }
                                }
                                onClicked: {
                                    flickableContentYAnimation.to = batteriesGroup.y - 50;
                                    flickableContentYAnimation.start();
                                }
                            }

                            CoInfoCard {
                                id: liveStatusConsumptionCard
                                Layout.fillWidth: true
                                Layout.row: 2
                                Layout.column: 2
                                text: qsTr("Consumption") // #TODO English name
                                value: Math.abs(dataProvider.currentPowerTotalConsumption)
                                unit: "W"
                                compactLayout: true
                                icon: Qt.resolvedUrl("qrc:/icons/energy.svg") // #TODO icon
                                onClicked: {
                                    flickableContentYAnimation.to = heatingGroup.y - 50;
                                    flickableContentYAnimation.start();
                                }
                            }

                            Item {
                                id: liveStatusSpacer
                                Layout.row: 1
                                Layout.column: 1
                                width: 64
                                height: 64
                            }
                        }
                    }

                    CoFrostyCard {
                        Layout.fillWidth: true

                        headerText: qsTr("Energy status")

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            spacing: 16 // #TODO use value from new style

                            CoInfoCard {
                                Layout.fillWidth: true
                                text: qsTr("Self-sufficiency")
                                value: dataProvider.kpiValid ? dataProvider.selfSufficiencyRate.toFixed(0) : "—"
                                unit: "%"
                                icon: Qt.resolvedUrl("qrc:/icons/energy.svg") // #TODO icon
                                clickable: false
                                showWarningIndicator: !dataProvider.kpiValid
                            }

                            CoInfoCard {
                                Layout.fillWidth: true
                                text: qsTr("Self-consumption")
                                value: dataProvider.kpiValid ? dataProvider.selfConsumptionRate.toFixed(0) : "—"
                                unit: "%"
                                icon: Qt.resolvedUrl("qrc:/icons/energy.svg") // #TODO icon
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
                                icon: {
                                    if (Configuration.energyIcon !== "") {
                                        return Qt.resolvedUrl("/ui/images/" + Configuration.energyIcon)
                                    } else {
                                        return Qt.resolvedUrl("/icons/energy.svg")
                                    }
                                }
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

                        headerText: qsTr("Inverters")
                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            spacing: 16 // #TODO use value from new style

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

                        headerText: qsTr("Batteries")
                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            spacing: 16 // #TODO use value from new style

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
                                                           "hemsManager": hemsManager,
                                                           "thing": thing,
                                                           "isBatteryView": true
                                                       });
                                    }
                                }
                            }
                        }
                    }

                    CoFrostyCard {
                        id: heatingGroup
                        Layout.fillWidth: true

                        headerText: qsTr("Heating")
                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            spacing: 16 // #TODO use value from new style

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
                                                            "hemsManager": hemsManager,
                                                            "thing": thing
                                                        });
                                        } else if (thing.thingClass.interfaces.indexOf("heatingrod") >= 0) {
                                            pageStack.push(
                                                        "/ui/devicepages/HeatingElementDevicePage.qml",
                                                        {
                                                            "hemsManager": hemsManager,
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

                        headerText: qsTr("Mobility")
                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            spacing: 16 // #TODO use value from new style

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
                                                            "hemsManager": hemsManager,
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

                        headerText: qsTr("Other consumers")
                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            spacing: 16 // #TODO use value from new style

                            Repeater {
                                model: otherConsumerThings

                                delegate: CoPowerThingInfoCard {
                                    Layout.fillWidth: true
                                    thing: otherConsumerThings.get(index)
                                    icon: thingToIcon(thing)
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
                                text: qsTr("Non-controllable") // #TODO name
                                value: Math.abs(dataProvider.currentPowerUnmeteredConsumption)
                                unit: "W"
                                icon: Qt.resolvedUrl("qrc:/icons/select-none.svg") // #TODO icon
                                clickable: false
                            }
                        }
                    }
                }
            }
        }
    }
}