import QtQuick 2.12
import QtQuick.Controls 2.15
import Nymea 1.0
import QtQuick.Controls.Material 2.1
import QtQml 2.15
import QtQuick.Layouts 1.3

import "../components"
import "../delegates"

Page {
    id: root

    property HemsManager hemsManager
    property Thing heatpumpThing
    property HeatingConfiguration heatingconfig: hemsManager.heatingConfigurations.getHeatingConfiguration(heatpumpThing.id)






    header: NymeaHeader {
        id: header
        text: heatpumpThing.name
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout{
        id: columnLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins
        anchors.margins: app.margins

        RowLayout{
            Layout.fillWidth: true
                Label{
                    Layout.fillWidth: true
                    id: consumption
                    text: qsTr("Current consumption:")
                }





            Label{
                id: consumptionValue
                text: heatpumpThing.stateByName("currentPower").value + " W"

             }
        }


        RowLayout{
            Layout.fillWidth: true

            Label{
                id: optimiziationEnabled
                Layout.fillWidth: true
                text: qsTr("Optimization")
            }

            Switch{
                id: optimizationEnableSwitch
                checked: heatingconfig.optimizationEnabled


            }



        }

        VerticalDivider
        {Layout.fillWidth: true}


        Label
        {
        Layout.fillWidth: true
        Layout.leftMargin: app.width/6
        text: qsTr("Energymanager: ")
        font.bold: true
        }




            Repeater
            {
                id: optimizerRepeater
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 5
                    // tbd: Configurationdata tab finishing
                model: [
                   // {Id: "operatingMode", name: "Operating mode: ", value: heatpumpThing.stateByName("sgReadyMode").value, component: stringValues, unit: ""},
                   // {Id: "configurationData", name: "Configuration data: ",  component: stringValues },
                    //{Id: "floorHeatingArea", name: "Floor heating area: ", value: heatingconfig.floorHeatingArea, unit: "m²"},
//                    {Id: "maximalElectricalPower", name: "Maximal electrical power: ", value: heatingconfig.maxElectricalPower, unit: "kW"},
                   // {Id: "thermalStorageCapacity", name: "Thermal storage capacity: ", value: heatingconfig.maxThermalEnergy, unit: "kWh"},

                ]

                delegate: ItemDelegate{
                    id: optimizerInputs
                    Layout.fillWidth: true
                    Layout.rightMargin: app.width/4
                    Layout.leftMargin: app.width/4
                    contentItem: ColumnLayout
                    {

                        Layout.fillWidth: true
                        RowLayout{
                            Layout.fillWidth: true
                            Label{
                                id: singleInput
                                Layout.fillWidth: true
                                text: modelData.name

                            }
                            Loader
                            {
                                id: optimizationParams
                                Binding{
                                    target: optimizationParams.item
                                    property: "delegateValue"
                                    value: modelData.value
                                }
                                Binding{
                                    target: optimizationParams.item
                                    property: "delegateUnit"
                                    value: modelData.unit
                                }


                                Layout.fillWidth: true
                                sourceComponent:
                                {
                                switch(modelData.Id)
                                {
                                case "operatingMode" :
                                    {
                                        return stringValues
                                    }
                                case "configuartionData":
                                    {
                                        return stringValues
                                    }
                                }

                                }

                            }

                        }

                    }

                }

            }

        VerticalDivider
        {
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
            onClicked: {

                hemsManager.setHeatingConfiguration(heatpumpThing, optimizationEnableSwitch.checked, heatingconfig.floorHeatingArea, heatingconfig.maxElectricalPower, heatingconfig.maxThermalEnergy, heatingconfig.heatMeterThingId)
                pageStack.pop()

            }
        }

        Component{
            id: stringValues

            Label{
                property var delegateValue
                property var delegateUnit
                id: singleValue
                text: delegateValue + delegateUnit
            }


        }


    }







}
