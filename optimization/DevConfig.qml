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

    title: qsTr("Dev Config")
    headerOptionsVisible: false

    function formatValue(value, decimals) {
        if (typeof value === "string" && isNaN(Number(value)))
            return value
        return Number(value).toLocaleString(Qt.locale(), 'f', decimals)
    }

    // Read-only numeric states to display.
    // Each entry: { name: "stateName", decimals: N, unit: "optionalOverride" }
    readonly property var readOnlyStates: [
        // TODO: Add read-only state names here
        // { name: "exampleReadState", decimals: 1, unit: "W" }
    ]

    // Writable numeric states. The thing must expose a matching action with the same name.
    // Each entry: { name: "stateName", decimals: N, min: 0, max: 100, step: 1, unit: "optionalOverride" }
    readonly property var writableStates: [
        // TODO: Add writable state names here
        // { name: "exampleWritableState", decimals: 0, min: 0, max: 100, step: 1, unit: "%" }
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

                // ── Read-only group ──────────────────────────────────────────
                CoFrostyCard {
                    Layout.fillWidth: true
                    visible: root.readOnlyStates.length > 0
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Values")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        Repeater {
                            model: root.readOnlyStates

                            CoCard {
                                readonly property State thingState: root.thing ? root.thing.stateByName(modelData.name) : null
                                readonly property var stateType: thingState ? root.thing.thingClass.stateTypes.getStateType(thingState.stateTypeId) : null

                                Layout.fillWidth: true
                                visible: thingState !== null
                                labelText: stateType ? stateType.displayName : modelData.name
                                text: thingState
                                      ? root.formatValue(thingState.value, modelData.decimals)
                                        + (modelData.unit ? " " + modelData.unit
                                                          : (stateType ? " " + Types.toUiUnit(stateType.unit) : ""))
                                      : "—"
                            }
                        }
                    }
                }

                // ── Writable group ───────────────────────────────────────────
                CoFrostyCard {
                    Layout.fillWidth: true
                    visible: root.writableStates.length > 0
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Writable values")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: Style.smallMargins

                        Repeater {
                            model: root.writableStates

                            CoInputStepper {
                                readonly property State thingState: root.thing ? root.thing.stateByName(modelData.name) : null
                                readonly property var stateType: thingState ? root.thing.thingClass.stateTypes.getStateType(thingState.stateTypeId) : null

                                Layout.fillWidth: true
                                visible: root.thing !== null
                                labelText: stateType ? stateType.displayName : modelData.name
                                unit: modelData.unit || (stateType ? Types.toUiUnit(stateType.unit) : "")
                                floatingPoint: modelData.decimals > 0
                                decimals: modelData.decimals
                                from: modelData.min
                                to: modelData.max
                                stepSize: modelData.step
                                value: thingState ? thingState.value : 0

                                onValueModified: function(newValue) {
                                    if (root.thing) {
                                        root.thing.executeAction(modelData.name, [{ paramName: modelData.name, value: newValue }])
                                    }
                                }
                            }
                        }
                    }
                }

                // ── Placeholder shown when both arrays are empty ─────────────
                CoFrostyCard {
                    Layout.fillWidth: true
                    visible: root.readOnlyStates.length === 0 && root.writableStates.length === 0
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Configuration")

                    CoCard {
                        Layout.fillWidth: true
                        labelText: qsTr("No values configured yet")
                        text: qsTr("Add entries to readOnlyStates or writableStates.")
                    }
                }
            }
        }
    ]
}
