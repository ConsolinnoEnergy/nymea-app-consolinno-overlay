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


    ThingsProxy {
        id: evProxy
        engine: _engine
        shownInterfaces: ["electricvehicle"]
    }

    property string pageSelectedCar: carThing.name
    property var pluggedInEvent: thing.stateByName("pluggedIn").value

    header: NymeaHeader {
        id: header


        text: qsTr("Charging configuration") + " - " + thing.name
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    onPluggedInEventChanged:
    {
        if (thing.stateByName("pluggedIn").value === false && chargingConfiguration.optimizationEnabled === true ){
            hemsManager.setChargingConfiguration(thing.id, false, chargingConfiguration.carThingId,   Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime , "HH:mm:ss").getHours() , Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime , "HH:mm:ss").getMinutes() , chargingConfiguration.targetPercentage, chargingConfiguration.zeroReturnPolicyEnabled, chargingConfiguration.optimizationMode)
        }
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

                property bool checked: color == "green" ? true:false
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
                text: " No car is connected at the moment. Please connect a car"
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
            text: "State of loading ..."
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
                text: thing.stateByName("pluggedIn").value ? (chargingConfiguration.optimizationEnabled ? pageSelectedCar : " -- " )  : " -- "
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 0

            }
        }

        RowLayout{
            Label{
                id: loadingModesLabel
                Layout.fillWidth: true
                text: "Loading mode: "
            }

            Label{
                id: loadingModes
                text: thing.stateByName("pluggedIn").value ? (chargingConfiguration.optimizationEnabled ? selectMode(chargingConfiguration.optimizationMode) : " -- "   ) : " -- "
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
                text: "Target Charge Reached at: "
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
                text: "Target Charge: "
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
                    text: "running"
                    Layout.alignment: Qt.AlignRight
                }

            }


        }

        RowLayout{
            id: noLoadingRowLayout
            visible: ! (chargingConfiguration.optimizationEnabled && thing.stateByName("pluggedIn").value)
            Label{
                id: noLoadingLabel
                text: "No chargingschedule active at the moment..."
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
            }
        }

        RowLayout{
            id: loadingRowLayout
            visible: chargingConfiguration.optimizationEnabled && thing.stateByName("pluggedIn").value
            Label{
                id: currentLoadingCurrentLabel
                Layout.fillWidth: true
                text: "Current battery charge:"

            }
            Label{
                id: currentLoadingCurrent
                text: chargingSessionConfiguration.batteryLevel
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
                text: "Amount of Energy charged:"

            }
            Label{
                id: alreadyLoaded
                text: chargingSessionConfiguration.energyBattery
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
            text: "Configure Charging"
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
            text: "Cancel Charging Schedule"
            onClicked: {


                hemsManager.setChargingConfiguration(thing.id, false, chargingConfiguration.carThingId,   Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime , "HH:mm:ss").getHours() , Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime , "HH:mm:ss").getMinutes() , chargingConfiguration.targetPercentage, chargingConfiguration.zeroReturnPolicyEnabled, chargingConfiguration.optimizationMode)
                //pageStack.push(optimizationComponent , { hemsManager: hemsManager, thing: thing })
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
                    text: qsTr("Charging configuration") + " - " + thing.name
                    backButtonVisible: true
                    onBackPressed: pageStack.pop()
                }

                ColumnLayout {
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


                        Layout.fillWidth: true
                        model: evProxy

                        textRole: "name"
                        currentIndex: evProxy.indexOf(evProxy.getThing(chargingConfiguration.carThingId))

                        onCurrentIndexChanged: {
                            endTimeSlider.computeFeasibility()
                            if (targetPercentageSlider.value < endTimeSlider.batteryLevel)
                            {
                                targetPercentageSlider.value = endTimeSlider.batteryLevel
                            }
                            if (targetPercentageSlider.value === 0){

                                targetPercentageSlider.value = 1
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
                        //currentIndex: evProxy.indexOf(evProxy.getThing(chargingConfiguration.carThingId ))

                        onCurrentIndexChanged: {



                            if ( model.get(currentIndex).key === "fast charging" ){
                                footer.text = "fast charging activated"

                            }
                        }
                    }
                }

                RowLayout{

                    Label{
                        id: batteryid
                        Layout.fillWidth: true
                        text: qsTr("Current battery charge: ")

                    }

                    TextField {
                        id: batterycharge
                        Layout.minimumWidth: 35
                        Layout.maximumWidth: 35
                        Layout.alignment: Qt.AlignRight

                        text: endTimeSlider.batteryLevel + "%"
                        readOnly: true


                        //onTextChanged:

                    }





                }



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
                        value = chargingConfiguration.targetPercentage
                        endTimeSlider.computeFeasibility()
                        endTimeSlider.feasibilityText()

                    }
                    onPositionChanged: {
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

                        property var necessaryEnergyinKwh







                        from: 0
                        to: 24*60
                        stepSize: 1
                        //         from config hours      from config minutes         current hours                    current minutes                 add a day if negative (since it means it is the next day)
                        value: chargingConfigHours*60 + chargingConfigMinutes - endTimeLabel.today.getHours()*60 - endTimeLabel.today.getMinutes() + nextDay*24*60

                        background: ChargingConfigSliderBackground{

                            id: backgroundEndTimeSlider
                            Layout.fillWidth: true


                            infeasibleSectionWidth: endTimeSlider.width * endTimeSlider.maximumChargingthreshhold/(24*60)
                            feasibleSectionWidth:  endTimeSlider.width - infeasibleSectionWidth
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

                            var maxChargingCurrent = thing.stateByName("maxChargingCurrent").value



                            var loadingVoltage
                            if (thing.stateByName("phaseCount").value === 1 ){
                                 loadingVoltage = 230
                            }
                            else{
                                loadingVoltage = 400
                            }


                            for (let i = 0; i < evProxy.get(comboboxev.currentIndex).thingClass.stateTypes.count; i++){

                                var thingStateId = evProxy.get(comboboxev.currentIndex).thingClass.stateTypes.get(i).id

                                if (evProxy.get(comboboxev.currentIndex).thingClass.stateTypes.get(i).name === "capacity" ){
                                    var capacity = evProxy.get(comboboxev.currentIndex).states.getState(thingStateId).value
                                    capacityInAh = (capacity*1000)/loadingVoltage
                                }
                                if (evProxy.get(comboboxev.currentIndex).thingClass.stateTypes.get(i).name === "minChargingCurrent" ){

                                    minChargingCurrent = evProxy.get(comboboxev.currentIndex).states.getState(thingStateId).value
                                    // for testing reasons


                                }
                                if (evProxy.get(comboboxev.currentIndex).thingClass.stateTypes.get(i).name === "batteryLevel" ){
                                    batteryLevel = evProxy.get(comboboxev.currentIndex).states.getState(thingStateId).value
                                    // not sure if in form 0 - 100 or 0 - 1
                                    batteryContentInAh = capacityInAh * batteryLevel/100
                                }
                            }


                            var targetSOCinAh = capacityInAh * targetSOC/100


                            var necessaryTimeinHMinCharg = (targetSOCinAh - batteryContentInAh)/minChargingCurrent
                            var necessaryTimeinHMaxCharg = (targetSOCinAh - batteryContentInAh)/maxChargingCurrent

                            necessaryEnergyinKwh = ((targetSOCinAh - batteryContentInAh) * loadingVoltage)/1000

                            minimumChargingthreshhold = necessaryTimeinHMinCharg*60
                            maximumChargingthreshhold = necessaryTimeinHMaxCharg*60

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


                        // Maintool to debug
                        //footer.text = "saved"

                        dialog.visible = true

                        //footer.text = necessaryEnergyinKwh
                        // TODO: wait for response
                        //d.pendingCallId =
                        // hemsManager.setChargingConfiguration(chargingConfiguration.evChargerThingId  , optimizationEnabledSwitch.checked, comboboxev.model.get(comboboxev.currentIndex).id,  parseInt(endTimeLabel.endTime.getHours()) , parseInt( endTimeLabel.endTime.getMinutes()) , targetPercentageSlider.value, zeroRetrunPolicyEnabledSwitch.checked, necessaryEnergyinKwh)


                    }
                }

                Dialog{
                    id: dialog
                    title: "Title"
                    standardButtons: Dialog.Ok | Dialog.Cancel



                    onAccepted:{
                        //footer.text = comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).value


                        pageSelectedCar = comboboxev.model.get(comboboxev.currentIndex).name

                        hemsManager.setChargingConfiguration(thing.id, true, comboboxev.model.get(comboboxev.currentIndex).id,  parseInt(endTimeLabel.endTime.getHours()) , parseInt( endTimeLabel.endTime.getMinutes()) , targetPercentageSlider.value, comboboxloadingmod.model.get(comboboxloadingmod.currentIndex).mode)
                        //hemsManager.setChargingSessionConfiguration( comboboxev.model.get(comboboxev.currentIndex).id , thing.id, "05:11", "10:22", 1, 1, 1, 1, 1, 3, "", 1, 500 )
                        pageStack.pop()

                    }
                    onRejected: console.log("Cancel clicked")

                }
                }



            }
        }

}
