import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQml 2.2
 import QtGraphicalEffects 1.15
import Nymea 1.0

import "../components"
import "../delegates"



Page {
    id: root


    property HemsManager hemsManager
    property ChargingConfiguration chargingConfiguration: hemsManager.chargingConfigurations.getChargingConfiguration(thing.id)
    property ChargingSessionConfiguration chargingSessionConfiguration: hemsManager.chargingSessionConfigurations.getChargingSessionConfiguration(thing.id)
    property Thing carThing
    property Thing thing
    property var pageSelectedCar: carThing.name === null ? qsTr("no car selected") : carThing.name
    property bool initializing: false

    // Connections to update the ChargingSessionConfiguration values
    Connections {
        target: hemsManager
        onChargingSessionConfigurationChanged:
        {
            if (chargingSessionConfiguration.evChargerThingId === thing.id){

                batteryLevelValue.text  = chargingSessionConfiguration.batteryLevel  + " %"
                energyChargedValue.text = chargingSessionConfiguration.energyCharged.toFixed(2) + " kWh"
                energyBatteryValue.text = chargingSessionConfiguration.energyBattery.toFixed(2) + " kWh"
                if (chargingSessionConfiguration.state === 2){
                    var duration = chargingSessionConfiguration.duration
                    var hours   = Math.floor(duration/3600)
                    var minutes = Math.floor((duration - hours*3600)/60)
                    var seconds = Math.floor(duration - hours*3600 - minutes*60)
                    durationValue.text = (hours === 0) ? (minutes == 0 ? seconds + qsTr("s")  :  minutes + qsTr("min ") + seconds + qsTr("s")   ) : hours + qsTr("h") + " " + minutes + qsTr("min ") + seconds + qsTr("s")
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



    header: NymeaHeader {
        id: header
        text: qsTr(thing.name)
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }



    ColumnLayout {
        id: infoColumnLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins
        anchors.margins: app.margins

        RowLayout{

            Label {
                id: pluggedInLagel
                Layout.fillWidth: true
                text: qsTr("Car plugged in:")

            }

            Rectangle{
                id: pluggedInLight

                width: 17
                height: 17
                Layout.rightMargin: 0
                Layout.alignment: Qt.AlignRight
                color: thing.stateByName("pluggedIn").value ? "green" : "red"
                border.color: "black"
                border.width: 0.5
                radius: width*0.5
            }
        }

        RowLayout{
            id: noPluggedInRowLayout
            visible: !(thing.stateByName("pluggedIn").value)
            Label{
                id: noPluggedInLabel
                text: qsTr("No car is connected at the moment. Please connect a car")
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width

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
                text: qsTr("Car: ")
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
                text: qsTr("Charging mode: ")
            }

            Label{
                id: loadingModes
                text: qsTr(thing.stateByName("pluggedIn").value ? (chargingConfiguration.optimizationEnabled ? selectMode(chargingConfiguration.optimizationMode) : " -- "   ) : " -- " )
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 0

                function selectMode(){

                    if (chargingConfiguration.optimizationMode == 0)
                    {
                        return qsTr("No optimization")
                    }
                    else if (chargingConfiguration.optimizationMode == 1)
                    {
                        return qsTr("PV optimized")
                    }
                }

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
                id: targetChargeReachedLabel
                Layout.fillWidth: true
                text: qsTr("Ending time: ")
            }

            Label{
                id: targetChargeReached
                property var today: new Date()
                property var tomorrow: new Date( today.getTime() + 1000*60*60*24)
                // determine whether it is today or tomorrow
                property var date: (parseInt(chargingConfiguration.endTime[0]+chargingConfiguration.endTime[1]) < today.getHours() ) | ( ( parseInt(chargingConfiguration.endTime[0]+chargingConfiguration.endTime[1]) === today.getHours() ) & parseInt(chargingConfiguration.endTime[3]+chargingConfiguration.endTime[4]) >= today.getMinutes() ) ? tomorrow : today

                text: thing.stateByName("pluggedIn").value ? (chargingConfiguration.optimizationEnabled ? date.toLocaleString(Qt.locale("de-DE"), "dd.MM") + "  " + Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime, "HH:mm:ss").toLocaleString(Qt.locale("de-DE"), "HH:mm") : " -- "  )   : " -- "
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
                id: targetChargeLabel
                Layout.fillWidth: true
                text: qsTr("Target charge: ")
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
                text: qsTr("Status: ")
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
                    color:  thing.stateByName("pluggedIn").value ? (initializing ? "blue" : state === 2 ? "green" : state === 3 ? "grey" : state === 4 ? "grey" : "lightgrey" ) : "lightgrey"
                    radius: width*0.1
                    Label{
                        id: description
                        text: initializing ? qsTr("Initialising") : (status.state === 2 ? qsTr("Running") : (status.state === 3 ? qsTr("Finished") : (status.state === 4 ? qsTr("Interrupted") : (status.state === 6 ? "Pending" :  "Failed"  ))))
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
                text: qsTr("Battery level:")

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
                text: qsTr("Battery charge:")

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
                text: qsTr("Charging current:")

            }
            Label{
                id: currentCurrentValue
                text: initializing ? 0 : thing.stateByName("maxChargingCurrent").value + " A"
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
                text: qsTr("Energy charged:")

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
                text: qsTr("Time elapsed:")

            }
            Label{
                id: durationValue
                property int duration: chargingSessionConfiguration.duration
                property int hours: duration/3600
                property int minutes: (duration - hours*3600)/60
                property int seconds: duration - hours*3600 - minutes*60
                text: (hours === 0) ? (minutes == 0 ? seconds + "s"  :  minutes + "min " + seconds + "s"    ) : hours + "h " + " " + minutes + "min " + seconds + "s"
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
                        pageStack.push(optimizationComponent , { hemsManager: hemsManager, thing: thing })
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
                text: qsTr("Cancel Charging Schedule")
                onClicked: {
                    hemsManager.setChargingConfiguration(thing.id, false, chargingConfiguration.carThingId,   Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime , "HH:mm:ss").getHours() , Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime , "HH:mm:ss").getMinutes() , chargingConfiguration.targetPercentage,  chargingConfiguration.optimizationMode, chargingConfiguration.uniqueIdentifier)
                }
            }
        }
    }


    Component{
        id: optimizationComponent



        Page{

            id: optimizationPage
            property HemsManager hemsManager
            property ChargingConfiguration chargingConfiguration: hemsManager.chargingConfigurations.getChargingConfiguration(thing.id)
            property Thing thing






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
                        text: holdingItem !== false ? holdingItem.name : qsTr("Add new car")
                        progressionsIcon: "add"
                        holdingItem: false
                        onClicked: {



                            var page = pageStack.push("../thingconfiguration/CarInventory.qml")
                            page.done.connect(function(selectedCar){
                                holdingItem = selectedCar
                                // may looks weird, but is necessary to reload the carInventory such that it is in the correct order
                            })



                        }


                    }



                }


                RowLayout{
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    Layout.rightMargin: 2 * app.margins


                    Row{
                        Layout.fillWidth: true
                        Label {
                            id: chargingModeid

                            text: qsTr("Charging mode: ")
                        }

                        InfoButton{
                            push: "ChargingModeInfo.qml"
                            anchors.left: chargingModeid.right
                            anchors.leftMargin:  5
                        }
                    }



                    ComboBox {
                        id: comboboxloadingmod
                        Layout.fillWidth: true
                        x: carSelector.x
                        model: ListModel{
                            ListElement{key: qsTr("PV optimized"); value: "Pv-Optimized"; mode: 1}
                            ListElement{key: qsTr("No optimization"); value: "No Optimization"; mode: 0}

                        }
                        textRole: "key"

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
                            Component.onCompleted:
                            {
                                    if (carSelector.holdingItem !== false){
                                        value = carSelector.holdingItem.stateByName("batteryLevel").value
                                    }
                            }

                            onPositionChanged:
                            {
                                // if the "new Car" option is not picked do something
                                if (carSelector.holdingItem !== false){
                                    if (value >= targetPercentageSlider.value)
                                    {
                                        targetPercentageSlider.value = value
                                    }
                                    endTimeSlider.computeFeasibility()
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

                            Component.onCompleted: {
                                if (carSelector.holdingItem !== false){
                                    value = chargingConfiguration.targetPercentage
                                    endTimeSlider.computeFeasibility()
                                    endTimeSlider.feasibilityText()
                                }

                            }
                            onPositionChanged: {

                                if (carSelector.holdingItem !== false){
                                    endTimeSlider.computeFeasibility()
                                    endTimeSlider.feasibilityText()

                                    if (value < endTimeSlider.batteryLevel)
                                    {
                                        value = endTimeSlider.batteryLevel
                                    }
                                    if (value == 0){

                                        value = 1
                                    }

                                }
                            }
                        }
                    }
                }

                RowLayout{
                    Layout.fillWidth: true
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

                            // TODo: Ladespannung von Wallbox ermittlen
                            //       Wieviel phasen hat die Wallbox
                            //       generell wallbox data integrieren
                            if (carSelector.holdingItem !== false){
                                var maxChargingCurrent = thing.stateByName("maxChargingCurrent").value



                                var loadingVoltage
                                if (thing.stateByName("phaseCount").value === 1 ){
                                    loadingVoltage = 230
                                }
                                else{
                                    loadingVoltage = thing.stateByName("phaseCount").value * 230
                                }


                                for (let i = 0; i < carSelector.holdingItem.thingClass.stateTypes.count; i++){

                                    var thingStateId = carSelector.holdingItem.thingClass.stateTypes.get(i).id

                                    if (carSelector.holdingItem.thingClass.stateTypes.get(i).name === "capacity" ){
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

                Label
                    {
                    id: feasibilityMessage
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignRight
                    text: qsTr("In the currently selected timeframe the charging process is not possible. Please reduce the target charge or increase the end time")
                    Material.foreground: Material.Red
                    visible: true
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

                }

                Button {
                    id: savebutton
                    Layout.fillWidth: true
                    text: qsTr("Save")
                    //enabled: configurationSettingsChanged
                    onClicked: {

                        if (carSelector.holdingItem !== false){
                            if (carSelector.holdingItem.stateByName("batteryLevel").value){
                                carSelector.holdingItem.executeAction("batteryLevel", [{ paramName: "batteryLevel", value: batteryLevel.value }])
                            }
                            // Maintool to debug
                            //footer.text = "saved"
                            pageSelectedCar = carSelector.holdingItem.name


                            hemsManager.setChargingConfiguration(thing.id, true, carSelector.holdingItem.id,  parseInt(endTimeLabel.endTime.getHours()) , parseInt( endTimeLabel.endTime.getMinutes()) , targetPercentageSlider.value, comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).mode, "00000000-0000-0000-0000-000000000000")
                            pageStack.pop()

                        }
                        else{
                            footer.text = qsTr("please select a car")
                        }

                    }
                }
            }
        }
    }
}
