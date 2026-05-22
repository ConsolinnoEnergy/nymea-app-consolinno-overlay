import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import NymeaApp.Utils 1.0
import "../components"
import "../delegates"
import "../devicepages"

GenericConfigPage {
    id: root

    property Thing thing: null

    title: root.thing.name
    headerOptionsVisible: false

    function hasAnyState(stateNames) {
        if (!thing) return false
        for (var i = 0; i < stateNames.length; i++) {
            var s = thing.stateByName(stateNames[i].name)
            if (s !== null && s.value > 0 ) return true
        }
        return false
    }

    function formatValue(value, decimals) {
        if (typeof value === "string" && isNaN(Number(value)))
            return value
        return Number(value).toLocaleString(Qt.locale(), 'f', decimals)
    }

    // List of states to display. Each entry: { name: "stateName", decimals: N, unit: "unitOverride"}
    readonly property var generatorStates: [
        { name: "outdoorTemperature",                 decimals: 1 },
        { name: "flowTemperatureGenerator",           decimals: 1 },
        { name: "flowTemperatureGeneratorSetpoint",   decimals: 1 },
        { name: "returnTemperatureGenerator",         decimals: 1 },
        { name: "returnTemperatureGeneratorSetpoint", decimals: 1 },
        { name: "operationHours",                     decimals: 0 },
        { name: "switchingCycles",                    decimals: 0 },
        { name: "volumeFlow",                         decimals: 1, unit: "l/h" },
        { name: "actualThermalPower",                 decimals: 1 },
        { name: "actualCoefficientOfPerformance",     decimals: 2 },
        { name: "totalOutputThermalEnergy",           decimals: 0 },
        { name: "averageCoefficientOfPerformance",    decimals: 2 },
        { name: "operationState",                     decimals: 0 },
        { name: "errorCode",                          decimals: 0 },
        { name: "errorString",                        decimals: 0 }
    ]

    readonly property var heatCircuit1States: [
        { name: "flowTemperatureHC1",        decimals: 1 },
        { name: "flowTemperatureHC1Setpoint", decimals: 1 },
        { name: "returnTemperatureHC1",       decimals: 1 },
        { name: "returnTemperatureHC1Setpoint", decimals: 1 }
    ]

    readonly property var heatCircuit2States: [
        { name: "flowTemperatureHC2",        decimals: 1 },
        { name: "flowTemperatureHC2Setpoint", decimals: 1 },
        { name: "returnTemperatureHC2",       decimals: 1 },
        { name: "returnTemperatureHC2Setpoint", decimals: 1 }
    ]

    readonly property var heatCircuit3States: [
        { name: "flowTemperatureHC3",        decimals: 1 },
        { name: "flowTemperatureHC3Setpoint", decimals: 1 },
        { name: "returnTemperatureHC3",       decimals: 1 },
        { name: "returnTemperatureHC3Setpoint", decimals: 1 }
    ]

    readonly property var hotWaterStates: [
        { name: "temperatureHotwater",        decimals: 1 },
        { name: "temperatureHotwaterSetpoint", decimals: 1 }
    ]

    readonly property var bufferStates: [
        { name: "temperatureBufferTop",      decimals: 1 },
        { name: "temperatureBufferBottom",   decimals: 1 },
        { name: "temperatureBufferSetpoint", decimals: 1 }
    ]

    content: [
        Flickable {
            anchors.fill: parent
            contentHeight: columnLayout.implicitHeight
                           + columnLayout.anchors.topMargin
                           + columnLayout.anchors.bottomMargin
            clip: true

            ColumnLayout {
                id: columnLayout
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                CoFrostyCard {
                    id: generatorGroup
                    Layout.fillWidth: true
                    visible: true // is always visible     root.hasAnyState(root.generatorStates)
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Generator")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        Repeater {
                            model: root.generatorStates

                            CoCard {
                                readonly property State thingState: root.thing ? root.thing.stateByName(modelData.name) : null
                                readonly property var stateType: thingState ? root.thing.thingClass.stateTypes.getStateType(thingState.stateTypeId) : null

                                Layout.fillWidth: true
                                visible: thingState !== null && thingState.value > -100
                                labelText: stateType ? stateType.displayName : "..."
                                text: thingState ? root.formatValue(thingState.value, modelData.decimals) + " " + (modelData.unit ? modelData.unit : Types.toUiUnit(stateType.unit)) : "..."
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: heatCircuit1Group
                    Layout.fillWidth: true
                    visible: root.hasAnyState(root.heatCircuit1States)
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Heating circuit 1")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        Repeater {
                            model: root.heatCircuit1States

                            CoCard {
                                readonly property State thingState: root.thing ? root.thing.stateByName(modelData.name) : null
                                readonly property var stateType: thingState ? root.thing.thingClass.stateTypes.getStateType(thingState.stateTypeId) : null

                                Layout.fillWidth: true
                                visible: thingState !== null && thingState.value > -100
                                labelText: stateType ? stateType.displayName : "..."
                                text: thingState ? root.formatValue(thingState.value, modelData.decimals) + " " + (modelData.unit ? modelData.unit : Types.toUiUnit(stateType.unit)) : "..."
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: heatCircuit2Group
                    Layout.fillWidth: true
                    visible: root.hasAnyState(root.heatCircuit2States)
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Heating circuit 2")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        Repeater {
                            model: root.heatCircuit2States

                            CoCard {
                                readonly property State thingState: root.thing ? root.thing.stateByName(modelData.name) : null
                                readonly property var stateType: thingState ? root.thing.thingClass.stateTypes.getStateType(thingState.stateTypeId) : null

                                Layout.fillWidth: true
                                visible: thingState !== null && thingState.value > -100
                                labelText: stateType ? stateType.displayName : "..."
                                text: thingState ? root.formatValue(thingState.value, modelData.decimals) + " " + (modelData.unit ? modelData.unit : Types.toUiUnit(stateType.unit)) : "..."
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: heatCircuit3Group
                    Layout.fillWidth: true
                    visible: root.hasAnyState(root.heatCircuit3States)
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Heating circuit 3")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        Repeater {
                            model: root.heatCircuit3States

                            CoCard {
                                readonly property State thingState: root.thing ? root.thing.stateByName(modelData.name) : null
                                readonly property var stateType: thingState ? root.thing.thingClass.stateTypes.getStateType(thingState.stateTypeId) : null

                                Layout.fillWidth: true
                                visible: thingState !== null && thingState.value > -100
                                labelText: stateType ? stateType.displayName : "..."
                                text: thingState ? root.formatValue(thingState.value, modelData.decimals) + " " + (modelData.unit ? modelData.unit : Types.toUiUnit(stateType.unit)) : "..."
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: hotWaterGroup
                    Layout.fillWidth: true
                    visible: root.hasAnyState(root.hotWaterStates)
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Hot water")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        Repeater {
                            model: root.hotWaterStates

                            CoCard {
                                readonly property State thingState: root.thing ? root.thing.stateByName(modelData.name) : null
                                readonly property var stateType: thingState ? root.thing.thingClass.stateTypes.getStateType(thingState.stateTypeId) : null

                                Layout.fillWidth: true
                                visible: thingState !== null && thingState.value > -100
                                labelText: stateType ? stateType.displayName : "..."
                                text: thingState ? root.formatValue(thingState.value, modelData.decimals) + " " + (modelData.unit ? modelData.unit : Types.toUiUnit(stateType.unit)) : "..."
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: bufferGroup
                    Layout.fillWidth: true
                    visible: root.hasAnyState(root.bufferStates)
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Buffer")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        Repeater {
                            model: root.bufferStates

                            CoCard {
                                readonly property State thingState: root.thing ? root.thing.stateByName(modelData.name) : null
                                readonly property var stateType: thingState ? root.thing.thingClass.stateTypes.getStateType(thingState.stateTypeId) : null

                                Layout.fillWidth: true
                                visible: thingState !== null && thingState.value > -100
                                labelText: stateType ? stateType.displayName : "..."
                                text: thingState ? root.formatValue(thingState.value, modelData.decimals) + " " + (modelData.unit ? modelData.unit : Types.toUiUnit(stateType.unit)) : "..."
                            }
                        }
                    }
                }

            }
        }
    ]
}
