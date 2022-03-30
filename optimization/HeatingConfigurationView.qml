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

    header: NymeaHeader {
        text: qsTr("Heating")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins

        Repeater {
            model: hemsManager.heatingConfigurations
            delegate: NymeaItemDelegate {

                property HeatingConfiguration heatingConfiguration: hemsManager.heatingConfigurations.getHeatingConfiguration(model.heatPumpThingId)
                property Thing heatPumpThing: engine.thingManager.things.getThing(model.heatPumpThingId)

                Layout.fillWidth: true
                iconName: "../images/thermostat/heating.svg"
                progressive: true
                text: heatPumpThing.name
                onClicked: pageStack.push(heatingConfigurationComponent, { hemsManager: hemsManager, heatingConfiguration: heatingConfiguration, heatPumpThing: heatPumpThing })
            }
        }
    }

    Component.onCompleted: {
        // FIXME: directly open if there is only one heatpump to save a click
        //                if (hemsManager.heatingConfigurations.count === 1) {
        //                    onClicked: pageStack.push(heatingConfigurationComponent, { hemsManager: hemsManager,
        //                                                  heatingConfiguration: hemsManager.heatingConfigurations.get(0),
        //                                                  heatPumpThing: engine.thingManager.things.getThing(hemsManager.heatingConfigurations.get(0).heatPumpThingId) })
        //                }
    }

    Component {
        id: heatingConfigurationComponent

        Page {
            id: root
            property HemsManager hemsManager
            property HeatingConfiguration heatingConfiguration
            property Thing heatPumpThing

            property bool heatMeterIncluded: heatPumpThing.thingClass.interfaces.includes("heatmeter")
            // TODO: only if any configuration has changed, warn also on leaving if unsaved settings
            //property bool configurationSettingsChanged

            header: NymeaHeader {
                text: qsTr("Heating configuration")
                backButtonVisible: true
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
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: heatPumpThing.name
                    wrapMode: Text.WordWrap
                    //font.pixelSize: app.smallFont
                }

                RowLayout {
                    Layout.fillWidth: true


                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Optimization enabled")
                    }

                    Switch {
                        id: optimizationEnabledSwitch
                        Component.onCompleted: checked = heatingConfiguration.optimizationEnabled
                    }

                }


                RowLayout{
                    Layout.fillWidth: true
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Floor heating area")

                    }


                    TextField {
                        id: floorHeatingArea
                        property bool floorHeatingArea_validated
                        width: 120
                        placeholderText: ""
                        maximumLength: 5
                        validator: DoubleValidator{bottom: 0}

                        onTextChanged: acceptableInput ?floorHeatingArea_validated = true : floorHeatingArea_validated = false
                    }



                }


                RowLayout{
                    Layout.fillWidth: true
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Maximal electrical power")

                    }


                    TextField {
                        id: maxElectricalPower
                        property bool maxElectricalPower_validated
                        width: 120
                        placeholderText: ""
                        maximumLength: 10
                        validator: DoubleValidator{bottom: 0 }

                        onTextChanged: acceptableInput ?maxElectricalPower_validated = true : maxElectricalPower_validated = false
                    }




                }

                RowLayout{
                    Layout.fillWidth: true
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Maximal thermical power")

                    }


                    TextField {
                        id: maxThermalEnergy
                        property bool maxThermalEnergy_validated
                        width: 120
                        placeholderText: ""
                        maximumLength: 10
                        validator: DoubleValidator{bottom: 0}

                        onTextChanged: acceptableInput ?maxThermalEnergy_validated = true : maxThermalEnergy_validated = false
                    }



                }






                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: qsTr("For a better optimization you can assign a heat meter which is measuring the produced heat energy of this heat pump.")
                    wrapMode: Text.WordWrap
                    font.pixelSize: app.smallFont
                    visible: !heatMeterIncluded
                }




                Button {
                    id: assignHeatMeter
                    Layout.fillWidth: true
                    // We only need to assign a hear meter if this heatpump does not provide one
                    visible: !heatMeterIncluded
                    text: qsTr("TODO: Assign heat meter")
                    // TODO: Select a heat meter from the things and show it here. Allow to reassign a heat meter and remove the assignment
                }

                Item {
                    // place holder
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }



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
                    property bool validated: floorHeatingArea.floorHeatingArea_validated && maxThermalEnergy.maxThermalEnergy_validated && maxElectricalPower.maxElectricalPower_validated

                    Layout.fillWidth: true
                    text: qsTr("Save")
                    onClicked: {
                        if (savebutton.validated)
                        {
                            footer.text = "saved"
                            d.pendingCallId = hemsManager.setHeatingConfiguration(heatingConfiguration.heatPumpThingId, optimizationEnabledSwitch.checked, parseFloat( floorHeatingArea.text) , parseFloat( maxElectricalPower.text)  ,  parseFloat(maxThermalEnergy.text) )
                        }
                        else
                        {
                            // for now this is the way how we show the user that some attributes are invalid
                            // TO DO: Show which ones are invalid
                            footer.text = "Some attributes are outside of the allowed range: Configurations were not saved"

                        }


                    }
                }
            }
        }
    }
}



