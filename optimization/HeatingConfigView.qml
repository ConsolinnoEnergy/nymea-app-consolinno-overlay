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
                    anchors.leftMargin:  5
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: 15
                    text: qsTr("Performance target:")
                }

                Label {
                    Layout.rightMargin: 15
                    text: "12345"
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
                    {Id: "operatingMode", name: qsTr("Operating mode: "), value: heatingPumpValues(thing.stateByName("sgReadyMode") ? thing.stateByName("sgReadyMode").value : null), component: stringValues, unit: ""},
                    {Id: "currentConsumption", name: qsTr("Current consumption"), value: thing.stateByName("outdoorTemperature") ? thing.stateByName("outdoorTemperature").value : null , unit: "W" , component: stringValues},
                    {Id: "totalAmountOfEnergy", name: qsTr("Total amount of energy"), value: thing.stateByName("outdoorTemperature") ? thing.stateByName("outdoorTemperature").value : null , unit: "kWh" , component: stringValues},
                    {Id: "totalThermalEnergyGenerated", name: qsTr("Total thermal energy generated"), value: thing.stateByName("outdoorTemperature") ? thing.stateByName("outdoorTemperature").value : null , unit: "kWh" , component: stringValues},
                    {Id: "outdoorTemperature", name: qsTr("Outdoor temperature"), value: thing.stateByName("outdoorTemperature") ? thing.stateByName("outdoorTemperature").value : null , unit: "°C" , component: stringValues},
                    {Id: "coefficientOfPerformance", name: qsTr("COP"), value: thing.stateByName("outdoorTemperature") ? thing.stateByName("outdoorTemperature").value : null , unit: "W" , component: stringValues},
                    {Id: "hotWaterTemperature", name: qsTr("Hot water temperature"), value: thing.stateByName("hotWaterTemperature") ? thing.stateByName("hotWaterTemperature").value : null , unit: "°C" , component: stringValues},
                ]

                function heatingPumpValues(state){
                    switch(something)
                    {
                        case"Off":
                        {
                            return qsTr("Off")
                        }
                        case "Start":
                        {
                            return qsTr("Start Pump")
                        }
                        case "Standard":
                        {
                            return qsTr("Standard")
                        }
                        case "Cooling":
                        {
                            return qsTr("Cooling")
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
                    {Id: "flowTemperature", name: qsTr("Flow temperature"), value: thing.stateByName("flowTemperature")? thing.stateByName("flowTemperature").value : null , unit: "°C", component: stringValues},
                    {Id: "returnTemperature", name: qsTr("Return temperature"), value: thing.stateByName("returnTemperature")? thing.stateByName("returnTemperature").value : null , unit: "°C", component: stringValues},
                ]
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

                        text: ( numberValue ? (+numberValue.toFixed(1)).toLocaleString() : delegateValue.toLocaleString()) + delegateUnit
                    }
                }
            }

        }
    ]
}
