import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"
import "../thingconfiguration"

StackView {
    id: root

    property string startView

    initialItem: setUpComponent

    property string name
    property bool newTariff: false
    property Thing dynElectricThing : dynElectricThings.count > 0 ? dynElectricThings.get(0) : null
    property int directionID: 0

    signal done(bool skip, bool abort, bool back);

    ThingsProxy {
        id: dynElectricThings
        engine: _engine
        shownInterfaces: ["dynamicelectricitypricing"]
    }

    ThingClassesProxy {
        id: thingClassesProxy
        engine: _engine
        includeProvidedInterfaces: true
        groupByInterface: true
        filterInterface: "dynamicelectricitypricing"
    }

    Connections {
        target: engine.thingManager
        onThingAdded: function(thing) {
            if (thing.thingClass.interfaces.includes("dynamicelectricitypricing")) {
                root.dynElectricThing = thing;
            }
        }
    }

    Component {
        id: setUpComponent
        Page {

            header: NymeaHeader {
                text: qsTr("Dynamic electricity tariff")
                backButtonVisible: true
                onBackPressed: {
                    if(directionID == 0) {
                        pageStack.pop()
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                CoFrostyCard {
                    Layout.fillWidth: true
                    contentTopMargin: Style.margins
                    headerText: qsTr("Submitted rate")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        Repeater {
                            model: dynElectricThings

                            delegate: CoCard {
                                Layout.fillWidth: true
                                iconLeft: Qt.resolvedUrl("/icons/euro.svg")
                                text: model.name
                                showChildrenIndicator: thing !== null
                                deletable: thing !== null
                                interactive: thing !== null
                                property int pageStackPopsAfterConfigure: 1
                                property Thing thing: dynElectricThings.get(index)

                                Component.onCompleted: {
                                    if (root.startView === "configure" && index === 0) {
                                        pageStackPopsAfterConfigure = 2;
                                        Qt.callLater(onClicked);
                                    }
                                }

                                onClicked: {
                                    if(thing.thingClass.setupMethod !== 4){
                                        var isEpexDayAheadThing =
                                                thing.thingClassId.toString() === "{678dd2a6-b162-4bfb-98cc-47f225f9008c}";
                                        var pageUrl = isEpexDayAheadThing ?
                                                    "qrc:///ui/thingconfiguration/EpexDayAheadSetup.qml" :
                                                    "qrc:///ui/thingconfiguration/SetupWizard.qml";
                                        var page = pageStack.push(Qt.resolvedUrl(pageUrl),
                                                                  { thing: thing });
                                        page.done.connect(function() {
                                            for (var i = 0; i < pageStackPopsAfterConfigure; i++) {
                                                pageStack.pop();
                                            }
                                        });
                                        page.aborted.connect(function() {
                                            for (var i = 0; i < pageStackPopsAfterConfigure; i++) {
                                                pageStack.pop();
                                            }
                                        });
                                    }
                                }
                                onDeleteClicked: {
                                    var popup = removeDialogComponent.createObject(root, { thing: thing });
                                    popup.open();
                                }
                            }
                        }

                        CoCard {
                            Layout.fillWidth: true
                            visible: dynElectricThings.count === 0
                            text: qsTr("There is no rate set up yet.")
                        }

                        CoComboBox {
                            id: energyRateComboBox
                            Layout.fillWidth: true
                            labelText: qsTr("Add Rate")
                            visible: dynElectricThings.count === 0
                            textRole: "displayName"
                            valueRole: "id"
                            model: ThingClassesProxy {
                                id: currentThing
                                engine: _engine
                                filterInterface: "dynamicelectricitypricing"
                                includeProvidedInterfaces: true
                            }
                        }

                        Button {
                            id: addButton
                            Layout.fillWidth: true
                            visible: dynElectricThings.count === 0
                            text: qsTr("Add")
                            property ThingClass thingClass: thingClassesProxy.get(energyRateComboBox.currentIndex)

                            onClicked: {
                                var isEpexDayAheadThing =
                                        thingClass.id.toString() === "{678dd2a6-b162-4bfb-98cc-47f225f9008c}";
                                var pageUrl = isEpexDayAheadThing ?
                                            "qrc:///ui/thingconfiguration/EpexDayAheadSetup.qml" :
                                            "qrc:///ui/thingconfiguration/SetupWizard.qml";
                                var page = pageStack.push(Qt.resolvedUrl(pageUrl), { thingClass: thingClass });
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

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }
        }
    }

    Component {
        id: removeDialogComponent
        NymeaDialog {
            id: removeDialog
            title: qsTr("Remove thing?")
            text: qsTr("Are you sure you want to remove %1 and all associated settings?").arg(thing.name)
            standardButtons: Dialog.Yes | Dialog.No

            property Thing thing: null

            onAccepted: {
                engine.thingManager.removeThing(thing.id);
            }
        }
    }
}
