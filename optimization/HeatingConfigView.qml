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

            }

            Repeater {

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 5

                model: [
                    {Id: "performanceTarget", name: qsTr("Performance target: "), value: thing.stateByName("actualPvSurplus") ? thing.stateByName("actualPvSurplus").value : null , unit: "", component: stringValues, paramsBool: true, paramsBoolPv: true},
                    {Id: "operatingMode", name: qsTr("Operating mode: "), value: translateNymeaHeatpumpValues(thing.stateByName("sgReadyMode") ? thing.stateByName("sgReadyMode").value : null), component: stringValues, unit: "", paramsBool:true},
                ]

                delegate: ItemDelegate {
                    visible: modelData.value !==  null ? true : false
                    id: optimizerMainParams
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
                                Binding{
                                    target: optimizationParams.item
                                    property: "delegateParamsBool"
                                    value: modelData.paramsBool
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
                                        case "operatingMode":
                                        {
                                            return modelData.component
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                function translateNymeaHeatpumpValues(something){
                    switch(something)
                    {
                    case"Off":
                    {
                        return qsTr("Off")
                    }
                    case "Low":
                    {
                        return qsTr("Standard")
                    }
                    case "Standard":
                    {
                        return qsTr("Increased")
                    }
                    case "High":
                    {
                        return qsTr("High")
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
                    {Id: "operatingMode", name: qsTr("Operating mode: "), value: heatingPumpValues(thing.stateByName("operatingMode") ? thing.stateByName("operatingMode").value : "STBY"), unit: "", component: stringValues, paramsBool:false},
                    {Id: "currentConsumption", name: qsTr("Current consumption"), value: thing.stateByName("currentPower") ? thing.stateByName("currentPower").value : null , unit: "W", component: stringValues, paramsBool:false},
                    {Id: "totalAmountOfEnergy", name: qsTr("Total amount of energy"), value: thing.stateByName("totalEnergyConsumed") ? thing.stateByName("totalEnergyConsumed").value : null , unit: "kWh", component: stringValues, paramsBool:false},
                    {Id: "totalThermalEnergyGenerated", name: qsTr("Total thermal energy generated"), value: thing.stateByName("compressorTotalHeatOutput") ? thing.stateByName("compressorTotalHeatOutput").value : null , unit: "kWh", component: stringValues, paramsBool:false},
                    {Id: "outdoorTemperature", name: qsTr("Outdoor temperature"), value: thing.stateByName("outdoorTemperature") ? thing.stateByName("outdoorTemperature").value : null , unit: "°C", component: stringValues, paramsBool:false},
                    {Id: "coefficientOfPerformance", name: qsTr("COP"), value: thing.stateByName("coefficientOfPerformance") ? thing.stateByName("coefficientOfPerformance").value : null , unit: "W", component: stringValues, paramsBool:false},
                    {Id: "hotWaterTemperature", name: qsTr("Hot water temperature"), value: thing.stateByName("hotWaterTemperature") ? thing.stateByName("hotWaterTemperature").value : null , unit: "°C", component: stringValues, paramsBool:false},
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
                    visible: modelData.value !==  null ? true : false
                    id: optimizerInputs
                    Layout.fillWidth: true
                    contentItem: ColumnLayout
                    {
                        Layout.fillWidth: true

                        RowLayout{
                            Layout.fillWidth: true

                            Loader
                            {
                                id: optimizationMainParams

                                Binding{
                                    target: optimizationMainParams.item
                                    property: "delegateValue"
                                    value: modelData.value
                                }

                                Binding{
                                    target: optimizationMainParams.item
                                    property: "delegateUnit"
                                    value: modelData.unit
                                }

                                Binding{
                                    target: optimizationMainParams.item
                                    property: "delegateName"
                                    value: modelData.name
                                }

                                Binding{
                                    target: optimizationMainParams.item
                                    property: "delegateParams"
                                    value: modelData.params
                                }
                                Binding{
                                    target: optimizationMainParams.item
                                    property: "delegateParamsBool"
                                    value: modelData.paramsBool
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
                visible: thing && (thing.stateByName("flowTemperature").value !== null || thing.stateByName("returnTemperature").value !== null)
                Label
                {
                    id: heatingPumpCircuit
                    text: qsTr("Heating circuit: ")
                    font.bold: true
                    font.pixelSize: 22
                }
            }


            Repeater {
                model: [
                    {Id: "flowTemperature", name: qsTr("Flow temperature"), value: thing.stateByName("flowTemperature")? thing.stateByName("flowTemperature").value : null , unit: "°C", component: stringValues, paramsBool:false},
                    {Id: "returnTemperature", name: qsTr("Return temperature"), value: thing.stateByName("returnTemperature")? thing.stateByName("returnTemperature").value : null , unit: "°C", component: stringValues, paramsBool:false},
                ]

                delegate: ItemDelegate{
                    visible: modelData.value !==  null ? true : false
                    id: optimizer
                    Layout.fillWidth: true
                    contentItem: ColumnLayout
                    {
                        Layout.fillWidth: true

                        RowLayout{
                            Layout.fillWidth: true

                            Loader
                            {
                                id: optimization

                                Binding{
                                    target: optimization.item
                                    property: "delegateValue"
                                    value: modelData.value
                                }

                                Binding{
                                    target: optimization.item
                                    property: "delegateUnit"
                                    value: modelData.unit
                                }

                                Binding{
                                    target: optimization.item
                                    property: "delegateName"
                                    value: modelData.name
                                }

                                Binding{
                                    target: optimization.item
                                    property: "delegateParams"
                                    value: modelData.params
                                }
                                Binding{
                                    target: optimizationMainParams.item
                                    property: "delegateParamsBool"
                                    value: modelData.paramsBool
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
                    property var delegateParamsBool
                    Layout.fillWidth: true

                    Label{
                        id: singleInput
                        text: delegateName
                        Layout.fillWidth: delegateParamsBool === true ? false : true
                    }

                    InfoButton{
                        stack: pageStack
                        push: paramsBoolPv === true ? "" : "EnergyManagerInfo.qml"
                        anchors.left: singleInput.right
                        anchors.top: singleInput.top
                        anchors.leftMargin: 5
                        Layout.fillWidth: true
                        visible: delegateParamsBool
                    }

                    Label{
                        id: singleValue

                        property double numberValue: Number(delegateValue)

                        text: ( numberValue && delegateName == "COP" ? (+numberValue.toFixed(1)).toLocaleString() : numberValue ? (+delegateValue.toFixed(0)).toLocaleString() : delegateValue.toLocaleString() ) + delegateUnit
                    }
                }
            }

        }
    ]
}
