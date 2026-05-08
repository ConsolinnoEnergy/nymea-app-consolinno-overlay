import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import QtQuick.Controls
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root

    property string filterInterface: ""
    property var thingsListId: []
    property Thing thingDevice

    readonly property string eebusGatewayThingClassId: "d7448dd7-cafc-4ef7-9169-09ea657f755c"
    readonly property var eebusChildThingClassIds: [
        "15e6bb51-ef91-4668-9f6f-a43413d4ee4b",  // EEBus Wallbox (EVSE)
        "a6273bc4-6ee4-4b76-ba20-edb3c054f158",  // EEBus Heatpump
        "7c29d23d-d98b-46fd-b941-39a585159fbe",  // EEBus Inverter
        "f84f7c28-04cc-4da5-8564-402a9361b136"   // EEBus GridGuard
    ]

    function refreshAllDelegates() {
        for (let i = 0; i < baseInterfaceRepeater.count; ++i) {
            let item = baseInterfaceRepeater.itemAt(i);
            if (item && item.refresh) {
                item.refresh();
            }
        }
    }

    StackView.onActivated: {
        refreshAllDelegates();
    }

    header: NymeaHeader {
        text: qsTr("Set up new device")
        onBackPressed: {
            pageStack.pop();
        }
    }

    Connections {
        target: engine.thingManager

        onThingAdded: function(thing) {
            thingDevice = thing
        }
    }

    function startWizard(thingClass) {
        if (thingClass.id.toString() === root.eebusGatewayThingClassId) {
            eebusState.knownChildIds = root.currentEebusChildThingIds();
        }
        var page = pageStack.push(Qt.resolvedUrl("ConsolinnoSetupWizard.qml"), {thingClass: thingClass});
        page.done.connect(function() {
            if (thingClass.id.toString() === root.eebusGatewayThingClassId) {
                eebusState.active = true;
                var child = root.findNewEebusChildThing();
                if (child) {
                    root.handleNewEebusChild(child);
                } else {
                    eebusChildPollTimer.retryCount = 0;
                    eebusChildPollTimer.start();
                }
                return;
            }
            var thingPage = "";
            if (thingClass.interfaces.includes("heatpump")) {
                thingPage = pageStack.push("../optimization/HeatingOptimization.qml", {
                    heatingConfiguration: hemsManager.heatingConfigurations.getHeatingConfiguration(thingDevice.id),
                    heatPumpThing: thingDevice,
                    directionID: 1
                });
                navigateBack(thingPage);
            } else if (thingClass.interfaces.includes("evcharger")) {
                thingPage = pageStack.push("../optimization/EvChargerOptimization.qml", {
                    chargingConfiguration: hemsManager.chargingConfigurations.getChargingConfiguration(thingDevice.id),
                    thing: thingDevice,
                    directionID: 1
                });
                navigateBack(thingPage);
            } else if (thingClass.interfaces.includes("heatingrod")) {
                thingPage = pageStack.push("../optimization/HeatingElementOptimization.qml", {
                    heatingConfiguration: hemsManager.heatingConfigurations.getHeatingConfiguration(thingDevice.id),
                    heatRodThing: thingDevice,
                    directionID: 1
                });
                navigateBack(thingPage);
            } else if (thingClass.interfaces.includes("solarinverter")) {
                thingPage = pageStack.push("../optimization/PVOptimization.qml", {
                    pvConfiguration: hemsManager.pvConfigurations.getPvConfiguration(thingDevice.id),
                    thing: thingDevice,
                    directionID: 1
                });
                navigateBack(thingPage);
            } else if (thingClass.interfaces.includes("energystorage")) {
                thingPage = pageStack.push("../optimization/BatteryOptimization.qml", {
                    batteryConfiguration: hemsManager.batteryConfigurations.getBatteryConfiguration(thingDevice.id),
                    thing: thingDevice,
                    directionID: 1
                });
                navigateBack(thingPage);
            } else if (thingClass.interfaces.includes("powersocket")) {
                thingPage = pageStack.push("../optimization/SwitchableConsumerOptimization.qml", {
                    switchConfiguration: hemsManager.switchConfigurations.getSwitchConfiguration(thingDevice.id),
                    switchThing: thingDevice,
                    directionID: 1
                });
                navigateBack(thingPage);
            } else {
                pageStack.pop(root);
            }
        })
        page.aborted.connect(function() {
            pageStack.pop();
        })

        function navigateBack(thingPage){
            thingPage.done.connect(function() {
                pageStack.pop(root);
            })
        }
    }

    function eebusDeviceTypeForThing(thing) {
        if (!thing || !thing.thingClass) return "";
        var ifaces = thing.thingClass.interfaces;
        if (ifaces.indexOf("evcharger") !== -1) return "evcharger";
        if (["heatpump", "smartgridheatpump", "simpleheatpump", "pvsurplusheatpump"].some(i => ifaces.indexOf(i) !== -1)) return "heatpump";
        if (ifaces.indexOf("solarinverter") !== -1) return "solarinverter";
        return "";
    }

    // Returns a non-empty limit-exceeded message when adding this thing violates a device-count limit.
    function eebusLimitExceededMessageForThing(thing) {
        switch (root.eebusDeviceTypeForThing(thing)) {
        case "evcharger":
            return evCharger.count > 1
                ? qsTr("At the moment, %1 can only control one EV charger. Support for multiple EV chargers is planned for future releases.").arg(Configuration.deviceName)
                : "";
        case "heatpump":
            return heatPumpAll.count > 1
                ? qsTr("At the moment, %1 can only control one heat pump. Support for multiple heat pumps is planned for future releases.").arg(Configuration.deviceName)
                : "";
        default:
            return "";
        }
    }

    function currentEebusChildThingIds() {
        var ids = [];
        for (var i = 0; i < eebusChildThingsProxy.count; i++) {
            var t = eebusChildThingsProxy.get(i);
            if (t) ids.push(t.id.toString());
        }
        return ids;
    }

    function findNewEebusChildThing() {
        for (var i = 0; i < eebusChildThingsProxy.count; i++) {
            var t = eebusChildThingsProxy.get(i);
            if (!t || eebusState.knownChildIds.indexOf(t.id.toString()) !== -1) continue;
            if (root.eebusDeviceTypeForThing(t) !== "") return t;
        }
        return null;
    }

    function handleNewEebusChild(thing) {
        if (!eebusState.active) return;
        eebusState.active = false;
        eebusChildPollTimer.stop();

        var limitMsg = root.eebusLimitExceededMessageForThing(thing);
        if (limitMsg === "") {
            openEebusOptimizationPage(thing);
            return;
        }

        eebusState.pendingLimitMessage = limitMsg;
        eebusState.pendingRemoveCommandId = engine.thingManager.removeThing(thing.isChild ? thing.parentId : thing.id);
    }

    function openEebusOptimizationPage(thing) {
        var thingPage = null;
        switch (root.eebusDeviceTypeForThing(thing)) {
        case "evcharger":
            thingPage = pageStack.push("../optimization/EvChargerOptimization.qml", {
                thing: thing,
                directionID: 1
            });
            break;
        case "heatpump":
            thingPage = pageStack.push("../optimization/HeatingOptimization.qml", {
                heatingConfiguration: hemsManager.heatingConfigurations.getHeatingConfiguration(thing.id),
                heatPumpThing: thing,
                directionID: 1
            });
            break;
        case "solarinverter":
            thingPage = pageStack.push("../optimization/PVOptimization.qml", {
                pvConfiguration: hemsManager.pvConfigurations.getPvConfiguration(thing.id),
                thing: thing,
                directionID: 1
            });
            break;
        default:
            pageStack.pop(root);
            return;
        }
        thingPage.done.connect(function() { pageStack.pop(root); });
    }

    QtObject {
        id: d
        property var baseInterfacesWithThingClasses: ({})
    }

    QtObject {
        id: eebusState
        property bool active: false
        property var knownChildIds: []
        property int pendingRemoveCommandId: -1
        property string pendingLimitMessage: ""
    }

    ThingClassesProxy {
        id: allThingClassesProxy
        engine: _engine
        includeProvidedInterfaces: true
        groupByInterface: true
    }

    Component.onCompleted: {
        let map = {};
        for (let i = 0; i < allThingClassesProxy.count; ++i) {
            const item = allThingClassesProxy.get(i);
            const baseInterface = item.baseInterface;
            if (!map[baseInterface]) {
                map[baseInterface] = [];
            }
            map[baseInterface].push(item.id);
        }
        d.baseInterfacesWithThingClasses = map;
    }

    ThingsProxy {
        id: gridSupport
        engine: _engine
        shownInterfaces: ["gridsupport"]
    }

    ThingsProxy {
        id: epexDataSource
        engine: _engine
        shownInterfaces: ["epexdatasource"]
    }

    ThingsProxy {
        id: evCharger
        engine: _engine
        shownInterfaces: ["evcharger"]
    }

    ThingsProxy {
        id: heatPump
        engine: _engine
        shownInterfaces: ["heatpump"]
    }

    ThingsProxy {
        id: heatingRod
        engine: _engine
        shownInterfaces: ["heatingrod"]
    }

    ThingsProxy {
        id: heatPumpAll
        engine: _engine
        shownInterfaces: ["heatpump", "smartgridheatpump", "simpleheatpump", "pvsurplusheatpump"]
    }

    ThingsProxy {
        id: eebusChildThingsProxy
        engine: _engine
        shownThingClassIds: root.eebusChildThingClassIds
    }

    Timer {
        id: eebusChildPollTimer
        interval: 200
        repeat: true
        property int retryCount: 0
        onTriggered: {
            retryCount++;
            var child = root.findNewEebusChildThing();
            if (child || retryCount >= 20) {
                stop();
                retryCount = 0;
                if (child) {
                    root.handleNewEebusChild(child);
                } else {
                    eebusState.active = false;
                    pageStack.pop(root);
                }
            }
        }
    }

    Connections {
        target: engine.thingManager

        onThingAdded: function(thing) {
            if (!eebusState.active || !thing) return;
            if (root.eebusChildThingClassIds.indexOf(thing.thingClassId.toString()) === -1) return;
            if (eebusState.knownChildIds.indexOf(thing.id.toString()) !== -1) return;
            if (root.eebusDeviceTypeForThing(thing) === "") return;
            root.handleNewEebusChild(thing);
        }

        onRemoveThingReply: function(commandId, thingError, ruleIds) {
            if (commandId !== eebusState.pendingRemoveCommandId) return;
            eebusState.pendingRemoveCommandId = -1;
            var succeeded = thingError === Thing.ThingErrorNoError;
            eebusLimitDialog.text = succeeded
                ? qsTr("%1 The newly added EEBUS device has been removed again.").arg(eebusState.pendingLimitMessage)
                : qsTr("%1 The newly added EEBUS device could not be removed automatically. Please remove it manually.").arg(eebusState.pendingLimitMessage);
            eebusLimitDialog.open();
        }
    }

    Dialog {
        id: eebusLimitDialog
        property string text: ""
        anchors.centerIn: Overlay.overlay
        modal: true
        standardButtons: Dialog.Ok
        onClosed: pageStack.pop(root)

        Label {
            width: Math.min(300, root.width - Style.margins * 4)
            text: eebusLimitDialog.text
            wrapMode: Text.WordWrap
        }
    }

    ThingClassesProxy {
        id: thingClassesProxyEvCharger
        engine: _engine
        filterInterface: "evcharger"
        includeProvidedInterfaces: true
    }

    ThingClassesProxy {
        id: thingClassesProxyHeatPump
        engine: _engine
        filterInterface: "heatpump"
        includeProvidedInterfaces: true
    }
    ThingClassesProxy {
        id: thingClassesProxyElectrics
        engine: _engine
        filterInterface: "dynamicelectricitypricing"
        includeProvidedInterfaces: true
    }
    ThingClassesProxy {
        id: thingClassesProxySmartHeatingRod
        engine: _engine
        filterInterface: "heatingrod"
        includeProvidedInterfaces: true
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins
            contentHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin
            clip: true

            ColumnLayout {
                id: layout
                anchors.fill: parent
                anchors.topMargin: Style.margins
                anchors.bottomMargin: Style.margins
                spacing: Style.margins

                Repeater {
                    id: baseInterfaceRepeater
                    model: Object.keys(d.baseInterfacesWithThingClasses)

                    delegate: CoFrostyCard {
                        Layout.fillWidth: true
                        contentTopMargin: 8
                        headerText: app.interfaceToString(modelData)
                        visible: thingClassesProxy.count > 0

                        Component.onCompleted: {
                            refresh();
                        }

                        function refresh(){
                            var thingsListId = [];
                            if (evCharger.count === 1) {
                                for (let i = 0; i < thingClassesProxyEvCharger.count; i++) {
                                    thingsListId[thingsListId.length] = thingClassesProxyEvCharger.get(i).id.toString();
                                }
                            }
                            if (heatPump.count === 1) {
                                for (let i = 0; i < thingClassesProxyHeatPump.count; i++) {
                                    thingsListId[thingsListId.length] = thingClassesProxyHeatPump.get(i).id.toString();
                                }
                            }
                            if (heatingRod.count === 1) {
                                for (let i = 0; i < thingClassesProxySmartHeatingRod.count; i++) {
                                    thingsListId[thingsListId.length] = thingClassesProxySmartHeatingRod.get(i).id.toString();
                                }
                            }
                            if (gridSupport.count === 1) {
                                thingsListId[thingsListId.length] = gridSupport.get(0).thingClass.id.toString();
                            }
                            if (epexDataSource.count === 1) {
                                thingsListId[thingsListId.length] = epexDataSource.get(0).thingClass.id.toString();
                            }
                            for (let i = 0; i < thingClassesProxyElectrics.count; i++) {
                                thingsListId[thingsListId.length] = thingClassesProxyElectrics.get(i).id.toString();
                            }
                            thingClassesProxy.hiddenThingClassIds = thingsListId;
                        }

                        ThingClassesProxy {
                            id: thingClassesProxy
                            engine: _engine
                            shownThingClassIds: d.baseInterfacesWithThingClasses[modelData]
                            filterString: filterField.text
                        }

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 0

                            Repeater {
                                id: thingClassesRepeater
                                model: thingClassesProxy
                                delegate: CoCard {
                                    property ThingClass thingClass: thingClassesProxy.get(index)

                                    Layout.fillWidth: true
                                    text: thingClass ? thingClass.displayName : ""
                                    helpText: thingClass ?
                                                  engine.thingManager.vendors.getVendor(thingClass.vendorId).displayName :
                                                  ""
                                    iconLeft: thingClass ? app.interfacesToIcon(thingClass.interfaces) : ""
                                    showChildrenIndicator: true
                                    visible: thingClass !== null

                                    onClicked: {
                                        root.startWizard(thingClass)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        CoInputField {
            id: filterField
            Layout.fillWidth: true
            labelText: qsTr("Search")
        }
    }
}
