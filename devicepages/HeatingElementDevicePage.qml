import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

GenericConfigPage {
    id: root

    readonly property State currentTemperature: root.thing.stateByName("waterTemperature")
    readonly property State targetTemperature: root.thing.stateByName("targetWaterTemperature")
    readonly property State minTemperature: root.thing.stateByName("minWaterTemperature")
    readonly property State currentConsumption: root.thing.stateByName("currentPower")
    readonly property State totalConsumption: root.thing.stateByName("totalEnergyConsumed")
    readonly property State powerSetpointActive: root.thing.stateByName("activateControlConsumer")
    readonly property State powerSetpoint: root.thing.stateByName("powerSetpointConsumer")

    readonly property real operatingModeStatus: 1;

    property Thing thing: null

    title: root.thing.name
    headerOptionsVisible: false

    content: [

        Flickable {
            anchors.fill: parent
            contentHeight: columnLayout.implicitHeight
            clip: false

            ColumnLayout{
                id: columnLayout
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: app.margins

                Repeater {

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 5

                    model: [
                        {
                            Id: "currentTemperature",
                            name: qsTr("Current Temperature"),
                            value: (root.currentTemperature === null) ? 0 : (+root.currentTemperature.value).toLocaleString(),
                            unit: " °C",
                            component: stringValues,
                            visible: true
                        },
                        {
                            Id: "targetTemperature",
                            name: qsTr("Target Temperature"),
                            value: (root.targetTemperature === null) ? 0 : (+root.targetTemperature.value).toLocaleString(),
                            unit: " °C",
                            component: stringValues,
                            visible: root.targetTemperature !== null
                        },
                        {
                            Id: "minTemperature",
                            name: qsTr("Minimal Temperature"),
                            value: (root.minTemperature === null) ? 0 : (+root.minTemperature.value).toLocaleString(),
                            unit: " °C",
                            component: stringValues,
                            visible: root.minTemperature !== null
                        },
                        {
                            Id: "currentConsumtion",
                            name: qsTr("Current Consumption"),
                            value: (+root.currentConsumption.value).toLocaleString(),
                            unit: " W",
                            component: stringValues,
                            visible: true
                        },
                        {
                            Id: "totalConsumption",
                            name: qsTr("Total Consumption"),
                            value: (+root.totalConsumption.value.toFixed(2)).toLocaleString(),
                            unit: " kWh",
                            component: stringValues,
                            visible: true
                        },
                        {
                            Id: "powerSetpointActive",
                            name: qsTr("Power Setpoint Active"),
                            value: root.powerSetpointActive.value,
                            component: boolValues,
                            visible: true
                        },
                        {
                            Id: "powerSetpoint",
                            name: qsTr("Power Setpoint"),
                            value: (+root.powerSetpoint.value).toLocaleString(),
                            unit: " W",
                            component: stringValues,
                            visible: root.powerSetpointActive.value
                        }
                    ]

                    delegate: ItemDelegate {
                        id: optimizerMainParams
                        Layout.fillWidth: true
                        visible: modelData.visible
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
                                        property: "delegateID"
                                        value: modelData.Id
                                    }

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
                                        when: typeof modelData.unit !== "undefined"
                                    }

                                    Layout.fillWidth: true
                                    sourceComponent:
                                    {
                                        return modelData.component
                                    }
                                }
                            }
                        }
                    }
                }

                Component {
                    id: stringValues

                    RowLayout {
                        property string delegateID: ""
                        property var delegateName
                        property var delegateValue
                        property var delegateUnit

                        Label{
                            id: singleInput
                            text: delegateName
                            Layout.fillWidth: true
                        }

                        Label{
                            id: singleValue
                            text: delegateValue + delegateUnit
                        }
                    }
                }

                Component {
                    id: boolValues

                    RowLayout {
                        property string delegateID: ""
                        property var delegateName
                        property var delegateValue

                        Label{
                            id: singleInput
                            text: delegateName
                            Layout.fillWidth: true
                        }

                        Led {
                            id: led
                            width: height
                            state: delegateValue === true ? "on" : "off"
                        }
                    }
                }
            }
        }
    ]


}
