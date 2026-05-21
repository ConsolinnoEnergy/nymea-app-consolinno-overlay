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
    property Thing eeBusThing: eebusThing.get(0)
    property double powerLimitLPC: gridSupportThing.stateByName("lpcValue").value
    property double powerLimitLPP: gridSupportThing.stateByName("lppValue").value
    property string powerLimitSource: gridSupportThing.settings.get(0).value

    property bool eebusState: eeBusThing ? eeBusThing.stateByName("connected").value : false

    property bool currentStateLPC: gridSupportThing.stateByName("isLpcActive").value
    property bool currentStateLPP: gridSupportThing.stateByName("isLppActive").value
    property string contentPlimLPP: currentStateLPP === true ? qsTr("The feed-in is <b>limited temporarily</b> to <b>%1 kW</b> due to a control command from the grid operator.").arg(convertToKw(powerLimitLPP)) : ""
    property string contentPlim: currentStateLPC === true ? qsTr("Due to a control order from the network operator, the total power of controllable devices is <b>temporarily limited</b> to <b>%1 kW.</b> If, for example, you are currently charging your electric car, the charging process may not be carried out at the usual power level.").arg(convertToKw(powerLimitLPC)) : ""


    Settings {
        id: eebusSettings
        property bool connected: false
        property bool everConnected: false
    }

    Component.onCompleted: {
        eebusSettings.connected = eebusState;
        if (eebusState && !eebusSettings.everConnected) {
            eebusSettings.everConnected = true;
        }
    }

    QtObject {
        id: d
        property int pendingCallId: -1
        property var params: []
    }

    Connections {
        target: engine.thingManager
        onAddThingReply: function(commandId, thingError, thingId, displayMessage) {
            eeBusThing = engine.thingManager.things.getThing(thingId)
        }
    }

    ThingDiscovery {
        id: discovery
        engine: _engine
    }

    ThingClassesProxy {
        id: thingClassesProxy
        engine: _engine
        includeProvidedInterfaces: true
        filterString: "EEBus"
        groupByInterface: true
    }

    function convertToKw(numberW){
        return (+(Math.round((numberW / 1000) * 100 ) / 100)).toLocaleString()
    }

    ThingsProxy {
        id: eebusThing
        engine: _engine
        nameFilter: "eebus"
        shownInterfaces: ["gateway"]
    }

    ThingsProxy {
        id: gridSupport
        engine: _engine
        shownInterfaces: ["gridsupport"]
    }

    function setGridSupportSettings(param){
        var setting = {};
        setting["paramTypeId"] = gridSupportThing.thingClass.settingsTypes.get(0).id;
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
                    headerText: qsTr("Control type")

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
                            visible: (powerLimitSource === "eebus" && eebusThing.count > 0)
                            text: qsTr("EEBUS SKI Pairing")
                            iconLeft: Qt.resolvedUrl("/ui/images/eebus.svg")
                            showChildrenIndicator: true
                            onClicked: {
                                pageStack.push(eebusView);
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
                    headerText: qsTr("Control type")

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
                            onClicked: {
                                discovery.discoverThings(thingClassesProxy.get(0).id);
                                pageStack.push(eebusViewSelect,
                                               { thingClass: thingClassesProxy.get(0) });
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
                                                               thingClass: thingClassesProxy.get(0),
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
                        discovery.discoverThings(thingClassesProxy.get(0).id);
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
                        if (eebusThing.count > 0) {
                            engine.thingManager.removeThing(eeBusThing.id);
                        }

                        for (var i = 0; i < thingClass.paramTypes.count; i++) {
                            var param = {};
                            var paramTypeId = thingClass.paramTypes.get(i).id;
                            var discoveryParam = discoveryThingParams.params.getParam(paramTypeId);
                            param["paramTypeId"] = paramTypeId;
                            param["value"] = discoveryParam ? discoveryParam.value : "";
                            d.params.push(param);
                        }

                        engine.thingManager.addThing(thingClass.id, thingClass.name, d.params);
                        root.setGridSupportSettings("eebus");
                        pageStack.push(eebusViewStatus,
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
                                    engine.thingManager.removeThing(eeBusThing.id);
                                    root.setGridSupportSettings("none");
                                    pageStack.pop();
                                } else if (index === 1) {
                                    discovery.discoverThings(thingClassesProxy.get(0).id);
                                    pageStack.push(eebusViewSelect, { thingClass: thingClassesProxy.get(0) });
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
                                    model: eeBusThing.thingClass.paramTypes
                                    delegate: CoCard {
                                        Layout.fillWidth: true
                                        property var paramType: eeBusThing.thingClass.paramTypes.get(index)
                                        property var param: eeBusThing.params.getParam(paramType.id)
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
                            visible: eebusThing.count > 0

                            ColumnLayout {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 0

                                CoCard {
                                    Layout.fillWidth: true
                                    text: (!eebusSettings.connected && !eebusSettings.everConnected) ?
                                              qsTr("Confirmation by network operator pending") :
                                              eebusState == true ?
                                                  qsTr("Connected") :
                                                  qsTr("Not connected")
                                    interactive: false
                                    status: (!eebusSettings.connected && !eebusSettings.everConnected) ?
                                                CoCard.StatusType.Warning :
                                                eebusState == true ?
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
                    visible: eebusThing.count > 0

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        CoCard {
                            Layout.fillWidth: true
                            text: (!eebusSettings.connected && !eebusSettings.everConnected) ?
                                      qsTr("Confirmation by network operator pending") :
                                      eebusState == true ?
                                          qsTr("Connected") :
                                          qsTr("Not connected")
                            interactive: false
                            status: (!eebusSettings.connected && !eebusSettings.everConnected) ?
                                        CoCard.StatusType.Warning :
                                        eebusState == true ?
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
