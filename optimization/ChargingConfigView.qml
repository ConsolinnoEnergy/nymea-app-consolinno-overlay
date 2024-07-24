import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
//import QtQuick.Controls.Styles 1.4
import QtQml 2.2
import QtGraphicalEffects 1.15
import Nymea 1.0

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
        return power.value
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
                energyChargedValue.text = chargingSessionConfiguration.energyCharged.toFixed(2) + " kWh"
                energyBatteryValue.text = chargingSessionConfiguration.energyBattery.toFixed(2) + " kWh"
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
                                    return qsTr("Pause")
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
                            text: qsTr('Average price ') + (priceThresholdProcentage + " %") +" / " + (thresholdPrice) + " ct";
                            Layout.alignment: Qt.AlignRight
                            Layout.rightMargin: 0

                            Component.onCompleted: {
                                let averagePrice = dynamicPrice.get(0).stateByName("averagePrice").value
                                thresholdPrice = (averagePrice * (1 + priceThresholdProcentage / 100)).toFixed(2)
                                currentValue = (currentValue === 0 && chargingConfiguration.priceThreshold === 0 ? -10 : chargingConfiguration.priceThreshold )
                            }

                            Timer{
                               property bool firstRun: false
                               repeat: true
                               interval: firstRun == false ? 100 : 10000
                               onTriggered: {
                                   firstRun = true
                                   let averagePrice = dynamicPrice.get(0).stateByName("averagePrice").value
                                   thresholdPrice = (averagePrice * (1 + priceThresholdProcentage / 100)).toFixed(2)
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

                            text: chargingSessionConfiguration.energyBattery.toFixed(2) + " kWh"
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
                            text: (initializing ? 0 : getChargingPower()) + " W"
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

                            text: chargingSessionConfiguration.energyCharged.toFixed(2) + " kWh"
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
                            background: Rectangle{
                                color: isCarPluggedIn() ? "#87BD26" : "lightgrey"
                                radius: 4
                            }

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

                                Layout.fillWidth: true

                                Label {
                                    id: chargingModeid

                                    text: qsTr("Charging mode: ")
                                }

                                InfoButton{
                                    id: chargingModeInfoButton

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
                                    ListElement{key: qsTr("Dynamic pricing"); value: "Dynamic-pricing"; mode: 4000}
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
                                    // Not working:
                                    // visible: parent.devOnly && settings.showHiddenOptions | !parent.devOnly
                                }

                                currentIndex: userconfig.defaultChargingMode
                                onCurrentIndexChanged:
                                {
                                    endTimeSlider.computeFeasibility()
                                    endTimeSlider.feasibilityText()
                                }
                            }
                        }

                        RowLayout {
                            Layout.preferredWidth: app.width
                            Layout.topMargin: 10
                            visible: isAnyOfModesSelected([pv_excess, simple_pv_excess, dyn_pricing])

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
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop
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
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop
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
                            Layout.topMargin: 10
                            visible: isAnyOfModesSelected([dyn_pricing])

                            RowLayout {

                                Label {
                                    id: priceLimitigId

                                    text: qsTr("Price limit: ")
                                }

                                InfoButton{
                                    id: priceLimitInfoButton

                                    push: "PriceLimitInfo.qml"
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignTop
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
                                }

                                ToolBar {

                                    background: Rectangle {
                                        color: "transparent"
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        ToolButton {
                                            text: qsTr("-")
                                            onClicked: {
                                                currentValue = currentValue - 1
                                                priceRow.getThresholdPrice()
                                            }
                                            onPressAndHold: {
                                                currentValue = currentValue - 10
                                                priceRow.getThresholdPrice()
                                            }
                                        }

                                        TextField {
                                            id: currentValueField
                                            text: currentValue
                                            horizontalAlignment: Qt.AlignHCenter
                                            verticalAlignment: Qt.AlignVCenter
                                        }

                                        Label {
                                            text: "%"
                                        }

                                        ToolButton {
                                            text: qsTr("+")
                                            onClicked: {
                                                currentValue = currentValue + 1
                                                priceRow.getThresholdPrice()
                                            }
                                            onPressAndHold: {
                                                currentValue = currentValue + 10
                                                priceRow.getThresholdPrice()
                                            }
                                        }

                                    }

                                }

                                Component.onCompleted: {
                                    getThresholdPrice()
                                }

                                function getThresholdPrice(){
                                    let averagePrice = dynamicPrice.get(0).stateByName("averagePrice").value
                                    let currentValue = parseInt(currentValueField.text)
                                    thresholdPrice = (averagePrice * (1 + currentValue / 100)).toFixed(2)
                                }

                            }

                        }

                        RowLayout {
                            Layout.preferredWidth: app.width
                            Layout.topMargin: 5
                            visible: isAnyOfModesSelected([dyn_pricing])
                            Label {
                                text: qsTr("Currently corresponds to a market price of ") + thresholdPrice
                            }
                        }

                        RowLayout{
                            visible: isAnyOfModesSelected([pv_optimized, pv_excess])
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

                        RowLayout {
                            Layout.fillWidth: true
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

                        RowLayout
                        {
                            visible: isAnyOfModesSelected([pv_optimized])

                            Label
                            {
                                id: feasibilityMessage
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignRight
                                text: qsTr("In the currently selected timeframe the charging process is not possible. Please reduce the target charge or increase the end time")
                                Material.foreground: Material.Red
                                visible: false
                                wrapMode: Text.WordWrap
                            }
                        }

                        Item {
                            // place holder
                            Layout.fillHeight: true
                            Layout.fillWidth: true
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
                            // place holder
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                        }

                        Button {
                            id: savebutton

                            Layout.fillWidth: true
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
