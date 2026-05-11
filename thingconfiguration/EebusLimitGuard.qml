import QtQuick
import QtQuick.Controls
import Nymea 1.0

import "../components"

// Non-visual component that enforces per-type device-count limits for EEBUS
// things. Instantiate once globally (e.g. in RootItem) alongside HemsManager.
//
// Whenever a new EEBUS child thing (Wallbox, Wärmepumpe, …) is added, this
// guard checks whether its type (evcharger, heatpump) exceeds the allowed
// count. If the limit is exceeded it removes the newly added gateway (and its
// child) and shows an error dialog. If the limit is not exceeded it emits
// eebusChildThingAdded(thing) so that the active setup flow can navigate to
// the matching optimization screen.
Item {
    id: root

    required property var engine

    // Emitted when an EEBUS child thing was added and is within the limit.
    signal eebusChildThingAdded(var thing)

    // Emitted after the limit-exceeded dialog has been closed (removal was
    // already attempted before the dialog appeared).
    signal eebusLimitExceeded()

    visible: false
    width: 0
    height: 0

    // EEBUS child thing class IDs (auto-created as children of the gateway)
    readonly property var eebusChildThingClassIds: [
        "{15e6bb51-ef91-4668-9f6f-a43413d4ee4b}",  // EEBus Wallbox (EVSE)
        "{a6273bc4-6ee4-4b76-ba20-edb3c054f158}",  // EEBus Heatpump
        "{7c29d23d-d98b-46fd-b941-39a585159fbe}",  // EEBus Inverter
        "{f84f7c28-04cc-4da5-8564-402a9361b136}"   // EEBus GridGuard
    ]

    function deviceTypeForThing(thing) {
        if (!thing || !thing.thingClass) return "";
        var ifaces = thing.thingClass.interfaces;
        if (ifaces.indexOf("evcharger") !== -1) return "evcharger";
        if (["heatpump", "smartgridheatpump", "simpleheatpump", "pvsurplusheatpump"].some(i => ifaces.indexOf(i) !== -1)) return "heatpump";
        if (ifaces.indexOf("solarinverter") !== -1) return "solarinverter";
        return "";
    }

    // Returns a non-empty message when adding this thing would violate the limit.
    function limitExceededMessageForThing(thing) {
        switch (deviceTypeForThing(thing)) {
        case "evcharger":
            return evChargerProxy.count > 1
                ? qsTr("At the moment, %1 can only control one EV charger. Support for multiple EV chargers is planned for future releases.").arg(Configuration.deviceName)
                : "";
        case "heatpump":
            return heatPumpProxy.count > 1
                ? qsTr("At the moment, %1 can only control one heat pump. Support for multiple heat pumps is planned for future releases.").arg(Configuration.deviceName)
                : "";
        default:
            return "";
        }
    }

    QtObject {
        id: d
        property int pendingRemoveCommandId: -1
        property string pendingLimitMessage: ""
    }

    ThingsProxy {
        id: evChargerProxy
        engine: root.engine
        shownInterfaces: ["evcharger"]
    }

    ThingsProxy {
        id: heatPumpProxy
        engine: root.engine
        shownInterfaces: ["heatpump", "smartgridheatpump", "simpleheatpump", "pvsurplusheatpump"]
    }

    Connections {
        target: root.engine.thingManager

        onThingAdded: function(thing) {
            if (!thing) return;
            if (root.eebusChildThingClassIds.indexOf(thing.thingClassId.toString()) === -1) return;
            if (root.deviceTypeForThing(thing) === "") return;

            var limitMsg = root.limitExceededMessageForThing(thing);
            if (limitMsg === "") {
                root.eebusChildThingAdded(thing);
                return;
            }

            d.pendingLimitMessage = limitMsg;
            d.pendingRemoveCommandId = root.engine.thingManager.removeThing(thing.isChild ? thing.parentId : thing.id);
        }

        onRemoveThingReply: function(commandId, thingError, ruleIds) {
            if (commandId !== d.pendingRemoveCommandId) return;
            d.pendingRemoveCommandId = -1;
            var succeeded = thingError === Thing.ThingErrorNoError;
            limitDialog.messageText = succeeded
                ? qsTr("%1 The newly added EEBUS device has been removed again.").arg(d.pendingLimitMessage)
                : qsTr("%1 The newly added EEBUS device could not be removed automatically. Please remove it manually.").arg(d.pendingLimitMessage);
            limitDialog.open();
        }
    }

    Dialog {
        id: limitDialog
        property string messageText: ""
        parent: Overlay.overlay
        anchors.centerIn: parent
        margins: Style.margins
        modal: true
        standardButtons: Dialog.Ok
        onClosed: root.eebusLimitExceeded()

        Label {
            anchors.fill: parent
            text: limitDialog.messageText
            wrapMode: Text.WordWrap
        }
    }
}
