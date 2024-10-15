import QtQuick 2.12
import QtQuick.Controls 2.15
import Nymea 1.0
import QtQuick.Controls.Material 2.1
import QtQml 2.15
import QtQuick.Layouts 1.3

import "../components"
import "../delegates"
import "../devicepages"

GenericConfigPage {
    id: root

    property HemsManager hemsManager
    property Thing thing
    property HeatingConfiguration heatingconfig: hemsManager.heatingConfigurations.getHeatingConfiguration(
                                                     thing.id)

    title: root.thing.name
    headerOptionsVisible: false

    content: [
        ColumnLayout{
            id: columnLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: app.margins
            anchors.rightMargin: app.margins

            RowLayout{
                Layout.fillWidth: true
                visible: false //thing && thing.stateByName("currentPower")

                Label{
                    Layout.fillWidth: true
                    id: consumption
                    text: qsTr("Current consumption:")
                    Layout.leftMargin:  15
                }

                Label{
                    id: consumptionValue
                    Layout.rightMargin: 15
                    text: (+thing.stateByName("currentPower").value).toLocaleString() + " W"
                }
            }

            Row{
                Layout.fillWidth: true
                Layout.leftMargin: 15
                Layout.topMargin: 10

                Label
                {
                    id: energyManager

                    text: qsTr("Energymanager: ")
                    font.bold: true
                    font.pixelSize: 22

                }

                InfoButton{
                    stack: pageStack
                    push: "EnergyManagerInfo.qml"
                    anchors.left: energyManager.right
                    anchors.top: energyManager.top
                    anchors.leftMargin:  5
                    anchors.topMargin: 5
                }
            }

            Repeater {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 5

                // tbd: Configurationdata tab finishing
                model: [
                    {Id: "performanceTarget", name: qsTr("Performance target: "), value: thing.stateByName("performanceTarget") ? thing.stateByName("performanceTarget").value : 15.89, component: stringValues, unit: "W"},
                ]


                delegate: ItemDelegate{
                    visible: true //modelData.value !==  null ? true : false
                    Layout.fillWidth: true
                    contentItem: ColumnLayout
                    {
                        Layout.fillWidth: true

                        RowLayout{
                            Layout.fillWidth: true

                            Loader
                            {
                                id: optimizationParamsEnergyManger

                                Binding{
                                    target: optimizationParamsEnergyManger.item
                                    property: "delegateValue"
                                    value: modelData.value
                                }

                                Binding{
                                    target: optimizationParamsEnergyManger.item
                                    property: "delegateUnit"
                                    value: modelData.unit
                                }

                                Binding{
                                    target: optimizationParamsEnergyManger.item
                                    property: "delegateName"
                                    value: modelData.name
                                }

                                Binding{
                                    target: optimizationParamsEnergyManger.item
                                    property: "delegateParams"
                                    value: modelData.params
                                }
                                Layout.fillWidth: true
                                sourceComponent:
                                {
                                    switch(modelData.Id)
                                    {
                                        case "performanceTarget":
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


            Row {
                Layout.fillWidth: true
                Layout.leftMargin: 15
                Layout.topMargin: 10

                Label
                {
                    id: heatingPumpStates

                    text: qsTr("Heatpump condition: ")
                    font.bold: true
                    font.pixelSize: 22
                }

            }

            Repeater {
                id: heatpumpConditions

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 5

                // tbd: Configurationdata tab finishing
                model: [
                    {Id: "operatingMode", name: qsTr("Operating mode: "), value: heatingPumpValues(thing.stateByName("operatingMode") ? thing.stateByName("operatingMode").value : "STBY"), component: stringValues, unit: ""},
                    {Id: "currentConsumption", name: qsTr("Current consumption"), value: thing.stateByName("currentConsumption") ? thing.stateByName("currentConsumption").value : 23.89 , unit: "W" , component: stringValues},
                    {Id: "totalAmountOfEnergy", name: qsTr("Total amount of energy"), value: thing.stateByName("totalAmountOfEnergy") ? thing.stateByName("totalAmountOfEnergy").value : 34.78 , unit: "kWh" , component: stringValues},
                    {Id: "totalThermalEnergyGenerated", name: qsTr("Total thermal energy generated"), value: thing.stateByName("totalThermalEnergyGenerated") ? thing.stateByName("totalThermalEnergyGenerated").value : 23.8 , unit: "kWh" , component: stringValues},
                    {Id: "outdoorTemperature", name: qsTr("Outdoor temperature"), value: thing.stateByName("outdoorTemperature") ? thing.stateByName("outdoorTemperature").value : 20.789 , unit: "°C" , component: stringValues},
                    {Id: "coefficientOfPerformance", name: qsTr("COP"), value: thing.stateByName("coefficientOfPerformance") ? thing.stateByName("coefficientOfPerformance").value : 23.89 , unit: "W" , component: stringValues},
                    {Id: "hotWaterTemperature", name: qsTr("Hot water temperature"), value: thing.stateByName("hotWaterTemperature") ? thing.stateByName("hotWaterTemperature").value : 45.6 , unit: "°C" , component: stringValues},
                ]

                function heatingPumpValues(state){
                    switch(state)
                    {
                        case"STBY":
                        {
                            return qsTr("STBY")
                        }
                        case "CH":
                        {
                            return qsTr("CH")
                        }
                        case "DHW":
                        {
                            return qsTr("DHW")
                        }
                        case "CC":
                        {
                            return qsTr("CC")
                        }
                        case "CIRCULATE":
                        {
                            return qsTr("CIRCULATE")
                        }
                        case "DEFROST":
                        {
                            return qsTr("DEFROST")
                        }
                        case "OFF":
                        {
                            return qsTr("OFF")
                        }
                        case "FROST":
                        {
                            return qsTr("FROST")
                        }
                        case "STBY-FROST":
                        {
                            return qsTr("STBY-FROST")
                        }
                        case "SUMMER":
                        {
                            return qsTr("SUMMER")
                        }
                        case "HOLIDAY":
                        {
                            return qsTr("HOLIDAY")
                        }
                        case "ERROR":
                        {
                            return qsTr("ERROR")
                        }
                        case "WARNING":
                        {
                            return qsTr("WARNING")
                        }
                        case "INFO-MESSAGE":
                        {
                            return qsTr("INFO-MESSAGE")
                        }
                        case "IME-BLOCK":
                        {
                            return qsTr("IME-BLOCK")
                        }
                        case "ELEASE-BLOCK":
                        {
                            return qsTr("ELEASE-BLOCK")
                        }
                        case "MINTEMP-BLOCK":
                        {
                            return qsTr("MINTEMP-BLOCK")
                        }
                        case "FIRMWARE-DOWNLOAD":
                        {
                            return qsTr("FIRMWARE-DOWNLOAD")
                        }
                    }
                }

                delegate: ItemDelegate{
                    visible: true //modelData.value !==  null ? true : false
                    id: optimizerInputs
                    Layout.fillWidth: true
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
                                        case "currentConsumption":
                                        {
                                            return modelData.component
                                        }
                                        case "totalAmountOfEnergy":
                                        {
                                            return modelData.component
                                        }
                                        case "totalThermalEnergyGenerated":
                                        {
                                            return modelData.component
                                        }
                                        case "outdoorTemperature":
                                        {
                                            return modelData.component
                                        }
                                        case "coefficientOfPerformance":
                                        {
                                            return modelData.component
                                        }
                                        case "hotWaterTemperature":
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

            Row {
                Layout.fillWidth: true
                Layout.leftMargin: 15
                Layout.topMargin: 10

                Label
                {
                    id: heatingPumpCircuit
                    text: qsTr("Heating circuit: ")
                    font.bold: true
                    font.pixelSize: 22
                }
            }

            Repeater {
                id: heatingPumpCircuitRepeater
                model: [
                    {Id: "flowTemperature", name: qsTr("Flow temperature"), value: thing.stateByName("flowTemperature")? thing.stateByName("flowTemperature").value : 45 , unit: "°C", component: stringValues},
                    {Id: "returnTemperature", name: qsTr("Return temperature"), value: thing.stateByName("returnTemperature")? thing.stateByName("returnTemperature").value : 56 , unit: "°C", component: stringValues},
                ]

                delegate: ItemDelegate{
                    visible: true //modelData.value !==  null ? true : false
                    Layout.fillWidth: true
                    contentItem: ColumnLayout
                    {
                        Layout.fillWidth: true

                        RowLayout{
                            Layout.fillWidth: true

                            Loader
                            {
                                id: optimizationParamsBottom

                                Binding{
                                    target: optimizationParamsBottom.item
                                    property: "delegateValue"
                                    value: modelData.value
                                }

                                Binding{
                                    target: optimizationParamsBottom.item
                                    property: "delegateUnit"
                                    value: modelData.unit
                                }

                                Binding{
                                    target: optimizationParamsBottom.item
                                    property: "delegateName"
                                    value: modelData.name
                                }

                                Binding{
                                    target: optimizationParamsBottom.item
                                    property: "delegateParams"
                                    value: modelData.params
                                }
                                Layout.fillWidth: true
                                sourceComponent:
                                {
                                    switch(modelData.Id)
                                    {
                                        case "flowTemperature":
                                        {
                                            return modelData.component
                                        }
                                        case "returnTemperature":
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

            Component{
                id: stringValues

                RowLayout {
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

                        property double numberValue: Number(delegateValue)

                        text: ( numberValue && delegateName === "COP"? (+numberValue.toFixed(1)).toLocaleString() : numberValue ? (+numberValue.toFixed(0)).toLocaleString() : delegateValue.toLocaleString()) + delegateUnit
                    }
                }
            }

        }
    ]
}
