import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtCore
import Nymea 1.0
import "../components"
import "../delegates"

StackView {
    id: root
    initialItem: setUpStart

    property int directionID: 0
    property Thing gridSupportThing: gridSupport.get(0)
    property Thing eebusGridGuardGateway: null
    property ThingClass genericEebusDeviceThingClass: engine.thingManager.thingClasses.getThingClass("d7448dd7-cafc-4ef7-9169-09ea657f755c")
    property string powerLimitSource: gridSupportThing.settings.getParam("e3f9a1e4-5f20-4b6b-9c6f-bf0f4ad7b74b").value
    property bool eebusConnectedState: eebusGridGuardGateway ? eebusGridGuardGateway.stateByName("connected").value : false
    property Thing eebusInformationThing: eebusInformationThings.count > 0 ? eebusInformationThings.get(0) : null

    property bool currentStateLPC: gridSupportThing.stateByName("isLpcActive").value
    property bool currentStateLPP: gridSupportThing.stateByName("isLppActive").value
    property double powerLimitLPC: gridSupportThing.stateByName("lpcValue").value
    property double powerLimitLPP: gridSupportThing.stateByName("lppValue").value
    property string contentPlimLPP: currentStateLPP === true ? qsTr("The feed-in is <b>limited temporarily</b> to <b>%1 kW</b> due to a control command from the grid operator.").arg(convertToKw(powerLimitLPP)) : ""
    property string contentPlim: currentStateLPC === true ? qsTr("Due to a control order from the network operator, the total power of controllable devices is <b>temporarily limited</b> to <b>%1 kW.</b> If, for example, you are currently charging your electric car, the charging process may not be carried out at the usual power level.").arg(convertToKw(powerLimitLPC)) : ""


    Settings {
        id: eebusSettings
        property bool connected: false
        property bool everConnected: false
    }

    Component.onCompleted: {
        updateEebusThing();

        eebusSettings.connected = eebusConnectedState;
        if (eebusConnectedState && !eebusSettings.everConnected) {
            eebusSettings.everConnected = true;
        }
    }

    function updateEebusThing() {
        if (eebusGridGuardThings.count === 0) {
            eebusGridGuardGateway = null;
            return;
        }

        if (eebusGridGuardThings.count > 1) {
            console.warn("More than one EEBus Grid Guard things are configured!");
        }
        const eebusGridGuardThing = eebusGridGuardThings.get(0);
        eebusGridGuardGateway = engine.thingManager.things.getThing(eebusGridGuardThing.parentId);
    }

    ThingsProxy {
        id: eebusGridGuardThings
        engine: _engine
        shownThingClassIds: ["f84f7c28-04cc-4da5-8564-402a9361b136"] // "EEBus Grid Guard" thing class ID
        Component.onCompleted: countChanged.connect(updateEebusThing)
    }

    QtObject {
        id: d
        property int pendingCallId: -1
        property var params: []
    }

    Connections {
        target: engine.thingManager
        onAddThingReply: function(commandId, thingError, thingId, displayMessage) {
            updateEebusThing();
        }
        onRemoveThingReply: function(commandId, thingError, ruleIds) {
            updateEebusThing();
        }
    }

    ThingDiscovery {
        id: discovery
        engine: _engine
    }

    function convertToKw(numberW){
        return (+(Math.round((numberW / 1000) * 100 ) / 100)).toLocaleString()
    }

    ThingsProxy {
        id: gridSupport
        engine: _engine
        shownInterfaces: ["gridsupport"]
    }

    ThingsProxy {
        id: eebusInformationThings
        engine: _engine
        shownThingClassIds: [ "f5f3c387-2482-4154-99ee-7a473f6d81e9" ]
    }

    function setGridSupportSettings(param){
        var setting = {};
        setting["paramTypeId"] = "e3f9a1e4-5f20-4b6b-9c6f-bf0f4ad7b74b";
        setting["value"] = param;
        var settings = [];
        settings.push(setting);
        engine.thingManager.setThingSettings(gridSupportThing.id, settings);
    }

    Component {
        id: setUpStart

        Page {
            header: CoHeader {
                text: qsTr("Grid-supportive control")
                backButtonVisible: true
                onBackPressed:{
                    if (directionID == 0)
                    {
                        pageStack.pop()
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                CoNotification {
                    Layout.fillWidth: true
                    visible: currentStateLPP === true && powerLimitSource !== "none"
                    type: CoNotification.Type.Warning
                    title: qsTr("Feed-in curtailment")
                    message: contentPlimLPP
                }

                CoNotification {
                    Layout.fillWidth: true
                    visible: currentStateLPC === true && powerLimitSource !== "none"
                    type: CoNotification.Type.Warning
                    title: qsTr("Grid-supportive control")
                    message: contentPlim
                }

                CoFrostyCard {
                    Layout.fillWidth: true
                    contentTopMargin: Style.margins
                    headerText: qsTr("Control box connection")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoCard {
                            id: startRelaisCard
                            Layout.fillWidth: true
                            visible: powerLimitSource === "relais"
                            text: qsTr("Relais")
                            iconLeft: Qt.resolvedUrl("/ui/images/relais.svg")
                            showChildrenIndicator: true
                            onClicked: {
                                pageStack.push(relaisSetUpFinish);
                            }
                        }

                        CoCard {
                            id: startEebusCard
                            Layout.fillWidth: true
                            visible: powerLimitSource === "eebus"
                            text: qsTr("EEBUS")
                            iconLeft: Qt.resolvedUrl("/ui/images/eebus.svg")
                            showChildrenIndicator: true
                            onClicked: {
                                if (eebusGridGuardGateway) {
                                    pageStack.push(eebusView);
                                } else {
                                    pageStack.push(eebusComfortPairingView);
                                }
                            }
                        }

                        CoCard {
                            Layout.fillWidth: true
                            visible: !startRelaisCard.visible && !startEebusCard.visible
                            text: "—"
                            interactive: false
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Button {
                    id: setUpButton
                    Layout.fillWidth: true
                    text: qsTr("Grid-supportive control setup")
                    onClicked: {
                        pageStack.push(selectComponent)
                    }
                }
            }
        }
    }

    //set-up select
    Component {
        id: selectComponent

        Page {
            header: CoHeader {
                text: qsTr("Grid-supportive control setup")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                CoFrostyCard {
                    Layout.fillWidth: true
                    contentTopMargin: Style.margins
                    headerText: qsTr("Control box connection")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoCard {
                            Layout.fillWidth: true
                            text: qsTr("Relais")
                            iconLeft: Qt.resolvedUrl("/ui/images/relais.svg")
                            showChildrenIndicator: true
                            onClicked: {
                                pageStack.push(relaisSetUp)
                            }
                        }

                        CoCard {
                            Layout.fillWidth: true
                            text: qsTr("EEBUS SKI Pairing")
                            labelText: qsTr("Must be in same network.")
                            iconLeft: Qt.resolvedUrl("/ui/images/eebus.svg")
                            showChildrenIndicator: true
                            enabled: genericEebusDeviceThingClass !== null
                            onClicked: {
                                discovery.discoverThings(genericEebusDeviceThingClass.id);
                                pageStack.push(eebusViewSelect,
                                               { thingClass: genericEebusDeviceThingClass });
                            }
                        }

                        CoCard {
                            Layout.fillWidth: true
                            text: qsTr("EEBUS Comfort Pairing")
                            iconLeft: Qt.resolvedUrl("/ui/images/eebus.svg")
                            showChildrenIndicator: true
                            onClicked: {
                                pageStack.push(eebusComfortPairingSetup);
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }

    Component {
        id: relaisSetUp

        Page {
            header: CoHeader {
                text: qsTr("Grid-supportive control setup")
                subText: qsTr("Relais")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                CoNotification {
                    Layout.fillWidth: true
                    visible: powerLimitSource === "relais" || powerLimitSource === "eebus"
                    type: CoNotification.Type.Danger
                    title: qsTr("Attention")
                    message: qsTr("Existing setup will be overwritten.")
                }

                CoFrostyCard {
                    Layout.fillWidth: true
                    contentTopMargin: Style.margins
                    headerText: qsTr("Connect device")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoCard {
                            Layout.fillWidth: true
                            text: qsTr("Please connect the control box or the ripple control receiver as described in our manual.")
                            interactive: false
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Complete setup")

                    onClicked: {
                        root.setGridSupportSettings("relais");
                        pageStack.pop();
                        pageStack.pop();
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Cancel")
                    flat: true

                    onClicked: {
                        pageStack.pop();
                        pageStack.pop();
                    }
                }
            }
        }
    }

    Component {
        id: relaisSetUpFinish

        Page {
            header: CoHeader {
                text: qsTr("Grid-supportive control")
                subText: qsTr("Relais")
                backButtonVisible: true
                menuButtonVisible: true
                onBackPressed: pageStack.pop()
                onMenuPressed: menu.open()
            }

            ListModel {
                id: menuListModel

                ListElement {
                    icon: "/icons/delete_forever.svg"
                    text: qsTr("Delete")
                }

                ListElement {
                    icon: "/icons/tune.svg"
                    text: qsTr("Reconfigure")
                }
            }

            Menu {
                id: menu
                x: root.width - width - Style.margins
                modal: true

                Repeater {
                    id: menuListRepeater
                    model: menuListModel

                    Item {
                        width: menuItemLayout.implicitWidth + Style.margins
                        height: 40

                        RowLayout {
                            id: menuItemLayout
                            anchors {
                                left: parent.left
                                right: parent.right
                                leftMargin: 16
                                rightMargin: 16
                            }

                            height: parent.height / 2
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Style.margins

                            ColorIcon {
                                Layout.fillHeight: false
                                Layout.fillWidth: false
                                Layout.preferredHeight: 24
                                Layout.preferredWidth: 24
                                source: model.icon
                            }

                            Label {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                text: model.text
                                font.pixelSize: app.mediumFont
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (index === 0) {
                                    root.setGridSupportSettings("none");
                                    pageStack.pop();
                                } else if (index === 1) {
                                    pageStack.push(relaisSetUp);
                                }
                                menu.close();
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                CoFrostyCard {
                    Layout.fillWidth: true
                    contentTopMargin: Style.margins
                    headerText: qsTr("Device connection")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoCard {
                            Layout.fillWidth: true
                            text: qsTr("The control box or the ripple control receiver must be connected as described in our manual.")
                            interactive: false
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }

    Component {
        id: eebusComfortPairingSetup

        Page {
            header: CoHeader {
                text: qsTr("Grid-supportive control setup")
                subText: qsTr("EEBUS Comfort Pairing")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                CoNotification {
                    Layout.fillWidth: true
                    visible: powerLimitSource === "relais" || powerLimitSource === "eebus"
                    type: CoNotification.Type.Danger
                    title: qsTr("Attention")
                    message: qsTr("Existing setup will be overwritten.")
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: eebusParameterContent.implicitHeight
                    clip: true

                    ColumnLayout {
                        id: eebusParameterContent
                        width: parent.width
                        spacing: Style.margins

                        CoFrostyCard {
                            Layout.fillWidth: true
                            contentTopMargin: Style.margins
                            headerText: qsTr("QR Code & Pairing Data")

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 0
                                visible: eebusInformationThing === null

                                CoCard {
                                    Layout.fillWidth: true
                                    interactive: false
                                    text: qsTr("EEBUS Comfort Pairing data not available.")
                                }
                            }

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 0
                                visible: eebusInformationThing !== null

                                CoCard {
                                    Layout.fillWidth: true
                                    interactive: false
                                    text: qsTr("The QR code or the pairing data below must be used for SHIP pairing by the metering point operator.")
                                }

                                CoQrCode {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.topMargin: Style.margins
                                    Layout.bottomMargin: Style.margins
                                    content: eebusInformationThing ? eebusInformationThing.paramByName("localQrCode").value : ""
                                }

                                CoCard {
                                    Layout.fillWidth: true
                                    text: eebusInformationThing ? eebusInformationThing.paramByName("secret").value : "-"
                                    labelText: qsTr("Secret Key (SPSEC)")
                                    iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                                    onClicked: {
                                        PlatformHelper.toClipBoard(text);
                                        ToolTip.show(qsTr("%1 copied to clipboard").arg(labelText), 1000);
                                    }
                                }

                                CoCard {
                                    Layout.fillWidth: true
                                    text: eebusInformationThing ? eebusInformationThing.paramByName("localShipId").value : "-"
                                    labelText: qsTr("SHIP ID (ID)")
                                    iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                                    onClicked: {
                                        PlatformHelper.toClipBoard(text);
                                        ToolTip.show(qsTr("%1 copied to clipboard").arg(labelText), 1000);
                                    }
                                }

                                CoCard {
                                    Layout.fillWidth: true
                                    text: eebusInformationThing ? eebusInformationThing.paramByName("localFingerprint").value : "-"
                                    labelText: qsTr("Certificate Fingerprint (SHA-256)")
                                    iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                                    onClicked: {
                                        PlatformHelper.toClipBoard(text);
                                        ToolTip.show(qsTr("%1 copied to clipboard").arg(labelText), 1000);
                                    }
                                }
                            }
                        }
                    }
                }

                Button {
                    id: eebusSetUpComplete
                    Layout.fillWidth: true
                    text: qsTr("Complete setup")

                    onClicked: {
                        if (eebusGridGuardGateway) {
                            engine.thingManager.removeThing(eebusGridGuardGateway.id);
                        }
                        root.setGridSupportSettings("eebus");
                        pageStack.push(eebusComfortPairingViewStatus);
                    }
                }

                Button {
                    text: qsTr("Cancel")
                    Layout.fillWidth: true
                    flat: true
                    onClicked: {
                        pageStack.pop();
                        pageStack.pop();
                    }
                }
            }
        }
    }

    Component {
        id: eebusComfortPairingViewStatus

        Page {
            header: CoHeader {
                text: qsTr("Grid-supportive control setup")
                subText: qsTr("EEBUS Comfort Pairing")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: eebusParameterContent.implicitHeight
                    clip: true

                    ColumnLayout {
                        id: eebusParameterContent
                        width: parent.width
                        spacing: Style.margins

                        CoFrostyCard {
                            Layout.fillWidth: true
                            contentTopMargin: Style.margins
                            headerText: qsTr("QR Code & Pairing Data")

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 0
                                visible: eebusInformationThing === null

                                CoCard {
                                    Layout.fillWidth: true
                                    interactive: false
                                    text: qsTr("EEBUS Comfort Pairing data not available.")
                                }
                            }

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 0
                                visible: eebusInformationThing !== null

                                CoCard {
                                    Layout.fillWidth: true
                                    interactive: false
                                    text: qsTr("The QR code or the pairing data below must be used for SHIP pairing by the metering point operator.")
                                }

                                CoQrCode {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.topMargin: Style.margins
                                    Layout.bottomMargin: Style.margins
                                    content: eebusInformationThing ? eebusInformationThing.paramByName("localQrCode").value : ""
                                }

                                CoCard {
                                    Layout.fillWidth: true
                                    text: eebusInformationThing ? eebusInformationThing.paramByName("secret").value : "-"
                                    labelText: qsTr("Secret Key (SPSEC)")
                                    iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                                    onClicked: {
                                        PlatformHelper.toClipBoard(text);
                                        ToolTip.show(qsTr("%1 copied to clipboard").arg(labelText), 1000);
                                    }
                                }

                                CoCard {
                                    Layout.fillWidth: true
                                    text: eebusInformationThing ? eebusInformationThing.paramByName("localShipId").value : "-"
                                    labelText: qsTr("SHIP ID (ID)")
                                    iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                                    onClicked: {
                                        PlatformHelper.toClipBoard(text);
                                        ToolTip.show(qsTr("%1 copied to clipboard").arg(labelText), 1000);
                                    }
                                }

                                CoCard {
                                    Layout.fillWidth: true
                                    text: eebusInformationThing ? eebusInformationThing.paramByName("localFingerprint").value : "-"
                                    labelText: qsTr("Certificate Fingerprint (SHA-256)")
                                    iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                                    onClicked: {
                                        PlatformHelper.toClipBoard(text);
                                        ToolTip.show(qsTr("%1 copied to clipboard").arg(labelText), 1000);
                                    }
                                }
                            }
                        }

                        CoFrostyCard {
                            Layout.fillWidth: true
                            contentTopMargin: Style.margins
                            headerText: qsTr("Status")

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 0

                                CoCard {
                                    Layout.fillWidth: true
                                    text: qsTr("Completion by the metering point operator pending")
                                    interactive: false
                                    status: CoCard.StatusType.Warning
                                }
                            }
                        }
                    }
                }

                Button {
                    id: eebusBackToView
                    Layout.fillWidth: true
                    text: qsTr("Back to overview")

                    onClicked: {
                        pageStack.pop();
                        pageStack.pop();
                        pageStack.pop();
                    }
                }
            }
        }
    }

    Component {
        id: eebusComfortPairingView

        Page {
            header: CoHeader {
                text: qsTr("Grid-supportive control")
                subText: qsTr("EEBUS Comfort Pairing")
                backButtonVisible: true
                menuButtonVisible: true
                onBackPressed: pageStack.pop()
                onMenuPressed: eebusViewMenu.open()
            }

            ListModel {
                id: eebusViewMenuListModel

                ListElement {
                    icon: "/icons/delete_forever.svg"
                    text: qsTr("Delete")
                }
            }

            Menu {
                id: eebusViewMenu
                x: root.width - width - Style.margins
                modal: true

                Repeater {
                    id: eebusViewMenuListRepeater
                    model: eebusViewMenuListModel

                    Item {
                        width: menuItemLayout.implicitWidth + Style.margins
                        height: 40

                        RowLayout {
                            id: menuItemLayout
                            anchors {
                                left: parent.left
                                right: parent.right
                                leftMargin: 16
                                rightMargin: 16
                            }

                            height: parent.height / 2
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Style.margins

                            ColorIcon {
                                Layout.fillHeight: false
                                Layout.fillWidth: false
                                Layout.preferredHeight: 24
                                Layout.preferredWidth: 24
                                source: model.icon
                            }

                            Label {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                text: model.text
                                font.pixelSize: app.mediumFont
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (index === 0) {
                                    root.setGridSupportSettings("none");
                                    pageStack.pop();
                                }
                                eebusViewMenu.close();
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: eebusParameterContent.implicitHeight
                    clip: true

                    ColumnLayout {
                        id: eebusParameterContent
                        width: parent.width
                        spacing: Style.margins

                        CoFrostyCard {
                            Layout.fillWidth: true
                            contentTopMargin: Style.margins
                            headerText: qsTr("QR Code & Pairing Data")

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 0
                                visible: eebusInformationThing === null

                                CoCard {
                                    Layout.fillWidth: true
                                    interactive: false
                                    text: qsTr("EEBUS Comfort Pairing data not available.")
                                }
                            }

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 0
                                visible: eebusInformationThing !== null

                                CoCard {
                                    Layout.fillWidth: true
                                    interactive: false
                                    text: qsTr("The QR code or the pairing data below must be used for SHIP pairing by the metering point operator.")
                                }

                                CoQrCode {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.topMargin: Style.margins
                                    Layout.bottomMargin: Style.margins
                                    content: eebusInformationThing ? eebusInformationThing.paramByName("localQrCode").value : ""
                                }

                                CoCard {
                                    Layout.fillWidth: true
                                    text: eebusInformationThing ? eebusInformationThing.paramByName("secret").value : "-"
                                    labelText: qsTr("Secret Key (SPSEC)")
                                    iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                                    onClicked: {
                                        PlatformHelper.toClipBoard(text);
                                        ToolTip.show(qsTr("%1 copied to clipboard").arg(labelText), 1000);
                                    }
                                }

                                CoCard {
                                    Layout.fillWidth: true
                                    text: eebusInformationThing ? eebusInformationThing.paramByName("localShipId").value : "-"
                                    labelText: qsTr("SHIP ID (ID)")
                                    iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                                    onClicked: {
                                        PlatformHelper.toClipBoard(text);
                                        ToolTip.show(qsTr("%1 copied to clipboard").arg(labelText), 1000);
                                    }
                                }

                                CoCard {
                                    Layout.fillWidth: true
                                    text: eebusInformationThing ? eebusInformationThing.paramByName("localFingerprint").value : "-"
                                    labelText: qsTr("Certificate Fingerprint (SHA-256)")
                                    iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                                    onClicked: {
                                        PlatformHelper.toClipBoard(text);
                                        ToolTip.show(qsTr("%1 copied to clipboard").arg(labelText), 1000);
                                    }
                                }
                            }
                        }

                        CoFrostyCard {
                            Layout.fillWidth: true
                            contentTopMargin: Style.margins
                            headerText: qsTr("Status")

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 0

                                CoCard {
                                    Layout.fillWidth: true
                                    text: qsTr("Completion by the metering point operator pending")
                                    interactive: false
                                    status: CoCard.StatusType.Warning
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: eebusViewSelect

        Page {
            header: CoHeader {
                text: qsTr("Grid-supportive control setup")
                subText: qsTr("EEBUS SKI Pairing")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            property var thingClass

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: eebusDiscoveryContent.implicitHeight
                    clip: true

                    ColumnLayout {
                        id: eebusDiscoveryContent
                        width: parent.width
                        spacing: Style.margins

                        CoFrostyCard {
                            Layout.fillWidth: true
                            contentTopMargin: Style.margins
                            headerText: qsTr("The following EEBUS devices were found")

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 0

                                CoCard {
                                    Layout.fillWidth: true
                                    text: qsTr("No EEBUS device was found in the network. Please make sure the device is powered on and connected to the same network.")
                                    visible: !discovery.busy && eebusRepeater.model.count === 0
                                    interactive: false
                                }

                                Repeater {
                                    id: eebusRepeater

                                    model: ThingDiscoveryProxy {
                                        id: eebusDiscovery
                                        thingDiscovery: discovery
                                    }

                                    delegate: CoCard {
                                        Layout.fillWidth: true
                                        iconLeft: "/icons/connections/network-wired.svg"
                                        text: model.name
                                        labelText: model.description
                                        showChildrenIndicator: true
                                        onClicked: {
                                            pageStack.push(eebusSetup,
                                                           {
                                                               thingClass: genericEebusDeviceThingClass,
                                                               discoveryThingParams: eebusDiscovery.get(index)
                                                           });
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Search again")

                    onClicked: {
                        discovery.discoverThings(genericEebusDeviceThingClass.id);
                    }
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Cancel")
                    flat: true
                    onClicked: {
                        pageStack.pop();
                        pageStack.pop();
                    }
                }
            }

            BusyOverlay {
                shown: discovery.busy
                text: qsTr("Searching for devices...")
            }
        }
    }

    Component {
        id: eebusSetup

        Page {
            property ThingClass thingClass
            property var discoveryThingParams

            header: CoHeader {
                text: qsTr("Grid-supportive control setup")
                subText: qsTr("EEBUS SKI Pairing")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                CoNotification {
                    Layout.fillWidth: true
                    visible: powerLimitSource === "relais" || powerLimitSource === "eebus"
                    type: CoNotification.Type.Danger
                    title: qsTr("Attention")
                    message: qsTr("Existing setup will be overwritten.")
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: eebusParameterContent.implicitHeight
                    clip: true

                    ColumnLayout {
                        id: eebusParameterContent
                        width: parent.width
                        spacing: Style.margins

                        CoFrostyCard {
                            Layout.fillWidth: true
                            contentTopMargin: Style.margins
                            headerText: qsTr("Parameter")

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 0

                                Repeater {
                                    model: thingClass.paramTypes

                                    delegate: CoCard {
                                        Layout.fillWidth: true
                                        property var param: discoveryThingParams.params.getParam(thingClass.paramTypes.get(index).id)
                                        property string paramValue: param ? param.value : ""
                                        text: paramValue !== "" ? paramValue : "—"
                                        labelText: index === 0 ? qsTr("This SKI is required by the network operator.") : ""
                                        helpText: model.displayName
                                        iconRight: index === 0 ? "/icons/file_copy.svg" : ""
                                        iconRightColor: Style.colors.brand_Basic_Accent
                                        interactive: index === 0
                                        onClicked: {
                                            PlatformHelper.toClipBoard(paramValue);
                                            ToolTip.show(qsTr("SKI copied to clipboard"), 500);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                CheckBox {
                    id: deviceConnected
                    Layout.fillWidth: true
                    text: qsTr("Establish a connection with this device.")
                }

                Button {
                    id: eebusSetUpComplete
                    Layout.fillWidth: true
                    enabled: deviceConnected.checked
                    text: qsTr("Complete setup")

                    onClicked: {
                        if (eebusGridGuardGateway) {
                            engine.thingManager.removeThing(eebusGridGuardGateway.id);
                        }

                        d.params = [];
                        for (var i = 0; i < thingClass.paramTypes.count; i++) {
                            var param = {};
                            var paramTypeId = thingClass.paramTypes.get(i).id;
                            var discoveryParam = discoveryThingParams.params.getParam(paramTypeId);
                            param["paramTypeId"] = paramTypeId;
                            param["value"] = discoveryParam ? discoveryParam.value : "";
                            d.params.push(param);
                        }

                        d.pendingCallId = engine.thingManager.addThing(thingClass.id, thingClass.name, d.params);
                        pageStack.push(eebusGridGuardChildWaiting,
                                       {
                                           thingClass: thingClass,
                                           discoveryThingParams: discoveryThingParams
                                       });
                    }
                }

                Button {
                    text: qsTr("Cancel")
                    Layout.fillWidth: true
                    flat: true
                    onClicked: {
                        pageStack.pop();
                        pageStack.pop();
                        pageStack.pop();
                    }
                }
            }
        }
    }


    Component {
        id: eebusView

        Page {
            header: CoHeader {
                text: qsTr("Grid-supportive control")
                subText: qsTr("EEBUS")
                backButtonVisible: true
                menuButtonVisible: true
                onBackPressed: pageStack.pop()
                onMenuPressed: eebusViewMenu.open()
            }

            ListModel {
                id: eebusViewMenuListModel

                ListElement {
                    icon: "/icons/delete_forever.svg"
                    text: qsTr("Delete")
                }

                ListElement {
                    icon: "/icons/tune.svg"
                    text: qsTr("Reconfigure")
                }
            }

            Menu {
                id: eebusViewMenu
                x: root.width - width - Style.margins
                modal: true

                Repeater {
                    id: eebusViewMenuListRepeater
                    model: eebusViewMenuListModel

                    Item {
                        width: menuItemLayout.implicitWidth + Style.margins
                        height: 40

                        RowLayout {
                            id: menuItemLayout
                            anchors {
                                left: parent.left
                                right: parent.right
                                leftMargin: 16
                                rightMargin: 16
                            }

                            height: parent.height / 2
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Style.margins

                            ColorIcon {
                                Layout.fillHeight: false
                                Layout.fillWidth: false
                                Layout.preferredHeight: 24
                                Layout.preferredWidth: 24
                                source: model.icon
                            }

                            Label {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                text: model.text
                                font.pixelSize: app.mediumFont
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (index === 0) {
                                    if (eebusGridGuardGateway) {
                                        engine.thingManager.removeThing(eebusGridGuardGateway.id);
                                    }
                                    root.setGridSupportSettings("none");
                                    pageStack.pop();
                                } else if (index === 1 && genericEebusDeviceThingClass) {
                                    discovery.discoverThings(genericEebusDeviceThingClass.id);
                                    pageStack.push(eebusViewSelect, { thingClass: genericEebusDeviceThingClass });
                                }
                                eebusViewMenu.close();
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: eebusViewContent.implicitHeight
                    clip: true

                    ColumnLayout {
                        id: eebusViewContent
                        width: parent.width
                        spacing: Style.margins

                        CoFrostyCard {
                            Layout.fillWidth: true
                            contentTopMargin: Style.margins
                            headerText: qsTr("Parameter")

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 0

                                Repeater {
                                    model: eebusGridGuardGateway ? eebusGridGuardGateway.thingClass.paramTypes : null
                                    delegate: CoCard {
                                        Layout.fillWidth: true
                                        property var paramType: eebusGridGuardGateway ? eebusGridGuardGateway.thingClass.paramTypes.get(index) : null
                                        property var param: (eebusGridGuardGateway && paramType) ? eebusGridGuardGateway.params.getParam(paramType.id) : null
                                        property string paramValue: param ? param.value : ""
                                        text: paramValue !== "" ? paramValue : "—"
                                        labelText: model.displayName
                                        helpText: index === 0 ? qsTr("This SKI is required by the network operator.") : ""
                                        iconRight: index === 0 ? "/icons/file_copy.svg" : ""
                                        iconRightColor: Style.colors.brand_Basic_Accent
                                        interactive: index === 0
                                        onClicked: {
                                            if (index === 0) {
                                                PlatformHelper.toClipBoard(paramValue);
                                                ToolTip.show(qsTr("SKI copied to clipboard"), 500);
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        CoFrostyCard {
                            Layout.fillWidth: true
                            contentTopMargin: Style.margins
                            headerText: qsTr("Status")
                            visible: eebusGridGuardGateway != null

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 0

                                CoCard {
                                    Layout.fillWidth: true
                                    text: (!eebusSettings.connected && !eebusSettings.everConnected) ?
                                              qsTr("Confirmation by network operator pending") :
                                              eebusConnectedState == true ?
                                                  qsTr("Connected") :
                                                  qsTr("Not connected")
                                    interactive: false
                                    status: (!eebusSettings.connected && !eebusSettings.everConnected) ?
                                                CoCard.StatusType.Warning :
                                                eebusConnectedState == true ?
                                                    CoCard.StatusType.Success :
                                                    CoCard.StatusType.Danger
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: eebusGridGuardChildWaiting

        Page {
            id: gridGuardWaitingPage

            property ThingClass thingClass
            property var discoveryThingParams

            // Gateway thingId, set once onAddThingReply fires for our commandId.
            property string gatewayThingId: ""

            // Prevent double-handling from race-condition check and signal.
            property bool _handled: false

            readonly property string gridGuardClassId: "f84f7c28-04cc-4da5-8564-402a9361b136"

            function normalizeUuid(uuid) {
                return uuid.toString().replace(/[{}]/g, "").toLowerCase()
            }

            function handleSuccess() {
                if (_handled) return
                _handled = true
                waitTimer.stop()
                root.setGridSupportSettings("eebus")
                pageStack.replace(eebusViewStatus,
                                  {
                                      thingClass: gridGuardWaitingPage.thingClass,
                                      discoveryThingParams: gridGuardWaitingPage.discoveryThingParams
                                  })
            }

            function handleError() {
                if (_handled) return
                _handled = true
                waitTimer.stop()
                if (gatewayThingId !== "") {
                    engine.thingManager.removeThing(gatewayThingId)
                }
                root.setGridSupportSettings("none")
                localState.state = "error"
            }

            // ---- state -----------------------------------------------------

            QtObject {
                id: localState
                property string state: "waiting"  // "waiting" | "error"
            }

            // ---- timer & signal listener -----------------------------------

            Timer {
                id: waitTimer
                interval: 30000
                running: true
                repeat: false
                onTriggered: gridGuardWaitingPage.handleError()
            }

            Connections {
                target: engine.thingManager

                onAddThingReply: function(commandId, thingError, thingId, displayMessage) {
                    if (commandId !== d.pendingCallId) return
                    if (thingError !== Thing.ThingErrorNoError) {
                        gridGuardWaitingPage.handleError()
                        return
                    }
                    gridGuardWaitingPage.gatewayThingId = thingId
                    // Race-condition guard: child may have appeared before this signal.
                    for (var i = 0; i < engine.thingManager.things.count; i++) {
                        var t = engine.thingManager.things.get(i)
                        if (gridGuardWaitingPage.normalizeUuid(t.parentId) === gridGuardWaitingPage.normalizeUuid(thingId) &&
                            gridGuardWaitingPage.normalizeUuid(t.thingClassId) === gridGuardWaitingPage.gridGuardClassId) {
                            gridGuardWaitingPage.handleSuccess()
                            return
                        }
                    }
                }

                onThingAdded: function(thing) {
                    if (gridGuardWaitingPage.gatewayThingId === "") return
                    if (gridGuardWaitingPage.normalizeUuid(thing.parentId) === gridGuardWaitingPage.normalizeUuid(gridGuardWaitingPage.gatewayThingId) &&
                        gridGuardWaitingPage.normalizeUuid(thing.thingClassId) === gridGuardWaitingPage.gridGuardClassId) {
                        gridGuardWaitingPage.handleSuccess()
                    }
                }
            }

            // ---- UI --------------------------------------------------------

            header: CoHeader {
                text: qsTr("Grid-supportive control setup")
                subText: qsTr("EEBUS SKI Pairing")
                backButtonVisible: localState.state === "waiting"
                onBackPressed: {
                    _handled = true
                    waitTimer.stop()
                    if (gatewayThingId !== "") {
                        engine.thingManager.removeThing(gatewayThingId)
                    }
                    pageStack.pop()
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                Item { Layout.fillHeight: true }

                // Waiting
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: localState.state === "waiting"
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

                // Error
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: localState.state === "error"
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
                        text: qsTr("The EEBUS device could not be set up. Please check the device and try again.")
                    }
                }

                Item { Layout.fillHeight: true }

                // Error: OK button → back to setup start
                Button {
                    Layout.fillWidth: true
                    visible: localState.state === "error"
                    text: qsTr("OK")
                    onClicked: {
                        pageStack.pop(root)
                    }
                }
            }
        }
    }


    Component {
        id: eebusViewStatus

        Page {
            property ThingClass thingClass
            property var discoveryThingParams

            header: CoHeader {
                text: qsTr("Grid-supportive control setup")
                subText: qsTr("EEBUS SKI Pairing")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                CoFrostyCard {
                    Layout.fillWidth: true
                    contentTopMargin: Style.margins
                    headerText: qsTr("Control box")

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoCard {
                            Layout.fillWidth: true
                            property var paramType: thingClass.paramTypes.get(0)
                            property string paramValue: discoveryThingParams.params.getParam(paramType.id).value
                            text: paramValue
                            labelText: qsTr("This SKI is required by the network operator.")
                            helpText: qsTr("Local Subject Key Identifier (SKI)")
                            iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                            iconRightColor: Style.colors.brand_Basic_Accent
                            interactive: true
                            onClicked: {
                                PlatformHelper.toClipBoard(paramValue);
                                ToolTip.show(qsTr("SKI copied to clipboard"), 500);
                            }
                        }
                    }
                }

                CoFrostyCard {
                    Layout.fillWidth: true
                    contentTopMargin: Style.margins
                    headerText: qsTr("Status")
                    visible: eebusGridGuardGateway != null

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoCard {
                            Layout.fillWidth: true
                            text: (!eebusSettings.connected && !eebusSettings.everConnected) ?
                                      qsTr("Confirmation by network operator pending") :
                                      eebusConnectedState == true ?
                                          qsTr("Connected") :
                                          qsTr("Not connected")
                            interactive: false
                            status: (!eebusSettings.connected && !eebusSettings.everConnected) ?
                                        CoCard.StatusType.Warning :
                                        eebusConnectedState == true ?
                                            CoCard.StatusType.Success :
                                            CoCard.StatusType.Danger
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Button {
                    id: eebusBackToView
                    Layout.fillWidth: true
                    text: qsTr("Back to overview")

                    onClicked: {
                        pageStack.pop();
                        pageStack.pop();
                        pageStack.pop();
                        pageStack.pop();
                    }
                }
            }
        }
    }
}
