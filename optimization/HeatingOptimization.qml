import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"


Page {
    id: root
    property HemsManager hemsManager
    property HeatingConfiguration heatingConfiguration
    property Thing heatPumpThing
    property int directionID: 0
    property bool isSetup: false
    signal done()

    //property bool heatMeterIncluded: heatPumpThing.thingClass.interfaces.includes("heatmeter")
    // TODO: only if any configuration has changed, warn also on leaving if unsaved settings
    //property bool configurationSettingsChanged

    header: NymeaHeader {
        text: qsTr("Heating configuration")
        backButtonVisible: directionID === 1 ? false : true
        onBackPressed: pageStack.pop()
    }

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onSetHeatingConfigurationReply: {
            if (commandId == d.pendingCallId) {
                d.pendingCallId = -1

                switch (error) {
                case "HemsErrorNoError":
                    pageStack.pop()
                    return;
                case "HemsErrorInvalidParameter":
                    props.text = qsTr("Could not save configuration. One of the parameters is invalid.");
                    break;
                case "HemsErrorInvalidThing":
                    props.text = qsTr("Could not save configuration. The thing is not valid.");
                    break;
                default:
                    props.errorCode = error;
                }
                var comp = Qt.createComponent("../components/ErrorDialog.qml")
                var popup = comp.createObject(app, props)
                popup.open();
            }
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: app.margins

        Label {
            Layout.fillWidth: true
            text: heatPumpThing.name
            wrapMode: Text.WordWrap

        }
//        RowLayout {
//            Layout.fillWidth: true

//            //            Label {
//            //                Layout.fillWidth: true
//            //                text: qsTr("Optimization enabled")
//            //            }

//            //            Switch {
//            //                id: optimizationEnabledSwitch
//            //                Component.onCompleted: checked = heatingConfiguration.optimizationEnabled
//            //            }

//        }

        /*
        RowLayout{
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: qsTr("Floor heating area")

            }


            TextField {
                id: floorHeatingAreaId
                property bool floorHeatingArea_validated
                Layout.preferredWidth: 60
                Layout.rightMargin: 10
                text: heatingConfiguration.floorHeatingArea
                maximumLength: 5
                validator: DoubleValidator{bottom: 1}

                onTextChanged: acceptableInput ?floorHeatingArea_validated = true : floorHeatingArea_validated = false
            }

            Label {
                id: floorHeatingunit
                text: qsTr("m²")
            }



        }*/

        RowLayout{
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: qsTr("Maximal electrical power")

            }


            ConsolinnoTextField {
                id: maxElectricalPower
                property bool maxElectricalPower_validated
                Layout.preferredWidth: 60
                Layout.rightMargin: 8
                text: (+heatingConfiguration.maxElectricalPower).toLocaleString()
                maximumLength: 10
                validator: DoubleValidator{bottom: 1 }

                onTextChanged: acceptableInput ?maxElectricalPower_validated = true : maxElectricalPower_validated = false
            }

            Label {
                id: maxElectricalPowerunit
                text: qsTr("kW")
            }

        }

        RowLayout{
            Layout.fillWidth: true
            visible: heatPumpThing.thingClass.interfaces.includes("smartgridheatpump")

            Label {
                Layout.fillWidth: true
                text: qsTr("Grid-supportive-control")

            }

            ConsolinnoSwitch {
                id: gridSupportControl
                Component.onCompleted: checked = heatingConfiguration.controllableLocalSystem
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: heatPumpThing.thingClass.interfaces.includes("smartgridheatpump")

            Text {
                Layout.fillWidth: true
                font: Style.smallFont
                color: Style.consolinnoMedium
                wrapMode: Text.Wrap
                text: qsTr("If the device must be controlled in accordance with § 14a, this setting must be enabled and the nominal power must correspond to the registered power.")
            }
        }

        Item {
            // place holder
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

//        RowLayout{
//            Layout.fillWidth: true
//            Label {
//                Layout.fillWidth: true
//                text: qsTr("Thermal storage capacity")

//            }


//            TextField {
//                id: maxThermalEnergy
//                property bool maxThermalEnergy_validated
//                Layout.preferredWidth: 60
//                text: heatingConfiguration.maxThermalEnergy
//                maximumLength: 10
//                validator: DoubleValidator{bottom: 1}

//                onTextChanged: acceptableInput ?maxThermalEnergy_validated = true : maxThermalEnergy_validated = false
//            }
//            Label {
//                id: maxThermalEnergyunit
//                text: qsTr("kWh")
//            }


//        }






//                Label {
//                    Layout.fillWidth: true
//                    Layout.leftMargin: app.margins
//                    Layout.rightMargin: app.margins
//                    text: qsTr("For a better optimization you can assign a heat meter which is measuring the produced heat energy of this heat pump.")
//                    wrapMode: Text.WordWrap
//                    font.pixelSize: app.smallFont
//                    visible: !heatMeterIncluded
//                }




//                Button {
//                    id: assignHeatMeter
//                    Layout.fillWidth: true
//                    // We only need to assign a hear meter if this heatpump does not provide one
//                    visible: !heatMeterIncluded
//                    text: qsTr("TODO: Assign heat meter")
//                    // TODO: Select a heat meter from the things and show it here. Allow to reassign a heat meter and remove the assignment
//                }


        // potential footer for the config app, as a way to show the user that certain attributes where invalid.
        Label {
            id: footer
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            //text: qsTr("For a better optimization you can please insert the upper data, so our optimizer has the information it needs.")
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont

        }


        Button {
            id: savebutton
            property bool validated: maxElectricalPower.maxElectricalPower_validated


            Layout.fillWidth: true
            text: qsTr("Save")
            onClicked: {
                let inputText = maxElectricalPower.text
                inputText.includes(",") === true ? inputText = inputText.replace(",",".") : inputText
                if (savebutton.validated)
                {
                    if (directionID == 1){
                        hemsManager.setHeatingConfiguration(heatingConfiguration.heatPumpThingId, {optimizationEnabled: true, maxElectricalPower: inputText, controllableLocalSystem: gridSupportControl.checked,})
                        root.done()
                    }else if(directionID == 0){
                        d.pendingCallId = hemsManager.setHeatingConfiguration(heatingConfiguration.heatPumpThingId, {optimizationEnabled: true, maxElectricalPower: inputText, controllableLocalSystem: gridSupportControl.checked,})
                        root.done()
                    }
                }
                else
                {
                    // for now this is the way how we show the user that some attributes are invalid
                    // TO DO: Show which ones are invalid
                    footer.text = qsTr("Some attributes are outside of the allowed range: Configurations were not saved.")
                }
            }
        }

        // only visible if installation mode (directionID == 1)
//        Button {
//            id: passbutton
//            visible: directionID === 1

//            Layout.fillWidth: true
//            text: qsTr("skip")
//            onClicked: {
//                root.done()
//            }
//        }



    }
}

