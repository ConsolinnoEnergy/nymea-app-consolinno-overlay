import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "qrc:/ui/components"
import Nymea 1.0

import "../delegates"
import "../components"

Page {
    id: root

    readonly property string eebusGatewayThingClassId: "d7448dd7-cafc-4ef7-9169-09ea657f755c"
    // EEBUS child thing class IDs (auto-created as children of the gateway)
    readonly property var eebusChildThingClassIds: [
        "15e6bb51-ef91-4668-9f6f-a43413d4ee4b",  // EEBus Wallbox (EVSE)
        "a6273bc4-6ee4-4b76-ba20-edb3c054f158",  // EEBus Heatpump
        "7c29d23d-d98b-46fd-b941-39a585159fbe",  // EEBus Inverter
        "f84f7c28-04cc-4da5-8564-402a9361b136"   // EEBus GridGuard
    ]

    signal done(bool skip, bool abort, bool back)

    // When true, skip the overview page and jump straight to discovery.
    // Use this when opening from AddNewThings so the list page is not shown.
    property bool directToDiscovery: false

    // Holds the discovery page instance so we can pop back to it on cancel.
    property var _discoveryPageInstance: null

    header: CoHeader {
        text: qsTr("EEBUS Devices")
        backButtonVisible: true
        onBackPressed: root.done(false, false, true)
    }
    background: Item {}

    QtObject {
        id: d
        property ThingDescriptor thingDescriptor: null
        property string thingName: ""
        property var params: []
        property string name: ""
    }

    ThingDiscovery {
        id: discovery
        engine: _engine
    }

    // Proxy to show EEBUS child things (Wallbox, Heatpump, Inverter, GridGuard)
    ThingsProxy {
        id: eebusChildThingsProxy
        engine: _engine
        shownThingClassIds: root.eebusChildThingClassIds
    }

    // Proxies used for device-count limit checks when a child thing appears.
    ThingsProxy {
        id: evChargerLimitProxy
        engine: _engine
        shownInterfaces: ["evcharger"]
    }

    ThingsProxy {
        id: heatPumpLimitProxy
        engine: _engine
        shownInterfaces: ["heatpump"]
    }

    // When directToDiscovery is set, skip the overview page and go straight to
    // the discovery page so the caller doesn't have to navigate through the list.
    // Defer the push so that the parent StackView has finished pushing this
    // wizard before we push the discovery page on top of it.
    Component.onCompleted: {
        if (root.directToDiscovery) {
            Qt.callLater(function() {
                var thingClass = engine.thingManager.thingClasses.getThingClass(root.eebusGatewayThingClassId);
                discovery.discoverThings(root.eebusGatewayThingClassId);
                root._discoveryPageInstance = pageStack.push(discoveryPage, {thingClass: thingClass});
            });
        }
    }

    Connections {
        target: engine.thingManager

        onAddThingReply: function(commandId, thingError, thingId, displayMessage) {
            busyOverlay.shown = false;
            if (thingError !== Thing.ThingErrorNoError) {
                var thing = engine.thingManager.things.getThing(thingId);
                pageStack.push(setupResultComponent, {thingError: thingError, thing: thing, message: displayMessage});
                return;
            }
            // Gateway added successfully – wait for the EEBUS child thing to appear.
            pageStack.push(eebusChildWaitingComponent, {gatewayThingId: thingId});
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.margins
        spacing: Style.margins
        // Hidden when opened via directToDiscovery (the list is never shown then).
        visible: !root.directToDiscovery

        CoFrostyCard {
            Layout.fillWidth: true
            contentTopMargin: Style.margins
            headerText: qsTr("Configured EEBUS Devices")

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                Flickable {
                    id: deviceFlickable
                    clip: true
                    Layout.fillWidth: true
                    contentHeight: deviceList.implicitHeight
                    contentWidth: width
                    visible: eebusChildThingsProxy.count > 0

                    Layout.preferredHeight: Math.min(deviceList.implicitHeight, app.height / 3)
                    flickableDirection: Flickable.VerticalFlick

                    ColumnLayout {
                        id: deviceList
                        width: parent.width
                        spacing: 0

                        Repeater {
                            id: deviceRepeater
                            model: eebusChildThingsProxy
                            delegate: CoCard {
                                Layout.fillWidth: true
                                readonly property Thing thing: eebusChildThingsProxy.get(index)
                                readonly property Thing parentThing: thing ? engine.thingManager.things.getThing(thing.parentId) : null
                                text: model.name
                                helpText: parentThing ? parentThing.name : ""
                                iconLeft: app.interfacesToIcon(model.interfaces)
                            }
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    Layout.preferredHeight: app.height / 6
                    visible: eebusChildThingsProxy.count === 0
                    text: qsTr("No EEBUS devices configured yet.")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                }
            }
        }

        CoFrostyCard {
            Layout.fillWidth: true
            contentTopMargin: Style.margins
            headerText: qsTr("Add EEBUS Device")

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Style.margins
                anchors.leftMargin: Style.margins
                spacing: 0

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Search in network")
                    onClicked: {
                        var thingClass = engine.thingManager.thingClasses.getThingClass(root.eebusGatewayThingClassId);
                        discovery.discoverThings(root.eebusGatewayThingClassId);
                        root._discoveryPageInstance = pageStack.push(discoveryPage, {thingClass: thingClass});
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Next")
            onClicked: root.done(true, false, false)
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Cancel")
            flat: true
            onClicked: root.done(false, true, false)
        }
    }

    // Component: Discovery page
    Component {
        id: discoveryPage

        SettingsPageBase {
            id: discoveryView

            property ThingClass thingClass

            header: CoHeader {
                text: qsTr("Discover EEBUS Devices")
                backButtonVisible: true
                onBackPressed: {
                    if (root.directToDiscovery) {
                        // Pop discovery page and signal the caller to close the wizard.
                        pageStack.pop(root, StackView.Immediate)
                        root.done(false, false, true)
                    } else {
                        pageStack.pop()
                    }
                }
            }

            CoFrostyCard {
                Layout.fillWidth: true
                Layout.topMargin: Style.margins
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                contentTopMargin: Style.margins
                headerText: qsTr("The following devices were found:")
                visible: !discovery.busy && discoveryProxy.count > 0

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    Repeater {
                        model: ThingDiscoveryProxy {
                            id: discoveryProxy
                            thingDiscovery: discovery
                            showAlreadyAdded: false
                            showNew: true
                        }

                        delegate: CoCard {
                            Layout.fillWidth: true
                            text: model.name
                            helpText: model.description
                            iconLeft: app.interfacesToIcon(discoveryView.thingClass.interfaces)
                            showChildrenIndicator: true

                            onClicked: {
                                d.thingDescriptor = discoveryProxy.get(index);
                                d.thingName = model.name;
                                pageStack.push(paramsPage, {thingClass: discoveryView.thingClass});
                            }
                        }
                    }
                }
            }

            busy: discovery.busy
            busyText: qsTr("Searching for devices...")

            ColumnLayout {
                visible: !discovery.busy && discoveryProxy.count === 0
                spacing: app.margins
                Layout.preferredHeight: discoveryView.height - discoveryView.header.height - retryButton.height - app.margins * 3

                Label {
                    text: qsTr("Too bad...")
                    font.pixelSize: app.largeFont
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    horizontalAlignment: Text.AlignHCenter
                }

                Label {
                    text: qsTr("No EEBUS device was found in the network. Please make sure the device is powered on and connected to the same network.")
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Button {
                id: retryButton
                Layout.fillWidth: true
                Layout.margins: Style.margins
                text: qsTr("Search again")
                onClicked: {
                    discovery.discoverThings(root.eebusGatewayThingClassId);
                }
                visible: !discovery.busy
            }
        }
    }

    // Component: Params page
    Component {
        id: paramsPage

        SettingsPageBase {
            id: paramsView

            property ThingClass thingClass

            title: qsTr("Set up %1").arg(d.thingName ? d.thingName : (thingClass ? thingClass.displayName : ""))
            header: CoHeader {
                text: paramsView.title
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            CoFrostyCard {
                id: nameGroup
                Layout.fillWidth: true
                Layout.topMargin: Style.margins
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                contentTopMargin: Style.smallMargins
                headerText: qsTr("Name")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoInputField {
                        id: nameTextField
                        Layout.fillWidth: true
                        text: d.thingName ? d.thingName : (thingClass ? thingClass.displayName : "")
                        labelText: qsTr("Please change name if necessary.")
                    }
                }
            }

            CoFrostyCard {
                id: paramsGroup
                Layout.fillWidth: true
                Layout.topMargin: Style.margins
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                contentTopMargin: Style.smallMargins
                headerText: qsTr("Thing parameters")
                visible: paramRepeater.count > 0

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    Repeater {
                        id: paramRepeater
                        model: engine.jsonRpcClient.ensureServerVersion("1.12") || d.thingDescriptor == null ?
                                   (thingClass ? thingClass.paramTypes : null) :
                                   null
                        delegate: ParamDelegate {
                            Layout.fillWidth: true
                            enabled: !model.readOnly
                            paramType: thingClass.paramTypes.get(index)
                            value: {
                                if (d.thingDescriptor && d.thingDescriptor.params.getParam(paramType.id)) {
                                    return d.thingDescriptor.params.getParam(paramType.id).value
                                }
                                return thingClass.paramTypes.get(index).defaultValue
                            }
                        }
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                Layout.topMargin: Style.margins

                text: qsTr("OK")
                onClicked: {
                    var params = [];
                    for (var i = 0; i < paramRepeater.count; i++) {
                        var param = {};
                        var paramType = paramRepeater.itemAt(i).paramType;
                        if (!paramType.readOnly) {
                            param.paramTypeId = paramType.id;
                            param.value = paramRepeater.itemAt(i).value;
                            params.push(param);
                        }
                    }
                    d.params = params;
                    d.name = nameTextField.text;

                    if (d.thingDescriptor) {
                        engine.thingManager.addDiscoveredThing(thingClass.id, d.thingDescriptor.id, d.name, params);
                    } else {
                        engine.thingManager.addThing(thingClass.id, d.name, params);
                    }
                    busyOverlay.shown = true;
                }
            }
        }
    }

    BusyOverlay {
        id: busyOverlay
    }

    // Component: Wait for the EEBUS child thing that the gateway creates automatically.
    // Shows a spinner for up to 30 seconds. On timeout or limit violation the gateway
    // is removed. On success the appropriate optimisation screen is opened.
    Component {
        id: eebusChildWaitingComponent

        Page {
            id: waitingPage

            property string gatewayThingId: ""

            // Prevent double-handling when both the race-condition check and the
            // thingAdded signal fire.
            property bool _handled: false

            header: CoHeader {
                text: qsTr("EEBUS Device")
                backButtonVisible: d2.state === "waiting"
                onBackPressed: waitingPage.handleCancel()
            }

            // ---- helpers ---------------------------------------------------

            function normalizeUuid(uuid) {
                return uuid.toString().replace(/[{}]/g, "").toLowerCase()
            }

            function handleCancel() {
                if (_handled) return
                _handled = true
                waitTimer.stop()
                engine.thingManager.removeThing(gatewayThingId, ThingManager.RemovePolicyCascade)
                // Pop back to the discovery page so the user can try again,
                // falling back to the wizard root if the reference is missing.
                var target = root._discoveryPageInstance ? root._discoveryPageInstance : root
                pageStack.pop(target, StackView.Immediate)
            }

            function handleChildThing(childThing) {
                if (_handled) return
                _handled = true
                waitTimer.stop()

                var classId = normalizeUuid(childThing.thingClassId)
                var isEvCharger = (classId === "15e6bb51-ef91-4668-9f6f-a43413d4ee4b")
                var isHeatPump  = (classId === "a6273bc4-6ee4-4b76-ba20-edb3c054f158")

                if (isEvCharger && evChargerLimitProxy.count > 1) {
                    engine.thingManager.removeThing(gatewayThingId, ThingManager.RemovePolicyCascade)
                    d2.errorText = qsTr("At the moment, %1 can only control one EV charger. Support for multiple EV chargers is planned for future releases. The device has been removed.").arg(Configuration.deviceName)
                    d2.state = "limit_error"
                    return
                }
                if (isHeatPump && heatPumpLimitProxy.count > 1) {
                    engine.thingManager.removeThing(gatewayThingId, ThingManager.RemovePolicyCascade)
                    d2.errorText = qsTr("At the moment, %1 can only control one heat pump. Support for multiple heat pumps is planned for future releases. The device has been removed.").arg(Configuration.deviceName)
                    d2.state = "limit_error"
                    return
                }

                d2.childThing = childThing
                d2.state = "success"
            }

            function handleTimeout() {
                if (_handled) return
                _handled = true
                engine.thingManager.removeThing(gatewayThingId, ThingManager.RemovePolicyCascade)
                d2.state = "timeout_error"
            }

            // Race-condition guard: check whether the child appeared before this
            // component finished loading.
            Component.onCompleted: {
                var gwId = normalizeUuid(gatewayThingId)
                for (var i = 0; i < engine.thingManager.things.count; i++) {
                    var t = engine.thingManager.things.get(i)
                    if (normalizeUuid(t.parentId) === gwId &&
                        root.eebusChildThingClassIds.indexOf(normalizeUuid(t.thingClassId)) >= 0) {
                        handleChildThing(t)
                        return
                    }
                }
            }

            // ---- state -----------------------------------------------------

            QtObject {
                id: d2
                property string state: "waiting"   // "waiting" | "success" | "timeout_error" | "limit_error"
                property string errorText: ""
                property Thing childThing: null
            }

            // ---- timer & signal listener -----------------------------------

            Timer {
                id: waitTimer
                interval: 30000
                running: true
                repeat: false
                onTriggered: waitingPage.handleTimeout()
            }

            Connections {
                target: engine.thingManager
                onThingAdded: function(thing) {
                    if (waitingPage.normalizeUuid(thing.parentId) === waitingPage.normalizeUuid(waitingPage.gatewayThingId) &&
                        root.eebusChildThingClassIds.indexOf(waitingPage.normalizeUuid(thing.thingClassId)) >= 0) {
                        waitingPage.handleChildThing(thing)
                    }
                }
            }

            // ---- UI --------------------------------------------------------

            ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: Style.margins }
                width: Math.min(parent.width - Style.margins * 2, 300)
                spacing: Style.margins

                Item { Layout.fillHeight: true }

                // Waiting
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: d2.state === "waiting"
                    spacing: Style.margins

                    BusyIndicator {
                        Layout.alignment: Qt.AlignHCenter
                        running: true
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Setting up EEBUS device...")
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }

                // Success
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: d2.state === "success"
                    spacing: Style.margins

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: qsTr("The EEBUS device has been successfully set up:")
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                        text: d2.childThing ? d2.childThing.name : ""
                    }

                    ColorIcon {
                        Layout.topMargin: Style.bigMargins
                        Layout.bottomMargin: Style.bigMargins
                        Layout.alignment: Qt.AlignHCenter
                        name: "tick"
                        color: Style.accentColor
                        size: Style.hugeIconSize * 3
                    }
                }

                // Error (timeout or limit exceeded)
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: d2.state === "timeout_error" || d2.state === "limit_error"
                    spacing: Style.margins

                    ColorIcon {
                        Layout.topMargin: Style.bigMargins
                        Layout.bottomMargin: Style.bigMargins
                        Layout.alignment: Qt.AlignHCenter
                        name: "close"
                        color: Style.red
                        size: Style.hugeIconSize * 3
                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                        text: d2.state === "timeout_error"
                              ? qsTr("The EEBUS device could not be set up. Please check the device and try again.")
                              : d2.errorText
                    }
                }

                Item { Layout.fillHeight: true }

                // OK button – success: open optimisation page
                Button {
                    Layout.fillWidth: true
                    visible: d2.state === "success"
                    text: qsTr("OK")
                    onClicked: {
                        var childThing = d2.childThing
                        var classId = waitingPage.normalizeUuid(childThing.thingClassId)
                        var optPage = null

                        if (classId === "15e6bb51-ef91-4668-9f6f-a43413d4ee4b") {
                            // EEBUS Wallbox → EV charger optimisation
                            optPage = pageStack.push("../optimization/EvChargerOptimization.qml", {
                                thing: childThing,
                                directionID: 1
                            })
                        } else if (classId === "a6273bc4-6ee4-4b76-ba20-edb3c054f158") {
                            // EEBUS Heatpump → heating optimisation
                            optPage = pageStack.push("../optimization/HeatingOptimization.qml", {
                                heatingConfiguration: hemsManager.heatingConfigurations.getHeatingConfiguration(childThing.id),
                                heatPumpThing: childThing,
                                directionID: 1
                            })
                        } else {
                            // No optimisation screen for inverter / GridGuard
                            pageStack.pop(root, StackView.Immediate)
                            if (root.directToDiscovery) {
                                root.done(true, false, false)
                            }
                            return
                        }

                        if (optPage) {
                            optPage.done.connect(function() {
                                pageStack.pop(root, StackView.Immediate)
                                if (root.directToDiscovery) {
                                    root.done(true, false, false)
                                }
                            })
                        }
                    }
                }

                // OK button – error: go back
                Button {
                    Layout.fillWidth: true
                    visible: d2.state === "timeout_error" || d2.state === "limit_error"
                    text: qsTr("OK")
                    onClicked: {
                        pageStack.pop(root, StackView.Immediate)
                        if (root.directToDiscovery) {
                            root.done(true, false, false)
                        }
                    }
                }
            }
        }
    }

    // Component: Setup result page (used for the gateway-add error path)
    Component {
        id: setupResultComponent

        Page {
            id: setupResultPage

            property int thingError: Thing.ThingErrorNoError
            property Thing thing: null
            property string message: ""

            header: CoHeader {
                text: qsTr("EEBUS Devices")
                backButtonVisible: false
            }

            ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: Style.margins }
                width: Math.min(parent.width - Style.margins * 2, 300)
                spacing: Style.margins

                Label {
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    wrapMode: Text.WordWrap
                    text: qsTr("An error occurred while setting up the EEBUS device. Please try again.")
                    visible: setupResultPage.thingError != Thing.ThingErrorNoError
                }

                ColumnLayout {
                    spacing: 0
                    Layout.alignment: Qt.AlignHCenter

                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 200
                        text: qsTr("OK")
                        onClicked: {
                            pageStack.pop(root);
                            if (root.directToDiscovery) {
                                root.done(true, false, false)
                            }
                        }
                    }
                }
            }
        }
    }
}
