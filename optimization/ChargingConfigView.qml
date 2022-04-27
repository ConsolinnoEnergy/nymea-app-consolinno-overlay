import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQml 2.2
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
    property var pageSelectedCar: carThing.name ? qsTr("no car selected") : carThing.name

    // Connections to update the ChargingSessionConfiguration values
    Connections {
        target: hemsManager
        onChargingSessionConfigurationChanged:
        {
            batteryLevelValue.text  = chargingSessionConfiguration.batteryLevel  + " %"
            energyChargedValue.text = chargingSessionConfiguration.energyCharged.toFixed(2) + " kWh"
            energyBatteryValue.text = chargingSessionConfiguration.energyBattery.toFixed(2) + " kWh"
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
                border.width: 1
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
            }
        }

    }



    ColumnLayout {
        id: stateOfLoadingColumnLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: infoColumnLayout.top
        anchors.topMargin: infoColumnLayout.height + 50
        anchors.margins: app.margins
        spacing: 10




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
            Label{
                id: selectedCarLabel
                Layout.fillWidth: true
                text: "Car: "
            }

            Label{
                id: selectedCar
                text: thing.stateByName("pluggedIn").value ? (chargingConfiguration.optimizationEnabled ? pageSelectedCar: " -- " )  : " -- "
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 0

            }
        }

        RowLayout{
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
                        return "No Optimization"
                    }
                    else if (chargingConfiguration.optimizationMode == 1)
                    {
                        return "PV Optimized"
                    }
                }

            }
        }

        RowLayout{
            Label{
                id: targetChargeReachedLabel
                Layout.fillWidth: true
                text: qsTr("Target Charge Reached at: ")
            }

            Label{
                id: targetChargeReached
                property var today: new Date()
                property var tomorrow: new Date( today.getTime() + 1000*60*60*24)
                // determine whether it is today or tomorrow
                property var date: (parseInt(chargingConfiguration.endTime[0]+chargingConfiguration.endTime[1]) < today.getHours() ) | ( ( parseInt(chargingConfiguration.endTime[0]+chargingConfiguration.endTime[1]) === today.getHours() ) & parseInt(chargingConfiguration.endTime[3]+chargingConfiguration.endTime[4]) >= today.getMinutes() ) ? tomorrow : today

                text: thing.stateByName("pluggedIn").value ? (  chargingConfiguration.optimizationEnabled ? date.toLocaleString(Qt.locale("de-DE"), "dd/MM") + "  " + Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime, "HH:mm:ss").toLocaleString(Qt.locale("de-DE"), "HH:mm") : " -- "  )   : " -- "
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 0

            }
        }

        RowLayout{
            Label{
                id: targetChargeLabel
                Layout.fillWidth: true
                text: qsTr("Target Charge: ")
            }

            Label{
                id: targetCharge
                text: thing.stateByName("pluggedIn").value ?(chargingConfiguration.optimizationEnabled ? chargingConfiguration.targetPercentage + " %" : " -- " ) : " -- "
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 0

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
        spacing: 10






        RowLayout{
            Label{
                id: statusLabel
                Layout.fillWidth: true
                text: "Status: "
                font.pixelSize: 22
                font.bold: true
            }
            ColumnLayout{
                Layout.fillWidth: true
                spacing: 0
                visible: chargingConfiguration.optimizationEnabled
                Rectangle{
                    id: status

                    //initiation   // yellow
                    //running      // green
                    //toBeCanceled // lightblue
                    //canceled     // blue
                    //notdefined   // white
                    //disabled     // lightgrey
                    //pausiert     // orange


                    width: 17
                    height: 17

                    Layout.alignment: Qt.AlignRight

                    //check if plugged in                 check if current power == 0           else show the current state the session is in atm
                    color:  thing.stateByName("pluggedIn").value ? (thing.stateByName("currentPower") !== 0 ? (chargingSessionConfiguration.state === 0  ? "yellow" : chargingSessionConfiguration.state == 1 ? "green" : chargingSessionConfiguration.state == 2 ? "lightblue" : chargingSessionConfiguration.state == 3 ? "blue" : "white" ): "orange") : "lightgrey"
                    border.color: "black"
                    border.width: 1
                    radius: width*0.5
                }
                Label{
                    id: description

                    text: chargingSessionConfiguration.state == 2 ? "running" : "not running"
                    Layout.alignment: Qt.AlignRight
                }

            }


        }

        RowLayout{
            id: noLoadingRowLayout
            visible: ! (chargingConfiguration.optimizationEnabled && thing.stateByName("pluggedIn").value)
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
            visible: chargingConfiguration.optimizationEnabled && thing.stateByName("pluggedIn").value
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
            id: energyBattery
            visible: chargingConfiguration.optimizationEnabled && thing.stateByName("pluggedIn").value
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
                text: thing.stateByName("maxChargingCurrent").value + " A"
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 0


            }
        }

        RowLayout{
            id: energyChargedLayout
            visible: chargingConfiguration.optimizationEnabled && thing.stateByName("pluggedIn").value
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
                text: qsTr("Charging configuration") + " - " + qsTr(thing.name)
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
                    id: evComboBoxRow


                    Label {
                        id: evLabelid
                        Layout.fillWidth: true
                        text: qsTr("Electric car:")


                    }

                    ComboBox {
                        id: comboboxev
                        property var counter: 0
                        textRole: "name"                                                        // indexOf function gives -1 back if not found
                        Layout.fillWidth: true
                        model: ListModel{
                            id: proxyModel
                            ListElement{name: "Configure new Car"; index: "0" }

                            Component.onCompleted: {
                                fillevCombobox()

                            }
                            function fillevCombobox(){
                                proxyModel.clear()
                                proxyModel.append({"name": "Configure new Car", "index": "0" })
                                for (var k = 0; k < evProxy.count; k++){
                                    proxyModel.append({"index": evProxy.get(k).id.toString(), "name": evProxy.get(k).name, "value": evProxy.get(k)} )
                                }
                                comboboxev.currentIndex = evProxy.indexOf(evProxy.getThing(chargingConfiguration.carThingId)) < 0 ? 0 : evProxy.indexOf(evProxy.getThing(chargingConfiguration.carThingId) )

                            }

                        }


                        onCurrentIndexChanged: {
                            // if "new Car" option is not used compute something
                            if (comboboxev.currentIndex > 0){
                                endTimeSlider.computeFeasibility()
                                if (evProxy.get(comboboxev.currentIndex-1).stateByName("batteryLevel").value !== undefined){
                                    if (batterycharge.value < evProxy.get(comboboxev.currentIndex-1).stateByName("batteryLevel").value){
                                        batterycharge.value = evProxy.get(comboboxev.currentIndex-1).stateByName("batteryLevel").value
                                    }
                                }
                                if (targetPercentageSlider.value < endTimeSlider.batteryLevel)
                                {
                                    targetPercentageSlider.value = endTimeSlider.batteryLevel
                                }
                                if (targetPercentageSlider.value === 0){

                                    targetPercentageSlider.value = 1
                                }
                            }
                        }
                        onActivated: {
                            // if "new Car" option is used do something
                            if (comboboxev.currentIndex === 0){
                                for (var i = 0; i<thingClassesProxy.count; i++){
                                    if (thingClassesProxy.get(i).id.toString() === "{dbe0a9ff-94ba-4a94-ae52-51da3f05c717}"  ){
                                        var page = pageStack.push("../thingconfiguration/AddGenericCar.qml" , {thingClass: thingClassesProxy.get(i)})
                                        page.done.connect(function(){

                                            pageStack.pop()
                                            proxyModel.fillevCombobox()
                                        })
                                        page.aborted.connect(function(){
                                            pageStack.pop()
                                        })



                                    }
                                }
                            }

                        }




                    }






                }

                RowLayout{
                    Layout.fillWidth: true



                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Charging mode: ")
                    }


                    // will replace the Optimization enabled switch, since there will be more optimization options
                    ComboBox {
                        id: comboboxloadingmod
                        Layout.fillWidth: true
                        model: ListModel{
                            ListElement{key: "Pv optimized"; value: "Pv-Optimized"; mode: 1}
                            ListElement{key: "No Optimization"; value: "No Optimization"; mode: 0}

                        }
                        textRole: "key"


                        onCurrentIndexChanged: {
                        }
                    }
                }

                RowLayout{
                    ColumnLayout{
                        Label{
                            id: batteryid
                            Layout.fillWidth: true
                            text: qsTr("Battery charge: " + batterycharge.value +" %")

                        }

                        Slider {
                            id: batterycharge

                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            stepSize: 1
                            Component.onCompleted:
                            {
                                if (comboboxev.currentIndex > 0){
                                    value = evProxy.get(comboboxev.currentIndex-1).stateByName("batteryLevel").value
                                }
                            }

                            onPositionChanged:
                            {
                                // if the "new Car" option is not picked do something
                                if (comboboxev.currentIndex > 0){
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
                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Target state of charge %1%").arg(targetPercentageSlider.value)
                        }

                        Slider {
                            id: targetPercentageSlider

                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            stepSize: 1

                            Component.onCompleted: {
                                if (comboboxev.currentIndex > 0){
                                    value = chargingConfiguration.targetPercentage
                                    endTimeSlider.computeFeasibility()
                                    endTimeSlider.feasibilityText()
                                }

                            }
                            onPositionChanged: {
                                if (comboboxev.currentIndex > 0){
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
                        property var feasibility
                        text: "End of the charging time: " + endTime.toLocaleString(Qt.locale("de-DE"), "dd/MM HH:mm") + "  Feasible: " + feasibility

                        function endTimeValidityPrediction(d){

                            switch (d){
                            case 1:
                                feasibility =  "  <font color=\"red\">not feasible</font>"
                                break
                            case 2:
                                feasibility = "  <font color=\"green\">feasible</font>"
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
                            if (comboboxev.currentIndex > 0){
                                var maxChargingCurrent = thing.stateByName("maxChargingCurrent").value



                                var loadingVoltage
                                if (thing.stateByName("phaseCount").value === 1 ){
                                    loadingVoltage = 230
                                }
                                else{
                                    loadingVoltage = 400
                                }


                                for (let i = 0; i < evProxy.get(comboboxev.currentIndex-1).thingClass.stateTypes.count; i++){

                                    var thingStateId = evProxy.get(comboboxev.currentIndex-1).thingClass.stateTypes.get(i).id

                                    if (evProxy.get(comboboxev.currentIndex-1).thingClass.stateTypes.get(i).name === "capacity" ){
                                        var capacity = evProxy.get(comboboxev.currentIndex-1).states.getState(thingStateId).value
                                        capacityInAh = (capacity*1000)/loadingVoltage
                                    }
                                    if (evProxy.get(comboboxev.currentIndex-1).thingClass.stateTypes.get(i).name === "minChargingCurrent" ){

                                        minChargingCurrent = evProxy.get(comboboxev.currentIndex-1).states.getState(thingStateId).value
                                        // for testing reasons

                                    }

                                }

                                batteryLevel = batterycharge.value
                                batteryContentInAh = capacityInAh * batteryLevel/100

                                var targetSOCinAh = capacityInAh * targetSOC/100


                                var necessaryTimeinHMinCharg = (targetSOCinAh - batteryContentInAh)/minChargingCurrent
                                var necessaryTimeinHMaxCharg = (targetSOCinAh - batteryContentInAh)/maxChargingCurrent


                                minimumChargingthreshhold = necessaryTimeinHMinCharg*60
                                maximumChargingthreshhold = necessaryTimeinHMaxCharg*60

                            }
                        }



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

                        if (comboboxev.currentIndex > 0){
                            if (evProxy.get(comboboxev.currentIndex-1).stateByName("batteryLevel").value !== undefined){
                                evProxy.get(comboboxev.currentIndex-1).executeAction("batteryLevel", [{ paramName: "batteryLevel", value: batterycharge.value }])

                            }
                            // Maintool to debug
                            //footer.text = "saved"
                            pageSelectedCar = comboboxev.model.get(comboboxev.currentIndex).name

                            hemsManager.setChargingConfiguration(thing.id, true, evProxy.get(comboboxev.currentIndex -1).id,  parseInt(endTimeLabel.endTime.getHours()) , parseInt( endTimeLabel.endTime.getMinutes()) , targetPercentageSlider.value, comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).mode, "00000000-0000-0000-0000-000000000000")
                            //hemsManager.setChargingSessionConfiguration(comboboxev.model.get(comboboxev.currentIndex).id, thing.id, "2022-04-23T22:51:41", "", 2, 2 , 2, 2, 2, "", 2, 2)

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
