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
                visible: thing && thing.stateByName("currentPower")

                Label{
                    Layout.fillWidth: true
                    id: consumption
                    text: qsTr("Current consumption:")
                    Layout.leftMargin:  15
                }

                Label{
                    id: consumptionValue

                    text: thing.stateByName("currentPower").value + " W"
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

            Repeater
            {
                id: optimizerRepeater

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 5

                // tbd: Configurationdata tab finishing
                model: [
                    {Id: "operatingMode", name: qsTr("Operating mode: "), value: translateNymeaHeatpumpValues(thing.stateByName("sgReadyMode") ? thing.stateByName("sgReadyMode").value : null), component: stringValues, unit: ""},
                    {Id: "configuartionData", name: qsTr("Configuration data: "), component: configValues,
                        params:[
                            {name: qsTr("Maximal electrical power"), value: heatingconfig.maxElectricalPower, unit: "kW"},
                        ]


                    },
                    {Id: "outdoorTemperature", name: qsTr("Outdoor temperature"), value: thing.stateByName("outdoorTemperature") ? thing.stateByName("outdoorTemperature").value : null , unit: "°C" , component: stringValues},
                    {Id: "hotWaterTemperature", name: qsTr("Hot water temperature"), value: thing.stateByName("hotWaterTemperature") ? thing.stateByName("hotWaterTemperature").value : null , unit: "°C" , component: stringValues},
                    {Id: "returnTemperature", name: qsTr("Return temperature"), value: thing.stateByName("returnTemperature")? thing.stateByName("returnTemperature").value : null , unit: "°C", component: stringValues},
                    {Id: "flowTemperature", name: qsTr("Flow temperature"), value: thing.stateByName("flowTemperature")? thing.stateByName("flowTemperature").value : null , unit: "°C", component: stringValues},
                ]

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

                        property double numberValue: Number(delegateValue)

                        text: ( numberValue ? numberValue.toFixed(1) : delegateValue) + delegateUnit
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
                            pageStack.push(configData, {
                                               "configDataValues": delegateParams
                                           })
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
                        text: thing.name
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
                                        Layout.minimumWidth: app.width - 2*app.margins - itemValue.contentWidth - itemUnit.width
                                        id: itemLabel
                                        text: modelData.name
                                    }

                                    Label
                                    {
                                        objectName: "ConfigDataRepeater_ItemValue_" + modelData.name
                                        id: itemValue
                                        text: modelData.value
                                    }

                                    Label
                                    {
                                        Layout.minimumWidth: 35
                                        id: itemUnit
                                        text: modelData.unit
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    ]
}
