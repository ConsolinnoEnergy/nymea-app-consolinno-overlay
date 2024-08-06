import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
//import QtQuick.Controls.Styles 1.4
import QtQml 2.2
import QtGraphicalEffects 1.15
import Nymea 1.0
import QtCharts 2.3

import "qrc:/ui/components"

import "../components"
import "../delegates"
import "../devicepages"

GenericConfigPage {
    id: root

    //    function getCurrentFileName() {
    //      var e = new Error();
    //      return e.stack.match(/\/{1}([^\/]*)\./).pop()
    //    }

    property HemsManager hemsManager
    property ChargingConfiguration chargingConfiguration: hemsManager.chargingConfigurations.getChargingConfiguration(thing.id)
    property ChargingSessionConfiguration chargingSessionConfiguration: hemsManager.chargingSessionConfigurations.getChargingSessionConfiguration(thing.id)
    property UserConfiguration userconfig: hemsManager.userConfigurations.getUserConfiguration("528b3820-1b6d-4f37-aea7-a99d21d42e72")
    property Thing carThing
    property Thing thing
    property var pageSelectedCar: carThing.name === null ? qsTr("no car selected") : carThing.name
    property bool initializing: false
    property int currentValue : 0
    property double thresholdPrice: 0

    property int validSince: 0
    property int validUntil: 0
    property string averagePrice: ""
    property double currentPrice: 0
    property double lowestPrice: 0
    property double highestPrice: 0
    property var prices: ({})

    enum ChargingMode {
        NO_OPTIMIZATION = 0,
        PV_OPTIMIZED = 1,
        PV_EXCESS = 2,
        SIMPLE_PV_EXCESS = 3,
        DYN_PRICING = 4
    }

    property int no_optimization: ChargingConfigView.ChargingMode.NO_OPTIMIZATION
    property int pv_optimized: ChargingConfigView.ChargingMode.PV_OPTIMIZED
    property int pv_excess: ChargingConfigView.ChargingMode.PV_EXCESS
    property int simple_pv_excess: ChargingConfigView.ChargingMode.SIMPLE_PV_EXCESS
    property int dyn_pricing: ChargingConfigView.ChargingMode.DYN_PRICING
    property ConEMSState conState: hemsManager.conEMSState

    function timer() {
        return Qt.createQmlObject("import QtQuick 2.0; Timer {}", root);
    }

    function isCarPluggedIn()
    {
        if (thing.stateByName("pluggedIn").value)
        {
            return true
        }
        return false
    }
    
    function relPrice2AbsPrice(relPrice){
        let averagePrice = dynamicPrice.get(0).stateByName("averagePrice").value
        let minPrice = dynamicPrice.get(0).stateByName("lowestPrice").value
        let maxPrice = dynamicPrice.get(0).stateByName("highestPrice").value
        if (averagePrice == minPrice || averagePrice == maxPrice){
            return averagePrice
        }
        if (relPrice <= 0){
            thresholdPrice = averagePrice - 0.01 * relPrice * (minPrice - averagePrice)
        }else{
            thresholdPrice = 0.01 * relPrice * (maxPrice - averagePrice) + averagePrice
        }
        thresholdPrice = thresholdPrice.toFixed(2)
        return thresholdPrice
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

    function getChargingPower(){
        // get the current power of the charger and null if not available
        var power = thing.stateByName("currentPower")
        if ( power === null){
            return " – "
        }
        return power.value.toLocaleString()
    }


    title: root.thing.name
    headerOptionsVisible: false

    // Connections to update the ChargingSessionConfiguration  and the ChargingConfiguration values
    Connections {
        target: hemsManager
        onConEMSOperatingStateChanged: {
            if (conState.currentState.operating_state === 1) // RUNNING
            {
                busyOverlay.shown = false
            }
        }

        onChargingSessionConfigurationChanged:
        {
            console.info("Charging session configuration changed...")
            if (chargingSessionConfiguration.evChargerThingId === thing.id){

                batteryLevelValue.text  = chargingSessionConfiguration.batteryLevel  + " %"
                energyChargedValue.text = (+chargingSessionConfiguration.energyCharged.toFixed(2)).toLocaleString() + " kWh"
                energyBatteryValue.text = (+chargingSessionConfiguration.energyBattery.toFixed(2)).toLocaleString() + " kWh"
                if (chargingSessionConfiguration.state === 2){
                    var duration = chargingSessionConfiguration.duration
                    var hours   = Math.floor(duration/3600)
                    var minutes = Math.floor((duration - hours*3600)/60)
                    durationValue.text = (hours === 0) ? minutes +  "min " : hours+ "h " + minutes + "min"

                }
                // Running
                if (chargingConfiguration.optimizationEnabled && (chargingSessionConfiguration.state == 2)){
                    console.info("Going into running mode...")
                    //batteryLevelRowLayout.visible = true
                    //energyBatteryLayout.visible = true
                    if (settings.showHiddenOptions)
                    {
                        maxCurrentRowLayout.visible = true
                        measuredCurrentRowLayout.visible = true
                    }
                    energyChargedLayout.visible = true
                    initializing = false
                }
                // Pending
                if (chargingConfiguration.optimizationEnabled && (chargingSessionConfiguration.state == 6)){
                    console.info("Going into pending mode...")
                    //batteryLevelRowLayout.visible = true
                    //energyBatteryLayout.visible = true
                    if (settings.showHiddenOptions)
                    {
                        maxCurrentRowLayout.visible = true
                        measuredCurrentRowLayout.visible = true
                    }
                    energyChargedLayout.visible = true
                    initializing = false
                }

            }


        }

        onChargingConfigurationChanged:
        {
            console.info("Charging session configuration changed...")
            if (chargingConfiguration.evChargerThingId === thing.id){
                if (!chargingConfiguration.optimizationEnabled){
                    batteryLevelRowLayout.visible = false
                    energyBatteryLayout.visible = false
                    maxCurrentRowLayout.visible = false
                    measuredCurrentRowLayout.visible = false
                    energyChargedLayout.visible = false
                    status.visible = false
                    initializing = false
                }
                else if(chargingConfiguration.optimizationEnabled){
                    if (chargingIsAnyOf([simple_pv_excess, no_optimization, dyn_pricing]))
                    {
                        status.visible = thing.stateByName("pluggedIn")
                        initializing = true
                        batteryLevelRowLayout.visible = false
                        energyBatteryLayout.visible = false
                        if (settings.showHiddenOptions)
                        {
                            maxCurrentRowLayout.visible = true
                            measuredCurrentRowLayout.visible = true
                        }
                        energyChargedLayout.visible = true
                        batteryLevelValue.text  = 0 + " %"
                        energyChargedValue.text = 0 + " kWh"
                        energyBatteryValue.text = 0 + " kWh"
                        durationValue.text = " — "
                    }
                    else{
                        status.visible = true
                        initializing = true
                        batteryLevelRowLayout.visible = true
                        energyBatteryLayout.visible = true
                        if (settings.showHiddenOptions)
                        {
                            maxCurrentRowLayout.visible = true
                            measuredCurrentRowLayout.visible = true
                        }
                        measuredCurrentRowLayout.visible = true
                        energyChargedLayout.visible = true
                        batteryLevelValue.text  = 0 + " %"
                        energyChargedValue.text = 0 + " kWh"
                        energyBatteryValue.text = 0 + " kWh"
                        durationValue.text = " — "

                    }
                    if (chargingIsAnyOf([dyn_pricing])){
                        priceLimit.text = priceLimit.getText()
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

    ThingClassesProxy{
        id: thingClassesProxy
        engine: _engine
        filterInterface: "electricvehicle"
        includeProvidedInterfaces: true
        groupByInterface: true
    }

    ThingsProxy {
        id: dynamicPrice
        engine: _engine
        shownInterfaces: ["dynamicelectricitypricing"]
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
    }

    function chargingIsAnyOf(modes)
    {
        return modes.includes(getChargingMode(chargingConfiguration.optimizationMode))
    }

    // 1234 -> mode==1; option1==2; option2==3; option3==4
    function getChargingModeOpts(opti_mode){
        return([(opti_mode/100) % 10, (opti_mode/10) % 10, opti_mode % 10])
    }


    content: [
        Item {
            anchors.fill: parent

            Flickable{
                id: chargingflickable

                clip: true
                anchors.top: parent.top
                width: app.width
                height: app.height
                contentHeight: infoColumnLayout.implicitHeight + stateOfLoadingColumnLayout.implicitHeight + statusColumnLayout.implicitHeight + header.height + 100
                contentWidth: app.width

                ColumnLayout {
                    id: infoColumnLayout

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: app.margins
                    anchors.margins: app.margins

                    RowLayout{
                        Label {
                            id: pluggedInLabel

                            Layout.fillWidth: true
                            text: qsTr("Car plugged in:")
                        }

                        Rectangle{
                            id: pluggedInLight

                            width: 17
                            height: 17
                            Layout.rightMargin: 0
                            Layout.alignment: Qt.AlignRight
                            color: isCarPluggedIn() ? "#87BD26" : "#CD5C5C"
                            border.color: "black"
                            border.width: 0
                            radius: width*0.5
                        }
                    }

                    RowLayout{
                        id: noPluggedInRowLayout

                        visible: !(isCarPluggedIn())

                        Label{
                            id: noPluggedInLabel
                            text: qsTr("No car is connected at the moment. Please connect a car.")
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignCenter
                            wrapMode: Text.WordWrap
                            Layout.preferredWidth: app.width
                        }
                    }

                    RowLayout{
                        id: simulationSwitchLayout

                        Layout.fillWidth: true
                        visible: !(isCarPluggedIn()) && (simulationEvProxy.count > 0)  && (thing.thingClassId.toString() === "{21a48e6d-6152-407a-a303-3b46e29bbb94}")

                        Label{
                            id: simulationLabel
                            text: qsTr("Activate simulated car")
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }

                        Switch{
                            id: simulationSwitch

                            onClicked: {
                                if (simulationSwitch.checked){
                                    simulationEvProxy.get(0).executeAction("pluggedIn", [{paramName: "pluggedIn", value: true}])
                                }
                                else{
                                    simulationEvProxy.get(0).executeAction("pluggedIn", [{paramName: "pluggedIn", value: false}])
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: stateOfLoadingColumnLayout

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: infoColumnLayout.top
                    anchors.topMargin: infoColumnLayout.height + 30
                    anchors.margins: app.margins

                    RowLayout{
                        Label{
                            id: loadingState

                            Layout.fillWidth: true
                            text: qsTr("Charging configuration")
                            font.pixelSize: 22
                            font.bold: true
                        }
                    }

                    RowLayout{
                        Layout.topMargin: 15
                        visible:  chargingIsAnyOf([pv_optimized]) ? true: false

                        Label{
                            id: selectedCarLabel
                            Layout.fillWidth: true
                            text: qsTr("Car")
                        }

                        Label{
                            id: selectedCar

                            text: qsTr(isCarPluggedIn() ? (chargingConfiguration.optimizationEnabled ? pageSelectedCar: " — " )  : " — ")
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 0
                        }
                    }

                    RowLayout{
                        Layout.topMargin: 15

                        Label{
                            id: loadingModesLabel

                            Layout.fillWidth: true
                            text: qsTr("Charging mode")
                        }

                        Label{
                            id: loadingModes

                            text: chargingConfiguration.optimizationEnabled ? selectMode(chargingConfiguration.optimizationMode) : " — "
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 0

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
                            }
                        }
                    }

                    RowLayout{
                        Layout.topMargin: 15
                        visible:  chargingIsAnyOf([simple_pv_excess, dyn_pricing])
                        Label{
                            id: ongridConsumptionLabel
                            visible: chargingIsAnyOf([dyn_pricing])
                            Layout.fillWidth: true
                            text: qsTr("Pausing")
                        }

                        Label{
                            visible: chargingIsAnyOf([simple_pv_excess])
                            Layout.fillWidth: true
                            text: qsTr("On grid consumption")
                        }

                        Label{
                            id: ongridConsumption
                            text: getText()
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 0
                            function getText(){
                                if (getChargingModeOpts(chargingConfiguration.optimizationMode)[0] === 0)
                                {
                                    return qsTr("Minimal current")
                                }
                                else if (getChargingModeOpts(chargingConfiguration.optimizationMode)[0] === 2)
                                {
                                    return qsTr("enabled")
                                }
                            }

                        }
                    }

                    RowLayout{
                        Layout.topMargin: 15
                        visible: chargingIsAnyOf([dyn_pricing])
                        Label{
                            id: priceLimitLabel

                            Layout.fillWidth: true
                            text: qsTr("Price limit")
                        }

                        Label{
                            id: priceLimit
                            property double priceThresholdProcentage: chargingConfiguration.priceThreshold
                            text: getText()
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 0

                            Component.onCompleted: {
                                thresholdPrice = relPrice2AbsPrice(priceThresholdProcentage)
                                currentValue = (currentValue === 0 && chargingConfiguration.priceThreshold === 0 ? -10 : chargingConfiguration.priceThreshold )
                                priceLimit.text = getText()
                            }

                            function getText(){
                                if (priceThresholdProcentage < 0)
                                {
                                    return (thresholdPrice.toLocaleString() + " ct/kWh ") + "(↓" +  (Math.abs(priceThresholdProcentage.toLocaleString()) + " %)")
                                }
                                else{
                                    return (thresholdPrice.toLocaleString() + " ct/kWh ") + "(↑" +  (Math.abs(priceThresholdProcentage.toLocaleString()) + " %)")
                                }
                            }

                            // Probably not needed anymore, should be checked at next refactoring.
                            // Leaving this untouched for now
                            Timer{
                               property bool firstRun: false
                               repeat: true
                               interval: firstRun == false ? 100 : 10000
                               onTriggered: {
                                   firstRun = true
                                   thresholdPrice = relPrice2AbsPrice(priceThresholdProcentage)
                                   priceLimit.text = getText()
                               }
                            }
                        }
                    }

                    RowLayout{
                        Layout.topMargin: 15
                        visible: !([pv_excess, simple_pv_excess, no_optimization, dyn_pricing].includes(getChargingMode(chargingConfiguration.optimizationMode)))

                        Label{
                            id: targetChargeReachedLabel

                            Layout.fillWidth: true
                            text: qsTr("Ending time")
                        }

                        Label{
                            id: targetChargeReached
                            property var today: new Date()
                            property var tomorrow: new Date( today.getTime() + 1000*60*60*24)
                            // determine whether it is today or tomorrow
                            property var date: (parseInt(chargingConfiguration.endTime[0]+chargingConfiguration.endTime[1]) < today.getHours() ) | ( ( parseInt(chargingConfiguration.endTime[0]+chargingConfiguration.endTime[1]) === today.getHours() ) & parseInt(chargingConfiguration.endTime[3]+chargingConfiguration.endTime[4]) >= today.getMinutes() ) ? tomorrow : today

                            text: isCarPluggedIn() ? (chargingConfiguration.optimizationEnabled ? date.toLocaleString(Qt.locale("de-DE"), "dd.MM") + "  " + Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime, "H:m:ss").toLocaleString(Qt.locale("de-DE"), "HH:mm") : " — "  )   : " — "
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 0

                        }
                    }

                    RowLayout{
                        Layout.topMargin: 10
                        visible: chargingIsAnyOf([dyn_pricing])

                        Label{
                            Layout.fillWidth: true
                            text: qsTr("Current Price")
                        }

                        Label{
                            id: currentMarketPrice
                            text: qsTr("%1 ct/kWh").arg((Math.round(currentPrice * 100) / 100).toLocaleString());
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 0

                            Component.onCompleted: {
                                currentPrice = dynamicPrice.get(0).stateByName("currentMarketPrice").value;
                            }
                        }
                    }

                    RowLayout{
                        Layout.topMargin: 10
                        visible: chargingIsAnyOf([dyn_pricing])
                        id: belowPriceLimit
                        Label{
                            Layout.fillWidth: true
                            text: qsTr("Below price limit")
                        }

                        Rectangle{
                            width: 17
                            height: 17
                            Layout.rightMargin: 0
                            Layout.alignment: Qt.AlignRight
                            color: (currentPrice <= thresholdPrice) ? "#87BD26" : "#CD5C5C"
                            border.color: "black"
                            border.width: 0
                            radius: width*0.5
                        }
                    }

                    RowLayout{
                        visible: chargingIsAnyOf([simple_pv_excess, dyn_pricing, no_optimization]) ? false : true
                        Layout.topMargin: 15

                        Label{
                            id: targetChargeLabel

                            Layout.fillWidth: true
                            text: qsTr("Target charge")
                        }

                        Label{
                            id: targetCharge

                            text: isCarPluggedIn() ?(chargingConfiguration.optimizationEnabled ? chargingConfiguration.targetPercentage + " %" : " — " ) : " — "
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 0
                        }
                    }
                }

                ColumnLayout {
                    id: statusColumnLayout

                    visible: isCarPluggedIn()
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: stateOfLoadingColumnLayout.top
                    anchors.topMargin: stateOfLoadingColumnLayout.height + 50
                    anchors.margins: app.margins
                    spacing: 15


                    RowLayout{

                        Label{
                            id: statusLabel

                            Layout.fillWidth: true
                            text: qsTr("Status")
                            font.pixelSize: 22
                            font.bold: true
                        }

                        ColumnLayout{
                            Layout.fillWidth: true
                            spacing: 0
                            visible: (chargingConfiguration.optimizationEnabled && isCarPluggedIn())

                            Rectangle{
                                id: status

                                property int state: chargingSessionConfiguration.state
                                width: 120
                                height: description.height + 10
                                Layout.alignment: Qt.AlignRight


                                //check if plugged in                 check if current power == 0           else show the current state the session is in atm
                                color:  isCarPluggedIn() ? (initializing ? "blue" : state === 2 ? "green" : state === 3 ? "#66a5e2" : state === 4 ? "grey" : "lightgrey" ) : "lightgrey"
                                radius: width*0.1

                                Label{
                                    id: description
                                    text: initializing ? qsTr("Initialising") : (status.state === 2 ? qsTr("Running") : (status.state === 3 ? qsTr("Finished") : (status.state === 4 ? qsTr("Interrupted") : (status.state === 6 ? qsTr("Pending") :  qsTr("Failed")  ))))
                                    color: "white"
                                    anchors.centerIn: parent
                                }
                            }
                        }
                    }

                    RowLayout{
                        id: noLoadingRowLayout

                        visible: !(chargingConfiguration.optimizationEnabled && isCarPluggedIn())

                        Label{
                            id: noLoadingLabel

                            text: qsTr("Charging deactivated. Please choose a charging mode.")
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignCenter
                            wrapMode: Text.WordWrap
                        }
                    }

                    RowLayout{
                        function isVisible() {
                            if (chargingIsAnyOf([simple_pv_excess, dyn_pricing, no_optimization]))
                            {
                                return false
                            }
                            if (!(chargingConfiguration.optimizationEnabled && isCarPluggedIn())){
                                return false
                            }
                            return true
                        }

                        id: batteryLevelRowLayout
                        visible: isVisible()
                        Label{
                            id: batteryLevelLabel

                            Layout.fillWidth: true
                            text: qsTr("Battery level")

                        }

                        Label{
                            id: batteryLevelValue

                            text: chargingSessionConfiguration.batteryLevel + " %"
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 0
                        }
                    }

                    RowLayout{
                        function isVisible() {
                            if (chargingIsAnyOf([simple_pv_excess, dyn_pricing, no_optimization]))
                            {
                                return false
                            }
                            if (!(chargingConfiguration.optimizationEnabled && isCarPluggedIn())){
                                return false
                            }


                            return true
                        }

                        id: energyBatteryLayout
                        visible: isVisible()
                        Label{
                            id: energyBatteryLabel

                            Layout.fillWidth: true
                            text: qsTr("Battery charge")

                        }

                        Label{
                            id: energyBatteryValue

                            text: (+chargingSessionConfiguration.energyBattery.toFixed(2)).toLocaleString() + " kWh"
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 0
                        }
                    }

                    RowLayout{
                        id: chargingPowerRowLayout

                        visible: chargingConfiguration.optimizationEnabled && isCarPluggedIn()

                        Label{
                            id: chargingPowerLabel

                            Layout.fillWidth: true
                            text: qsTr("Charging power")
                        }

                        Label{
                            id: chargingPowerValue
                            text: (initializing ? 0 : (+getChargingPower()).toLocaleString()) + " W"
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 0
                        }
                    }

                    RowLayout{
                        id: maxCurrentRowLayout

                        visible: chargingConfiguration.optimizationEnabled && isCarPluggedIn() && settings.showHiddenOptions

                        Label{
                            id: maxCurrentLabel

                            Layout.fillWidth: true
                            text: qsTr("Target charging current")
                        }

                        Label{
                            id: maxCurrentValue
                            text: (initializing ? 0 : thing.stateByName("maxChargingCurrent").value) + " A"
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 0
                        }
                    }
                    RowLayout{
                        id: measuredCurrentRowLayout

                        visible: chargingConfiguration.optimizationEnabled && isCarPluggedIn() && settings.showHiddenOptions

                        Label{
                            id: measuredCurrentLabel
                            Layout.fillWidth: true
                            text: qsTr("Actual charging current")
                        }

                        Label{
                            id: measuredCurrentValue
                            text: (initializing ? 0 : calcChargingCurrent()) + " A"
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 0
                        }
                    }

                    RowLayout{
                        id: energyChargedLayout

                        visible: (chargingConfiguration.optimizationEnabled && isCarPluggedIn())

                        Label{
                            id: alreadyLoadedLabel
                            Layout.fillWidth: true
                            text: qsTr("Energy charged")

                        }

                        Label{
                            id: energyChargedValue

                            text: (+chargingSessionConfiguration.energyCharged.toFixed(2)).toLocaleString() + " kWh"
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 0
                        }
                    }

                    RowLayout{
                        id: durationLayout

                        visible: (chargingConfiguration.optimizationEnabled && isCarPluggedIn())

                        Label{
                            id: durationLabel

                            Layout.fillWidth: true
                            text: qsTr("Time elapsed")

                        }

                        Label{
                            id: durationValue

                            property int duration: chargingSessionConfiguration.duration
                            property int hours: duration/3600
                            property int minutes: (duration - hours*3600)/60
                            text: (hours === 0) ? minutes +  "min " : hours+ "h " + minutes + "min"
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 0
                        }
                    }

                    RowLayout{
                        id: createLoadingSchedule

                        Layout.fillWidth: true
                        visible: !cancelLoadingSchedule.visible

                        Button{
                            Layout.fillWidth: true
                            text: qsTr("Configure Charging")
                            enabled: isCarPluggedIn()

                            onClicked: {
                                if (isCarPluggedIn()){
                                    var page = pageStack.push(optimizationComponent , { hemsManager: hemsManager, thing: thing })
                                    page.done.connect(function(){
                                        busyOverlay.shown = true

                                    })
                                }
                            }
                        }
                    }



                    RowLayout{
                        id: cancelLoadingSchedule

                        Layout.fillWidth: true
                        visible: chargingConfiguration.optimizationEnabled && isCarPluggedIn()

                        Button{
                            Layout.fillWidth: true
                            text:  status.state == 3 ? qsTr("Configure charging mode") : qsTr("Reconfigure charging mode" )
                            onClicked: {
                                hemsManager.setChargingConfiguration(thing.id, {optimizationEnabled: false, optimizationMode:9})
                                busyOverlay.shown = true
                            }
                        }
                    }
                }
            }

            Component{
                id: optimizationComponent

                Page{
                    signal done()
                    id: optimizationPage
                    property HemsManager hemsManager
                    property ChargingConfiguration chargingConfiguration: hemsManager.chargingConfigurations.getChargingConfiguration(thing.id)
                    property Thing thing

                    function getSelectedMode(){
                        return getChargingMode(comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).mode)
                    }

                    function isAnyOfModesSelected(modes)
                    {
                        var selected_mode = getSelectedMode()
                        return (modes.includes(selected_mode))
                    }

                    Component.onCompleted:{
                        endTimeSlider.feasibilityText()
                    }

                    header: NymeaHeader {
                        id: header
                        text: qsTr("Configure charging mode")
                        backButtonVisible: true
                        onBackPressed: pageStack.pop()
                    }

                    ColumnLayout {
                        spacing: 1
                        id: optimizationColumnLayout
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: app.margins
                        anchors.rightMargin: app.margins
                        anchors.margins: app.margins

                        RowLayout {
                            Layout.fillWidth: true
                            id: evRow

                            Label {
                                id: evLabel
                                //Layout.fillWidth: true
                                text: qsTr("Electric car:")
                            }

                            ConsolinnoItemDelegate {
                                id: carSelector

                                Layout.fillWidth: true
                                //Layout.maximumWidth: 300
                                Layout.minimumWidth: 50
                                Layout.leftMargin: 20
                                Layout.alignment: Qt.AlignRight

                                text:  evProxy.getThing(userconfig.lastSelectedCar) ? evProxy.getThing(userconfig.lastSelectedCar).name : qsTr("Select/Add Car")
                                holdingItem: evProxy.getThing(userconfig.lastSelectedCar) ? evProxy.getThing(userconfig.lastSelectedCar) : false
                                onClicked: {

                                    var page = pageStack.push("../thingconfiguration/CarInventory.qml")
                                    page.done.connect(function(selectedCar){

                                        footer.visible = false
                                        hemsManager.setUserConfiguration({lastSelectedCar: selectedCar.id})
                                        carSelector.text = selectedCar.name
                                        holdingItem = selectedCar
                                        batteryLevel.value = 0


                                    })

                                    page.back.connect(function(){
                                        pageStack.pop()
                                        carSelector.text = evProxy.getThing(userconfig.lastSelectedCar) ? evProxy.getThing(userconfig.lastSelectedCar).name : qsTr("Select/Add Car")
                                        if (!(evProxy.getThing(userconfig.lastSelectedCar))){
                                            holdingItem = false
                                        }

                                    })

                                }
                                onHoldingItemChanged:{
                                    if (holdingItem !== false){
                                        endTimeSlider.computeFeasibility()
                                        endTimeSlider.feasibilityText()
                                    }
                                }
                            }
                        }

                        RowLayout{
                            Layout.preferredWidth: app.width
                            Layout.topMargin: 10

                            RowLayout{
                                id: chargingModeRowid

                                Label {
                                    id: chargingModeid

                                    text: qsTr("Charging mode: ")
                                }

                                InfoButton{
                                    id: chargingModeInfoButton
                                    Layout.rightMargin: 15
                                    push: "ChargingModeInfo.qml"
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop
                                }
                            }


                            ComboBox {
                                id: comboboxloadingmod
                                Layout.fillWidth: true
                                model: ListModel{
                                    id: dynamicModel
                                    ListElement{key: qsTr("Charge always"); value: "No Optimization"; mode: 0}
                                    ListElement{key: qsTr("Solar only"); value: "Simple-Pv-Only"; mode: 3000;}
                                    ListElement{key: qsTr("Next trip"); value: "Pv-Optimized"; mode: 1000;}
                                    ListElement{key: qsTr("Dynamic pricing"); value: "Dynamic-pricing"; mode: 4000;}
                                }

                                function addDynamicComboBoxItems() {
                                    if (dynamicPrice.count === 0){
                                        dynamicModel.remove(3)
                                    }
                                }

                                textRole: "key"
                                contentItem: Text{
                                    text: parent.displayText
                                    width: parent.width
                                    color: Material.foreground
                                    verticalAlignment: Text.AlignVCenter;
                                    horizontalAlignment: Text.AlignLeft;
                                    leftPadding: app.margins
                                    elide: Text.ElideRight
                                }

                                currentIndex: (userconfig.defaultChargingMode == 3 && dynamicPrice.count == 0) ? userconfig.defaultChargingMode - 1 : userconfig.defaultChargingMode
                                onCurrentIndexChanged:
                                {
                                    endTimeSlider.computeFeasibility()
                                    endTimeSlider.feasibilityText()
                                    comboboxloadingmod.currentIndex === 3 ? gridConsumptionloadingmod.currentIndex = 1 : gridConsumptionloadingmod.currentIndex = 0
                                }

                                Component.onCompleted: {
                                    addDynamicComboBoxItems();
                                    comboboxloadingmod.currentIndex === 3 ? gridConsumptionloadingmod.currentIndex = 1 : gridConsumptionloadingmod.currentIndex = 0
                                }
                            }
                        }

                        ColumnLayout{
                            visible: isAnyOfModesSelected([pv_optimized, pv_excess])
                            //Slider 1
                            RowLayout{
                                visible: isAnyOfModesSelected([pv_optimized, pv_excess])
                                spacing: 0
                                Layout.topMargin: 10

                                ColumnLayout{
                                    Row{
                                        Label{
                                            id: batteryid

                                            text: qsTr("Battery level: ") + batteryLevel.value +" %"
                                        }

                                        InfoButton{
                                            push: "BatteryLevel.qml"
                                            anchors.left: batteryid.right
                                            anchors.leftMargin:  5
                                        }
                                    }

                                    Slider {
                                        id: batteryLevel

                                        Layout.fillWidth: true
                                        from: 0
                                        to: 100
                                        stepSize: 1
                                        // when entering the Optimization page -> get values from holdingItem (selected Car)
                                        //                            Component.onCompleted:
                                        //                            {
                                        //                                    if (carSelector.holdingItem !== false){
                                        //                                        value = carSelector.holdingItem.stateByName("batteryLevel").value
                                        //                                    }
                                        //                            }

                                        onPositionChanged:
                                        {
                                            // if the "new Car" option is not picked do something
                                            if (carSelector.holdingItem !== false){
                                                if (value  >= targetPercentageSlider.value)
                                                {
                                                    if (value === 100){
                                                        value = 99
                                                    }

                                                    targetPercentageSlider.value = value +1
                                                }

                                                endTimeSlider.computeFeasibility()
                                                endTimeSlider.feasibilityText()
                                            }
                                        }
                                    }
                                }
                            }
                            //Slider 2
                            RowLayout{
                                visible:  isAnyOfModesSelected([pv_optimized, pv_excess])
                                ColumnLayout {
                                    spacing: 0
                                    Row{
                                        Label {
                                            id: targetCharge

                                            text: qsTr("Target charge %1%").arg(targetPercentageSlider.value)
                                        }

                                        InfoButton{
                                            push: "TargetChargeInfo.qml"
                                            anchors.left: targetCharge.right
                                            anchors.leftMargin:  5
                                        }
                                    }

                                    Slider {
                                        id: targetPercentageSlider

                                        Layout.fillWidth: true
                                        from: 0
                                        to: 100
                                        stepSize: 1
                                        value: 0

                                        Component.onCompleted: {
                                            if (carSelector.holdingItem !== false){
                                                //                                    value = chargingConfiguration.targetPercentage
                                                endTimeSlider.computeFeasibility()
                                                endTimeSlider.feasibilityText()
                                            }
                                        }
                                        onPositionChanged: {
                                            if (carSelector.holdingItem !== false){
                                                endTimeSlider.computeFeasibility()
                                                endTimeSlider.feasibilityText()

                                                if (value <= batteryLevel.value)
                                                {
                                                    if (value === 100){
                                                        value = batteryLevel.value
                                                    }else{
                                                        value = batteryLevel.value + 1
                                                    }
                                                }
                                                //                                    if (value == 0){

                                                //                                        value = 1
                                                //                                    }

                                            }
                                        }
                                    }
                                }
                            }
                            //Slider 3 Label
                            RowLayout{
                                Layout.fillWidth: true
                                visible:  isAnyOfModesSelected([pv_optimized])

                                Label {
                                    id: endTimeLabel

                                    Layout.fillWidth: true
                                    property var today: new Date()
                                    property var endTime: new Date(today.getTime() + endTimeSlider.value * 60000)
                                    text: qsTr("Ending time: ") + endTime.toLocaleString(Qt.locale("de-DE"), "dd.MM HH:mm")

                                    function endTimeValidityPrediction(d){
                                        switch (d){
                                        case 1:
                                            feasibilityMessage.visible = true

                                            break
                                        case 2:
                                            feasibilityMessage.visible = false
                                            break

                                        }
                                        return
                                    }
                                }
                            }

                            //Slider 3
                            RowLayout{
                                Layout.fillWidth: true
                                //Layout.alignment: Qt.AlignTop
                                visible:   isAnyOfModesSelected([pv_optimized])

                                Slider {
                                    id: endTimeSlider

                                    Layout.fillWidth: true
                                    implicitWidth: backgroundEndTimeSlider.implicitWidth
                                    property int chargingConfigHours: Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime , "HH:mm:ss").getHours()
                                    property int chargingConfigMinutes: Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime , "HH:mm:ss").getMinutes()
                                    property int nextDay: chargingConfigHours*60 + chargingConfigMinutes - endTimeLabel.today.getHours()*60 - endTimeLabel.today.getMinutes() < 0 ? 1 : 0
                                    property int targetSOC: targetPercentageSlider.value

                                    property real minimumChargingthreshhold
                                    property real maximumChargingthreshhold

                                    property var batteryLevel
                                    property var capacityInAh
                                    property var batteryContentInAh
                                    property var minChargingCurrent

                                    from: 0
                                    to: 24*60
                                    stepSize: 1
                                    //         from config hours      from config minutes         current hours                    current minutes                 add a day if negative (since it means it is the next day)
                                    value: chargingConfigHours*60 + chargingConfigMinutes - endTimeLabel.today.getHours()*60 - endTimeLabel.today.getMinutes() + nextDay*24*60

                                    background: ChargingConfigSliderBackground{
                                        id: backgroundEndTimeSlider

                                        Layout.fillWidth: true
                                        infeasibleSectionWidth: Math.min(endTimeSlider.width * endTimeSlider.maximumChargingthreshhold/(24*60), endTimeSlider.width )
                                        feasibleSectionWidth:  Math.min(endTimeSlider.width - infeasibleSectionWidth, endTimeSlider.width)
                                    }

                                    onPositionChanged: {
                                        feasibilityText()
                                    }

                                    function feasibilityText(){
                                        if (value < maximumChargingthreshhold){
                                            endTimeLabel.endTimeValidityPrediction(1)
                                        }
                                        else{
                                            endTimeLabel.endTimeValidityPrediction(2)
                                        }
                                    }

                                    function computeFeasibility(){

                                        // TODo: Determine charging Voltage of wallbox
                                        //       How many phases does the wallbox have
                                        if (carSelector.holdingItem !== false){
                                            var maxChargingCurrent = thing.stateByName("maxChargingCurrent").maxValue


                                            var loadingVoltage = thing.stateByName("phaseCount").value * 230

                                            for (let i = 0; i < carSelector.holdingItem.thingClass.stateTypes.count; i++){

                                                var thingStateId = carSelector.holdingItem.thingClass.stateTypes.get(i).id

                                                if (carSelector.holdingItem.thingClass.stateTypes.get(i).name === "capacity" ){
                                                    // capacity in KWh
                                                    var capacity = carSelector.holdingItem.states.getState(thingStateId).value
                                                    capacityInAh = (capacity*1000)/loadingVoltage
                                                }
                                                if (carSelector.holdingItem.thingClass.stateTypes.get(i).name === "minChargingCurrent" ){

                                                    minChargingCurrent = carSelector.holdingItem.states.getState(thingStateId).value
                                                }

                                            }

                                            batteryContentInAh = capacityInAh * batteryLevel.value/100

                                            var targetSOCinAh = capacityInAh * targetSOC/100

                                            var necessaryTimeinHMinCharg = (targetSOCinAh - batteryContentInAh)/minChargingCurrent
                                            var necessaryTimeinHMaxCharg = (targetSOCinAh - batteryContentInAh)/maxChargingCurrent


                                            minimumChargingthreshhold = necessaryTimeinHMinCharg*60
                                            maximumChargingthreshhold = necessaryTimeinHMaxCharg*60

                                        }
                                    }
                                }
                            }

                            //Slider error
                            RowLayout{
                                visible: isAnyOfModesSelected([pv_optimized])

                                Label
                                {
                                    id: feasibilityMessage
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignRight
                                    text: qsTr("In the currently selected timeframe the charging process is not possible. Please reduce the target charge or increase the end time")
                                    Material.foreground: Material.Red
                                    visible: false
                                    wrapMode: Text.WordWrap
                                }
                            }

                        }


                        RowLayout {
                            Layout.preferredWidth: app.width
                            Layout.topMargin: 10

                            RowLayout {
                                Layout.fillWidth: true

                                Label{
                                    id: gridConsumptionLabel
                                    visible: isAnyOfModesSelected([pv_excess, simple_pv_excess])
                                    text: qsTr("Behaviour on grid consumption:")
                                }

                                InfoButton{
                                    id: gridConsumptionInfoButton
                                    visible: isAnyOfModesSelected([pv_excess, simple_pv_excess])
                                    push: "GridConsumptionInfo.qml"
                                    anchors.left: gridConsumptionLabel.right
                                    anchors.leftMargin:  5
                                }

                                Label {
                                    id: pausingModeid
                                    visible: isAnyOfModesSelected([dyn_pricing])
                                    text: qsTr("Pausing: ")
                                }

                                InfoButton{
                                    id: pausingModeInfoButton
                                    visible: isAnyOfModesSelected([dyn_pricing])
                                    push: "PausingInfo.qml"
                                    anchors.left: pausingModeid.right
                                    anchors.leftMargin:  5
                                }

                            }
                        }

                        RowLayout {
                            Layout.preferredWidth: app.width
                            Layout.topMargin: 10

                            ComboBox {
                                visible: isAnyOfModesSelected([pv_excess, dyn_pricing, simple_pv_excess])
                                id: gridConsumptionloadingmod
                                Layout.fillWidth: true
                                model: ListModel{
                                    ListElement{key: qsTr("Charge with minimum current"); mode: 0}
                                    ListElement{key: qsTr("Pause charging"); mode: 200}
                                }
                                textRole: "key"
                                contentItem: Text{
                                    text: parent.displayText
                                    width: parent.width
                                    color: Material.foreground
                                    verticalAlignment: Text.AlignVCenter;
                                    horizontalAlignment: Text.AlignLeft;
                                    leftPadding: app.margins
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        RowLayout {
                            Layout.preferredWidth: app.width
                            Layout.topMargin: 5
                            visible: isAnyOfModesSelected([dyn_pricing])

                            RowLayout {

                                Label {
                                    id: priceLimitigId

                                    text: qsTr("Price limit: ")
                                }

                                InfoButton{
                                    id: priceLimitInfoButton

                                    push: "PriceLimitInfo.qml"
                                    anchors.left: priceLimitigId.right
                                    anchors.leftMargin:  5
                                }

                            }
                        }

                        RowLayout {
                            Layout.preferredWidth: app.width
                            Layout.topMargin: 5
                            visible: isAnyOfModesSelected([dyn_pricing])

                            RowLayout {
                                id: priceRow

                                Label {
                                    id: averagePriceLimitigId
                                    text: qsTr("average price: ")
                                    Layout.fillWidth: true
                                    Layout.rightMargin: 10
                                }

                                ToolBar {

                                    background: Rectangle {
                                        color: "transparent"
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        property var debounceTimer: Timer {
                                            interval: 1000
                                            repeat: false
                                            running: false
                                            onTriggered: {
                                                pricingCurrentLimitSeries.clear();
                                                pricingUpperSeriesAbove.clear();
                                                pricingLowerSeriesAbove.clear();
                                                consumptionSeries.insertEntry(dynamicPrice.get(0).stateByName("priceSeries").value, true);
                                            }
                                        }

                                        function redrawChart() {
                                            debounceTimer.stop();
                                            debounceTimer.start();
                                        }

                                        ToolButton {
                                            text: qsTr("-")
                                            onClicked: {
                                                currentValue = currentValue > -100 ? currentValue - 1 : -100
                                                priceRow.getThresholdPrice()
                                                parent.redrawChart();
                                            }
                                            onPressAndHold: {
                                                currentValue = currentValue > -100 ? currentValue - 10 : -100
                                                priceRow.getThresholdPrice()
                                                parent.redrawChart();
                                            }
                                        }

                                        TextField {
                                            id: currentValueField
                                            text: currentValue
                                            horizontalAlignment: Qt.AlignHCenter
                                            verticalAlignment: Qt.AlignVCenter
                                            Layout.preferredWidth: 50
                                            validator: RegExpValidator {
                                                regExp: /^-?(100|[1-9]?[0-9])$/
                                            }
                                            onTextChanged: {
                                                currentValue = currentValueField.text
                                                priceRow.getThresholdPrice()
                                                parent.redrawChart();
                                            }
                                        }

                                        Label {
                                            text: "%"
                                        }

                                        ToolButton { 
                                            text: qsTr("+")
                                            onClicked: {
                                                currentValue = currentValue < 100 ? currentValue + 1 : 100
                                                priceRow.getThresholdPrice()
                                                parent.redrawChart();
                                            }
                                            onPressAndHold: {
                                                currentValue = currentValue < 100 ? currentValue + 10 : 100
                                                priceRow.getThresholdPrice()
                                                parent.redrawChart();
                                            }
                                        }

                                    }

                                }

                                Component.onCompleted: {
                                    getThresholdPrice()
                                }

                                function getThresholdPrice(){
                                    let currentValue = parseInt(currentValueField.text)
                                    thresholdPrice = relPrice2AbsPrice(currentValue)
                                }

                            }

                        }




                        RowLayout {
                            Layout.preferredWidth: parent.width
                            Layout.topMargin: 5
                            visible: isAnyOfModesSelected([dyn_pricing])
                            Label {
                                text: qsTr("Currently corresponds to a market price of %1 ct/kWh.").arg(thresholdPrice.toLocaleString())
                                font.pixelSize: 13
                            }
                        }

                        Label {
                            id: footer

                            Layout.fillWidth: true
                            Layout.leftMargin: app.margins
                            Layout.rightMargin: app.margins
                            wrapMode: Text.WordWrap
                            font.pixelSize: app.smallFont
                            text: qsTr("please select a car")
                            visible: false
                        }

                        Item {
                            id: rootChart
                            Layout.fillWidth: true
                            Layout.fillHeight: true
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
                                    const dpThing = dynamicPrice.get(0)
                                    if(!dpThing)
                                        return;

                                    pricingCurrentLimitSeries.clear();
                                    pricingUpperSeries.clear();
                                    pricingUpperSeriesAbove.clear();

                                    validSince = dpThing.stateByName("validSince").value
                                    validUntil = dpThing.stateByName("validUntil").value
                                    currentPrice = dpThing.stateByName("currentMarketPrice").value
                                    averagePrice = dpThing.stateByName("averagePrice").value.toFixed(0).toString();

                                    consumptionSeries.insertEntry(dpThing.stateByName("priceSeries").value, false)
                                    valueAxis.adjustMax(lowestPrice,highestPrice);
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
                                                max = Math.ceil(maxPrice) + 1;
                                                max += 4 - (max % 4);
                                                min = minPrice <= 0 ? minPrice - 5 : 0;

                                                if(min < 0) {
                                                    max += 4 - ((max + min * (-1)) % 4);
                                                }
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
                                            borderColor: Style.green


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
                                            borderColor: Style.red

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

                        Button {
                            id: savebutton

                            Layout.fillWidth: true
                            Layout.alignment: bottom
                            text: qsTr("Save")
                            onClicked: {
                                // if simple PV excess mode is used set the batteryLevel to 1
                                if(isAnyOfModesSelected([simple_pv_excess, no_optimization, dyn_pricing])){
                                    batteryLevel.value = 1
                                    targetPercentageSlider.value = 100
                                }

                                // Set the endTime to maximum value for all modes except pv_optimized
                                if(isAnyOfModesSelected([pv_excess, simple_pv_excess, dyn_pricing, no_optimization])){
                                    endTimeSlider.value = 24*60
                                }


                                if ((endTimeSlider.value >= endTimeSlider.maximumChargingthreshhold) && (endTimeSlider.value >= 30) && carSelector.holdingItem !== false && batteryLevel.value !== 0){
                                    if (carSelector.holdingItem.stateByName("batteryLevel").value){
                                        carSelector.holdingItem.executeAction("batteryLevel", [{ paramName: "batteryLevel", value: batteryLevel.value }])
                                    }
                                    pageSelectedCar = carSelector.holdingItem.name

                                    var optimizationMode = compute_OptimizationMode()

                                    hemsManager.setUserConfiguration({defaultChargingMode: comboboxloadingmod.currentIndex})
                                    hemsManager.setChargingConfiguration(thing.id, {optimizationEnabled: true, carThingId: carSelector.holdingItem.id, endTime: endTimeLabel.endTime.getHours() + ":" +  endTimeLabel.endTime.getMinutes() + ":00", targetPercentage: targetPercentageSlider.value, optimizationMode: optimizationMode, priceThreshold: currentValue})

                                    optimizationPage.done()
                                    pageStack.pop()

                                }
                                else{
                                    // footer message to notifiy the user, what is wrong
                                    if(batteryLevel.value === 0){
                                        footer.text = qsTr("Please select a battery level greater than 0%.")
                                    }
                                    else if (carSelector.holdingItem === false){
                                        footer.text = qsTr("Please select a car")
                                    }
                                    else if((endTimeSlider.value < endTimeSlider.maximumChargingthreshhold) || (endTimeSlider.value < 30)){
                                        footer.text = qsTr("Please select a valid target time")
                                    }
                                    else{
                                        footer.text = qsTr("Unknown error")
                                    }

                                    footer.visible = true
                                }



                            }

                            function compute_OptimizationMode(){
                                var mode = comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).mode
                                if(isAnyOfModesSelected([pv_excess, dyn_pricing, simple_pv_excess])){
                                    // single digit
                                    var gridConsumptionOption = gridConsumptionloadingmod.model.get(gridConsumptionloadingmod.currentIndex).mode
                                    mode = mode + gridConsumptionOption
                                }
                                return mode
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
}
