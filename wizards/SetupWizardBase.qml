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

    // Required properties to be set by derived wizards
    property string headerTitle: ""
    property string filterInterface: ""
    property var shownInterfaces: []  // For ThingsProxy - can be array like ["heatpump", "smartgridheatpump"]
    property string deviceIcon: ""
    property string emptyListText: ""
    property string addDeviceLabel: ""
    property string integratedDevicesLabel: ""
    property string successMessage: ""
    property string errorMessage: ""
    property string limitPopupText: ""
    property int deviceLimit: 1  // 0 means unlimited
    property bool supportsPairing: false  // SolarInverter needs pairing support

    // Optional: custom success handler (e.g., SolarInverter pushes PVOptimization)
    property var onSuccessHandler: null

    // Signals
    signal done(bool skip, bool abort, bool back)
    signal countChanged()

    header: NymeaHeader {
        text: root.headerTitle
        backButtonVisible: true
        onBackPressed: root.done(false, false, true)
    }
    background: Item {}

    // Internal state object
    QtObject {
        id: d
        property var vendorId: null
        property ThingDescriptor thingDescriptor: null
        property var discoveryParams: []
        property string thingName: ""
        property int pairRequestId: 0
        property var pairingTransactionId: null
        property int addRequestId: 0
        property var name: ""
        property var params: []
        property var thing: null

        function pairThing(thingClass, thing) {
            d.thing = thing

            switch (thingClass.setupMethod) {
            // Just Add
            case 0:
                if (thing) {
                    if (d.thingDescriptor) {
                        engine.thingManager.reconfigureDiscoveredThing(d.thingDescriptor.id, params);
                    } else {
                        engine.thingManager.reconfigureThing(thing.id, params);
                    }
                } else {
                    if (d.thingDescriptor) {
                        engine.thingManager.addDiscoveredThing(thingClass.id, d.thingDescriptor.id, d.name, params);
                    } else {
                        engine.thingManager.addThing(thingClass.id, d.name, params);
                    }
                }
                break;
            case 1: // DisplayPin
            case 2: // EnterPin
            case 3: // PushButton
            case 4: // OAuth
            case 5: // User and Password
                if (root.supportsPairing) {
                    if (thing) {
                        if (d.thingDescriptor) {
                            engine.thingManager.pairDiscoveredThing(d.thingDescriptor.id, params, d.name);
                        } else {
                            engine.thingManager.rePairThing(thing.id, params, d.name);
                        }
                        return;
                    } else {
                        if (d.thingDescriptor) {
                            engine.thingManager.pairDiscoveredThing(d.thingDescriptor.id, params, d.name);
                        } else {
                            engine.thingManager.pairThing(thingClass.id, params, d.name);
                        }
                    }
                }
                break;
            }

            busyOverlay.shown = true;
        }
    }

    ThingDiscovery {
        id: discovery
        engine: _engine
    }

    StackView {
        id: internalPageStack
        anchors.fill: parent
    }

    Connections {
        target: engine.thingManager

        onAddThingReply: function(commandId, thingError, thingId, displayMessage) {
            busyOverlay.shown = false;
            root.countChanged();
            var thing = engine.thingManager.things.getThing(thingId);
            pageStack.push(setupResultComponent, {thingError: thingError, thing: thing, message: displayMessage});
        }

        onConfirmPairingReply: function(commandId, thingError, thingId, displayMessage) {
            if (!root.supportsPairing) return;
            busyOverlay.shown = false;
            pageStack.push(resultsPage, {thingError: thingError, thingId: thingId, message: displayMessage});
        }

        onPairThingReply: function(commandId, thingError, pairingTransactionId, setupMethod, displayMessage, oAuthUrl) {
            if (!root.supportsPairing) return;
            busyOverlay.shown = false;
            if (thingError !== Thing.ThingErrorNoError) {
                busyOverlay.shown = false;
                pageStack.push(resultsPage, {thingError: thingError, message: displayMessage});
                return;
            }

            d.pairingTransactionId = pairingTransactionId;

            switch (setupMethod) {
            case "SetupMethodPushButton":
            case "SetupMethodDisplayPin":
            case "SetupMethodEnterPin":
            case "SetupMethodUserAndPassword":
                pageStack.push(pairingPageComponent, {thing: d.thing, transactionId: pairingTransactionId, text: displayMessage, setupMethod: setupMethod});
                break;
            case "SetupMethodOAuth":
                pageStack.push(oAuthPageComponent, {oAuthUrl: oAuthUrl});
                break;
            default:
                print("Setup method reply not handled:", setupMethod);
            }
        }
    }

    // Main content layout
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.margins
        spacing: Style.margins

        CoFrostyCard {
            Layout.fillWidth: true
            contentTopMargin: Style.margins
            headerText: root.integratedDevicesLabel

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
                    visible: deviceProxy.count !== 0

                    Layout.preferredHeight: Math.min(deviceList.implicitHeight, app.height / 3)
                    flickableDirection: Flickable.VerticalFlick

                    ColumnLayout {
                        id: deviceList
                        width: parent.width
                        spacing: 0

                        Repeater {
                            id: deviceRepeater
                            Layout.fillWidth: true
                            model: ThingsProxy {
                                id: deviceProxy
                                engine: _engine
                                shownInterfaces: root.shownInterfaces.length > 0 ? root.shownInterfaces : [root.filterInterface]
                            }
                            delegate: CoCard {
                                Layout.fillWidth: true
                                text: deviceProxy.get(index) ? deviceProxy.get(index).name : ""
                                iconLeft: Qt.resolvedUrl(root.deviceIcon)
                                interactive: false
                            }
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    Layout.preferredHeight: app.height / 6
                    visible: deviceProxy.count === 0
                    text: root.emptyListText
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                }
            }
        }

        CoFrostyCard {
            Layout.fillWidth: true
            contentTopMargin: 8
            headerText: root.addDeviceLabel
            visible: root.deviceLimit > 0 ? deviceRepeater.model.count < root.deviceLimit : true

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                CoComboBox {
                    id: thingClassComboBox
                    Layout.fillWidth: true
                    labelText: qsTr("Please select your model:")
                    textRole: "displayName"
                    valueRole: "id"
                    model: ThingClassesProxy {
                        engine: _engine
                        filterInterface: root.filterInterface
                        includeProvidedInterfaces: true
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: Style.margins
                    Layout.rightMargin: Style.margins
                    text: qsTr("Add")
                    onClicked: {
                        if (root.deviceLimit > 0 && deviceRepeater.model.count >= root.deviceLimit) {
                            deviceLimitPopup.open();
                            return;
                        }
                        internalPageStack.push(creatingMethodDecider, {thingClassId: thingClassComboBox.currentValue});
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Popup {
            id: deviceLimitPopup
            parent: Overlay.overlay
            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 2)
            width: parent.width
            height: 100
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            contentItem: Label {
                Layout.fillWidth: true
                Layout.topMargin: app.margins
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                wrapMode: Text.WordWrap
                text: root.limitPopupText
            }
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Next step")
            onClicked: root.done(true, false, false)
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Cancel")
            secondary: true
            onClicked: root.done(false, true, false)
        }
    }

    // Component: Decide creation method based on thingClass
    Component {
        id: creatingMethodDecider

        Page {
            id: deciderPage

            property var thingClassId
            property var thingClass: engine.thingManager.thingClasses.getThingClass(thingClassId)
            property var thing: null

            Component.onCompleted: {
                // If discovery and user: Always Discovery
                if (thingClass.createMethods.indexOf("CreateMethodDiscovery") !== -1) {
                    if (thingClass["discoveryParamTypes"].count > 0) {
                        // ThingDiscovery with discoveryParams
                        pageStack.push(discoveryParamsPage, {thingClass: thingClass});
                    } else {
                        // ThingDiscovery without discoveryParams
                        pageStack.push(discoveryPage, {thingClass: thingClass});
                        discovery.discoverThings(thingClass.id);
                    }
                } else if (thingClass.createMethods.indexOf("CreateMethodUser") !== -1) {
                    pageStack.push(paramsPage, {thingClass: thingClass});
                }
            }
        }
    }

    // Component: Discovery params page
    Component {
        id: discoveryParamsPage

        SettingsPageBase {
            id: discoveryParamsView

            property ThingClass thingClass

            title: qsTr("Discover %1").arg(thingClass.displayName)

            CoFrostyCard {
                Layout.fillWidth: true
                Layout.topMargin: Style.margins
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                contentTopMargin: Style.margins
                headerText: qsTr("Discovery options")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    Repeater {
                        id: paramRepeater
                        model: thingClass ? thingClass.discoveryParamTypes : null
                        delegate: ParamDelegate {
                            Layout.fillWidth: true
                            paramType: thingClass.discoveryParamTypes.get(index)
                        }
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.topMargin: Style.margins
                        text: qsTr("Next")
                        onClicked: {
                            var paramTypes = thingClass.discoveryParamTypes;
                            d.discoveryParams = [];
                            for (var i = 0; i < paramTypes.count; i++) {
                                var param = {};
                                param["paramTypeId"] = paramTypes.get(i).id;
                                param["value"] = paramRepeater.itemAt(i).value;
                                d.discoveryParams.push(param);
                            }
                            discovery.discoverThings(thingClass.id, d.discoveryParams);
                            pageStack.push(discoveryPage, {thingClass: thingClass});
                        }
                    }
                }
            }
        }
    }

    // Component: Discovery page
    Component {
        id: discoveryPage

        SettingsPageBase {
            id: discoveryView

            property ThingClass thingClass
            property Thing thing

            header: NymeaHeader {
                text: qsTr("Discover %1").arg(thingClass.displayName)
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
                            showAlreadyAdded: thing !== null
                            showNew: thing === null
                        }

                        delegate: CoCard {
                            Layout.fillWidth: true
                            text: model.name
                            helpText: model.description
                            iconLeft: root.deviceIcon !== "" ? Qt.resolvedUrl(root.deviceIcon) : app.interfacesToIcon(discoveryView.thingClass.interfaces)
                            showChildrenIndicator: true

                            onClicked: {
                                d.thingDescriptor = discoveryProxy.get(index);
                                d.thingName = model.name;
                                pageStack.push(paramsPage, {thingClass: thingClass, thing: thing});
                            }
                        }
                    }
                }
            }

            busy: discovery.busy
            busyText: qsTr("Searching for things...")

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
                    text: qsTr("No device was found. Please check if you have selected the correct type and if the device is connected to the correct port and go to 'Search again'.")
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
                    discovery.discoverThings(thingClass.id, d.discoveryParams);
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

            property Thing thing
            property ThingClass thingClass

            title: thing ? qsTr("Reconfigure %1").arg(thing.name) : qsTr("Set up %1").arg(thingClass.displayName)

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
                        text: (d.thingName ?
                                   d.thingName :
                                   thingClass.displayName)
                              + (thingClass.id.toString().match(/\{?f0dd4c03-0aca-42cc-8f34-9902457b05de\}?/) ?
                                     " (" + PlatformHelper.machineHostname + ")" :
                                     "")
                        labelText: qsTr("Please change name if necessary")
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
                                   thingClass.paramTypes :
                                   null
                        delegate: ParamDelegate {
                            Layout.fillWidth: true
                            enabled: !model.readOnly
                            paramType: thingClass.paramTypes.get(index)
                            value: {
                                // Discovery: use params from discovered descriptor
                                if (d.thingDescriptor && d.thingDescriptor.params.getParam(paramType.id)) {
                                    return d.thingDescriptor.params.getParam(paramType.id).value
                                }
                                // Manual setup: use default value from thing class
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
                            print("adding param", param.paramTypeId, param.value);
                            params.push(param);
                        }
                    }
                    d.params = params;
                    d.name = nameTextField.text;
                    d.pairThing(thingClass, thing);
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

            header: NymeaHeader {
                text: root.headerTitle
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
                        text: root.successMessage
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
                    text: root.errorMessage
                    visible: setupResultPage.thingError != Thing.ThingErrorNoError
                }

                ColumnLayout {
                    spacing: 0
                    Layout.alignment: Qt.AlignHCenter

                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 200
                        text: qsTr("Next")
                        onClicked: {
                            if (root.onSuccessHandler && thing) {
                                root.onSuccessHandler(thing);
                            } else {
                                root.done(false, false, false);
                            }
                        }
                    }
                }
            }
        }
    }

    // Component: Pairing page (for devices that need authentication)
    Component {
        id: pairingPageComponent

        SettingsPageBase {
            id: pairingPage

            property var thing
            property var transactionId
            property alias text: textLabel.text
            property string setupMethod

            title: qsTr("Reconfigure %1").arg(d.thingName)

            CoFrostyCard {
                Layout.fillWidth: true
                Layout.topMargin: Style.margins
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                contentTopMargin: Style.margins
                headerText: qsTr("Login required")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: Style.smallMargins

                    Label {
                        id: textLabel
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }

                    CoInputField {
                        id: usernameTextField
                        Layout.fillWidth: true
                        textField.placeholderText: qsTr("Username")
                        labelText: qsTr("Username")
                        visible: pairingPage.setupMethod === "SetupMethodUserAndPassword"
                    }

                    ConsolinnoPasswordTextField {
                        id: pinTextField
                        Layout.fillWidth: true
                        visible: pairingPage.setupMethod === "SetupMethodDisplayPin" || pairingPage.setupMethod === "SetupMethodEnterPin" || pairingPage.setupMethod === "SetupMethodUserAndPassword"
                        signup: false
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.topMargin: Style.margins
                        text: qsTr("OK")
                        onClicked: {
                            engine.thingManager.confirmPairing(transactionId, pinTextField.password, usernameTextField.text);
                            busyOverlay.shown = true;
                        }
                    }
                }
            }
        }
    }

    // Component: Results page (for pairing flow)
    Component {
        id: resultsPage

        Page {
            id: resultsView

            property string thingId
            property int thingError
            property string message

            readonly property bool success: thingError === Thing.ThingErrorNoError
            readonly property Thing thing: engine.thingManager.things.getThing(thingId)

            header: NymeaHeader {
                text: qsTr("Reconfigure %1").arg(d.thingName)
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
                    text: resultsView.success ? qsTr("Thing added!") : qsTr("Uh oh")
                    font.pixelSize: app.largeFont
                    color: Style.accentColor
                }

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: resultsView.success ? qsTr("All done. You can now start using %1.").arg(resultsView.thing ? resultsView.thing.name : "") : qsTr("Something went wrong setting up this thing...")
                }

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: resultsView.message
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    visible: !resultsView.success
                    text: qsTr("Retry")
                    onClicked: {
                        d.pairThing();
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: qsTr("Ok")
                    onClicked: {
                        if (root.onSuccessHandler && resultsView.thing) {
                            root.onSuccessHandler(resultsView.thing);
                        } else {
                            root.done(false, false, false);
                        }
                    }
                }
            }
        }
    }

    // Component: OAuth page (placeholder for OAuth flow)
    Component {
        id: oAuthPageComponent

        Page {
            property string oAuthUrl

            header: NymeaHeader {
                text: qsTr("OAuth Authentication")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            // OAuth implementation would go here
            // For now, just a placeholder
            Label {
                anchors.centerIn: parent
                text: qsTr("Please complete authentication in your browser")
            }
        }
    }
}
