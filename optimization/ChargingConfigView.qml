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



Page {
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



    // Connections to update the ChargingSessionConfiguration  and the ChargingConfiguration values
    Connections {
        target: hemsManager
        onChargingSessionConfigurationChanged:
        {
            if (chargingSessionConfiguration.evChargerThingId === thing.id){

                busyOverlay.shown = false

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
                    batteryLevelRowLayout.visible = true
                    energyBatteryLayout.visible = true
                    currentCurrentRowLayout.visible = true
                    energyChargedLayout.visible = true
                    initializing = false
                }
                // Pending
                if (chargingConfiguration.optimizationEnabled && (chargingSessionConfiguration.state == 6)){
                    batteryLevelRowLayout.visible = true
                    energyBatteryLayout.visible = true
                    currentCurrentRowLayout.visible = true
                    energyChargedLayout.visible = true
                    initializing = false
                }

            }


        }

        onChargingConfigurationChanged:
        {

            if (chargingConfiguration.evChargerThingId === thing.id){

                if (!chargingConfiguration.optimizationEnabled){
                    batteryLevelRowLayout.visible = false
                    energyBatteryLayout.visible = false
                    currentCurrentRowLayout.visible = false
                    energyChargedLayout.visible = false
                    status.visible = false
                    initializing = false
                }
                else if(chargingConfiguration.optimizationEnabled){
                    status.visible = true
                    initializing = true
                    batteryLevelRowLayout.visible = true
                    energyBatteryLayout.visible = true
                    currentCurrentRowLayout.visible = true
                    energyChargedLayout.visible = true
                    batteryLevelValue.text  = 0 + " %"
                    energyChargedValue.text = 0 + " kWh"
                    energyBatteryValue.text = 0 + " kWh"
                    durationValue.text = " -- "




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

    header: NymeaHeader {
        id: header
        text: qsTr(thing.name)

        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }



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
                    color: thing.stateByName("pluggedIn").value ? "#87BD26" : "#CD5C5C"
                    border.color: "black"
                    border.width: 0
                    radius: width*0.5
                }
            }

            RowLayout{
                id: noPluggedInRowLayout
                visible: !(thing.stateByName("pluggedIn").value)
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
                visible: !(thing.stateByName("pluggedIn").value) && (simulationEvProxy.count > 0)  && (thing.thingClassId.toString() === "{21a48e6d-6152-407a-a303-3b46e29bbb94}")

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
                Label{
                    id: selectedCarLabel
                    Layout.fillWidth: true
                    text: qsTr("Car")
                }
                Label{
                    id: selectedCar
                    text: qsTr(thing.stateByName("pluggedIn").value ? (chargingConfiguration.optimizationEnabled ? pageSelectedCar: " -- " )  : " -- ")
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: 0
                }
            }

            RowLayout
            {
                Rectangle{
                    color: "grey"
                    Layout.fillWidth: true
                    height: 1
                    Layout.alignment: Qt.AlignTop
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
                    text: thing.stateByName("pluggedIn").value ? (chargingConfiguration.optimizationEnabled ? selectMode(chargingConfiguration.optimizationMode) : " -- "   ) : " -- "
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: 0

                    function selectMode(){

                        if (chargingConfiguration.optimizationMode === 0)
                        {
                            return qsTr("No optimization")
                        }                                                                                                                      // Legacy will be deleted
                        else if ((chargingConfiguration.optimizationMode >= 1000 && chargingConfiguration.optimizationMode < 2000) || chargingConfiguration.optimizationMode === 1)
                        {
                            return qsTr("PV optimized")
                        }                                                                                                                      // Legacy will be deleted
                        else if ((chargingConfiguration.optimizationMode >= 2000 && chargingConfiguration.optimizationMode < 3000) || chargingConfiguration.optimizationMode === 2 )
                        {
                            return qsTr("PV only")
                        }
                    }

                }
            }

            RowLayout
            {
                visible: chargingConfiguration.optimizationMode === 2 ? false : true
                Rectangle{
                    color: "grey"
                    Layout.fillWidth: true
                    height: 1
                    Layout.alignment: Qt.AlignTop
                }
            }

            RowLayout{
                Layout.topMargin: 15
                visible: !(chargingConfiguration.optimizationMode === 2 || (chargingConfiguration.optimizationMode >= 2000 && chargingConfiguration.optimizationMode < 3000 ))
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

                    text: thing.stateByName("pluggedIn").value ? (chargingConfiguration.optimizationEnabled ? date.toLocaleString(Qt.locale("de-DE"), "dd.MM") + "  " + Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime, "H:m:ss").toLocaleString(Qt.locale("de-DE"), "HH:mm") : " -- "  )   : " -- "
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: 0

                }
            }

            RowLayout
            {
                Rectangle{
                    color: "grey"    // will be replaced when the app gets updated
                    visible: !(chargingConfiguration.optimizationMode === 2 || (chargingConfiguration.optimizationMode >= 2000 && chargingConfiguration.optimizationMode < 3000 ))
                    Layout.fillWidth: true
                    height: 1
                    Layout.alignment: Qt.AlignTop
                }
            }


            RowLayout{
                Layout.topMargin: 15
                Label{
                    id: targetChargeLabel
                    Layout.fillWidth: true
                    text: qsTr("Target charge")
                }

                Label{
                    id: targetCharge
                    text: thing.stateByName("pluggedIn").value ?(chargingConfiguration.optimizationEnabled ? chargingConfiguration.targetPercentage + " %" : " -- " ) : " -- "
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: 0

                }
            }

            RowLayout
            {
                Rectangle{
                    color: "grey"
                    Layout.fillWidth: true
                    height: 1
                    Layout.alignment: Qt.AlignTop
                }
            }
        }

        ColumnLayout {
            id: statusColumnLayout
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
                    visible: (chargingConfiguration.optimizationEnabled && thing.stateByName("pluggedIn").value)
                    Rectangle{

                        id: status
                        property int state: chargingSessionConfiguration.state
                        width: 120
                        height: description.height + 10
                        Layout.alignment: Qt.AlignRight


                        //check if plugged in                 check if current power == 0           else show the current state the session is in atm
                        color:  thing.stateByName("pluggedIn").value ? (initializing ? "blue" : state === 2 ? "green" : state === 3 ? "#66a5e2" : state === 4 ? "grey" : "lightgrey" ) : "lightgrey"
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
                visible: !(chargingConfiguration.optimizationEnabled && thing.stateByName("pluggedIn").value)
                Label{
                    id: noLoadingLabel
                    text: qsTr("No chargingschedule active at the moment...")
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                }
            }

            RowLayout{
                id: batteryLevelRowLayout
                visible: (chargingConfiguration.optimizationEnabled && thing.stateByName("pluggedIn").value)
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
                id: energyBatteryLayout
                visible: (chargingConfiguration.optimizationEnabled && thing.stateByName("pluggedIn").value)
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
                id: currentCurrentRowLayout
                visible: chargingConfiguration.optimizationEnabled && thing.stateByName("pluggedIn").value
                Label{
                    id: currentCurrentLabel
                    Layout.fillWidth: true
                    text: qsTr("Charging current")

                }
                Label{
                    id: currentCurrentValue
                    text: initializing ? 0 + " A": thing.stateByName("maxChargingCurrent").value + " A"
                    Layout.alignment: Qt.AlignRight
                    Layout.rightMargin: 0


                }
            }

            RowLayout{
                id: energyChargedLayout
                visible: (chargingConfiguration.optimizationEnabled && thing.stateByName("pluggedIn").value)
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
                visible: (chargingConfiguration.optimizationEnabled && thing.stateByName("pluggedIn").value)
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
                        color: thing.stateByName("pluggedIn").value ? "#87BD26" : "lightgrey"
                        radius: 4
                    }

                    onClicked: {
                        if (thing.stateByName("pluggedIn").value){
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
                visible: chargingConfiguration.optimizationEnabled && thing.stateByName("pluggedIn").value
                Button{
                    Layout.fillWidth: true
                    text:  status.state == 3 ? qsTr("Start new charging schedule") : qsTr("Cancel Charging Schedule" )
                    onClicked: {
                        hemsManager.setChargingConfiguration(thing.id, {optimizationEnabled: false})
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


            Component.onCompleted:{
                endTimeSlider.feasibilityText()
            }



            header: NymeaHeader {
                id: header
                text: qsTr("Configure charging")
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
                        Layout.fillWidth: true
                        text: qsTr("Electric car:")


                    }
                    ConsolinnoItemDelegate {
                        id: carSelector
                        Layout.fillWidth: true
                        Layout.maximumWidth: 300
                        Layout.leftMargin: 20

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

                        Layout.preferredWidth: carSelector.width

                        model: ListModel{

                            ListElement{key: qsTr("No optimization"); value: "No Optimization"; mode: 0}
                            ListElement{key: qsTr("PV optimized"); value: "Pv-Optimized"; mode: 1000}
                            ListElement{key: qsTr("PV excess only"); value: "Pv-Only"; mode: 2000}



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

                        currentIndex: userconfig.defaultChargingMode
                        onCurrentIndexChanged:
                        {
                          endTimeSlider.computeFeasibility()
                          endTimeSlider.feasibilityText()

                        }
                    }
                }


                RowLayout{
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
                    visible:  (comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).mode === 1000 )
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
                    visible:  (comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).mode === 1000 )
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
                visible: (comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).mode === 1000)
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


                Label{
                    visible: (comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).mode === 2000)
                    id: gridConsumptionLabel
                    text: qsTr("Behaviour on grid consumption:")
                }

                ComboBox {
                    visible: (comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).mode === 2000)
                    id: gridConsumptionloadingmod
                    Layout.fillWidth: true
                    model: ListModel{
                        ListElement{key: qsTr("Charge with minimum current"); mode: 0}
                        ListElement{key: qsTr("Cancel charging"); mode: 100}
                        ListElement{key: qsTr("Pause charging"); mode: 200}
                    }
                    textRole: "key"
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

                Button {
                    id: savebutton
                    Layout.fillWidth: true
                    text: qsTr("Save")
                    onClicked: {

                        // if PV excess mode is used set the endTime to maximum value
                        if((comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).mode >= 2000) && (comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).mode < 3000) ){
                            endTimeSlider.value = 24*60
                        }
                        // Set endTime to maximum for no optimization
                        if((comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).mode < 1000) ){
                            endTimeSlider.value = 24*60
                        }

                        if ((endTimeSlider.value >= endTimeSlider.maximumChargingthreshhold) && (endTimeSlider.value >= 30) && carSelector.holdingItem !== false && batteryLevel.value !== 0){
                            if (carSelector.holdingItem.stateByName("batteryLevel").value){
                                carSelector.holdingItem.executeAction("batteryLevel", [{ paramName: "batteryLevel", value: batteryLevel.value }])
                            }
                            pageSelectedCar = carSelector.holdingItem.name

                            var optimizationMode = compute_OptimizationMode()

                            hemsManager.setUserConfiguration({defaultChargingMode: comboboxloadingmod.currentIndex})
                            hemsManager.setChargingConfiguration(thing.id, {optimizationEnabled: true, carThingId: carSelector.holdingItem.id, endTime: endTimeLabel.endTime.getHours() + ":" +  endTimeLabel.endTime.getMinutes() + ":00", targetPercentage: targetPercentageSlider.value, optimizationMode: optimizationMode })

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

                        if(mode === 2000){
                            // single diget
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
