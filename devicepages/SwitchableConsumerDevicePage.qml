import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import NymeaApp.Utils 1.0
import "../components"

GenericConfigPage {
    id: root

    property Thing thing: null
    property SwitchableConsumerConfiguration consumerConfig: hemsManager.switchableConsumerConfigurations.getSwitchableConsumerConfiguration(thing.id)
    readonly property State connectedState: root.thing.stateByName("connected")
    readonly property State powerState: root.thing.stateByName("power")
    readonly property State currentConsumptionState: root.thing.stateByName("currentPower")
    readonly property State totalConsumptionState: root.thing.stateByName("totalEnergyConsumed")

    title: root.thing.name
    headerOptionsVisible: false

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onSetSwitchableConsumerConfigurationReply: function(commandId, error) {
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
        ListElement{ name: qsTr("Always on"); value: 1 }   // SwitchableConsumerConfiguration.OptimizationModeManualOn
        ListElement{ name: qsTr("Off"); value: 2 }          // SwitchableConsumerConfiguration.OptimizationModeManualOff
        ListElement{ name: qsTr("PV surplus"); value: 0 }   // SwitchableConsumerConfiguration.OptimizationModePvSurplus
        ListElement{ name: qsTr("No control"); value: 3 }   // SwitchableConsumerConfiguration.OptimizationModeNoControl
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
                    power: root.currentConsumptionState ? root.currentConsumptionState.value : 0
                    icon: app.interfacesToIcon(root.thing.thingClass.interfaces)
                    label: Math.round(power) > 0 ? qsTr("Consuming") : qsTr("Idle")
                }

                RowLayout {
                    id: kpiCardsLayout
                    Layout.fillWidth: true
                    spacing: Style.margins

                    CoKPICard {
                        id: totalConsumptionCard
                        Layout.fillWidth: true
                        icon: Qt.resolvedUrl("qrc:/icons/functions.svg")
                        labelText: qsTr("Total consumption") // #TODO wording
                        // #TODO use decimal places when value is small?
                        valueText: (root.totalConsumptionState ? NymeaUtils.floatToLocaleString((+root.totalConsumptionState.value), 0) : "-") + qsTr(" kWh")
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
                            id: connectedStatusCard
                            Layout.fillWidth: true
                            interactive: false
                            labelText: qsTr("Status")
                            visible: root.connectedState
                            text: !root.connectedState ?
                                      "" :
                                      root.connectedState.value ?
                                          qsTr("Connected") :
                                          qsTr("Not connected")
                            status: (root.connectedState && root.connectedState.value) ?
                                        CoCard.StatusType.Success :
                                        CoCard.StatusType.Neutral
                        }

                        CoCard {
                            id: powerStatusCard
                            Layout.fillWidth: true
                            interactive: false
                            labelText: qsTr("Switch state consumer")
                            text: !root.powerState ?
                                      "" :
                                      root.powerState.value ?
                                          qsTr("On") :
                                          qsTr("Off")
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
                                if (!root.consumerConfig) {
                                    currentIndex = 0;
                                } else {
                                    currentIndex = comboBox.indexOfValue(root.consumerConfig.optimizationMode);
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
                    visible: optimizationModeCombobox.currentValue === 0 // SwitchableConsumerConfiguration.OptimizationModePvSurplus

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

                        // #TODO add controls for other parameters
                    }
                }

                Button {
                    id: savebutton
                    Layout.fillWidth: true
                    text: qsTr("Apply changes")
                    enabled: {
                        if (!root.consumerConfig) return false;
                        return optimizationModeCombobox.currentValue !== root.consumerConfig.optimizationMode;
                        // #TODO check other parameters
                    }

                    onClicked: {
                        d.pendingCallId = hemsManager.setSwitchableConsumerConfiguration(
                            root.consumerConfig.switchableConsumerThingId,
                            { optimizationMode: optimizationModeCombobox.currentValue } // #TODO add other parameters
                        );
                    }
                }
            }
        }
    ]
}
