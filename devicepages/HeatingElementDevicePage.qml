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
    /*
    content: [
        ColumnLayout {
            width: parent.width - Style.margins

            anchors {
                top: parent.top
                topMargin: Style.margins
                horizontalCenter: parent.horizontalCenter
            }

            spacing: Style.margins
            //Disabled for now
            /*
            ColumnLayout {
                visible: true
                Layout.fillWidth: true
                Layout.fillHeight: false
                Layout.preferredHeight: operatingModeValueText.height + toolTipText.height
                spacing: Style.smallMargins

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    spacing: Style.smallMargins
                    visible: false

                    Label {
                        Layout.fillWidth: false
                        Layout.preferredWidth: parent.width * 0.65
                        text: qsTr("Operating Mode (Solar Only)")
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle {
                            width: 100
                            height: operatingModeValueText.height + 10
                            anchors.right: parent.right
                            radius: 13
                            color: {
                                if(root.operatingModeStatus === 1) {
                                    return "#008000"
                                } else if(root.operatingModeStatus === 2) {
                                    return "#F37B8E"
                                } else {
                                    return "#9B9B9B"
                                }
                            }

                            Label {
                                id: operatingModeValueText
                                Layout.leftMargin: 10
                                anchors.centerIn: parent
                                color: Style.white
                                text: {
                                    if(root.operatingModeStatus === 1) {
                                        return qsTr("Active")
                                    } else if(root.operatingModeStatus === 2) {
                                        return qsTr("Off")
                                    } else {
                                        return qsTr("Not available")
                                    }
                                }
                            }
                        }
                    }
                }

                Label {
                    id: toolTipText
                    Layout.topMargin: 13
                    Layout.fillWidth: true
                    visible: false
                    text: {
                        if(root.operatingModeStatus === 1) {
                            return qsTr("The heating is operated only with solar power.")
                        } else if(root.operatingModeStatus === 2) {
                            return qsTr("The operating mode (Solar Only) is turned off. The settings can be changed in the optimization settings.")
                        } else {
                            return qsTr("The operating mode (Solar Only) is not available because a charging process is currently being prioritized.")
                        }
                    }
                    font: Style.smallFont
                    wrapMode: Text.WordWrap
                    color: Configuration.iconColor
                }
            }*/
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
                            //anchors { top: parent.top; right: parent.right; bottom: parent.bottom }
                            width: height
                            state: delegateValue === true ? "on" : "off"
                        }
                    }
                }
            }
        }
    ]


}
