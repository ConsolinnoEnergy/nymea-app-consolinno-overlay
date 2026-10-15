import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea
import NymeaApp.Utils
import "../components"

GenericConfigPage {
    id: root

    property Thing thing: null
    readonly property State operationStateState: root.thing.stateByName("operationState")
    readonly property State selectedProgramState: root.thing.stateByName("selectedProgram")
    readonly property State durationState: root.thing.stateByName("forecastDuration")
    readonly property State startTimeState: root.thing.stateByName("suggestedStartTime")
    readonly property State endTimeState: root.thing.stateByName("endTime")
    readonly property State earliestStartTimeState: root.thing.stateByName("earliestStartTime")
    readonly property State latestEndTimeState: root.thing.stateByName("lastEndTime")

    title: root.thing.name
    headerOptionsVisible: false

    Connections {
        target: hemsManager.emsConfiguration
        function onPvSurplusPriolistChanged() {
            pvPrioCard.updatePrioFromConfig();
        }
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

                CoNotConnectedNotification {
                    Layout.fillWidth: true
                    thing: root.thing
                }

                CoFrostyCard {
                    id: pvSurplusGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("PV device prioritization")

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

                            function updatePrioFromConfig() {
                                text = (hemsManager.emsConfiguration.pvSurplusPriolistIndexOf(root.thing.id) + 1).toString();
                            }

                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("../optimization/PVPriorities.qml"), { alwaysEnabledThingId: root.thing.id.toString() });
                            }
                        }
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
                        spacing: Style.smallMargins

                        CoCard {
                            id: operationStateCard
                            Layout.fillWidth: true
                            text: UiUtils.whiteGoodOperationStateToString(root.operationStateState ? root.operationStateState.value : "")
                            labelText: qsTr("Current status")
                            status: {
                                switch (root.operationStateState ? root.operationStateState.value : "") {
                                case "Scheduled":
                                case "Paused":
                                    return CoCard.StatusType.Warning;
                                case "Running":
                                    return CoCard.StatusType.Success;
                                case "Completed":
                                case "Inactive":
                                    return CoCard.StatusType.Neutral;
                                case "Invalid":
                                    return CoCard.StatusType.Danger;
                                default:
                                    return CoCard.StatusType.NoStatus;
                                }
                            }
                            showChildrenIndicator: false
                            interactive: false
                        }

                        CoCard {
                            id: programCard
                            Layout.fillWidth: true
                            text: root.selectedProgramState ? root.selectedProgramState.value : ""
                            labelText: qsTr("Selected program")
                            showChildrenIndicator: false
                            interactive: false
                        }

                        CoCard {
                            id: durationCard
                            Layout.fillWidth: true
                            text: UiUtils.durationMinutesToString(root.durationState ? root.durationState.value : 0)
                            labelText: qsTr("Estimated duration")
                            showChildrenIndicator: false
                            interactive: false
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            CoCard {
                                id: scheduledStartTimeCard
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                text: UiUtils.unixTimeToTimeString(root.startTimeState ? root.startTimeState.value : 0)
                                labelText: qsTr("Scheduled start time")
                                showChildrenIndicator: false
                                interactive: false
                            }

                            CoCard {
                                id: scheduledEndTimeCard
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                text: UiUtils.unixTimeToTimeString(root.endTimeState ? root.endTimeState.value : 0)
                                labelText: qsTr("Scheduled end time")
                                showChildrenIndicator: false
                                interactive: false
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            CoCard {
                                id: earliestStartTimeCard
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                text: UiUtils.unixTimeToTimeString(root.earliestStartTimeState ? root.earliestStartTimeState.value : 0)
                                labelText: qsTr("Earliest start time")
                                showChildrenIndicator: false
                                interactive: false
                            }

                            CoCard {
                                id: latestEndTimeCard
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                text: UiUtils.unixTimeToTimeString(root.latestEndTimeState ? root.latestEndTimeState.value : 0)
                                labelText: qsTr("Latest end time")
                                showChildrenIndicator: false
                                interactive: false
                            }
                        }
                    }
                }
            }
        }
    ]
}
