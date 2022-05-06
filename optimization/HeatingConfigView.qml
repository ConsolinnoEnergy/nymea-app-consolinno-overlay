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
        //Layout.leftMargin: app.width/6
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
                    {Id: "operatingMode", name: "Operating mode: ", value: translateNymeaHeatpumpValues(heatpumpThing.stateByName("sgReadyMode").value), component: stringValues, unit: ""},
                    {Id: "configuartionData", name: "Configuration data: ", component: configValues,
                        params:[
                            {name: "Floor heating area", value: heatingconfig.floorHeatingArea},
                            {name: "Maximal electrical power", value: heatingconfig.maxElectricalPower},
                            {name: "Thermal storage capacity", value: heatingconfig.maxThermalEnergy},
                        ]


                    },
                    {Id: "outdoorTemperature", name: "Outdoor temperature", value: heatpumpThing.stateByName("outdoorTemperature") , unit: "°C" , component: stringValues},
                    {Id: "hotWaterTemperature", name: "Hot water temperature", value: heatpumpThing.stateByName("hotWaterTemperature") , unit: "°C" , component: stringValues},
                    {Id: "returnTemperature", name: "Return temperature", value: heatpumpThing.stateByName("returnTemperature") , unit: "°C", component: stringValues},
                    {Id: "flowTemperature", name: "Flow temperature", value: heatpumpThing.stateByName("flowTemperature") , unit: "°C", component: stringValues},


                ]

                function translateNymeaHeatpumpValues(something){


                    switch(something)
                    {
                    case"Off":
                        {
                            return "Off"
                        }
                    case "Low":
                        {
                            return "Standard"
                        }
                    case "Standard":
                        {
                            return "Increased"
                        }
                    case "High":
                        {
                            return "High"
                        }

                    }

                }

                delegate: ItemDelegate{
                    visible: modelData.value !== null ? true : false
                    id: optimizerInputs
                    Layout.fillWidth: true
                    //Layout.rightMargin: app.width/4
                    //Layout.leftMargin: app.width/4
                    contentItem: ColumnLayout
                    {
                        Layout.fillWidth: true
                        RowLayout{
                            Layout.fillWidth: true
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
                                Binding{
                                    target: optimizationParams.item
                                    property: "delegateName"
                                    value: modelData.name
                                }
                                Binding{
                                    target: optimizationParams.item
                                    property: "delegateParams"
                                    value: modelData.params
                                }


                                Layout.fillWidth: true
                                sourceComponent:
                                {



                                switch(modelData.Id)
                                {
                                case "operatingMode":
                                    {
                                        return modelData.component
                                    }
                                case "configuartionData":
                                    {
                                        return modelData.component
                                    }
                                case "outdoorTemperature":
                                    {
                                        return modelData.component
                                    }
                                case "hotWaterTemperature":
                                    {
                                        return modelData.component
                                    }
                                case "returnTemperature":
                                    {
                                        return modelData.component
                                    }
                                case "flowTemperature":
                                    {
                                        return modelData.component
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


                hemsManager.setHeatingConfiguration(heatpumpThing.id, optimizationEnableSwitch.checked, heatingconfig.floorHeatingArea, heatingconfig.maxElectricalPower, heatingconfig.maxThermalEnergy)
                pageStack.pop()

            }
        }

        Component{
            id: stringValues
            RowLayout{
                property var delegateName
                property var delegateValue
                property var delegateUnit
                property var delegateParams
                Layout.fillWidth: true
                Label{
                    id: singleInput
                    Layout.fillWidth: true
                    text: delegateName

                }

                Label{
                    id: singleValue
                    text: delegateValue + delegateUnit
                }
            }

        }

        Component
        {
            id: configValues


            RowLayout{
                property var delegateName
                property var delegateValue
                property var delegateUnit
                property var delegateParams
                Layout.fillWidth: true


                Label{
                    id: configLabel
                    text: delegateName

                }


                NymeaItemDelegate{

                    id: configDelegate
                    Layout.fillWidth: true
                    onClicked:
                    {
                       pageStack.push(configData, {configDataValues: delegateParams })
                    }




                    }
              }




        }
        Component
        {
            id: configData
            Page{
                id: configDataPage
                Layout.fillWidth: true
                property var configDataValues

                header: NymeaHeader {
                    id: header
                    text: heatpumpThing.name
                    backButtonVisible: true
                    onBackPressed: pageStack.pop()
                }


                ColumnLayout{
                    Layout.fillWidth: true
                    Repeater
                    {
                        Layout.fillWidth: true
                        id:  configDataRepeater
                        model: configDataValues
                        delegate: ItemDelegate{
                            Layout.fillWidth: true
                            contentItem: RowLayout{
                                    Layout.fillWidth: true


                                    Label
                                    {
                                        Layout.minimumWidth: app.width - 2*app.margins - itemValue.contentWidth
                                        id: itemLabel
                                        text: modelData.name

                                    }

                                    Label
                                    {

                                        id: itemValue
                                        text: modelData.value

                                    }


                            }




                        }




                    }


                }

            }
        }



    }







}
