import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../components"
import "../delegates"
import "../wizards"
import Nymea 1.0

Page {
    id: root
    signal startWizard()

    header: NymeaHeader {
        text: qsTr("Device Overview")
        onBackPressed: {
            if (hemsManager.availableUseCases === 0){
                pageStack.pop()
                pageStack.pop()
            }
            else{
                pageStack.pop()
            }

        }
    }

    QtObject {
        id: d
        property var thingToRemove: null
        property var baseInterfacesWithThingClasses: ({})
    }

    Connections {
        target: engine.thingManager
        onRemoveThingReply: function(commandId, thingError, ruleIds) {
            if (!d.thingToRemove) {
                return;
            }

            switch (thingError) {
            case Thing.ThingErrorNoError:
                d.thingToRemove = null;
                return;
            case Thing.ThingErrorThingInRule:
                var removeMethodComponent = Qt.createComponent(Qt.resolvedUrl("../components/RemoveThingMethodDialog.qml"))
                var popup = removeMethodComponent.createObject(root, {thing: d.thingToRemove, rulesList: ruleIds});
                popup.open();
                return;
            default:
                var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"))
                var popup = errorDialog.createObject(root, {error: thingError})
                popup.open();
            }
        }
    }

    WizardController {
        id: wizardController
        onWizardDone: {
            // Nach dem Wizard: zurück zum Dashboard.
            // Stack: empty Page(0) → MainPage(1) → SettingsPage(2) → DeviceOverview(3)
            // Je zweimal poppen.
            pageStack.pop()
            pageStack.pop()
        }
    }

    ThingClassesProxy {
        id: thingClassesProxy
        engine: _engine
        includeProvidedInterfaces: true
        groupByInterface: true
    }

    Component.onCompleted: {
        let map = {};
        for (let i = 0; i < thingClassesProxy.count; ++i) {
            const item = thingClassesProxy.get(i);
            const baseInterface = item.baseInterface;
            if (!map[baseInterface]) {
                map[baseInterface] = [];
            }
            map[baseInterface].push(item.id);
        }
        d.baseInterfacesWithThingClasses = map;
    }


    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.margins
        spacing: Style.margins

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
            clip: true

            ColumnLayout {
                id: layout
                anchors.fill: parent
                spacing: Style.margins

                Repeater {
                    id: baseInterfaceRepeater
                    model: Object.keys(d.baseInterfacesWithThingClasses)

                    delegate: CoFrostyCard {
                        Layout.fillWidth: true
                        contentTopMargin: 8
                        headerText: app.interfaceToString(modelData)
                        visible: thingsProxy.count > 0

                        ThingsProxy {
                            id: thingsProxy
                            engine: _engine
                            hideTagId: "hiddenInDeviceView"
                            hiddenInterfaces: ["gridsupport", "epexdatasource"]
                            shownThingClassIds: d.baseInterfacesWithThingClasses[modelData]
                        }

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 0

                            Repeater {
                                id: thingsRepeater
                                model: thingsProxy
                                delegate: CoCard {
                                    property var thing: thingsProxy.getThing(model.id)

                                    Layout.fillWidth: true
                                    text: thing.name
                                    // #TODO use same stuff as in CoDashboardView.qml to get battery icons right
                                    iconLeft: app.interfacesToIcon(thing.thingClass.interfaces)
                                    showChildrenIndicator: true

                                    // FIXME: This isn't entirely correct... we should have a way to know if a particular thing is in fact autocreated
                                    // This check might be wrong for thingClasses with multiple create methods...
                                    deletable: !thing.isChild || thing.thingClass.createMethods.indexOf("CreateMethodAuto") < 0

                                    onClicked: {
                                        pageStack.push(Qt.resolvedUrl("ConsolinnoConfigureThingPage.qml"),
                                                       { thing: thing });
                                    }

                                    onDeleteClicked: {
                                        d.thingToRemove = thing;
                                        engine.thingManager.removeThing(d.thingToRemove.id);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Button{
            id: startWizardButton
            Layout.fillWidth: true
            Layout.topMargin: Style.margins
            text: qsTr("Start Wizard")
            onClicked: {
                wizardController.startManualSetup();
            }
        }

        Button{
            id: addDevice
            Layout.fillWidth: true
            text: qsTr("Set up new device")
            onClicked: {
                pageStack.push( "../wizards/AuthorisationView.qml", { directionID: 1 });
            }
        }
    }


    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: engine.thingManager.things.count === 0 && !engine.thingManager.fetchingData
        title: qsTr("There are no things set up yet.")
        text: qsTr("In order for your %1 system to be useful, go ahead and add some things.").arg(Configuration.systemName)
        imageSource: "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
        //buttonText: qsTr("Add a thing")
        buttonVisible: false
        //onButtonClicked: pageStack.push(Qt.resolvedUrl("NewThingPage.qml"))

    }
}
