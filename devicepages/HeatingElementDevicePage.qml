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

    readonly property bool applyEnabled: {
        if (!root.heatingRodConfig) return false;
        let optimizationEnabledInConfig = heatingRodConfig.optimizationEnabled;
        let optimizationEnabledInComboBox = optimizationModeCombobox.currentValue === 1; // PV surplus
        return optimizationEnabledInConfig != optimizationEnabledInComboBox;
    }

    function applyChanges() {
        d.pendingCallId = hemsManager.setHeatingElementConfiguration(root.heatingRodConfig.heatingRodThingId,
                                                                     {
                                                                         optimizationEnabled: optimizationModeCombobox.currentValue === 1 // PV surplus
                                                                     });
    }

    property Component navbarControls: heatingElementNavbarControls

    Component {
        id: heatingElementNavbarControls
        CoNavbarButton {
            text: qsTr("Apply changes")
            enabled: root.applyEnabled
            onClicked: root.applyChanges()
        }
    }

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
        ListElement{ name: qsTr("PV surplus"); value: 1 }
        ListElement{ name: qsTr("No control"); value: 0 }
    }

    content: [
        Flickable {
            anchors.fill: parent
            contentHeight: columnLayout.implicitHeight +
                           columnLayout.anchors.topMargin +
                           columnLayout.anchors.bottomMargin + root.navigationFooterHeight
            clip: true

            ColumnLayout {
                id: columnLayout
                anchors { left: parent.left; right: parent.right; top: parent.top }
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
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: Math.max(implicitHeight, totalConsumptionCard.implicitHeight)
                        icon: Qt.resolvedUrl("qrc:/icons/device_thermostat.svg")
                        labelText: qsTr("Current temperature")
                        valueText: (root.currentTemperature ? NymeaUtils.floatToLocaleString((+root.currentTemperature.value), 1) : "-") + qsTr(" °C")
                    }

                    CoKPICard {
                        id: totalConsumptionCard
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: Math.max(implicitHeight, temperatureCard.implicitHeight)
                        icon: Qt.resolvedUrl("qrc:/icons/functions.svg")
                        labelText: qsTr("Total consumption")
                        valueText: UiUtils.energyDisplayValue(root.totalConsumption) + " kWh"
                    }
                }

                CoFrostyCard {
                    id: statusGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Status")

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
                            text: {
                                if (root.powerSetpointActive.value && root.powerSetpoint) {
                                    return UiUtils.powerDisplayValue(+root.powerSetpoint.value) +
                                            " " +
                                            UiUtils.powerDisplayUnit(+root.powerSetpoint.value);
                                } else {
                                    return "- " + qsTr("W");
                                }
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: controlGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Control")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Style.smallMargins

                        CoComboBox {
                            id: optimizationModeCombobox
                            Layout.fillWidth: true
                            labelText: qsTr("Operating mode")
                            infoUrl: "HeatingRodOperatingModeInfo.qml"
                            model: optimizationModesModel
                            textRole: "name"
                            valueRole: "value"
                            Component.onCompleted: {
                                if (!heatingRodConfig) {
                                    comboBox.currentIndex = 1;
                                } else {
                                    comboBox.currentIndex = heatingRodConfig.optimizationEnabled ? 0 : 1;
                                }
                            }
                        }
                    }
                }

                CoFrostyCard {
                    id: pvSurplusGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("\"PV Surplus\"")
                    visible: optimizationModeCombobox.currentValue === 1 // PV surplus

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Style.smallMargins

                        CoCard {
                            id: pvPrioCard
                            Layout.fillWidth: true
                            labelText: qsTr("Priority")
                            text: (hemsManager.emsConfiguration.pvSurplusPriolistIndexOf(root.thing.id) + 1).toString()
                            showChildrenIndicator: true

                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("../optimization/PVPriorities.qml"), { alwaysEnabledThingId: root.thing.id.toString() });
                            }
                        }
                    }
                }
            }
        }
    ]
}
