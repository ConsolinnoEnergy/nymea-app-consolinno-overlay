import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Nymea 1.0

import "../components"
import "../delegates"

Page {
    id: root

    property ThingClass thingClass: thing ? thing.thingClass : null
    property Thing thing: null

    signal aborted();
    signal done();


    QtObject {
        id: d
        property var name: ""
        property var params: []
        property var states: []
        property var settings: []


        function pairThing() {
            engine.thingManager.addThing(root.thingClass.id, d.name, params);
        }
    }

    Component.onCompleted: {
        // Setting up a new thing
        internalPageStack.push(paramsPage)
    }

    Connections {
        target: engine.thingManager

        onAddThingReply: function(commandId, thingError, thingId, displayMessage) {
            busyOverlay.shown = false;
            internalPageStack.push(resultsPage, {thingError: thingError, thingId: thingId, message: displayMessage});
        }

        onThingAdded: function(thing) {
            for(var i = 0; i < d.states.length; i++) {
                thing.executeAction( d.states[i].name, [{ paramName: d.states[i].name , value: d.states[i].value }]);
            }

            for (var j = 0; j < d.settings.length; j++) {
                engine.thingManager.setThingSettings(thing.id,
                                                     [{ paramTypeId: d.settings[j].paramTypeId , value: d.settings[j].value }]);
            }
        }

    }

    StackView {
        id: internalPageStack
        anchors.fill: parent
    }

    property QtObject pageStack: QtObject {
        function pop(item) {
            if (internalPageStack.depth > 1) {
                internalPageStack.pop(item);
            } else {
                root.aborted();
            }
        }
    }

    Component {
        id: paramsPage

        SettingsPageBase {
            title: qsTr("Add new car")

            ColumnLayout {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                spacing: Style.margins

                CoFrostyCard {
                    id: vehiclesGroup
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Setup car") // #TODO wording

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoInputField {
                            id: nameInput
                            Layout.fillWidth: true
                            labelText: qsTr("Name")
                            text: thing ? thing.name : ""
                        }

                        // #TODO use CoInputStepper when ready
                        CoInputField {
                            id: capacityInput
                            Layout.fillWidth: true
                            labelText: qsTr("Capacity")
                            infoUrl: "Capacity.qml"
                            text: thing ? thing.stateByName("capacity").value : 0
                            unit: "kWh"
                        }

                        CoSlider {
                            id: minChargingCurrentInput
                            Layout.fillWidth: true
                            labelText: qsTr("Minimum charging current")
                            infoUrl: "MinimumChargingCurrent.qml"
                            from: 6
                            to: 16
                            stepSize: 1
                            value: thing ?  thing.stateByName("minChargingCurrent").value : 6
                            valueText: value + " A"
                        }

                        CoSlider {
                            id: maxChargingLimitInput
                            Layout.fillWidth: true
                            labelText: qsTr("Maximum charging limit")
                            infoUrl: "MaximumAllowedChargingLimit.qml"
                            from: 0
                            to: 100
                            stepSize: 1
                            value: thing ? thing.stateByName("batteryLevelLimit").value : 100
                            valueText: value + " %"
                        }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: qsTr("OK")
                    enabled: {
                        if (nameInput.text === "") {
                            return false;
                        }
                        let capacity = parseInt(capacityInput.text);
                        if (isNaN(capacity)) {
                            return false;
                        }
                        return true;
                    }
                    onClicked: {
                        var states = [];
                        var settings = [];
                        var capacitySetting = {};
                        capacitySetting.paramTypeId = "57f36386-dd71-4ab0-8d2f-8c74a391f90d";
                        capacitySetting.value = parseInt(capacityInput.text);
                        settings.push(capacitySetting);
                        var minChargingCurrentSetting = {};
                        minChargingCurrentSetting.paramTypeId = "0c55516d-4285-4d02-8926-1dae03649e18";
                        minChargingCurrentSetting.value = minChargingCurrentInput.value;
                        settings.push(minChargingCurrentSetting);
                        var maxChargingLimitState = {};
                        maxChargingLimitState.name = "batteryLevelLimit";
                        maxChargingLimitState.value = maxChargingLimitInput.value;
                        states.push(maxChargingLimitState);
                        d.name = nameInput.text;
                        d.settings = settings;
                        d.states = states;
                        d.pairThing();
                    }
                }
            }
        }
    }


    Component {
        id: resultsPage

        Page {
            id: resultsView
            header: NymeaHeader {
                text: root.thing ? qsTr("Reconfigure %1").arg(root.thing.name) : qsTr("Add generic car")
                onBackPressed: pageStack.pop()
            }

            property string thingId
            property int thingError
            property string message

            readonly property bool success: thingError === Thing.ThingErrorNoError

            readonly property Thing thing: root.thing ? root.thing : engine.thingManager.things.getThing(thingId)

            ColumnLayout {
                width: Math.min(500, parent.width - app.margins * 2)
                anchors.centerIn: parent
                spacing: app.margins * 2
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: resultsView.success ? root.thing ? qsTr("Thing reconfigured!") : qsTr("Thing added!") : qsTr("Uh oh")
                    font.pixelSize: app.largeFont
                    color: Style.accentColor
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: resultsView.success ? qsTr("All done. You can now start using %1.").arg(resultsView.thing.name) : qsTr("Something went wrong setting up this thing...");
                }

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: resultsView.message
                }


                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    visible: !resultsView.success
                    text: qsTr("Retry")
                    onClicked: {
                        internalPageStack.pop({immediate: true});
                        internalPageStack.pop({immediate: true});
                        d.pairThing();
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    text: qsTr("Ok")
                    onClicked: {
                        root.done();
                    }
                }
            }
        }
    }

    BusyOverlay {
        id: busyOverlay
    }
}
