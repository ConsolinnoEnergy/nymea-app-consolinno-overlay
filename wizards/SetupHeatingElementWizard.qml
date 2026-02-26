import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

import "qrc:/ui/components"
import Nymea 1.0

import "../components"
import "../delegates"

Page {
    id: root

    signal done(bool skip, bool abort, bool back);

    header: NymeaHeader {
        text: qsTr("Setup heating element")
        onBackPressed: root.done(false, false, true)
    }

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

        function pairThing(thingClass, thing) {

            switch (thingClass.setupMethod) {
                // Just Add
            case 0:
                if (d.thingDescriptor) {
                    engine.thingManager.addDiscoveredThing(thingClass.id, d.thingDescriptor.id, d.name, params);
                } else {
                    engine.thingManager.addThing(thingClass.id, d.name, params);
                }
                break;

                // If any Plugin comes up with one of those setupMethods to be implemented, Look up SetupSolarInverterWizard and look at
                // the implementation there. Its more than just this case and you need a bit of stuff
                // However I couldnt implement it yet, since there is no EvCharger yet, which needs this Method.

                // Display Pin
            case 1:
                // Enter Pin
            case 2:
                // PushButton
            case 3:
                // OAuth
            case 4:
                // User and Password
            case 5:
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
        onAddThingReply: {
            busyOverlay.shown = false;
            var thing = engine.thingManager.things.getThing(thingId)
            pageStack.push(setupHeatingElementComponent, {thingError: thingError, thing: thing, message: displayMessage})
        }
    }

    ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom;left: parent.left; right: parent.right;}
        Layout.preferredWidth: root.width

        ColumnLayout{
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                Layout.leftMargin: Style.margins
                Layout.rightMargin: Style.margins
                Layout.alignment: Qt.AlignRight
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.WordWrap
                text: qsTr("Integrated heating elements")
            }

            VerticalDivider {
                Layout.preferredWidth: root.width
                dividerColor: Material.accent
            }

            Flickable{
                id: energyMeterFlickable
                clip: true
                Layout.fillWidth: true
                contentHeight: energyMeterList.height
                contentWidth: energyMeterList.width
                visible: heProxy.count !== 0

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: app.height/3
                flickableDirection: Flickable.VerticalFlick

                ColumnLayout{
                    id: energyMeterList

                    Layout.preferredWidth: root.width
                    Layout.fillHeight: true
                    Repeater{
                        id: heatingElementRepeater
                        Layout.fillWidth: true
                        model: ThingsProxy {
                            id: heProxy
                            engine: _engine
                            shownInterfaces: ["heatingrod"]
                        }
                        delegate: ItemDelegate{
                            Layout.preferredWidth: root.width
                            contentItem: ConsolinnoItemDelegate{
                                id: setupHeatingRoad
                                Layout.preferredWidth: root.width
                                iconName:{
                                    if(Configuration.heatingRodIcon !== ""){
                                        return "/ui/images/"+Configuration.heatingRodIcon;
                                    }else{
                                        return "/icons/heating_rod.svg";
                                    }
                                }
                                progressive: false
                                text: heProxy.get(index).name

                                Image {
                                    id: iconHeatingRoad
                                    height: 24
                                    width: 24
                                    source: setupHeatingRoad.iconName
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                }
                                ColorOverlay {
                                    anchors.fill: iconHeatingRoad
                                    source: iconHeatingRoad
                                    color: Style.consolinnoMedium
                                }

                            }
                        }
                    }
                }
            }

            Rectangle{
                Layout.preferredHeight: app.height/3
                Layout.fillWidth: true
                visible: heProxy.count === 0
                color: Material.background
                Text {
                    text: qsTr("There is no heating element set up yet.")
                    color: Material.foreground
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            VerticalDivider {
                Layout.preferredWidth: root.width
                dividerColor: Material.accent
            }
        }

        ColumnLayout {
            Layout.topMargin: Style.margins
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins
            Layout.fillWidth: true

            Label {
                wrapMode: Text.WordWrap
                text: qsTr("Add heating element: ")
            }

            ConsolinnoDropdown {
                id: thingClassComboBox

                Layout.fillWidth: true
                textRole: "displayName"
                valueRole: "id"
                model: ThingClassesProxy {
                    engine: _engine
                    filterInterface: "heatingrod"
                    includeProvidedInterfaces: true
                }
            }
        }

        ColumnLayout {
            spacing: 0
            Layout.alignment: Qt.AlignHCenter

            Button {
                text: qsTr("cancel")
                Layout.preferredWidth: 200
                onClicked: root.done(false, true, false)
            }

            Popup {
                id: heatingElementLimitPopup
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
                    text: qsTr("At the moment, %1 can only control one heating element.").arg(Configuration.deviceName)
                }
            }

            Button {
                id: addButton
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignLeft
                text: qsTr("add")
                onClicked: {
                    if (heatingElementRepeater.model.count > 0) {
                        heatingElementLimitPopup.open()
                        return
                    }
                    internalPageStack.push(creatingMethodDecider, {thingClassId: thingClassComboBox.currentValue})
                }
            }

            Button {
                id: nextStepButton
                text: qsTr("Next step")
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignHCenter

                Image{
                    id: headerImage
                    anchors.right : nextStepButton.right
                    anchors.verticalCenter:  nextStepButton.verticalCenter
                    anchors.rightMargin: 5
                    sourceSize.width: 18
                    sourceSize.height: 18
                    source: "/icons/next.svg"

                    layer{
                        enabled: true
                        effect: ColorOverlay{
                            color: Style.consolinnoHighlightForeground
                        }
                    }
                }

                onClicked: root.done(true, false, false)
            }
        }
    }

    // This Component Looks at the thingClass and decides based on the createMethod, which "Route" of the
    // Setup we should take
    // tested and supported are atm:
    // ThingDiscovery
    // ThingDiscovery with discoveryParams
    Component {
        id: creatingMethodDecider

        Page {
            id: searchHeatingElementPage

            property var thingClassId
            property var thingClass: engine.thingManager.thingClasses.getThingClass(thingClassId)
            property var thing: null

            Component.onCompleted: {
                // if discovery and user. Always Discovery
                if (thingClass.createMethods.indexOf("CreateMethodDiscovery") !== -1) {

                    if (thingClass["discoveryParamTypes"].count > 0) {
                        // ThingDiscovery with discoveryParams
                        pageStack.push(discoveryParamsPage, {thingClass: thingClass})
                    } else {
                        // ThingDiscovery without discoveryParams
                        pageStack.push(discoveryPage, {thingClass: thingClass})
                        discovery.discoverThings(thingClass.id)
                    }
                }// not supported yet
                else if (thingClass.createMethods.indexOf("CreateMethodUser") !== -1) {
                    pageStack.push(paramsPage, {thingClass: thingClass})
                }
            }
        }
    }

    // discoveryParams: Params necessary for Discovery
    Component {
        id: discoveryParamsPage

        SettingsPageBase {
            id: discoveryParamsView

            title: qsTr("Discover %1").arg(thingClass.displayName)

            property ThingClass thingClass

            SettingsPageSectionHeader {
                text: qsTr("Discovery options")
            }

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
                Layout.margins: app.margins
                text: qsTr("Next")
                onClicked: {
                    var paramTypes = thingClass.discoveryParamTypes;
                    d.discoveryParams = [];
                    for (var i = 0; i < paramTypes.count; i++) {
                        var param = {};
                        param["paramTypeId"] = paramTypes.get(i).id;
                        param["value"] = paramRepeater.itemAt(i).value
                        d.discoveryParams.push(param);
                    }
                    discovery.discoverThings(thingClass.id, d.discoveryParams)
                    pageStack.push(discoveryPage, {thingClass: thingClass})
                }
            }
        }
    }

    // discoveryPage
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

            SettingsPageSectionHeader {
                visible: !discovery.busy && discoveryProxy.count > 0
                text: qsTr("The following devices were found:")
            }

            Repeater {
                model: ThingDiscoveryProxy {
                    id: discoveryProxy
                    thingDiscovery: discovery
                    showAlreadyAdded: thing !== null
                    showNew: thing === null
                    //filterThingId: root.thing ? root.thing.id : ""
                }
                delegate: NymeaItemDelegate {
                    Layout.fillWidth: true
                    text: model.name
                    subText: model.description
                    iconName: app.interfacesToIcon(discoveryView.thingClass.interfaces)
                    onClicked: {
                        d.thingDescriptor = discoveryProxy.get(index);
                        d.thingName = model.name;
                        pageStack.push(paramsPage,{thingClass: thingClass, thing: thing})
                    }
                }
            }

            busy: discovery.busy
            busyText: qsTr("Searching for things...")

            ColumnLayout {
                Layout.preferredHeight: discoveryView.height - discoveryView.header.height - retryButton.height - app.margins * 3
                spacing: app.margins
                visible: !discovery.busy && discoveryProxy.count === 0

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: app.largeFont
                    text: qsTr("Too bad...")
                }
                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: qsTr("No device was found. Please check if you have selected the correct type and if the device is connected to the correct port and go to 'Search again'.")
                }
            }

            Button {
                id: retryButton

                Layout.fillWidth: true
                Layout.margins: app.margins
                onClicked: discovery.discoverThings(thingClass.id, d.discoveryParams)
                visible: !discovery.busy
                text: qsTr("Search again")
            }
        }
    }

    Component {
        id: paramsPage

        SettingsPageBase {
            id: paramsView

            property Thing thing
            property ThingClass thingClass

            title: thing ? qsTr("Reconfigure %1").arg(thing.name) : qsTr("Set up %1").arg(thingClass.displayName)

            SettingsPageSectionHeader {
                text: qsTr("Name the thing:")
            }

            TextField {
                id: nameTextField

                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                text: (d.thingName ? d.thingName : thingClass.displayName)
                      + (thingClass.id.toString().match(/\{?f0dd4c03-0aca-42cc-8f34-9902457b05de\}?/) ? " (" + PlatformHelper.machineHostname + ")" : "")
            }

            Label{
                id: nameExplain

                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 0
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                verticalAlignment: Text.AlignTop
                color: Style.accentColor
                font.pixelSize: 12
                text: qsTr("Please change name if necessary.")
            }

            SettingsPageSectionHeader {
                text: qsTr("Thing parameters")
                visible: paramRepeater.count > 0
            }

            Repeater {
                id: paramRepeater

                model: engine.jsonRpcClient.ensureServerVersion("1.12") || d.thingDescriptor == null ?  thingClass.paramTypes : null
                delegate: ParamDelegate {
                    //                            Layout.preferredHeight: 60
                    Layout.fillWidth: true
                    enabled: !model.readOnly
                    paramType: thingClass.paramTypes.get(index)
                    value: {
                        // Discovery, use params from discovered descriptor
                        if (d.thingDescriptor && d.thingDescriptor.params.getParam(paramType.id)) {
                            return d.thingDescriptor.params.getParam(paramType.id).value
                        }

                        // Manual setup, use default value from thing class
                        return thingClass.paramTypes.get(index).defaultValue
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                text: qsTr("OK")

                onClicked: {
                    var params = []
                    for (var i = 0; i < paramRepeater.count; i++) {
                        var param = {}
                        var paramType = paramRepeater.itemAt(i).paramType
                        if (!paramType.readOnly) {
                            param.paramTypeId = paramType.id
                            param.value = paramRepeater.itemAt(i).value
                            print("adding param", param.paramTypeId, param.value)
                            params.push(param)
                        }
                    }
                    d.params = params
                    d.name = nameTextField.text
                    d.pairThing(thingClass, thing);
                }
            }
        }
    }

    BusyOverlay {
        id: busyOverlay
    }

    Component {
        id: setupHeatingElementComponent

        Page {
            id: setupHeatingElementPage

            header: NymeaHeader {
                text: qsTr("Set up Heating Element")
                backButtonVisible: false
                //onBackPressed: pageStack.pop(root)
            }

            property ThingDescriptor thingDescriptor: null

            //added
            property var thingClassId: null
            property var thingClass: thingClassId ? engine.thingManager.thingClasses.getThingClass(thingClassId) : null

            property int pendingCallId: -1
            property int thingError: Thing.ThingErrorNoError

            property Thing thing: null

            function getParams(){
                var params = []
                for (var i = 0; i < thingClass.paramTypes.count; i++)
                {
                    var param = {}
                    param.paramTypeId = thingClass.paramTypes.get(i).id
                    param.value = thingClass.paramTypes.get(i).defaultValue
                    params.push(param)

                }
                return params
            }

            Component.onCompleted: {
                if (thingDescriptor){
                    pendingCallId = engine.thingManager.addDiscoveredThing(thingDescriptor.thingClassId, thingDescriptor.id, thingDescriptor.name, {})
                }
                else{
                    var thingclassparams = getParams()
                    engine.thingManager.addThing(thingClassId, thingClass.displayName , thingclassparams);
                }
            }

            HemsManager{
                id: hemsManager
                engine: _engine
            }

            Connections {
                target: engine.thingManager
                onAddThingReply: {
                    root.countChanged()
                    if (commandId === setupHeatingElementPage.pendingCallId) {

                        setupHeatingElementPage.thingError = thingError
                        setupHeatingElementPage.pendingCallId = -1
                        setupHeatingElementPage.thing = engine.thingManager.things.getThing(thingId)
                    }
                }
            }

            ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: Style.margins }
                width: Math.min(parent.width - Style.margins * 2, 300)
                spacing: Style.margins

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: setupHeatingElementPage.pendingCallId != -1

                    BusyIndicator {
                        anchors.centerIn: parent
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: setupHeatingElementPage.pendingCallId === -1 && setupHeatingElementPage.thingError === Thing.ThingErrorNoError
                    spacing: Style.margins

                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: qsTr("The following heating element has been found and set up:")
                    }

                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                        text: thing.name
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
                    visible: setupHeatingElementPage.thingError != Thing.ThingErrorNoError
                    text: qsTr("An unexpected error happened during the setup. Please verify the heating element is installed correctly and try again.")
                }

                ColumnLayout{
                    spacing: 0
                    Layout.alignment: Qt.AlignHCenter

                    Button {
                        Layout.preferredWidth: 200
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Next")

                        onClicked:{
                            if (thing){
                                var page = pageStack.push("../optimization/HeatingElementOptimization.qml", { hemsManager: hemsManager, heatingConfiguration:  hemsManager.heatingConfigurations.getHeatingConfiguration(thing.id), heatRodThing: thing, directionID: 1})
                                page.done.connect(function(){
                                    pageStack.pop(root)
                                })
                            }else{
                                pageStack.pop(root)
                            }
                        }
                    }
                }
            }
        }
    }
}
