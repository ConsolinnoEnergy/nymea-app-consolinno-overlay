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
        // For EEBUS: the gateway creates its child thing asynchronously on the server.
        // EebusLimitGuard always listens for thingAdded and handles limit enforcement
        // globally. We connect to its signals here to capture the child (or limit-hit
        // event) before and after page.done fires.
        var lastEebusChild = null;
        var eebusLimitHit = false;
        var pageDoneFired = false;

        function stopEebusWait() {
            eebusChildWaitTimer.storedChildHandler = null;
            eebusChildWaitTimer.storedLimitHandler = null;
            eebusChildWaitTimer.stop();
            eebusChildWaitOverlay.shown = false;
        }

        if (thingClass.id.toString() === root.eebusGatewayThingClassId) {
            var childHandler = function(thing) {
                eebusLimitGuard.eebusChildThingAdded.disconnect(childHandler);
                eebusLimitGuard.eebusLimitExceeded.disconnect(limitHandler);
                lastEebusChild = thing;
                if (pageDoneFired) {
                    // page.done already fired and we were waiting — navigate now
                    stopEebusWait();
                    openEebusOptimizationPage(thing);
                }
                // else: page.done will read lastEebusChild and navigate
            };
            var limitHandler = function() {
                eebusLimitGuard.eebusChildThingAdded.disconnect(childHandler);
                eebusLimitGuard.eebusLimitExceeded.disconnect(limitHandler);
                eebusLimitHit = true;
                stopEebusWait();
                pageStack.pop(root);
            };
            eebusLimitGuard.eebusChildThingAdded.connect(childHandler);
            eebusLimitGuard.eebusLimitExceeded.connect(limitHandler);
        }

        var page = pageStack.push(Qt.resolvedUrl("ConsolinnoSetupWizard.qml"), {thingClass: thingClass});
        page.done.connect(function() {
            if (thingClass.id.toString() === root.eebusGatewayThingClassId) {
                if (eebusLimitHit) return; // limitHandler already popped and cleaned up
                pageDoneFired = true;
                if (lastEebusChild !== null) {
                    // Child already arrived before page.done — disconnect and navigate
                    eebusLimitGuard.eebusChildThingAdded.disconnect(childHandler);
                    eebusLimitGuard.eebusLimitExceeded.disconnect(limitHandler);
                    openEebusOptimizationPage(lastEebusChild);
                } else {
                    // Child not yet here — show overlay and wait
                    eebusChildWaitOverlay.shown = true;
                    eebusChildWaitTimer.storedChildHandler = childHandler;
                    eebusChildWaitTimer.storedLimitHandler = limitHandler;
                    eebusChildWaitTimer.start();
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
            if (thingClass.id.toString() === root.eebusGatewayThingClassId) {
                eebusLimitGuard.eebusChildThingAdded.disconnect(childHandler);
                eebusLimitGuard.eebusLimitExceeded.disconnect(limitHandler);
                stopEebusWait();
            }
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
        if (["heatpump", "smartgridheatpump", "simpleheatpump", "pvsurplusheatpump"].some(function(i) { return ifaces.indexOf(i) !== -1; })) return "heatpump";
        if (ifaces.indexOf("solarinverter") !== -1) return "solarinverter";
        return "";
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

    // Timer and overlay used when page.done fires for an EEBUS gateway before
    // the child thing has arrived. We keep the guard handlers connected and wait
    // up to 4 s for the child; if nothing arrives we pop back to the list.
    Timer {
        id: eebusChildWaitTimer
        interval: 10000
        repeat: false
        // Stored so the timer can disconnect them on timeout
        property var storedChildHandler: null
        property var storedLimitHandler: null
        onTriggered: {
            if (storedChildHandler) { eebusLimitGuard.eebusChildThingAdded.disconnect(storedChildHandler); storedChildHandler = null; }
            if (storedLimitHandler) { eebusLimitGuard.eebusLimitExceeded.disconnect(storedLimitHandler); storedLimitHandler = null; }
            eebusChildWaitOverlay.shown = false;
            pageStack.pop(root);
        }
    }

    BusyOverlay {
        id: eebusChildWaitOverlay
        parent: Overlay.overlay
        anchors.fill: parent
    }

    QtObject {
        id: d
        property var baseInterfacesWithThingClasses: ({})
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
