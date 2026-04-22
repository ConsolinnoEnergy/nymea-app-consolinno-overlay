import QtQuick
import QtQuick.Controls
import QtQml
import QtQuick.Layouts
import Nymea 1.0
import Qt5Compat.GraphicalEffects

import "../components"
import "../delegates"

Page{
    id: root

    property UserConfiguration userconfig: hemsManager.userConfigurations.getUserConfiguration("528b3820-1b6d-4f37-aea7-a99d21d42e72")

    signal done(var selectedCar)
    signal back()

    header: NymeaHeader {
        id: header
        text: qsTr("List of Cars")
        backButtonVisible: true
        onBackPressed: root.back()
    }

    ThingsProxy {
        id: evProxy
        engine: _engine
        shownInterfaces: ["electricvehicle"]
    }


    ThingClassesProxy{
        id: thingClassesProxy
        engine: _engine
        filterInterface: "electricvehicle"
        includeProvidedInterfaces: true
        groupByInterface: true
    }



    QtObject {
        id: d
        property var name: ""
        property var states: []
        property var settings: []
        property var attr: []

        function updateThing(thing) {
            for(var i = 0; i < d.states.length; i++) {
                thing.executeAction( d.states[i].name, [{ paramName: d.states[i].name , value: d.states[i].value }]);
            }

            for (var j = 0; j < d.settings.length; j++) {
                engine.thingManager.setThingSettings(thing.id,
                                                     [{ paramTypeId: d.settings[j].paramTypeId , value: d.settings[j].value }]);
            }
            engine.thingManager.editThing(thing.id, d.name);
            pageStack.push(resultsPage, {thing: thing});
        }
    }

    Flickable {
        clip: true
        anchors.fill: parent
        contentHeight: layout.implicitHeight +
                       layout.anchors.topMargin +
                       layout.anchors.bottomMargin

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: Style.margins
            spacing: Style.margins

            CoFrostyCard {
                id: vehiclesGroup
                Layout.fillWidth: true
                contentTopMargin: Style.smallMargins
                headerText: qsTr("Electric vehicles") // #TODO wording

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    Repeater {
                        id: optimizerRepeater
                        Layout.fillWidth: true
                        model: evProxy

                        function updateRadioButtonCheckStates(clickedIndex) {
                            for (let i = 0; i < count; ++i) {
                                if (i === clickedIndex) { continue; }
                                let item = itemAt(i);
                                item.checked = false;
                            }
                        }

                        function checkedIndex() {
                            for (let i = 0; i < count; ++i) {
                                let item = itemAt(i);
                                if (item.checked) { return i; }
                            }
                            return -1;
                        }

                        delegate: CoCardWithRadioButton {
                            Layout.fillWidth: true
                            text: evProxy.get(index) ? evProxy.get(index).name : ""
                            iconRight: Qt.resolvedUrl("/icons/edit.svg")
                            checked: evProxy.get(index).id === userconfig.lastSelectedCar

                            onClicked: {
                                pageStack.push(carData, { thing: evProxy.get(index) });
                            }

                            onRadioButtonClicked: {
                                // Don't allow to uncheck a radio button by clicking.
                                if (!checked) {
                                    checked = true;
                                    return;
                                }
                                optimizerRepeater.updateRadioButtonCheckStates(index);
                            }
                        }
                    }
                }
            }

            Button {
                id: addCarButton
                Layout.alignment: Qt.AlignCenter
                text: "+"
                font.pixelSize: 32
                topPadding: 6
                leftPadding: 6
                rightPadding: 6
                bottomPadding: 6
                width: height
                implicitWidth: implicitHeight

                onClicked: {
                    for (var i = 0; i < thingClassesProxy.count; i++) {
                        if (thingClassesProxy.get(i).id.toString() === "{dbe0a9ff-94ba-4a94-ae52-51da3f05c717}" ||
                                thingClassesProxy.get(i).id.toString() === "{0d6151d6-e013-47ab-a8c1-9c516a2c8664}"  ) {
                            var page = pageStack.push("../thingconfiguration/AddGenericCar.qml",
                                                      { thingClass: thingClassesProxy.get(i) });
                            page.done.connect(function() {
                                pageStack.pop();
                            });
                            page.aborted.connect(function() {
                                pageStack.pop();
                            });
                        }
                    }
                }
            }

        }
    }

    footer: ColumnLayout {
        Button {
            Layout.fillWidth: true
            Layout.margins: Style.margins
            id: saveButton
            text: qsTr("Apply changes")
            enabled: optimizerRepeater.checkedIndex() !== -1

            onClicked: {
                const checkedIndex = optimizerRepeater.checkedIndex();
                let carThing = evProxy.getThing(userconfig.lastSelectedCar);
                if (checkedIndex === -1) {
                    console.error("No car selected!");
                } else {
                    carThing = evProxy.get(checkedIndex);
                }
                root.done(carThing);
                pageStack.pop();
            }
        }
    }

    Component {
        id: resultsPage

        Page {
            id: resultsView
            property var thing
            header: NymeaHeader {
                text: qsTr("Reconfigure " + thing.name)
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                width: Math.min(500, parent.width - app.margins * 2)
                anchors.centerIn: parent
                spacing: app.margins * 2
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Thing reconfigured!")
                    font.pixelSize: app.largeFont
                    color: Style.accentColor
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: qsTr("All done. You can now start using %1.").arg(thing.name)
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    text: qsTr("Ok")
                    onClicked: {
                        root.done(thing)
                        pageStack.pop()
                        pageStack.pop()
                        pageStack.pop()
                    }
                }
            }
        }
    }




    Component {
        id: carData

        SettingsPageBase {
            property var thing
            title: thing ? thing.name : ""

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
                    text: qsTr("Delete")
                    secondary: true

                    onClicked: {
                        engine.thingManager.removeThing(thing.id);
                        pageStack.pop();
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Apply changes")
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
                        d.updateThing(thing);
                    }
                }
            }
        }
    }
}


