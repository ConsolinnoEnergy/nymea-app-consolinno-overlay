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
    readonly property string evChargerLimitExceededText: qsTr("At the moment, %1 can only control one EV charger. Support for multiple EV chargers is planned for future releases.").arg(Configuration.deviceName)
    readonly property string heatPumpLimitExceededText: qsTr("At the moment, %1 can only control one heat pump. Support for multiple heat pumps is planned for future releases.").arg(Configuration.deviceName)

    function currentEebusChildThingIds() {
        var thingIds = [];
        for (var i = 0; i < eebusChildThingsProxy.count; i++) {
            var thing = eebusChildThingsProxy.get(i);
            if (thing) {
                thingIds.push(thing.id.toString());
            }
        }
        return thingIds;
    }

    function deviceTypeForThing(thing) {
        if (!thing || !thing.thingClass) {
            return "";
        }

        var interfaces = thing.thingClass.interfaces;
        if (interfaces.indexOf("evcharger") !== -1) {
            return "evcharger";
        }
        if (interfaces.indexOf("heatpump") !== -1 || interfaces.indexOf("smartgridheatpump") !== -1 || interfaces.indexOf("simpleheatpump") !== -1 || interfaces.indexOf("pvsurplusheatpump") !== -1) {
            return "heatpump";
        }
        if (interfaces.indexOf("solarinverter") !== -1) {
            return "solarinverter";
        }

        return "";
    }

    function findNewEebusChildThing() {
        var fallbackThing = null;

        for (var i = 0; i < eebusChildThingsProxy.count; i++) {
            var thing = eebusChildThingsProxy.get(i);
            if (!thing) {
                continue;
            }

            var thingId = thing.id.toString();
            var matchesPendingGateway = d.pendingGatewayThingId !== "" && thing.parentId.toString() === d.pendingGatewayThingId;
            if (d.pendingGatewayThingId !== "") {
                if (!matchesPendingGateway) {
                    continue;
                }
            } else {
                var isNewThing = d.knownEebusChildThingIds.indexOf(thingId) === -1;
                if (!isNewThing) {
                    continue;
                }
            }

            if (root.deviceTypeForThing(thing) !== "") {
                return thing;
            }

            if (!fallbackThing) {
                fallbackThing = thing;
            }
        }

        return fallbackThing;
    }

    function isDeviceLimitExceeded(thing) {
        switch (root.deviceTypeForThing(thing)) {
        case "evcharger":
            return evChargerThingsProxy.count > 1;
        case "heatpump":
            return heatPumpThingsProxy.count > 1;
        default:
            return false;
        }
    }

    function limitExceededTextForThing(thing) {
        switch (root.deviceTypeForThing(thing)) {
        case "evcharger":
            return root.evChargerLimitExceededText;
        case "heatpump":
            return root.heatPumpLimitExceededText;
        default:
            return "";
        }
    }

    function successThingFor(thing) {
        if (root.deviceTypeForThing(thing) !== "") {
            return thing;
        }

        if (!thing) {
            return null;
        }

        for (var i = 0; i < eebusChildThingsProxy.count; i++) {
            var childThing = eebusChildThingsProxy.get(i);
            if (!childThing || childThing.parentId.toString() !== thing.id.toString()) {
                continue;
            }

            // Only consider children added during this setup session
            if (d.knownEebusChildThingIds.indexOf(childThing.id.toString()) !== -1) {
                continue;
            }

            if (root.deviceTypeForThing(childThing) !== "") {
                return childThing;
            }
        }

        return thing;
    }

    function openOptimizationPage(thing) {
        var successThing = root.successThingFor(thing);
        var optimizationPage = null;

        switch (root.deviceTypeForThing(successThing)) {
        case "evcharger":
            optimizationPage = pageStack.push("../optimization/EvChargerOptimization.qml", {
                thing: successThing,
                directionID: 1
            });
            break;
        case "heatpump":
            optimizationPage = pageStack.push("../optimization/HeatingOptimization.qml", {
                heatingConfiguration: hemsManager.heatingConfigurations.getHeatingConfiguration(successThing.id),
                heatPumpThing: successThing,
                directionID: 1
            });
            break;
        case "solarinverter":
            optimizationPage = pageStack.push("../optimization/PVOptimization.qml", {
                pvConfiguration: hemsManager.pvConfigurations.getPvConfiguration(successThing.id),
                thing: successThing,
                directionID: 1
            });
            break;
        default:
            pageStack.pop(root);
            return;
        }

        optimizationPage.done.connect(function() {
            pageStack.pop(root);
        });
    }

    function limitExceededResultText(baseText, removalSucceeded) {
        if (removalSucceeded) {
            return qsTr("%1 The newly added EEBUS device has been removed again.").arg(baseText);
        }

        return qsTr("%1 The newly added EEBUS device could not be removed automatically. Please remove it manually.").arg(baseText);
    }

    signal done(bool skip, bool abort, bool back)

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
        property var knownEebusChildThingIds: []
        property string pendingGatewayThingId: ""
        property string pendingAddMessage: ""
        property string pendingLimitExceededMessage: ""
        property int pendingRemoveCommandId: -1

        function resetPendingSetup() {
            pendingThingTimer.stop();
            pendingThingTimer.retryCount = 0;
            d.pendingGatewayThingId = "";
            d.pendingAddMessage = "";
            d.pendingLimitExceededMessage = "";
            d.pendingRemoveCommandId = -1;
        }

        function showSetupResult(thingError, thing, message) {
            d.resetPendingSetup();
            pageStack.push(setupResultComponent, {thingError: thingError, thing: thing, message: message});
        }

        function handleAddedEebusThing(thing) {
            if (!thing || d.pendingRemoveCommandId !== -1) {
                return false;
            }

            pendingThingTimer.stop();
            pendingThingTimer.retryCount = 0;

            if (!root.isDeviceLimitExceeded(thing)) {
                d.showSetupResult(Thing.ThingErrorNoError, thing, d.pendingAddMessage);
                return true;
            }

            d.pendingLimitExceededMessage = root.limitExceededTextForThing(thing);
            busyOverlay.shown = true;
            d.pendingRemoveCommandId = engine.thingManager.removeThing(thing.isChild ? thing.parentId : thing.id);
            return true;
        }
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

    ThingsProxy {
        id: evChargerThingsProxy
        engine: _engine
        shownInterfaces: ["evcharger"]
    }

    ThingsProxy {
        id: heatPumpThingsProxy
        engine: _engine
        shownInterfaces: ["heatpump", "smartgridheatpump", "simpleheatpump", "pvsurplusheatpump"]
    }

    StackView {
        id: internalPageStack
        anchors.fill: parent
    }

    Timer {
        id: pendingThingTimer
        interval: 200
        repeat: true
        running: false

        property int retryCount: 0

        onTriggered: {
            var newThing = root.findNewEebusChildThing();
            if (d.handleAddedEebusThing(newThing)) {
                return;
            }

            retryCount += 1;
            if (retryCount >= 20) {
                var gatewayThing = d.pendingGatewayThingId !== "" ? engine.thingManager.things.getThing(d.pendingGatewayThingId) : null;
                d.showSetupResult(Thing.ThingErrorNoError, gatewayThing, d.pendingAddMessage);
            }
        }
    }

    Connections {
        target: engine.thingManager

        onAddThingReply: function(commandId, thingError, thingId, displayMessage) {
            busyOverlay.shown = false;
            if (thingError !== Thing.ThingErrorNoError) {
                var thing = engine.thingManager.things.getThing(thingId);
                d.showSetupResult(thingError, thing, displayMessage);
                return;
            }

            d.pendingGatewayThingId = thingId.toString();
            d.pendingAddMessage = displayMessage;

            if (!d.handleAddedEebusThing(root.findNewEebusChildThing())) {
                pendingThingTimer.retryCount = 0;
                pendingThingTimer.start();
            }
        }

        onThingAdded: function(thing) {
            if (d.pendingGatewayThingId === "" || !thing) {
                return;
            }

            if (thing.parentId.toString() !== d.pendingGatewayThingId || root.eebusChildThingClassIds.indexOf(thing.thingClassId.toString()) === -1) {
                return;
            }

            d.handleAddedEebusThing(root.findNewEebusChildThing());
        }

        onRemoveThingReply: function(commandId, thingError, ruleIds) {
            if (commandId !== d.pendingRemoveCommandId) {
                return;
            }

            busyOverlay.shown = false;

            if (thingError === Thing.ThingErrorNoError) {
                d.showSetupResult(Thing.ThingErrorSetupFailed, null, root.limitExceededResultText(d.pendingLimitExceededMessage, true));
                return;
            }

            d.showSetupResult(
                Thing.ThingErrorSetupFailed,
                null,
                root.limitExceededResultText(d.pendingLimitExceededMessage, false)
            );
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.margins
        spacing: Style.margins

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
                        pageStack.push(discoveryPage, {thingClass: thingClass});
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
            secondary: true
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
                onBackPressed: pageStack.pop()
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

            title: qsTr("Set up %1").arg(thingClass ? thingClass.displayName : "")
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
                    d.resetPendingSetup();
                    d.knownEebusChildThingIds = root.currentEebusChildThingIds();

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

    // Component: Setup result page
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

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: setupResultPage.thingError == Thing.ThingErrorNoError
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
                        text: thing ? thing.name : ""
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

                Label {
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    wrapMode: Text.WordWrap
                    text: setupResultPage.message !== "" ? setupResultPage.message : qsTr("An error occurred while setting up the EEBUS device. Please try again.")
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
                            if (setupResultPage.thingError == Thing.ThingErrorNoError) {
                                root.openOptimizationPage(thing);
                            } else {
                                pageStack.pop(root);
                            }
                        }
                    }
                }
            }
        }
    }
}
