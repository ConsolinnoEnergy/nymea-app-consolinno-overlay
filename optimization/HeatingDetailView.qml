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
            var s = thing.stateByName(stateNames[i])
            if (s !== null && s.value > 0 ) return true
        }
        return false
    }

    function formatValue(value, unit) {
        if (typeof value === "string" && isNaN(Number(value)))
            return value

        var decimals
        switch (unit) {
        case Types.UnitDegreeCelsius:
        case Types.UnitDegreeKelvin:
        case Types.UnitDegreeFahrenheit:
            decimals = 1
            break
        case Types.UnitWatt:
        case Types.UnitKiloWatt:
        case Types.UnitMilliWatt:
        case Types.UnitKiloWattHour:
            decimals = 0
            break
        case Types.UnitNone:
            decimals = 0
            break
        default:
            decimals = 2
            break
        }
        return Number(value).toLocaleString(Qt.locale(), 'f', decimals)
    }

    // List of state names to display
    readonly property var generatorStates: [
        "outdoorTemperature",
        "flowTemperatureGenerator",
        "flowTemperatureGeneratorSetpoint",
        "returnTemperatureGenerator",
        "returnTemperatureGeneratorSetpoint",
        "operationHours",
        "switchingCycles",
        "volumeFlow",
        "actualThermalPower",
        "actualCoefficientOfPerformance",
        "totalOutputThermalEnergy",
        "averageCoefficientOfPerformance",
        "operationState",
        "errorCode",
        "errorString"
    ]

    readonly property var heatCircuit1States: [
        "flowTemperatureHC1",
        "flowTemperatureHC1Setpoint",
        "returnTemperatureHC1",
        "returnTemperatureHC1Setpoint"
    ]

    readonly property var heatCircuit2States: [
        "flowTemperatureHC2",
        "flowTemperatureHC2Setpoint",
        "returnTemperatureHC2",
        "returnTemperatureHC2Setpoint"
    ]

    readonly property var heatCircuit3States: [
        "flowTemperatureHC3",
        "flowTemperatureHC3Setpoint",
        "returnTemperatureHC3",
        "returnTemperatureHC3Setpoint"
    ]

    readonly property var hotWaterStates: [
        "temperatureHotwater",
        "temperatureHotwaterSetpoint",
    ]

    readonly property var bufferStates: [
        "temperatureBufferTop",
        "temperatureBufferBottom",
        "temperatureBufferSetpoint"
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
                                readonly property State thingState: root.thing ? root.thing.stateByName(modelData) : null
                                readonly property var stateType: thingState ? root.thing.thingClass.stateTypes.getStateType(thingState.stateTypeId) : null

                                Layout.fillWidth: true
                                visible: thingState !== null && thingState.value > -100
                                labelText: stateType ? stateType.displayName : "..."
                                text: thingState ? root.formatValue(thingState.value, stateType.unit) + " " + Types.toUiUnit(stateType.unit) : "..."
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
                                readonly property State thingState: root.thing ? root.thing.stateByName(modelData) : null
                                readonly property var stateType: thingState ? root.thing.thingClass.stateTypes.getStateType(thingState.stateTypeId) : null

                                Layout.fillWidth: true
                                visible: thingState !== null && thingState.value > -100
                                labelText: stateType ? stateType.displayName : "..."
                                text: thingState ? root.formatValue(thingState.value, stateType.unit) + " " + Types.toUiUnit(stateType.unit) : "..."
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
                                readonly property State thingState: root.thing ? root.thing.stateByName(modelData) : null
                                readonly property var stateType: thingState ? root.thing.thingClass.stateTypes.getStateType(thingState.stateTypeId) : null

                                Layout.fillWidth: true
                                visible: thingState !== null && thingState.value > -100
                                labelText: stateType ? stateType.displayName : "..."
                                text: thingState ? root.formatValue(thingState.value, stateType.unit) + " " + Types.toUiUnit(stateType.unit) : "..."
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
                                readonly property State thingState: root.thing ? root.thing.stateByName(modelData) : null
                                readonly property var stateType: thingState ? root.thing.thingClass.stateTypes.getStateType(thingState.stateTypeId) : null

                                Layout.fillWidth: true
                                visible: thingState !== null && thingState.value > -100
                                labelText: stateType ? stateType.displayName : "..."
                                text: thingState ? root.formatValue(thingState.value, stateType.unit) + " " + Types.toUiUnit(stateType.unit) : "..."
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
                                readonly property State thingState: root.thing ? root.thing.stateByName(modelData) : null
                                readonly property var stateType: thingState ? root.thing.thingClass.stateTypes.getStateType(thingState.stateTypeId) : null

                                Layout.fillWidth: true
                                visible: thingState !== null && thingState.value > -100
                                labelText: stateType ? stateType.displayName : "..."
                                text: thingState ? root.formatValue(thingState.value, stateType.unit) + " " + Types.toUiUnit(stateType.unit) : "..."
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
                                readonly property State thingState: root.thing ? root.thing.stateByName(modelData) : null
                                readonly property var stateType: thingState ? root.thing.thingClass.stateTypes.getStateType(thingState.stateTypeId) : null

                                Layout.fillWidth: true
                                visible: thingState !== null && thingState.value > -100
                                labelText: stateType ? stateType.displayName : "..."
                                text: thingState ? root.formatValue(thingState.value, stateType.unit) + " " + Types.toUiUnit(stateType.unit) : "..."
                            }
                        }
                    }
                }

            }
        }
    ]
}
