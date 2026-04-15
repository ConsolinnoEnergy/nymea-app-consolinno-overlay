import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import NymeaApp.Utils 1.0
import "../components"

GenericConfigPage {
    id: root

    property Thing thing: null
    property HeatingElementConfiguration heatingRodConfig: hemsManager.heatingElementConfigurations.getHeatingElementConfiguration(thing.id)
    readonly property State currentTemperature: root.thing.stateByName("waterTemperature")
    readonly property State currentConsumption: root.thing.stateByName("currentPower")
    readonly property State totalConsumption: root.thing.stateByName("totalEnergyConsumed")
    readonly property State powerSetpointActive: root.thing.stateByName("activateControlConsumer")
    readonly property State powerSetpoint: root.thing.stateByName("powerSetpointConsumer")

    title: root.thing.name
    headerOptionsVisible: false

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onSetHeatingElementConfigurationReply: function(commandId, error) {
            if (commandId === d.pendingCallId) {
                d.pendingCallId = -1;
                let props = "";
                switch (error) {
                case "HemsErrorNoError":
                    return;
                case "HemsErrorInvalidParameter":
                    props.text = qsTr("Could not save configuration. One of the parameters is invalid.");
                    break;
                case "HemsErrorInvalidThing":
                    props.text = qsTr("Could not save configuration. The thing is not valid.");
                    break;
                default:
                    props.errorCode = error;
                }
                var comp = Qt.createComponent("../components/ErrorDialog.qml");
                var popup = comp.createObject(app, { props });
                popup.open();
            }
        }
    }

    ListModel {
        id: optimizationModesModel
        // #TODO wordings
        ListElement{ name: qsTr("No control"); value: 0 }
        ListElement{ name: qsTr("PV surplus"); value: 1 }
    }

    content: [
        Flickable {
            anchors.fill: parent
            contentHeight: columnLayout.implicitHeight +
                           columnLayout.anchors.topMargin +
                           columnLayout.anchors.bottomMargin
            clip: true

            ColumnLayout {
                id: columnLayout
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                CoEnergyCircle {
                    id: energyCircle
                    Layout.fillWidth: true
                    power: root.currentConsumption.value
                    icon: app.interfacesToIcon(root.thing.thingClass.interfaces)
                    label: Math.round(power) > 0 ? qsTr("Consuming") : qsTr("Idle")
                }

                RowLayout {
                    id: kpiCardsLayout
                    Layout.fillWidth: true
                    spacing: Style.margins

                    CoKPICard {
                        id: temperatureCard
                        Layout.fillWidth: true
                        icon: Qt.resolvedUrl("qrc:/icons/device_thermostat.svg")
                        labelText: qsTr("Current temperature") // #TODO wording
                        valueText: (root.currentTemperature ? NymeaUtils.floatToLocaleString((+root.currentTemperature.value), 1) : "-") + qsTr(" °C")
                    }

                    CoKPICard {
                        id: totalConsumptionCard
                        Layout.fillWidth: true
                        icon: Qt.resolvedUrl("qrc:/icons/functions.svg")
                        labelText: qsTr("Total consumption") // #TODO wording
                        // #TODO use decimal places when value is small?
                        valueText: (root.totalConsumption ? NymeaUtils.floatToLocaleString((+root.totalConsumption.value), 0) : "-") + qsTr(" kWh")
                    }
                }

                CoFrostyCard {
                    id: statusGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Status") // #TODO wording

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoCard {
                            id: powerSetpointStatusCard
                            Layout.fillWidth: true
                            interactive: false
                            labelText: qsTr("Power Setpoint")
                            text: root.powerSetpointActive.value ?
                                      qsTr("Active") :
                                      qsTr("Inactive")
                            status: root.powerSetpointActive.value ?
                                        CoCard.StatusType.Success :
                                        CoCard.StatusType.Neutral
                        }

                        CoCard {
                            id: powerSetpointCard
                            Layout.fillWidth: true
                            interactive: false
                            labelText: qsTr("Power Setpoint Value")
                            // #TODO use kW for power setpoint value?
                            text: (root.powerSetpointActive.value ?
                                       (root.powerSetpoint ? NymeaUtils.floatToLocaleString((+root.powerSetpoint.value), 0) : "-") :
                                       "-") +
                                  qsTr(" W")
                        }
                    }
                }

                CoFrostyCard {
                    id: controlGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Control") // #TODO wording

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Style.smallMargins

                        CoComboBox {
                            id: optimizationModeCombobox
                            Layout.fillWidth: true
                            labelText: qsTr("Operating mode") // #TODO wording
                            // #TODO infoUrl:
                            model: optimizationModesModel
                            textRole: "name"
                            valueRole: "value"
                            Component.onCompleted: {
                                if (!heatingRodConfig) {
                                    comboBox.currentIndex = 0;
                                } else {
                                    comboBox.currentIndex = heatingRodConfig.optimizationEnabled ? 1 : 0;
                                }
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: pvSurplusGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("PV Surplus") // #TODO wording, quotation marks from design?
                    visible: optimizationModeCombobox.currentValue === 1 // PV surplus

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Style.smallMargins

                        CoCard {
                            id: pvPrioCard
                            Layout.fillWidth: true
                            labelText: qsTr("Priority")
                            text: (hemsManager.emsConfiguration.pvSurplusPriolist.indexOf(root.thing.id) + 1).toString()
                            showChildrenIndicator: true

                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("../optimization/PVPriorities.qml"));
                            }
                        }
                    }
                }

                Button {
                    id: savebutton
                    Layout.fillWidth: true
                    text: qsTr("Apply changes")
                    enabled: {
                        let optimizationEnabledInConfig = heatingRodConfig.optimizationEnabled;
                        let optimizationEnabledInComboBox = optimizationModeCombobox.currentValue === 1; // PV surplus
                        return optimizationEnabledInConfig != optimizationEnabledInComboBox;
                    }

                    onClicked: {
                        d.pendingCallId = hemsManager.setHeatingElementConfiguration(root.heatingRodConfig.heatingRodThingId,
                                                                                     {
                                                                                         optimizationEnabled: optimizationModeCombobox.currentValue === 1 // PV surplus
                                                                                     });
                    }
                }
            }
        }
    ]
}
