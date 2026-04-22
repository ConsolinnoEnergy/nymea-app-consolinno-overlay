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

    header: NymeaHeader {
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

    StackView {
        id: internalPageStack
        anchors.fill: parent
    }

    Connections {
        target: engine.thingManager

        onAddThingReply: function(commandId, thingError, thingId, displayMessage) {
            busyOverlay.shown = false;
            var thing = engine.thingManager.things.getThing(thingId);
            pageStack.push(setupResultComponent, {thingError: thingError, thing: thing, message: displayMessage});
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

            header: NymeaHeader {
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

    // Component: Setup result page
    Component {
        id: setupResultComponent

        Page {
            id: setupResultPage

            property int thingError: Thing.ThingErrorNoError
            property Thing thing: null
            property string message: ""

            header: NymeaHeader {
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
                            // Pop back to the main EEBUS setup page
                            pageStack.pop(root);
                        }
                    }
                }
            }
        }
    }
}
