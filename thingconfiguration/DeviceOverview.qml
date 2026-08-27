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
    bottomPadding: 0
    property int navigationFooterHeight: 0
    property bool busy: d.thingToRemove !== null
    signal startWizard()

    property Component navbarControls: deviceOverviewNavbarControls

    Component {
        id: deviceOverviewNavbarControls
        ColumnLayout {
            spacing: Style.smallMargins

            CoNavbarButton {
                Layout.fillWidth: true
                text: qsTr("Start Wizard")
                onClicked: wizardController.startManualSetup()
            }

            CoNavbarButton {
                Layout.fillWidth: true
                text: qsTr("Set up new device")
                onClicked: pageStack.push("../wizards/AuthorisationView.qml", { calledFromSetupWizard: false })
            }
        }
    }

    header: null

    CoHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        blurSource: bodyFlickable
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

        // ESUI-1620: Rebuild the base-interface -> thing-id map from the live
        // thingsProxy. Needs to run again whenever thingsProxy's content
        // changes, not just once on page creation - see thingsProxy.onCountChanged
        // below. Without this, things added/removed elsewhere (e.g. via the
        // "Set up new device" wizard, or by deleting a thing here) wouldn't
        // show up until this page instance is destroyed and recreated, since
        // Component.onCompleted only runs once per instance and this page is
        // kept alive on the pageStack while the wizard is pushed on top of it.
        function rebuildBaseInterfaceMap() {
            let map = {};
            for (let i = 0; i < thingsProxy.count; ++i) {
                const item = thingsProxy.get(i);
                const baseInterface = item.thingClass.baseInterface;
                if (!map[baseInterface]) {
                    map[baseInterface] = [];
                }
                map[baseInterface].push(item.id);
            }
            d.baseInterfacesWithThingClasses = map;
        }
    }

    Connections {
        target: engine.thingManager
        onRemoveThingReply: function(commandId, thingError, ruleIds) {
            if (!d.thingToRemove) {
                return;
            }

            var thing = d.thingToRemove;
            d.thingToRemove = null;
            switch (thingError) {
            case Thing.ThingErrorNoError:
                return;
            case Thing.ThingErrorThingInRule: {
                var removeMethodComponent = Qt.createComponent(Qt.resolvedUrl("../components/RemoveThingMethodDialog.qml"))
                var popup = removeMethodComponent.createObject(root, {thing: thing, rulesList: ruleIds});
                popup.open();
                return;
            }
            default: {
                var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"))
                var popup = errorDialog.createObject(root, {error: thingError})
                popup.open();
            }
            }
        }
    }

    WizardController {
        id: wizardController
        onWizardDone: {
            // ESUI-879: Settings is itself a main view tab now. Pop back to
            // MainPage and switch the active tab to the dashboard.
            var mainPage = pageStack.get(0)
            pageStack.pop(mainPage)
            if (mainPage && mainPage.goToView) {
                mainPage.goToView("consolinnoDashboard", undefined, true)
            }
        }
    }

    ThingsProxy {
        id: thingsProxy
        engine: _engine
        hideTagId: "hiddenInDeviceView"
        hiddenInterfaces: ["gridsupport", "epexdatasource"]
        hiddenThingClassIds: [
            "7a597210-8f7e-4667-8cf7-82ccdc23c313", // Device claiming plugin
            "f5f3c387-2482-4154-99ee-7a473f6d81e9" // Eebus information plugin
        ]
        groupByInterface: true
        // ESUI-1620: keep the JS snapshot in d.baseInterfacesWithThingClasses
        // in sync with the live model instead of only building it once in
        // Component.onCompleted.
        onCountChanged: d.rebuildBaseInterfaceMap()
    }

    Component.onCompleted: d.rebuildBaseInterfaceMap()


    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: Style.margins
        anchors.rightMargin: Style.margins
        anchors.bottomMargin: Style.margins
        spacing: Style.margins

        Flickable {
            id: bodyFlickable
            Layout.fillWidth: true
            Layout.fillHeight: true
            topMargin: header.height + Style.smallMargins
            contentHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin + root.navigationFooterHeight
            clip: true

            Component.onCompleted: Qt.callLater(() => contentY = -topMargin)

            ColumnLayout {
                id: layout
                anchors { left: parent.left; right: parent.right; top: parent.top }
                spacing: Style.margins

                Repeater {
                    id: baseInterfaceRepeater
                    model: Object.keys(d.baseInterfacesWithThingClasses)

                    delegate: CoFrostyCard {
                        id: baseInterfaceCard
                        property string baseInterface: modelData
                        property var thingIds: d.baseInterfacesWithThingClasses[baseInterface] || []

                        Layout.fillWidth: true
                        contentTopMargin: 8
                        headerText: app.interfaceToString(modelData)
                        visible: thingIds.length > 0

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 0

                            Repeater {
                                id: thingsRepeater
                                model: baseInterfaceCard.thingIds

                                delegate: CoCard {
                                    property var thing: thingsProxy.getThing(modelData)

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

    BusyOverlay {
        shown: root.busy
    }
}
