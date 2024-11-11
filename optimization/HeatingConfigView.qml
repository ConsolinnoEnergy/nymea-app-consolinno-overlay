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

                    text: qsTr("Energymanager")
                    font.bold: true
                    font.pixelSize: 22

                }

            }

            Repeater {

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 5

                model: [
                    {Id: "performanceTarget", name: qsTr("Forwarded Solar Surplus"), value: thing.stateByName("actualPvSurplus") ? thing.stateByName("actualPvSurplus").value : null , unit: "W", component: stringValues, params: false, paramsSurPlus: thing.stateByName("actualPvSurplus") ? true : false},
                    {Id: "operatingMode", name: qsTr("Operating mode"), value: translateNymeaHeatpumpValues(thing.stateByName("sgReadyMode") ? thing.stateByName("sgReadyMode").value : null), unit: "", component: stringValues, params: thing.stateByName("sgReadyMode") ? true : false, paramsSurPlus: false},
                ]

                delegate: ItemDelegate {
                    visible: modelData.value !==  null && (modelData.params === true || modelData.paramsSurPlus === true) ? true : false
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
                                    property: "delegateName"
                                    value: modelData.name
                                }

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
                                    property: "delegateParams"
                                    value: modelData.params
                                }
                                Binding{
                                    target: optimizationParams.item
                                    property: "delegateParamsSurPlus"
                                    value: modelData.paramsSurPlus
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

                    text: qsTr("Heatpump condition")
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
                    {Id: "operatingMode", name: qsTr("Operating mode"), value: thing.stateByName("systemStatus") ? thing.stateByName("systemStatus").value : null, unit: "", component: stringValues, params: false, paramsSurPlus: false},
                    {Id: "currentConsumption", name: qsTr("Current consumption"), value: thing.stateByName("currentPower") ? thing.stateByName("currentPower").value : null , unit: "W", component: stringValues, params: false, paramsSurPlus: false},
                    {Id: "totalAmountOfEnergy", name: qsTr("Total amount of energy"), value: thing.stateByName("totalEnergyConsumed") ? thing.stateByName("totalEnergyConsumed").value : null , unit: "kWh", component: stringValues, params: false, paramsSurPlus: false},
                    {Id: "totalThermalEnergyGenerated", name: qsTr("Total thermal energy generated"), value: thing.stateByName("compressorTotalHeatOutput") ? thing.stateByName("compressorTotalHeatOutput").value : null , unit: "kWh", component: stringValues, params: false, paramsSurPlus: false},
                    {Id: "outdoorTemperature", name: qsTr("Outdoor temperature"), value: thing.stateByName("outdoorTemperature") ? thing.stateByName("outdoorTemperature").value : null , unit: "°C", component: stringValues, params: false, paramsSurPlus: false},
                    {Id: "coefficientOfPerformance", name: qsTr("COP"), value: thing.stateByName("coefficientOfPerformance") ? thing.stateByName("coefficientOfPerformance").value : null , unit: "", component: stringValues, params: false, paramsSurPlus: false},
                    {Id: "hotWaterTemperature", name: qsTr("Hot water temperature"), value: thing.stateByName("hotWaterTemperature") ? thing.stateByName("hotWaterTemperature").value : null , unit: "°C", component: stringValues, params: false, paramsSurPlus: false},
                ]

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
                                    property: "delegateParamsSurPlus"
                                    value: modelData.paramsSurPlus
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
                visible: thing && (thing.stateByName("flowTemperature") || thing.stateByName("returnTemperature"))
                Label
                {
                    id: heatingPumpCircuit
                    text: qsTr("Heating circuit")
                    font.bold: true
                    font.pixelSize: 22
                }
            }


            Repeater {

                model: [
                    {Id: "flowTemperature", name: qsTr("Flow temperature"), value: thing.stateByName("flowTemperature")? thing.stateByName("flowTemperature").value : null , unit: "°C", component: stringValues, params:false, paramsSurPlus: false},
                    {Id: "returnTemperature", name: qsTr("Return temperature"), value: thing.stateByName("returnTemperature")? thing.stateByName("returnTemperature").value : null , unit: "°C", component: stringValues, params:false, paramsSurPlus: false},
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
                                    target: optimization.item
                                    property: "delegateParamsSurPlus"
                                    value: modelData.paramsSurPlus
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
                    property var delegateParamsSurPlus: false
                    Layout.fillWidth: true

                    Label{
                        id: singleInput
                        text: delegateName
                        Layout.fillWidth: delegateParams === true || delegateParamsSurPlus === true ? false : true
                    }

                    InfoButton{
                        stack: pageStack
                        push: "EnergyManagerInfo.qml"
                        Layout.alignment: Qt.AlignTop
                        Layout.fillWidth: true
                        visible: delegateParams
                    }

                    InfoButton{
                        stack: pageStack
                        push: "PvSurplusInfo.qml"
                        Layout.alignment: Qt.AlignTop
                        Layout.fillWidth: true
                        visible: delegateParamsSurPlus
                    }

                    Label{
                        id: singleValue

                        property double numberValue: Number(delegateValue)

                        text: ( numberValue && delegateName == "COP" ? (((+delegateValue.toFixed(1)) <= 0) ? 0 : (+delegateValue.toFixed(1)).toLocaleString()) : numberValue ? (((+delegateValue.toFixed(0)) <= 0) ? 0 : (+delegateValue.toFixed(0)).toLocaleString()) : delegateValue) +" "+ delegateUnit
                    }
                }
            }

        }
    ]
}
