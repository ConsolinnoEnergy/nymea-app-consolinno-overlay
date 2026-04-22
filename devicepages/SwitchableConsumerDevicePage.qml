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
                let props = {};
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
                var popup = comp.createObject(app, props);
                popup.open();
            }
        }
    }

    ListModel {
        id: optimizationModesModel
        // #TODO wordings
        ListElement{ name: qsTr("Always on"); value: 1 }   // SwitchableConsumerConfiguration.OptimizationModeManualOn
        ListElement{ name: qsTr("Off"); value: 2 }          // SwitchableConsumerConfiguration.OptimizationModeManualOff
        ListElement{ name: qsTr("No control"); value: 3 }   // SwitchableConsumerConfiguration.OptimizationModeNoControl

        Component.onCompleted: {
            if (hemsManager.availableUseCases & HemsManager.HemsUseCasePv) {
                insert(2, { name: qsTr("PV surplus"), value: 0 }); // SwitchableConsumerConfiguration.OptimizationModePvSurplus
            }
            if (!root.consumerConfig) {
                optimizationModeCombobox.currentIndex = 0;
            } else {
                const ind = optimizationModeCombobox.comboBox.indexOfValue(root.consumerConfig.optimizationMode);
                if (ind !== -1) {
                    optimizationModeCombobox.currentIndex = ind;
                } else {
                    optimizationModeCombobox.currentIndex = 0;
                }
            }
        }
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

                        // Initialization is done here rather than in each stepper's Component.onCompleted
                        // because the parent's onCompleted fires after all children are fully constructed.
                        // This guarantees maxTotalRuntimeStepper exists and its value is set first, so
                        // minRuntimeStepper.to (which binds to maxTotalRuntimeStepper.value) is already
                        // at the correct upper bound when minRuntimeStepper.value is assigned — preventing
                        // it from being spuriously clamped to 0.
                        Component.onCompleted: {
                            if (!root.consumerConfig) { return; }
                            maxTotalRuntimeStepper.value = Math.round(root.consumerConfig.durationMaxTotal / 15);
                            minRuntimeStepper.value = Math.round(root.consumerConfig.durationMinAfterTurnOn / 15);
                        }

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

                        CoInputField {
                            id: minPVSurplusPower
                            Layout.fillWidth: true
                            compactTextField: true
                            labelText: qsTr("Minimum power")
                            helpText: qsTr("Minimum PV surplus power required for activation.")
                            unit: "W"
                            text: root.consumerConfig ? root.consumerConfig.pvSurplusThreshold : ""
                            feedbackText: qsTr("Value must not be below %1 W.").arg(minPVSurplusPowerValidator.bottom)
                            textField.validator: IntValidator  {
                                id: minPVSurplusPowerValidator
                                bottom: 100
                            }
                        }

                        CoInputStepper {
                            id: minRuntimeStepper
                            Layout.fillWidth: true
                            labelText: qsTr("Minimum runtime")
                            helpText: qsTr("Runs at least this long after activation.")
                            unit: qsTr("h")
                            compact: true
                            from: 0
                            to: maxTotalRuntimeStepper.value
                            stepSize: 1
                            feedbackText: qsTr("Value must be between 0 and %1 h.").arg(NymeaUtils.floatToLocaleString(maxTotalRuntimeStepper.value / 4, 2))
                            spinbox.textFromValue: function(value, locale) {
                                return NymeaUtils.floatToLocaleString(value / 4, 2);
                            }
                            spinbox.valueFromText: function(text, locale) {
                                return Math.round(Number.fromLocaleString(Qt.locale(), text) * 4);
                            }
                            spinbox.validator: DoubleValidator {
                                bottom: 0
                                top: maxTotalRuntimeStepper.value / 4
                                decimals: 2
                                notation: DoubleValidator.StandardNotation
                            }
                        }

                        CoInputStepper {
                            id: maxTotalRuntimeStepper
                            Layout.fillWidth: true
                            labelText: qsTr("Maximum runtime")
                            helpText: qsTr("Limits the daily runtime and automatically switches the device off.")
                            unit: qsTr("h")
                            compact: true
                            from: minRuntimeStepper.value
                            to: 96 // 24 h * 4 quarter-hours
                            stepSize: 1
                            feedbackText: qsTr("Value must be between %1 and 24 h.").arg(NymeaUtils.floatToLocaleString(minRuntimeStepper.value / 4, 2))
                            spinbox.textFromValue: function(value, locale) {
                                return NymeaUtils.floatToLocaleString(value / 4, 2);
                            }
                            spinbox.valueFromText: function(text, locale) {
                                return Math.round(Number.fromLocaleString(Qt.locale(), text) * 4);
                            }
                            spinbox.validator: DoubleValidator {
                                bottom: minRuntimeStepper.value / 4
                                top: 24
                                decimals: 2
                                notation: DoubleValidator.StandardNotation
                            }
                        }
                    }
                }

                Button {
                    id: savebutton
                    Layout.fillWidth: true
                    text: qsTr("Apply changes")
                    enabled: {
                        if (!root.consumerConfig) { return false; }
                        if (pvSurplusGroup.visible && (!minRuntimeStepper.acceptableInput || !maxTotalRuntimeStepper.acceptableInput)) { return false; }
                        if (pvSurplusGroup.visible && !minPVSurplusPower.acceptableInput) { return false; }
                        if (optimizationModeCombobox.currentValue !== root.consumerConfig.optimizationMode) { return true; }
                        if (pvSurplusGroup.visible && minRuntimeStepper.value * 15 !== root.consumerConfig.durationMinAfterTurnOn) { return true; }
                        if (pvSurplusGroup.visible && maxTotalRuntimeStepper.value * 15 !== root.consumerConfig.durationMaxTotal) { return true; }
                        if (pvSurplusGroup.visible && parseInt(minPVSurplusPower.text) !== root.consumerConfig.pvSurplusThreshold) { return true; }
                        return false;
                    }

                    onClicked: {
                        d.pendingCallId = hemsManager.setSwitchableConsumerConfiguration(
                            root.consumerConfig.switchableConsumerThingId,
                            {
                                optimizationMode: optimizationModeCombobox.currentValue,
                                durationMinAfterTurnOn: minRuntimeStepper.value * 15,
                                durationMaxTotal: maxTotalRuntimeStepper.value * 15,
                                pvSurplusThreshold: parseInt(minPVSurplusPower.text)
                            }
                        );
                    }
                }
            }
        }
    ]
}
