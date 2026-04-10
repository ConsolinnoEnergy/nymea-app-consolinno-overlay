import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml
import Qt5Compat.GraphicalEffects
import Nymea 1.0
import NymeaApp.Utils 1.0
import QtCharts

import "qrc:/ui/components"

import "../components"
import "../delegates"
import "../devicepages"
import "../utils/DynPricingUtils.js" as DynPricingUtils

GenericConfigPage {
    id: root

    property ChargingConfiguration chargingConfiguration: hemsManager.chargingConfigurations.getChargingConfiguration(thing.id)
    property ChargingSessionConfiguration chargingSessionConfiguration: hemsManager.chargingSessionConfigurations.getChargingSessionConfiguration(thing.id)
    property UserConfiguration userconfig: hemsManager.userConfigurations.getUserConfiguration("528b3820-1b6d-4f37-aea7-a99d21d42e72")
    property Thing carThing
    property Thing thing
    property var pageSelectedCar: carThing ? carThing.name : qsTr("no car selected")
    property bool initializing: false
    property int currentValue : 0
    property double thresholdPrice: 0

    property double currentPrice: 0
    property double lowestPrice: 0
    property double highestPrice: 0
    property var prices: ({})

    enum ChargingMode {
        NO_OPTIMIZATION = 0,
        PV_OPTIMIZED = 1,
        PV_EXCESS = 2,
        SIMPLE_PV_EXCESS = 3,
        DYN_PRICING = 4,
        TIME_CONTROLLED = 5
    }

    property int no_optimization: ChargingConfigView.ChargingMode.NO_OPTIMIZATION
    property int pv_optimized: ChargingConfigView.ChargingMode.PV_OPTIMIZED
    property int pv_excess: ChargingConfigView.ChargingMode.PV_EXCESS
    property int simple_pv_excess: ChargingConfigView.ChargingMode.SIMPLE_PV_EXCESS
    property int dyn_pricing: ChargingConfigView.ChargingMode.DYN_PRICING
    property int time_controlled: ChargingConfigView.ChargingMode.TIME_CONTROLLED

    // Model for schedule overview in status section
    ListModel {
        id: scheduleOverviewModel
    }

    function parseScheduleForOverview() {
        scheduleOverviewModel.clear()
        if (!chargingIsAnyOf([time_controlled])) return

        var scheduleJson = chargingConfiguration.chargingSchedule
        if (scheduleJson === "" || scheduleJson === undefined || scheduleJson === "null") return

        var dayLabels = {
            "monday": qsTr("Monday"),
            "tuesday": qsTr("Tuesday"),
            "wednesday": qsTr("Wednesday"),
            "thursday": qsTr("Thursday"),
            "friday": qsTr("Friday"),
            "saturday": qsTr("Saturday"),
            "sunday": qsTr("Sunday")
        }

        try {
            var schedule = JSON.parse(scheduleJson)
            for (var i = 0; i < schedule.length; i++) {
                var entry = schedule[i]
                if (entry.startTime && entry.endTime) {
                    // Skip entries with no actual time set (00:00 - 00:00)
                    if (entry.startTime === "00:00" && entry.endTime === "00:00") continue
                    var label = dayLabels[entry.day] || entry.day
                    scheduleOverviewModel.append({
                        timeText: entry.startTime + "–" + entry.endTime + " Uhr",
                        dayText: label
                    })
                }
            }
        } catch (e) {
            console.error("Failed to parse charging schedule for overview:", e)
        }
    }

    function isCarPluggedIn()
    {
        if (thing.stateByName("pluggedIn").value)
        {
            return true
        }
        return false
    }
    

    function calcChargingCurrent(){
        // get the current power of the charger and null if not available
        var power = thing.stateByName("currentPower")
        var phaseCount = thing.stateByName("phaseCount").value
        if (phaseCount === 0 | power === null){
            return " – "
        }
        return power.value/(230*phaseCount)
    }

    function getUserVisibleChargingPower(){
        // get the current power of the charger and null if not available
        var power = thing.stateByName("currentPower");
        if (power === null ||
                typeof power.value !== "number" ||
                isNaN(power.value)){
            return " – ";
        }

        var userVisiblePower = power.value;
        var unit = "";
        if (userVisiblePower < 1000) {
            userVisiblePower = Math.round(userVisiblePower);
            unit = "W";
        } else {
            userVisiblePower = userVisiblePower / 1000;
            // Round to 2 decimals.
            userVisiblePower = Math.round(userVisiblePower * 100) / 100;
            unit = "kW";
        }
        return NymeaUtils.floatToLocaleString(userVisiblePower) + " " + unit;
    }

    // check if there exists a Simulated Car which is plugged in
    function checkForPluggedInCars(){
        var exist = false
        for( var i = 0; i < simulationEvProxy.count; i++){
            if (simulationEvProxy.get(i).stateByName("pluggedIn").value === true )
            {
                exist = true
            }
        }
        return exist
    }

    function getChargingMode(opti_mode){

        if (opti_mode < 1000) {
            return no_optimization
        }
        if (opti_mode >= 1000 && opti_mode < 2000) {
            return pv_optimized
        }
        if (opti_mode >= 2000 && opti_mode < 3000) {
            return pv_excess
        }
        if (opti_mode >= 3000 && opti_mode < 4000) {
            return simple_pv_excess
        }
        if (opti_mode >= 4000 && opti_mode < 5000) {
            return dyn_pricing
        }
        if (opti_mode >= 5000 && opti_mode < 6000) {
            return time_controlled
        }
    }

    function chargingIsAnyOf(modes)
    {
        return modes.includes(getChargingMode(chargingConfiguration.optimizationMode))
    }

    // 1234 -> mode==1; option1==2; option2==3; option3==4
    function getChargingModeOpts(opti_mode){
        return([(opti_mode/100) % 10, (opti_mode/10) % 10, opti_mode % 10])
    }

    title: root.thing.name
    headerOptionsVisible: false

    // Connections to update the ChargingSessionConfiguration  and the ChargingConfiguration values
    Connections {
        target: hemsManager
        onConEMSOperatingStateChanged: function(state) {
            if (state.currentState.operating_state === 1) // RUNNING
            {
                busyOverlay.shown = false
            }
        }

        onChargingSessionConfigurationChanged: function(configuration)
        {
            console.info("Charging session configuration changed...")
            if (configuration.evChargerThingId === thing.id){

                batteryLevelCard.text  = configuration.batteryLevel  + " %"
                energyChargedCard.text = (+configuration.energyCharged.toFixed(2)).toLocaleString() + " kWh"
                batteryEnergyCard.text = (+configuration.energyBattery.toFixed(2)).toLocaleString() + " kWh"
                if (configuration.state === 2){
                    var duration = configuration.duration
                    var hours   = Math.floor(duration / 3600)
                    var minutes = Math.floor((duration - hours * 3600) / 60)
                    durationCard.text = (hours === 0) ? minutes +  " min " : hours + " h " + minutes + " min"

                }
                // Running
                if (chargingConfiguration.optimizationEnabled && (configuration.state == 2)){
                    console.info("Going into running mode...")
                    if (settings.showHiddenOptions)
                    {
                        maxChargingCurrentCard.visible = true
                        measuredChargingCurrentCard.visible = true
                    }
                    energyChargedCard.visible = true
                    initializing = false
                }
                // Pending
                if (chargingConfiguration.optimizationEnabled && (configuration.state == 6)){
                    console.info("Going into pending mode...")
                    if (settings.showHiddenOptions)
                    {
                        maxChargingCurrentCard.visible = true
                        measuredChargingCurrentCard.visible = true
                    }
                    energyChargedCard.visible = true
                    initializing = false
                }
            }
        }

        onChargingConfigurationChanged: function(configuration)
        {
            console.info("Charging session configuration changed...")
            if (configuration.evChargerThingId === thing.id){
                if (!configuration.optimizationEnabled){
                    batteryLevelCard.visible = false
                    batteryEnergyCard.visible = false
                    maxChargingCurrentCard.visible = false
                    measuredChargingCurrentCard.visible = false
                    energyChargedCard.visible = false
                    initializing = false
                }
                else if(configuration.optimizationEnabled){
                    if (chargingIsAnyOf([simple_pv_excess, no_optimization, dyn_pricing, time_controlled]))
                    {
                        initializing = chargingIsAnyOf([time_controlled]) ? false : true
                        if (chargingIsAnyOf([time_controlled])) {
                            busyOverlay.shown = false
                        }
                        batteryLevelCard.visible = false
                        batteryEnergyCard.visible = false
                        if (settings.showHiddenOptions)
                        {
                            maxChargingCurrentCard.visible = true
                            measuredChargingCurrentCard.visible = true
                        }
                        energyChargedCard.visible = true
                        batteryLevelCard.text  = 0 + " %"
                        energyChargedCard.text = 0 + " kWh"
                        batteryEnergyCard.text = 0 + " kWh"
                        durationCard.text = "—"
                    }
                    else{
                        initializing = true
                        batteryLevelCard.visible = true
                        batteryEnergyCard.visible = true
                        if (settings.showHiddenOptions)
                        {
                            maxChargingCurrentCard.visible = true
                            measuredChargingCurrentCard.visible = true
                        }
                        measuredChargingCurrentCard.visible = true
                        energyChargedCard.visible = true
                        batteryLevelCard.text  = 0 + " %"
                        energyChargedCard.text = 0 + " kWh"
                        batteryEnergyCard.text = 0 + " kWh"
                        durationCard.text = "—"

                    }
                    if (chargingIsAnyOf([dyn_pricing])){
                        priceLimitCard.text = priceLimitCard.getText()
                    }
                }
            }
        }
    }

    ThingsProxy {
        id: simulationEvProxy
        engine: _engine
        shownInterfaces: ["electricvehicle"]
        requiredStateName: "pluggedIn"
    }

    ThingsProxy {
        id: evProxy
        engine: _engine
        shownInterfaces: ["electricvehicle"]
    }

    ThingsProxy {
        id: dynamicPrice
        engine: _engine
        shownInterfaces: ["dynamicelectricitypricing"]
    }

    // Convenience property – always null-safe: check before use with `if (dpThing)`
    readonly property var dpThing: dynamicPrice.count > 0 ? dynamicPrice.get(0) : null

    content: [
        Flickable {
            id: chargingflickable

            clip: true
            anchors.fill: parent
            contentHeight: contentColumn.implicitHeight +
                           contentColumn.anchors.topMargin +
                           contentColumn.anchors.bottomMargin +
                           (header ? header.height : 0)

            ColumnLayout {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                CoNotification {
                    id: phaseCountNotification
                    Layout.fillWidth: true
                    Layout.bottomMargin: 15
                    type: CoNotification.Type.Warning
                    visible: desiredPhaseCountCard.visible &&
                             actualPhaseCountCard.visible &&
                             desiredPhaseCount !== actualPhaseCount
                    property int desiredPhaseCount: isCarPluggedIn() ? chargingConfiguration.desiredPhaseCount : 0
                    property int actualPhaseCount: thing ? thing.stateByName("phaseCount").value : 0
                    title: qsTr("Phase setting could not be applied")
                    message: qsTr("The selected %1‑phase configuration could not be applied. Charging will proceed in %2‑phase mode.")
                    .arg(desiredPhaseCount)
                    .arg(actualPhaseCount)
                }

                CoFrostyCard {
                    id: vehicleGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Vehicle") // #TODO wording

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoCard {
                            id: vehiclePluggedInCard
                            Layout.fillWidth: true
                            text: qsTr("Car plugged in")
                            status: isCarPluggedIn() ?
                                        CoCard.StatusType.Success :
                                        CoCard.StatusType.Danger
                            interactive: false
                        }

                        CoCard {
                            id: noVehiclePluggedInCard
                            Layout.fillWidth: true
                            text: qsTr("No car is connected at the moment. Please connect a car.")
                            visible: !(isCarPluggedIn())
                            interactive: false
                        }

                        CoSwitch {
                            id: simulationSwitch
                            Layout.fillWidth: true
                            text: qsTr("Activate simulated car")
                            visible: !(isCarPluggedIn()) &&
                                     (simulationEvProxy.count > 0)  &&
                                     (thing.thingClassId.toString() === "{21a48e6d-6152-407a-a303-3b46e29bbb94}")

                            onCheckedChanged: {
                                if (simulationSwitch.checked) {
                                    simulationEvProxy.get(0).executeAction("pluggedIn", [{paramName: "pluggedIn", value: true}]);
                                } else {
                                    simulationEvProxy.get(0).executeAction("pluggedIn", [{paramName: "pluggedIn", value: false}]);
                                }
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: chargingSettingsGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Charging settings") // #TODO wording

                    Connections {
                        target: chargingConfiguration
                        onChargingScheduleChanged: parseScheduleForOverview()
                        onOptimizationModeChanged: parseScheduleForOverview()
                        onOptimizationEnabledChanged: parseScheduleForOverview()
                    }

                    Component.onCompleted: {
                        parseScheduleForOverview();
                    }

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoCard {
                            id: chargingModeCard
                            Layout.fillWidth: true
                            text: chargingConfiguration.optimizationEnabled ? selectMode(chargingConfiguration.optimizationMode) : "—"
                            labelText: qsTr("Charging mode") // #TODO wording
                            showChildrenIndicator: isCarPluggedIn()
                            interactive: isCarPluggedIn()

                            onClicked: {
                                if (isCarPluggedIn()){
                                    // #TODO Cancel charging already here if charging is currently active? (Or only
                                    // when new charging mode is set in optimizationComponent) Cf. old cancelLoadingSchedule
                                    var page = pageStack.push(optimizationComponent , { thing: thing });
                                    page.done.connect(function() {
                                        busyOverlay.shown = true;
                                    });
                                }
                            }

                            function selectMode(){

                                if (chargingIsAnyOf([no_optimization]))
                                {
                                    return qsTr("Charge always")
                                }
                                else if (chargingIsAnyOf([pv_optimized]))
                                {
                                    return qsTr("Next trip")
                                }
                                else if (chargingIsAnyOf([pv_excess]))
                                {
                                    return qsTr("PV only")
                                }
                                else if (chargingIsAnyOf([simple_pv_excess]))
                                {
                                    return qsTr("Solar only")
                                }
                                else if (chargingIsAnyOf([dyn_pricing]))
                                {
                                    return qsTr("Dynamic pricing")
                                }
                                else if (chargingIsAnyOf([time_controlled]))
                                {
                                    return qsTr("Time controlled")
                                }
                            }
                        }

                        CoCard {
                            id: selectedCarCard
                            Layout.fillWidth: true
                            text: qsTr(isCarPluggedIn() ? (chargingConfiguration.optimizationEnabled ? pageSelectedCar: "—" )  : "—")
                            labelText: qsTr("Car")
                            visible:  chargingIsAnyOf([pv_optimized])
                            interactive: false
                        }

                        Repeater {
                            id: timeControlledChargingScheduleRepeater
                            model: scheduleOverviewModel
                            delegate: CoCard {
                                Layout.fillWidth: true
                                visible: chargingIsAnyOf([time_controlled]) && chargingConfiguration.optimizationEnabled
                                text: model.timeText
                                labelText: model.dayText
                                interactive: false
                            }
                        }

                        CoCard {
                            id: onGridConsumptionCard
                            Layout.fillWidth: true
                            text: (typeof getText() === "undefined" ? "" : getText())
                            labelText: chargingIsAnyOf([dyn_pricing]) ?
                                           qsTr("Pausing") :
                                           qsTr("Low solar availability") // #TODO wording
                            visible:  chargingIsAnyOf([simple_pv_excess, dyn_pricing])
                            interactive: false

                            function getText(){
                                if (getChargingModeOpts(chargingConfiguration.optimizationMode)[0] === 0) {
                                    return qsTr("Minimal current");
                                } else if (getChargingModeOpts(chargingConfiguration.optimizationMode)[0] === 2) {
                                    return qsTr("Pausing");
                                }
                            }
                        }

                        CoCard {
                            id: priceLimitCard
                            Layout.fillWidth: true
                            text: getText()
                            labelText: qsTr("Price limit")
                            visible: chargingIsAnyOf([dyn_pricing])
                            interactive: false

                            Component.onCompleted: {
                                if (!dpThing) return;
                                thresholdPrice = DynPricingUtils.relPrice2AbsPrice(chargingConfiguration.priceThreshold, dpThing);
                                currentValue = (currentValue === 0 && chargingConfiguration.priceThreshold === 0 ? -10 : chargingConfiguration.priceThreshold );
                                priceLimitCard.text = getText();
                            }

                            function getText(){
                                if (chargingConfiguration.priceThreshold < 0) {
                                    return (thresholdPrice.toLocaleString() + " ct/kWh ") + "(↓ " +  (Math.abs(chargingConfiguration.priceThreshold.toLocaleString()) + " %)");
                                } else {
                                    return (thresholdPrice.toLocaleString() + " ct/kWh ") + "(↑ " +  (Math.abs(chargingConfiguration.priceThreshold.toLocaleString()) + " %)");
                                }
                            }
                        }

                        CoCard {
                            id: currentPriceCard
                            Layout.fillWidth: true
                            text: qsTr("%1 ct/kWh").arg((Math.round(currentPrice * 100) / 100).toLocaleString());
                            labelText: qsTr("Current Price")
                            visible: chargingIsAnyOf([dyn_pricing])
                            interactive: false

                            // #TODO needed here?
                            Component.onCompleted: {
                                if (!dpThing) return;
                                currentPrice = dpThing.stateByName("currentTotalCost").value;
                            }
                        }

                        CoCard {
                            id: belowPriceLimitCard
                            Layout.fillWidth: true
                            text: qsTr("Below price limit")
                            visible: chargingIsAnyOf([dyn_pricing])
                            status: (currentPrice <= thresholdPrice) ?
                                        CoCard.StatusType.Success :
                                        CoCard.StatusType.Danger
                            interactive: false
                        }

                        CoCard {
                            id: endingTimeCard

                            property var today: new Date()
                            property var tomorrow: new Date(today.getTime() + 1000 * 60 * 60 * 24)
                            // determine whether it is today or tomorrow
                            property var date: (parseInt(chargingConfiguration.endTime[0] + chargingConfiguration.endTime[1]) < today.getHours()) | ((parseInt(chargingConfiguration.endTime[0] + chargingConfiguration.endTime[1]) === today.getHours()) & parseInt(chargingConfiguration.endTime[3] + chargingConfiguration.endTime[4]) >= today.getMinutes()) ? tomorrow : today

                            Layout.fillWidth: true
                            text: isCarPluggedIn() ? (chargingConfiguration.optimizationEnabled ? date.toLocaleString(Qt.locale("de-DE"), "dd.MM") + "  " + Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime, "H:m:ss").toLocaleString(Qt.locale("de-DE"), "HH:mm") : "—"  )   : "—"
                            labelText: qsTr("Ending time")
                            visible: !([pv_excess, simple_pv_excess, no_optimization, dyn_pricing, time_controlled].includes(getChargingMode(chargingConfiguration.optimizationMode)))
                            interactive: false
                        }

                        CoCard {
                            id: targetChargeCard
                            Layout.fillWidth: true
                            text: isCarPluggedIn() ?(chargingConfiguration.optimizationEnabled ? chargingConfiguration.targetPercentage + " %" : "—" ) : "—"
                            labelText: qsTr("Target charge")
                            visible: !chargingIsAnyOf([simple_pv_excess, dyn_pricing, no_optimization, time_controlled])
                            interactive: false
                        }

                        CoCard {
                            id: desiredPhaseCountCard
                            Layout.fillWidth: true
                            text: isCarPluggedIn() ? chargingConfiguration.desiredPhaseCount : "—"
                            labelText: qsTr("Phase count")
                            visible: chargingIsAnyOf([pv_optimized, simple_pv_excess]) && thing.thingClass.interfaces.includes("phaseswitching")
                            interactive: false
                        }
                    }
                }

                CoFrostyCard {
                    id: statusGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Status") // #TODO wording
                    visible: isCarPluggedIn()

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoCard {
                            id: noLoadingCard
                            Layout.fillWidth: true
                            text: qsTr("Charging deactivated. Please choose a charging mode.")
                            visible: !(chargingConfiguration.optimizationEnabled && isCarPluggedIn())
                            interactive: false
                        }

                        CoCard {
                            id: chargingStatusCard
                            Layout.fillWidth: true
                            text: {
                                if (initializing) {
                                    return qsTr("Initialising");
                                } else if (chargingSessionConfiguration.state === 2) {
                                    return qsTr("Running");
                                } else if (chargingSessionConfiguration.state === 3) {
                                    return qsTr("Finished");
                                } else if (chargingSessionConfiguration.state === 4) {
                                    return qsTr("Interrupted");
                                } else if (chargingSessionConfiguration.state === 6) {
                                    return qsTr("Pending");
                                } else {
                                    return qsTr("Failed");
                                }
                            }
                            labelText: qsTr("Status")
                            visible: chargingConfiguration.optimizationEnabled && isCarPluggedIn()
                            interactive: false
                            status: {
                                if (initializing) {
                                    return CoCard.StatusType.Warning; // yellow
                                } else if (chargingSessionConfiguration.state === 2) {
                                    return CoCard.StatusType.Success;
                                } else if (chargingSessionConfiguration.state === 3) {
                                    return CoCard.StatusType.Success; // #TODO was formerly blue. what color/type should be used?
                                } else if (chargingSessionConfiguration.state === 4) {
                                    return CoCard.StatusType.Neutral;
                                } else if (chargingSessionConfiguration.state === 6) {
                                    return CoCard.StatusType.Neutral;
                                } else {
                                    return CoCard.StatusType.Danger;
                                }
                            }
                        }

                        CoCard {
                            id: batteryLevelCard
                            Layout.fillWidth: true
                            text: chargingSessionConfiguration.batteryLevel + " %"
                            labelText: qsTr("Battery level")
                            interactive: false
                            visible: {
                                if (chargingIsAnyOf([simple_pv_excess, dyn_pricing, no_optimization, time_controlled])) {
                                    return false;
                                }
                                if (!(chargingConfiguration.optimizationEnabled && isCarPluggedIn())) {
                                    return false;
                                }
                                return true
                            }
                        }

                        CoCard {
                            id: batteryEnergyCard
                            Layout.fillWidth: true
                            text: (+chargingSessionConfiguration.energyBattery.toFixed(2)).toLocaleString() + " kWh"
                            labelText: qsTr("Battery charge")
                            interactive: false
                            visible: {
                                if (chargingIsAnyOf([simple_pv_excess, dyn_pricing, no_optimization])) {
                                    return false;
                                }
                                if (!(chargingConfiguration.optimizationEnabled && isCarPluggedIn())) {
                                    return false;
                                }
                                return true;
                            }
                        }

                        CoCard {
                            id: chargingPowerCard
                            Layout.fillWidth: true
                            text: initializing ? 0 : getUserVisibleChargingPower()
                            labelText: qsTr("Charging power")
                            visible: chargingConfiguration.optimizationEnabled && isCarPluggedIn()
                            interactive: false
                        }

                        CoCard {
                            id: maxChargingCurrentCard
                            Layout.fillWidth: true
                            text: (initializing ? 0 : thing.stateByName("maxChargingCurrent").value) + " A"
                            labelText: qsTr("Target charging current")
                            visible: chargingConfiguration.optimizationEnabled && isCarPluggedIn() && settings.showHiddenOptions
                            interactive: false
                        }

                        CoCard {
                            id: measuredChargingCurrentCard
                            Layout.fillWidth: true
                            text: (initializing ? 0 : calcChargingCurrent()) + " A"
                            labelText: qsTr("Actual charging current")
                            visible: chargingConfiguration.optimizationEnabled && isCarPluggedIn() && settings.showHiddenOptions
                            interactive: false
                        }

                        CoCard {
                            id: energyChargedCard
                            Layout.fillWidth: true
                            text: (+chargingSessionConfiguration.energyCharged.toFixed(2)).toLocaleString() + " kWh"
                            labelText: qsTr("Energy charged")
                            visible: chargingConfiguration.optimizationEnabled && isCarPluggedIn()
                            interactive: false
                        }

                        CoCard {
                            id: durationCard

                            property int duration: chargingSessionConfiguration.duration
                            property int hours: duration / 3600
                            property int minutes: (duration - hours * 3600) / 60

                            Layout.fillWidth: true
                            text: (hours === 0) ? minutes +  " min " : hours + " h " + minutes + " min"
                            labelText: qsTr("Time elapsed")
                            visible: chargingConfiguration.optimizationEnabled && isCarPluggedIn()
                            interactive: false
                        }

                        CoCard {
                            id: actualPhaseCountCard
                            Layout.fillWidth: true
                            text: thing ? thing.stateByName("phaseCount").value : "—"
                            labelText: qsTr("Phase count")
                            visible: chargingConfiguration.optimizationEnabled &&
                                     isCarPluggedIn() &&
                                     chargingIsAnyOf([pv_optimized, simple_pv_excess])
                            interactive: false
                        }

                        Button {
                            id: cancelChargingButton
                            Layout.fillWidth: true
                            Layout.topMargin: Style.smallMargins
                            Layout.leftMargin: Style.margins
                            Layout.rightMargin: Style.margins
                            visible: chargingConfiguration.optimizationEnabled
                            text: qsTr("Cancel charging") // #TODO wording

                            onClicked: {
                                hemsManager.setChargingConfiguration(thing.id,
                                                                     {
                                                                         optimizationEnabled: false,
                                                                         optimizationMode: 9
                                                                     });
                                busyOverlay.shown = true;
                            }
                        }
                    }
                }
            }

            BusyOverlay {
                id: busyOverlay
            }
        }
    ]

    Component {
        id: optimizationComponent

        Page{
            id: optimizationPage

            signal done()

            property ChargingConfiguration chargingConfiguration: hemsManager.chargingConfigurations.getChargingConfiguration(thing.id)
            property Thing thing

            function getSelectedMode() {
                return getChargingMode(comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).mode);
            }

            function isAnyOfModesSelected(modes)
            {
                var selected_mode = getSelectedMode();
                if (typeof selected_mode !== "number") { return false; }
                return (modes.includes(selected_mode));
            }

            ListModel {
                id: scheduleModel
            }

            function initScheduleModel() {
                var days = [
                            { dayKey: "monday",    dayLabel: qsTr("Monday") },
                            { dayKey: "tuesday",   dayLabel: qsTr("Tuesday") },
                            { dayKey: "wednesday", dayLabel: qsTr("Wednesday") },
                            { dayKey: "thursday",  dayLabel: qsTr("Thursday") },
                            { dayKey: "friday",    dayLabel: qsTr("Friday") },
                            { dayKey: "saturday",  dayLabel: qsTr("Saturday") },
                            { dayKey: "sunday",    dayLabel: qsTr("Sunday") }
                        ];
                scheduleModel.clear();
                for (var i = 0; i < days.length; i++) {
                    scheduleModel.append({
                                             dayKey: days[i].dayKey,
                                             dayLabel: days[i].dayLabel,
                                             startTime: "",
                                             endTime: "",
                                             hasEntry: false
                                         });
                }
            }

            function restoreSchedule() {
                var scheduleJson = chargingConfiguration.chargingSchedule;
                console.log("Restoring schedule:", scheduleJson);
                if (scheduleJson === "" || scheduleJson === undefined || scheduleJson === "null") return;

                try {
                    var schedule = JSON.parse(scheduleJson);
                    var weekdays = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"];

                    for (var i = 0; i < weekdays.length; i++) {
                        var currentDay = weekdays[i];
                        var entry = schedule.find(function(e) { return e.day === currentDay });

                        if (entry && entry.startTime && entry.endTime) {
                            var hasTime = !(entry.startTime === "00:00" && entry.endTime === "00:00");
                            if (i < scheduleModel.count) {
                                scheduleModel.setProperty(i, "startTime", entry.startTime);
                                scheduleModel.setProperty(i, "endTime", entry.endTime);
                                scheduleModel.setProperty(i, "hasEntry", hasTime);
                            }
                        }
                    }
                } catch (e) {
                    console.error("Failed to parse charging schedule:", e);
                }
            }

            Connections {
                target: chargingConfiguration
                onChargingScheduleChanged: {
                    restoreSchedule();
                }
            }

            Component.onCompleted: {
                initScheduleModel();
                endTimeSlider.feasibilityText();
                restoreSchedule();
            }

            header: NymeaHeader {
                id: header
                text: qsTr("Configure charging mode")
                backButtonVisible: true
                onBackPressed: {
                    pageStack.pop();
                }
            }

            Flickable {
                anchors.fill: parent
                contentHeight: optimizationPageLayout.implicitHeight +
                               optimizationPageLayout.anchors.topMargin +
                               optimizationPageLayout.anchors.bottomMargin
                clip: true

                ColumnLayout {
                    id: optimizationPageLayout
                    anchors.fill: parent
                    anchors.margins: Style.margins
                    spacing: Style.margins

                    CoFrostyCard {
                        id: selectChargingModeGroup
                        Layout.fillWidth: true
                        contentTopMargin: Style.smallMargins
                        headerText: qsTr("Configure charging mode") // #TODO wording

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 0

                            CoCard {
                                id: carSelector // #TODO rename (selectVehicleCard)

                                // #TODO rename (e.g. selectedCarThing) and don't use false as "no selected car" (but undefined)
                                property var holdingItem: evProxy.getThing(userconfig.lastSelectedCar) ?
                                                              evProxy.getThing(userconfig.lastSelectedCar) :
                                                              false
                                Layout.fillWidth: true
                                labelText: qsTr("Selected car")
                                text: evProxy.getThing(userconfig.lastSelectedCar) ?
                                          evProxy.getThing(userconfig.lastSelectedCar).name :
                                          qsTr("Select/Add Car")
                                showChildrenIndicator: true

                                onClicked: {
                                    var page = pageStack.push("../thingconfiguration/CarInventory.qml");
                                    page.done.connect(function(selectedCar) {
                                        footer.visible = false;
                                        hemsManager.setUserConfiguration({ lastSelectedCar: selectedCar.id });
                                        carSelector.text = selectedCar.name;
                                        holdingItem = selectedCar;
                                        batteryLevel.value = 0;
                                    });

                                    page.back.connect(function() {
                                        pageStack.pop();
                                        carSelector.text = evProxy.getThing(userconfig.lastSelectedCar) ?
                                                    evProxy.getThing(userconfig.lastSelectedCar).name :
                                                    qsTr("Select/Add Car");
                                        if (!(evProxy.getThing(userconfig.lastSelectedCar))){
                                            holdingItem = false;
                                        }
                                    });
                                }

                                onHoldingItemChanged: {
                                    if (holdingItem !== false){
                                        endTimeSlider.computeFeasibility();
                                        endTimeSlider.feasibilityText();
                                    }
                                }
                            }

                            CoComboBox {
                                id: comboboxloadingmod // #TODO rename (comboBoxChargingMode)
                                Layout.fillWidth: true
                                labelText: qsTr("Charging mode")
                                infoUrl: "ChargingModeInfo.qml"

                                property var fullModel: [
                                    { key: qsTr("Charge always"), mode: 0 },
                                    { key: qsTr("Solar only"), mode: 3000 },
                                    { key: qsTr("Next trip"), mode: 1000 },
                                    { key: qsTr("Dynamic pricing"), mode: 4000 },
                                    { key: qsTr("Time controlled"), mode: 5000 }
                                ]

                                model: ListModel { id: dynamicModel }

                                textRole: "key"
                                // #TODO use mode as valueRole (easier access via currentValue)?
                                //comboBox.valueRole: "value"

                                Component.onCompleted: {
                                    rebuildModel();
                                }

                                Connections {
                                    target: hemsManager
                                    onAvailableUseCasesChanged: {
                                        comboboxloadingmod.rebuildModel();
                                    }
                                }

                                onCurrentIndexChanged: {
                                    endTimeSlider.computeFeasibility();
                                    endTimeSlider.feasibilityText();
                                    comboboxloadingmod.currentIndex === 3 ?
                                                gridConsumptionloadingmod.currentIndex = 1 :
                                                gridConsumptionloadingmod.currentIndex = 0;
                                }

                                // Function to rebuild model based on available use cases
                                function rebuildModel() {
                                    dynamicModel.clear();

                                    const pvEnabled = hemsManager.availableUseCases & HemsManager.HemsUseCasePv;
                                    const dynEnabled = hemsManager.availableUseCases & HemsManager.HemsUseCaseDynamicEPricing;

                                    for (let i = 0; i < fullModel.length; ++i) {
                                        const item = fullModel[i];

                                        // Determine visibility
                                        if (item.mode === 0) {
                                            dynamicModel.append(item);
                                        } else if ((item.mode === 1000 || item.mode === 3000) && pvEnabled) {
                                            dynamicModel.append(item);
                                        } else if (item.mode === 4000 && dynEnabled) {
                                            dynamicModel.append(item);
                                        } else if (item.mode === 5000) {
                                            dynamicModel.append(item);
                                        }
                                    }
                                    // Check which charging mode is currently set and update currentIndex accordingly.
                                    // Use only thousands digit for comparison with model items (others are sub configs).
                                    console.debug("Config mode:", chargingConfiguration.optimizationMode);
                                    let currentChargingConfigOptimizationMode = chargingConfiguration.optimizationMode - (chargingConfiguration.optimizationMode % 1000);
                                    for (let j = 0; j < dynamicModel.count; ++j) {
                                        console.debug("Current dynamic model mode: " +
                                                     dynamicModel.get(j).mode +
                                                     " vs config mode: " +
                                                     currentChargingConfigOptimizationMode);
                                        if (dynamicModel.get(j).mode === currentChargingConfigOptimizationMode) {
                                            comboboxloadingmod.currentIndex = j;
                                            return;
                                        }
                                        // #TODO does this work for "no charging"
                                        if (chargingConfiguration.optimizationMode === 9) {
                                            // If optimizationMode is 9 (no optimization), set to "Charge always"
                                            if (dynamicModel.get(j).mode === 0) {
                                                comboboxloadingmod.currentIndex = j;
                                                return;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    CoFrostyCard {
                        id: configureChargingModeGroup
                        Layout.fillWidth: true
                        contentTopMargin: Style.smallMargins
                        headerText: comboboxloadingmod.currentText
                        visible: isAnyOfModesSelected([pv_optimized, pv_excess, simple_pv_excess, dyn_pricing, time_controlled])

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 0

                            CoCard {
                                Layout.fillWidth: true
                                interactive: false
                                text: qsTr("If the price limit is exceeded, PV surplus power is used according to device priority.")
                                visible: isAnyOfModesSelected([dyn_pricing])
                            }

                            CoCard {
                                id: pvPrioCard
                                Layout.fillWidth: true
                                labelText: qsTr("Priority")
                                text: "3" // #TODO get real priority from config
                                showChildrenIndicator: true
                                visible: isAnyOfModesSelected([pv_excess, simple_pv_excess, dyn_pricing])

                                onClicked: {
                                    pageStack.push(Qt.resolvedUrl("../optimization/PVPriorities.qml"));
                                }
                            }

                            CoComboBox {
                                id: desiredPhaseCountDropdown
                                Layout.fillWidth: true
                                visible:  isAnyOfModesSelected([pv_optimized, simple_pv_excess]) &&
                                          thing.thingClass.interfaces.includes("phaseswitching")
                                labelText: qsTr("Number of phases")
                                infoUrl: "ChargingPhaseSwitchingInfo.qml"

                                model: [
                                    { key: "1", value: 1 },
                                    { key: "3", value: 3 }
                                ]

                                textRole: "key"
                                valueRole: "value"

                                Component.onCompleted: {
                                    let currentPhaseCount = parseInt(thing.stateByName("phaseCount").value);
                                    desiredPhaseCountDropdown.currentIndex = 1; // Default phase count: 3
                                    for (let i = 0; i < model.length; ++i) {
                                        const item = model[i];
                                        if (item.value === currentPhaseCount) {
                                            desiredPhaseCountDropdown.currentIndex = i;
                                            break;
                                        }
                                    }
                                }
                            }

                            CoSlider {
                                id: batteryLevel // #TODO rename
                                Layout.fillWidth: true
                                visible: isAnyOfModesSelected([pv_optimized, pv_excess])
                                labelText: qsTr("Battery level")
                                infoUrl: "BatteryLevel.qml"
                                valueText: value + " %"
                                from: 0
                                to: 100
                                stepSize: 1

                                onValueChanged: {
                                    // if the "new Car" option is not picked do something
                                    if (carSelector.holdingItem !== false) {
                                        if (value  >= targetPercentageSlider.value) {
                                            if (value === 100) {
                                                value = 99;
                                            }
                                            targetPercentageSlider.value = value + 1;
                                        }
                                        endTimeSlider.computeFeasibility();
                                        endTimeSlider.feasibilityText();
                                    }
                                }
                            }

                            CoSlider {
                                id: targetPercentageSlider // #TODO rename
                                Layout.fillWidth: true
                                visible: isAnyOfModesSelected([pv_optimized, pv_excess])
                                labelText: qsTr("Target charge")
                                infoUrl: "TargetChargeInfo.qml"
                                valueText: value + " %"
                                from: 0
                                to: 100
                                stepSize: 1
                                value: 0

                                Component.onCompleted: {
                                    if (carSelector.holdingItem !== false) {
                                        endTimeSlider.computeFeasibility();
                                        endTimeSlider.feasibilityText();
                                    }
                                }
                                onValueChanged: {
                                    if (carSelector.holdingItem !== false) {
                                        endTimeSlider.computeFeasibility();
                                        endTimeSlider.feasibilityText();

                                        if (value <= batteryLevel.value) {
                                            if (value === 100) {
                                                value = batteryLevel.value;
                                            } else {
                                                value = batteryLevel.value + 1;
                                            }
                                        }
                                    }
                                }
                            }

                            CoSlider {
                                id: endTimeSlider // #TODO rename
                                Layout.fillWidth: true

                                property var today: new Date()
                                property var endTime: new Date(today.getTime() + value * 60000)
                                property int chargingConfigHours: Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime , "HH:mm:ss").getHours()
                                property int chargingConfigMinutes: Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime , "HH:mm:ss").getMinutes()
                                property int nextDay: chargingConfigHours*60 + chargingConfigMinutes - today.getHours()*60 - today.getMinutes() < 0 ? 1 : 0
                                property int targetSOC: targetPercentageSlider.value
                                property real minimumChargingthreshhold
                                property real maximumChargingthreshhold
                                property var capacityInAh
                                property var batteryContentInAh
                                property var minChargingCurrent

                                visible: isAnyOfModesSelected([pv_optimized])
                                labelText: qsTr("Ending time")
                                valueText: endTime.toLocaleString(Qt.locale("de-DE"), "dd.MM HH:mm")
                                from: 0
                                to: 24 * 60
                                stepSize: 1
                                //     from config hours          from config minutes     current hours           current minutes      add a day if negative (since it means it is the next day)
                                value: chargingConfigHours * 60 + chargingConfigMinutes - today.getHours() * 60 - today.getMinutes() + nextDay * 24 * 60

                                onValueChanged: {
                                    feasibilityText()
                                }

                                // #TODO feasibility message
                                function endTimeValidityPrediction(d) {
                                    switch (d) {
                                    case 1:
                                        feasibilityMessage.visible = true;
                                        break;
                                    case 2:
                                        feasibilityMessage.visible = false;
                                        break;
                                    }
                                    return;
                                }

                                function feasibilityText(){
                                    if (value < maximumChargingthreshhold){
                                        endTimeValidityPrediction(1);
                                    }
                                    else{
                                        endTimeValidityPrediction(2);
                                    }
                                }

                                function computeFeasibility() {
                                    if (carSelector.holdingItem !== false){
                                        var maxChargingCurrent = thing.stateByName("maxChargingCurrent").maxValue;
                                        var loadingVoltage = thing.stateByName("phaseCount").value * 230;

                                        for (let i = 0; i < carSelector.holdingItem.thingClass.stateTypes.count; i++) {
                                            var thingStateId = carSelector.holdingItem.thingClass.stateTypes.get(i).id;
                                            if (carSelector.holdingItem.thingClass.stateTypes.get(i).name === "capacity" ) {
                                                // capacity in KWh
                                                var capacity = carSelector.holdingItem.states.getState(thingStateId).value;
                                                capacityInAh = (capacity * 1000) / loadingVoltage;
                                            }
                                            if (carSelector.holdingItem.thingClass.stateTypes.get(i).name === "minChargingCurrent") {
                                                minChargingCurrent = carSelector.holdingItem.states.getState(thingStateId).value;
                                            }
                                        }

                                        batteryContentInAh = capacityInAh * batteryLevel.value / 100;
                                        var targetSOCinAh = capacityInAh * targetSOC / 100;
                                        var necessaryTimeinHMinCharg = (targetSOCinAh - batteryContentInAh) / minChargingCurrent;
                                        var necessaryTimeinHMaxCharg = (targetSOCinAh - batteryContentInAh) / maxChargingCurrent;
                                        minimumChargingthreshhold = necessaryTimeinHMinCharg * 60;
                                        maximumChargingthreshhold = necessaryTimeinHMaxCharg * 60;
                                    }
                                }
                            }

                            // #TODO replace by CoSlider feedback mechanism
                            CoCard {
                                id: feasibilityMessage
                                Layout.fillWidth: true
                                visible: false
                                interactive: false
                                helpText: qsTr("In the currently selected timeframe the charging process is not possible. Please reduce the target charge or increase the end time")
                            }

                            Repeater {
                                id: weekdayRepeater
                                model: scheduleModel

                                delegate: CoCard {
                                    Layout.fillWidth: true
                                    text: model.hasEntry ? model.startTime + "–" + model.endTime + " Uhr" : "—"
                                    labelText: model.dayLabel
                                    showChildrenIndicator: true
                                    visible: isAnyOfModesSelected([time_controlled])
                                    deletable: model.hasEntry

                                    onClicked: {
                                        var dayIndex = index;
                                        var page = pageStack.push(Qt.resolvedUrl("DayTimePickerPage.qml"), {
                                                                      dayLabel: model.dayLabel,
                                                                      initialStartTime: model.hasEntry ? model.startTime : "",
                                                                      initialEndTime: model.hasEntry ? model.endTime : ""
                                                                  });
                                        page.timeSelected.connect(function(startTime, endTime) {
                                            scheduleModel.setProperty(dayIndex, "startTime", startTime);
                                            scheduleModel.setProperty(dayIndex, "endTime", endTime);
                                            scheduleModel.setProperty(dayIndex, "hasEntry", true);
                                        });
                                        page.entryRemoved.connect(function() {
                                            scheduleModel.setProperty(dayIndex, "hasEntry", false);
                                            scheduleModel.setProperty(dayIndex, "startTime", "");
                                            scheduleModel.setProperty(dayIndex, "endTime", "");
                                        });
                                    }

                                    onDeleteClicked: {
                                        scheduleModel.setProperty(index, "hasEntry", false)
                                        scheduleModel.setProperty(index, "startTime", "")
                                        scheduleModel.setProperty(index, "endTime", "")
                                    }
                                }
                            }

                            CoComboBox {
                                id: gridConsumptionloadingmod // #TODO rename
                                Layout.fillWidth: true
                                visible: isAnyOfModesSelected([pv_excess, simple_pv_excess, dyn_pricing])
                                labelText: isAnyOfModesSelected([pv_excess, simple_pv_excess]) ?
                                               qsTr("Low solar avalaibility") :
                                               qsTr("Pausing")
                                infoUrl: isAnyOfModesSelected([pv_excess, simple_pv_excess]) ?
                                             "GridConsumptionInfo.qml" :
                                             "PausingInfo.qml"
                                model: ListModel {
                                    ListElement{ key: qsTr("Charge with minimum current"); mode: 0 }
                                    ListElement{ key: qsTr("Pause charging"); mode: 200 }
                                }
                                textRole: "key"
                            }
                        }
                    }

                    CoFrostyCard {
                        id: chargingPlanGroup
                        Layout.fillWidth: true
                        contentTopMargin: Style.smallMargins
                        headerText: qsTr("Charging plan")
                        visible: isAnyOfModesSelected([dyn_pricing])

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 0

                            CoCard {
                                id: currentPriceCard
                                Layout.fillWidth: true
                                labelText: qsTr("Current price")
                                iconLeft: Qt.resolvedUrl("qrc:/icons/euro.svg")
                                iconLeftColor: Style.colors.brand_Basic_Icon
                                text: dpThing ?
                                          dpThing.stateByName("currentTotalCost").value.toLocaleString(Qt.locale(), 'f', 2) + " ct/kWh" :
                                          "—"
                            }

                            CoSlider {
                                id: priceThresholdSlider
                                Layout.fillWidth: true
                                labelText: qsTr("\"Charging\" price limit")
                                helpText: qsTr("Deviation from the 48-h average (in %) at which charging takes place. Currently corresponds to %1 ct/kWh.").arg(root.thresholdPrice.toLocaleString(Qt.locale(), 'f', 2))
                                infoUrl: "PriceLimitInfo.qml"
                                valueText: value + " %"
                                value: Math.round(root.currentValue)
                                from: -100
                                to: 100
                                stepSize: 1

                                onValueChanged: {
                                    root.currentValue = value;
                                    updateThresholdPrice();
                                    redrawChart();
                                }

                                Component.onCompleted: {
                                    updateThresholdPrice();
                                }

                                function updateThresholdPrice() {
                                    if (!dpThing) return;
                                    root.thresholdPrice = DynPricingUtils.relPrice2AbsPrice(root.currentValue, dpThing)
                                }

                                function redrawChart() {
                                    if (!dpThing) return;
                                    pricingCurrentLimitSeries.clear();
                                    pricingUpperSeriesAbove.clear();
                                    pricingLowerSeriesAbove.clear();
                                    consumptionSeries.insertEntry(dpThing.stateByName("totalCostSeries").value, true);
                                }
                            }

                            Item {
                                id: rootChart
                                Layout.fillWidth: true
                                Layout.preferredHeight: 200
                                Layout.leftMargin: Style.bigMargins
                                QtObject {
                                    id: d

                                    property date now: new Date()

                                    readonly property var startTimeSince: {
                                        var date = new Date();
                                        date.setHours(0);
                                        date.setMinutes(0);
                                        date.setSeconds(0);

                                        return date;
                                    }

                                    readonly property var endTimeUntil: {
                                        var date = new Date();
                                        date.setHours(0);
                                        date.setMinutes(0);
                                        date.setSeconds(0);
                                        date.setDate(date.getDate()+1);
                                        return date;
                                    }

                                }

                                Component {
                                    id: lineSeriesComponent
                                    LineSeries { }
                                }

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 0
                                    visible: isAnyOfModesSelected([dyn_pricing])

                                    Component.onCompleted: {
                                        if (!dpThing)
                                            return;

                                        pricingCurrentLimitSeries.clear();
                                        pricingUpperSeries.clear();
                                        pricingUpperSeriesAbove.clear();

                                        currentPrice = dpThing.stateByName("currentTotalCost").value

                                        consumptionSeries.insertEntry(dpThing.stateByName("totalCostSeries").value, false)
                                        valueAxis.adjustMax((Math.ceil(lowestPrice)), highestPrice);
                                    }

                                    Item {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        ChartView {
                                            id: chartView
                                            anchors.fill: parent

                                            backgroundColor: "transparent"
                                            margins.left: 0
                                            margins.right: 0
                                            margins.top: 0
                                            margins.bottom: Style.smallIconSize + Style.margins

                                            legend.visible: false

                                            ActivityIndicator {
                                                id: noDataIndicator
                                                x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                                                y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                                                visible: false
                                                opacity: .5
                                            }

                                            Label {
                                                id: noDataLabel
                                                x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                                                y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                                                text: qsTr("No data available")
                                                visible: false
                                                font: Style.smallFont
                                                opacity: .5
                                            }

                                            ValueAxis {
                                                id: valueAxis
                                                min: 0
                                                max: 1
                                                labelFormat: ""
                                                gridLineColor: Style.tileOverlayColor
                                                labelsVisible: false
                                                tickCount: 5
                                                lineVisible: false
                                                titleVisible: false
                                                shadesVisible: false

                                                function adjustMax(minPrice,maxPrice) {
                                                    // force yaxis steps to multiples of 5
                                                    let step = Math.ceil(maxPrice / 4);
                                                    const rest = step % 5;
                                                    if(rest !== 0) {
                                                        step += 5 - rest;
                                                    }

                                                    max = step * 4;
                                                }
                                            }

                                            Item {
                                                id: labelsLayout
                                                x: Style.smallMargins
                                                y: chartView.plotArea.y
                                                height: chartView.plotArea.height
                                                width: chartView.plotArea.x - x
                                                Repeater {
                                                    model: valueAxis.tickCount
                                                    delegate: Label {
                                                        y: parent.height / (valueAxis.tickCount - 1) * index - font.pixelSize / 2
                                                        width: parent.width - Style.smallMargins
                                                        horizontalAlignment: Text.AlignRight
                                                        text: (Math.ceil(valueAxis.max - index * (valueAxis.max - valueAxis.min) / (valueAxis.tickCount - 1))) + " ct"  //linke Seite vom Graphen
                                                        verticalAlignment: Text.AlignTop
                                                        font: Style.extraSmallFont
                                                    }
                                                }
                                            }

                                            DateTimeAxis {
                                                id: dateTimeAxis
                                                min: d.startTimeSince
                                                max: d.endTimeUntil
                                                format: "HH:mm"
                                                tickCount: 5
                                                labelsFont: Style.extraSmallFont
                                                gridVisible: false
                                                minorGridVisible: false
                                                lineVisible: false
                                                shadesVisible: false
                                                labelsColor: Style.foregroundColor
                                            }


                                            AreaSeries {
                                                id: currentLimitSeries
                                                axisX: dateTimeAxis
                                                axisY: valueAxis
                                                color: '#ccc'
                                                borderWidth: 1
                                                borderColor: 'transparent'

                                                upperSeries: LineSeries {
                                                    id: pricingCurrentLimitSeries
                                                }
                                            }

                                            AreaSeries {
                                                id: consumptionSeries
                                                axisX: dateTimeAxis
                                                axisY: valueAxis
                                                color: 'transparent'
                                                borderWidth: 1
                                                borderColor: Style.epexMainLineColor


                                                upperSeries: LineSeries {
                                                    id: pricingUpperSeries
                                                }

                                                function insertEntry(value, onlyThreshold){
                                                    var lastObjectValue = value[Object.keys(value)[Object.keys(value).length - 1]];

                                                    var firstRun = true;
                                                    let lastChange = 0;
                                                    let lastChangeTimestamp = 0;
                                                    let identicalIndexes = [];

                                                    for (const item in value){
                                                        const date = new Date(item);
                                                        let currentTimestamp = date.getTime();
                                                        let itemValue = value[item];
                                                        if(itemValue < lowestPrice){
                                                            lowestPrice = itemValue
                                                        }

                                                        if(itemValue > highestPrice){
                                                            highestPrice = itemValue
                                                        }

                                                        if(lastChange !== itemValue) {
                                                            lastChangeTimestamp = currentTimestamp;

                                                            for(const ts of identicalIndexes) {
                                                                prices[ts].end = currentTimestamp;
                                                            }

                                                            identicalIndexes = [currentTimestamp];
                                                        }
                                                        else {
                                                            identicalIndexes.push(currentTimestamp);
                                                        }

                                                        lastChange = itemValue;

                                                        prices[currentTimestamp] = {
                                                            start: lastChangeTimestamp,
                                                            value: itemValue
                                                        };

                                                        if(firstRun === true){
                                                            firstRun = false;
                                                            highestPrice = itemValue
                                                            lowestPrice = itemValue
                                                            currentTimestamp = currentTimestamp - 600000;
                                                        }

                                                        if(itemValue < thresholdPrice) {
                                                            pricingCurrentLimitSeries.append(currentTimestamp - (60000 * 15),thresholdPrice);
                                                            pricingCurrentLimitSeries.append(currentTimestamp,thresholdPrice);
                                                        }
                                                        else {
                                                            pricingCurrentLimitSeries.append(currentTimestamp - (60000 * 15),valueAxis.min -5);
                                                            pricingCurrentLimitSeries.append(currentTimestamp,valueAxis.min - 5);
                                                        }

                                                        pricingUpperSeriesAbove.append(currentTimestamp,thresholdPrice);
                                                        if(!onlyThreshold) {
                                                            pricingUpperSeries.append(currentTimestamp - (60000 * 15) + 1,itemValue);
                                                            pricingUpperSeries.append(currentTimestamp,itemValue);
                                                        }
                                                    }

                                                    const todayMidnight = new Date(identicalIndexes[0]);
                                                    todayMidnight.setDate(todayMidnight.getDate() +1);
                                                    todayMidnight.setMinutes(0);
                                                    todayMidnight.setHours(0);

                                                    const todayMidnightTs = todayMidnight.getTime();

                                                    for(const ts of identicalIndexes) {
                                                        prices[ts].end = todayMidnightTs;
                                                    }

                                                    pricingCurrentLimitSeries.append(todayMidnightTs + 6000000, valueAxis.min - 5);
                                                    pricingUpperSeriesAbove.append(todayMidnightTs + 6000000, thresholdPrice);
                                                    pricingLowerSeriesAbove.append(todayMidnightTs + 6000000, thresholdPrice);

                                                    if(!onlyThreshold) {
                                                        pricingUpperSeries.append(todayMidnightTs + 6000000, lastObjectValue);
                                                    }
                                                }
                                            }

                                            AreaSeries {
                                                id: consumptionSeriesAbove
                                                axisX: dateTimeAxis
                                                axisY: valueAxis
                                                color: 'transparent'
                                                borderWidth: 1
                                                borderColor: Configuration.epexAverageColor

                                                upperSeries: LineSeries {
                                                    id: pricingUpperSeriesAbove
                                                }

                                                lowerSeries: LineSeries {
                                                    id: pricingLowerSeriesAbove
                                                }
                                            }
                                        }

                                        MouseArea {
                                            id: mouseArea
                                            anchors.fill: parent
                                            anchors.leftMargin: chartView.plotArea.x
                                            anchors.topMargin: chartView.plotArea.y
                                            anchors.rightMargin: chartView.width - chartView.plotArea.width - chartView.plotArea.x
                                            anchors.bottomMargin: chartView.height - chartView.plotArea.height - chartView.plotArea.y

                                            hoverEnabled: true
                                            preventStealing: tooltipping

                                            property int startMouseX: 0
                                            property bool tooltipping: false
                                            property var startDatetime: null

                                            Rectangle {
                                                height: parent.height
                                                width: 1
                                                color: Style.foregroundColor
                                                x: Math.min(mouseArea.width - 1, Math.max(0, mouseArea.mouseX))
                                                visible: (mouseArea.containsMouse || mouseArea.tooltipping)
                                            }

                                            //Mouseover Details in Graph
                                            NymeaToolTip {
                                                id: toolTip
                                                visible: (mouseArea.containsMouse || mouseArea.tooltipping)

                                                backgroundRect: Qt.rect(mouseArea.x + toolTip.x, mouseArea.y + toolTip.y, toolTip.width, toolTip.height)

                                                property double currentValueY: 0
                                                property int idx: mouseArea.mouseX
                                                property int timeSince: new Date(d.startTimeSince).getTime()
                                                property int timestamp: (new Date(d.endTimeUntil).getTime() - new Date(d.startTimeSince).getTime())

                                                property int xOnRight: Math.max(0, mouseArea.mouseX) + Style.smallMargins
                                                property int xOnLeft: Math.min(mouseArea.width, mouseArea.mouseX) - Style.smallMargins - width
                                                x: xOnRight + width < mouseArea.width ? xOnRight : xOnLeft
                                                property double maxValue: 0
                                                y: Math.min(Math.max(mouseArea.height - (maxValue * mouseArea.height / valueAxis.max) - height - Style.margins, 0), mouseArea.height - height)

                                                width: tooltipLayout.implicitWidth + Style.smallMargins * 2
                                                height: tooltipLayout.implicitHeight + Style.smallMargins * 2

                                                function getQuaterlyTimestamp(ts) {
                                                    const currTime = new Date(ts);
                                                    const currMinutes = currTime.getMinutes();
                                                    const modRes = currMinutes % 15;

                                                    if(modRes !== 0) {
                                                        if(modRes < 8) {
                                                            currTime.setMinutes(currMinutes - modRes);
                                                        }
                                                        else {
                                                            currTime.setMinutes(currMinutes + (15 - modRes));
                                                        }

                                                        currTime.setSeconds(0);
                                                        return currTime.getTime();
                                                    }
                                                    else {
                                                        return ts;
                                                    }
                                                }

                                                ColumnLayout {
                                                    id: tooltipLayout
                                                    anchors {
                                                        left: parent.left
                                                        top: parent.top
                                                        margins: Style.smallMargins
                                                    }
                                                    Label {
                                                        text: {
                                                            if(!mouseArea.containsMouse) {
                                                                return "";
                                                            }

                                                            let hoveredTime = Number.parseInt(((new Date(d.endTimeUntil).getTime() - new Date(d.startTimeSince).getTime())/Math.ceil(mouseArea.width)*toolTip.idx+new Date(d.startTimeSince).getTime())/100000) * 100000;

                                                            d.startTimeSince.toLocaleString(Qt.locale(), Locale.ShortFormat);

                                                            let currentPrice = prices[toolTip.getQuaterlyTimestamp(hoveredTime)];

                                                            if(!currentPrice)
                                                                return qsTr("No prices available, yet");

                                                            if(!currentPrice || typeof currentPrice === "undefined") {
                                                                const priceKeys = Object.keys(prices);
                                                                const lastItem = priceKeys[priceKeys.length -1];
                                                                currentPrice = prices[lastItem];
                                                            }

                                                            let val = currentPrice.start;
                                                            val = new Date(val).toLocaleString(Qt.locale(), Locale.ShortFormat);

                                                            let endVal = currentPrice.end;
                                                            endVal = new Date(endVal).toLocaleTimeString(Qt.locale(), Locale.ShortFormat) + ":00";

                                                            return val + " - " + endVal.slice(0, -3);
                                                        }
                                                        font: Style.smallFont
                                                    }
                                                    Label {
                                                        property string unit: qsTr("ct/kWh")
                                                        text: {
                                                            if(!mouseArea.containsMouse) {
                                                                return "";
                                                            }

                                                            let hoveredTime = Number.parseInt(((new Date(d.endTimeUntil).getTime() - new Date(d.startTimeSince).getTime())/Math.ceil(mouseArea.width)*toolTip.idx+new Date(d.startTimeSince).getTime())/100000) * 100000;

                                                            let currentPrice = prices[toolTip.getQuaterlyTimestamp(hoveredTime)];

                                                            if(!currentPrice)
                                                                return "";

                                                            if(!currentPrice || typeof currentPrice === "undefined") {
                                                                const priceKeys = Object.keys(prices);
                                                                const lastItem = priceKeys[priceKeys.length -1];
                                                                currentPrice = prices[lastItem];
                                                            }

                                                            let dynamicVal = currentPrice.value;

                                                            const scaleValue = valueAxis.max + (valueAxis.min > 0 ? 0 : (valueAxis.min * (-1)));

                                                            dynamicVal += valueAxis.min < 0 ? (valueAxis.min * (-1)) : 0;

                                                            toolTip.y = mouseArea.height - (mouseArea.height * (dynamicVal / scaleValue)) - toolTip.height - 2;
                                                            const val = (+currentPrice.value.toFixed(2)).toLocaleString();
                                                            return "%1 %2".arg(val).arg(unit);
                                                        }
                                                        font: Style.extraSmallFont
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Style.margins

                        Item {
                            id: spacer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }

                        CoCard {
                            id: footer
                            Layout.fillWidth: true
                            text: qsTr("Please select a car")
                            visible: false
                        }

                        Button {
                            id: savebutton
                            Layout.fillWidth: true
                            text: qsTr("Save")
                            onClicked: {
                                // if simple PV excess mode is used set the batteryLevel to 1
                                if(isAnyOfModesSelected([simple_pv_excess, no_optimization, dyn_pricing, time_controlled])) {
                                    batteryLevel.value = 1;
                                    targetPercentageSlider.value = 100;
                                }

                                // Set the endTime to maximum value for all modes except pv_optimized
                                if(isAnyOfModesSelected([pv_excess, simple_pv_excess, dyn_pricing, no_optimization, time_controlled])) {
                                    endTimeSlider.value = 24 * 60;
                                }

                                // Collect time controlled schedule data from scheduleModel
                                var chargingSchedule = [];
                                if(isAnyOfModesSelected([time_controlled])) {
                                    for (var i = 0; i < scheduleModel.count; i++) {
                                        var entry = scheduleModel.get(i);
                                        chargingSchedule.push({
                                                                  day: entry.dayKey,
                                                                  startTime: entry.hasEntry ? entry.startTime : "00:00",
                                                                  endTime: entry.hasEntry ? entry.endTime : "00:00"
                                                              });
                                    }
                                }

                                if ((endTimeSlider.value >= endTimeSlider.maximumChargingthreshhold) &&
                                        (endTimeSlider.value >= 30) &&
                                        carSelector.holdingItem !== false &&
                                        batteryLevel.value !== 0) {
                                    if (carSelector.holdingItem.stateByName("batteryLevel").value) {
                                        carSelector.holdingItem.executeAction("batteryLevel",
                                                                              [{
                                                                                   paramName: "batteryLevel",
                                                                                   value: batteryLevel.value
                                                                               }]);
                                    }
                                    pageSelectedCar = carSelector.holdingItem.name;
                                    var optimizationMode = compute_OptimizationMode();
                                    var desiredPhaseCount = 3;
                                    if (isAnyOfModesSelected([pv_optimized, simple_pv_excess]) &&
                                            thing.thingClass.interfaces.includes("phaseswitching")) {
                                        desiredPhaseCount = desiredPhaseCountDropdown.currentValue;
                                    }

                                    hemsManager.setUserConfiguration({defaultChargingMode: comboboxloadingmod.currentIndex});

                                    var configData = {
                                        optimizationEnabled: true,
                                        carThingId: carSelector.holdingItem.id,
                                        endTime: endTimeSlider.endTime.getHours() + ":" +  endTimeSlider.endTime.getMinutes() + ":00",
                                        targetPercentage: targetPercentageSlider.value,
                                        optimizationMode: optimizationMode,
                                        priceThreshold: currentValue,
                                        desiredPhaseCount: desiredPhaseCount
                                    };

                                    // Add charging schedule if time controlled mode
                                    if(isAnyOfModesSelected([time_controlled])) {
                                        configData.chargingSchedule = JSON.stringify(chargingSchedule);
                                    }

                                    hemsManager.setChargingConfiguration(thing.id, configData);
                                    optimizationPage.done();
                                    pageStack.pop();
                                } else {
                                    // footer message to notifiy the user, what is wrong
                                    if(batteryLevel.value === 0) {
                                        footer.text = qsTr("Please select a battery level greater than 0%.");
                                    } else if (carSelector.holdingItem === false) {
                                        footer.text = qsTr("Please select a car");
                                    } else if((endTimeSlider.value < endTimeSlider.maximumChargingthreshhold) ||
                                              (endTimeSlider.value < 30)) {
                                        footer.text = qsTr("Please select a valid target time");
                                    } else {
                                        footer.text = qsTr("Unknown error");
                                    }
                                    footer.visible = true;
                                }
                            }

                            function compute_OptimizationMode(){
                                var mode = comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).mode;
                                if(isAnyOfModesSelected([pv_excess, dyn_pricing, simple_pv_excess])) {
                                    var gridConsumptionOption = gridConsumptionloadingmod.model.get(gridConsumptionloadingmod.currentIndex).mode;
                                    mode = mode + gridConsumptionOption;
                                }
                                return mode;
                            }
                        }
                    }
                }
            }
        }
    }
}
