import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.1
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
    property Thing thing



    header: NymeaHeader {
        text: qsTr("Charging configuration") + " - " + thing.name
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        id: contentColumn
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

            RadioButton{
                id: pluggedInRadioButton

                Layout.rightMargin: 0
                Layout.alignment: Qt.AlignRight
                checked: thing.stateByName("pluggedIn").value


            }



        }

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
                model: ThingsProxy {
                    id: evProxy
                    engine: _engine
                    shownInterfaces: ["electricvehicle"]
                }

                textRole: "name"
                currentIndex: evProxy.indexOf(evProxy.getThing(chargingConfiguration.carThingId ))

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
            text: qsTr("Optimization mode: ")
        }


            // will replace the Optimization enabled switch, since there will be more optimization options
            ComboBox {
                id: comboboxloadingmod
                Layout.fillWidth: true
                model: ListModel{
                    ListElement{key: "Pv optimized"; value: "PvOpimized"}
                    ListElement{key: "fast charging"; value: "FastCharging"}




                }

                textRole: "key"
                //currentIndex: evProxy.indexOf(evProxy.getThing(chargingConfiguration.carThingId ))

                onCurrentIndexChanged: {



                    if ( model.get(currentIndex).value === "FastCharging" ){
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
                //         von config hours      von config minutes         current hours                    current minutes                 add a day if negative (since it means it is the next day)
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
                    var loadingVoltage = 230

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
                       var necessaryTimeinHMaxCharg = (targetSOCinAh - batteryContentInAh)/16

                       necessaryEnergyinKwh = ((targetSOCinAh - batteryContentInAh) * loadingVoltage)/1000

                       minimumChargingthreshhold = necessaryTimeinHMinCharg*60
                       maximumChargingthreshhold = necessaryTimeinHMaxCharg*60

                       //footer.text = "necessaryEnergyinKwh:  " + necessaryEnergyinKwh



                }



            }

        }




        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Zero return policy")
            }

            Switch {
                id: zeroRetrunPolicyEnabledSwitch
                Component.onCompleted: checked = chargingConfiguration.zeroReturnPolicyEnabled
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

                //var necessaryEnergyinKwh = ((endTimeSlider.capacityInAh * endTimeSlider.targetSOC/100 - endTimeSlider.batteryContentInAh) * 230)/1000
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
                var necessaryEnergyinKwh = ((endTimeSlider.capacityInAh * endTimeSlider.targetSOC/100 - endTimeSlider.batteryContentInAh) * 230)/1000
                hemsManager.setChargingConfiguration(thing.id, optimizationEnabledSwitch.checked, comboboxev.model.get(comboboxev.currentIndex).id,  parseInt(endTimeLabel.endTime.getHours()) , parseInt( endTimeLabel.endTime.getMinutes()) , targetPercentageSlider.value, zeroRetrunPolicyEnabledSwitch.checked, necessaryEnergyinKwh)
                pageStack.pop()
                footer.text = "saved"
            }
            onRejected: console.log("Cancel clicked")

        }


    }
}
