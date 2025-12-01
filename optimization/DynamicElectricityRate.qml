import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.15

import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

StackView {
    id: root

    property string startView

    initialItem: setUpComponent

    property HemsManager hemsManager
    property string name
    property bool newTariff: false
    property Thing dynElectricThing : thing.get(0)
    property int directionID: 0
    signal done(bool skip, bool abort, bool back);

    ThingsProxy {
        id: thing
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
                anchors {top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right;}
                spacing: 0

                ColumnLayout {
                    spacing: 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 0

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Submitted Rate")
                        wrapMode: Text.WordWrap
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: app.margins
                        horizontalAlignment: Text.AlignRight
                    }
                }

                VerticalDivider
                {
                    Layout.fillWidth: true
                    dividerColor: Material.accent
                }

                Flickable {
                    id: flickableContainer
                    clip: true


                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        id: column
                        Layout.topMargin: 0
                        width: parent.width
                        spacing: 0

                        Repeater {
                            id: dynamicRateRepeater
                            model: ThingsProxy {
                                id: erProxy
                                engine: _engine
                                shownInterfaces: ["dynamicelectricitypricing"]
                            }
                            delegate: ConsolinnoThingDelegate {
                                implicitHeight: 50
                                Layout.fillWidth: true
                                iconName: Configuration.energyIcon !== "" ? "/ui/images/"+Configuration.energyIcon : "/icons/energy.svg"
                                text: model.name
                                progressive: true
                                canDelete: true
                                property int pageStackPopsAfterConfigure: 1

                                Component.onCompleted: {
                                    if (root.startView === "configure") {
                                        pageStackPopsAfterConfigure = 2
                                        Qt.callLater(onClicked)
                                    }
                                }

                                onClicked: {
                                    if(erProxy.get(0).thingClass.setupMethod !== 4){
                                        // #TODO own screen in case of Epex day ahead
                                        var page = pageStack.push(Qt.resolvedUrl("qrc:///ui/thingconfiguration/SetupWizard.qml"),
                                                                  {thing: dynElectricThing});
                                        page.done.connect(function() {
                                            for (var i = 0; i < pageStackPopsAfterConfigure; i++) {
                                                pageStack.pop();
                                            }
                                        })
                                        page.aborted.connect(function() {
                                            for (var i = 0; i < pageStackPopsAfterConfigure; i++) {
                                                pageStack.pop();
                                            }
                                        })
                                    }
                                }
                                onDeleteClicked: {
                                    var popup = removeDialogComponent.createObject(root, {thing: erProxy.get(0)})
                                    popup.open()
                                }
                            }
                        }
                    }
                }

                Rectangle{
                    Layout.preferredHeight: parent.height / 3
                    Layout.fillWidth: true
                    visible: erProxy.count === 0
                    color: Material.background
                    Text {
                        text: qsTr("There is no rate set up yet")
                        color: Material.foreground
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignHCenter
                    }
                }

                VerticalDivider
                {
                    Layout.fillWidth: true
                    dividerColor: Material.accent
                    visible: thing.count >= 1 ? false : true
                }

                ColumnLayout {
                    Layout.topMargin: Style.margins
                    visible: (root.newTariff && thing.count === 0 )
                    Label {
                        Layout.fillWidth: true
                        Layout.leftMargin: Style.margins
                        Layout.rightMargin: Style.margins
                        text: qsTr("Add Rate: ")
                        wrapMode: Text.WordWrap
                    }

                    ConsolinnoDropdown {
                        id: energyRateComboBox
                        Layout.fillWidth: true
                        Layout.leftMargin: Style.margins
                        Layout.rightMargin: Style.margins
                        textRole: "displayName"
                        valueRole: "id"
                        model: ThingClassesProxy {
                            id: currentThing
                            engine: _engine
                            filterInterface: "dynamicelectricitypricing"
                            includeProvidedInterfaces: true
                        }
                    }
                }

                ColumnLayout {
                    spacing: 0
                    Layout.alignment: Qt.AlignHCenter
                    visible: thing.count >= 1 ? false : true

                    Button {
                        id: addButton
                        text: qsTr("Add Rate")
                        Layout.fillWidth: true
                        Layout.leftMargin: Style.margins
                        Layout.rightMargin: Style.margins
                        Layout.alignment: Qt.AlignHCenter
                        property ThingClass thingClass: thingClassesProxy.get(energyRateComboBox.currentIndex)

                        Connections {
                            target: engine.thingManager
                            onThingAdded: {
                                if (thing.thingClass.interfaces.includes("dynamicelectricitypricing")) {
                                    root.dynElectricThing = thing
                                }
                            }
                        }

                        onClicked: {
                            if(!root.newTariff) {
                              root.newTariff = true;
                              addButton.text = qsTr("Next");
                              return;
                            }

                            // #TODO own screen in case of Epex day ahead
                            var page = pageStack.push(Qt.resolvedUrl("qrc:///ui/thingconfiguration/SetupWizard.qml"), {thingClass: thingClass});
                            page.done.connect(function() {
                                pageStack.pop();
                            })
                            page.aborted.connect(function() {
                                pageStack.pop();
                            })
                        }
                    }

                    ConsolinnoSetUpButton {
                        Layout.leftMargin: Style.margins
                        Layout.rightMargin: Style.margins
                        text: qsTr("Cancel")
                        backgroundColor: "transparent"
                        onClicked: {
                            pageStack.pop()
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
                engine.thingManager.removeThing(thing.id)
            }
        }
    }
}
