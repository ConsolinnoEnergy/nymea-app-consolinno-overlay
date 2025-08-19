import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.15

import "qrc:/ui/components"
import Nymea 1.0

import "../components"
import "../delegates"

Page {
    id: root

    signal done(bool skip, bool abort, bool back);

    header: NymeaHeader {
        text: qsTr("Setup solar inverter")
        backButtonVisible: true
        onBackPressed: root.done(false, false, true)
    }


    HemsManager{
        id: hemsManager
        engine: _engine
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
            case 1:// DisplayPin
            case 2:// EnterPin
            case 3:// PushButton
            case 4:// OAuth
            case 5:// User and Password
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

        onAddThingReply: {

            busyOverlay.shown = false;
            var thing = engine.thingManager.things.getThing(thingId)

            pageStack.push(setupInverterComponent, {thingError: thingError, thing: thing, message: displayMessage})

        }

        onConfirmPairingReply: {
            busyOverlay.shown = false
            pageStack.push(resultsPage, {thingError: thingError, thingId: thingId, message: displayMessage})
        }

        onPairThingReply: {
            busyOverlay.shown = false
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
                pageStack.push(pairingPageComponent, {thing: d.thing, transactionId: pairingTransactionId,  text: displayMessage, setupMethod: setupMethod})
                break;
            case "SetupMethodOAuth":
                pageStack.push(oAuthPageComponent, {oAuthUrl: oAuthUrl})
                break;
            default:
                print("Setup method reply not handled:", setupMethod);
            }
        }




    }

    ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right;  margins: Style.margins }
        width: Math.min(parent.width - Style.margins * 2, 300)


    ColumnLayout{
        Layout.fillWidth: true
        Layout.fillHeight: true

        Label {
            Layout.fillWidth: true
            text: qsTr("Integrated solar inverter:")
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignLeft
            horizontalAlignment: Text.AlignLeft
        }


        VerticalDivider
        {
            Layout.preferredWidth: app.width - 2* Style.margins
            dividerColor: Material.accent
        }

        Flickable{
            id: energyMeterFlickable
            clip: true
            width: parent.width
            height: parent.height
            contentHeight: energyMeterList.height
            contentWidth: app.width
            visible: emProxy.count !== 0

            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: app.height/3
            Layout.preferredWidth: app.width
            flickableDirection: Flickable.VerticalFlick

            ColumnLayout{
                id: energyMeterList
                Layout.preferredWidth: app.width
                Layout.fillHeight: true
                Repeater{
                    id: solarInverterRepeater
                    Layout.preferredWidth: app.width
                    model: ThingsProxy {
                        id: emProxy
                        engine: _engine
                        shownInterfaces: ["solarinverter"]
                    }
                    delegate: ItemDelegate{
                        Layout.preferredWidth: app.width
                        contentItem: ConsolinnoItemDelegate{
                            id: icon
                            Layout.fillWidth: true
                            iconName: {
                                if(Configuration.inverterIcon !== ""){
                                    return "/ui/images/"+Configuration.inverterIcon
                                }else{
                                    return "../images/weathericons/weather-clear-day.svg"
                                }
                            }
                            progressive: false
                            text: emProxy.get(index) ? emProxy.get(index).name : ""
                            onClicked: {
                            }
                            Image {
                                id: iconInvertor
                                height: 24
                                width: 24
                                source: icon.iconName
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                            }
                            ColorOverlay {
                                anchors.fill: iconInvertor
                                source: iconInvertor
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
        visible: emProxy.count === 0
        color: Material.background
        Text {
            text: qsTr("There is no inverter set up yet.")
            color: Material.foreground
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        }

        VerticalDivider
        {
            Layout.preferredWidth: app.width - 2* Style.margins
            dividerColor: Material.accent
        }

    }

        ColumnLayout {
            Layout.topMargin: Style.margins
            Label {
                Layout.fillWidth: true
                text: qsTr("Add solar Inverter: ")
                wrapMode: Text.WordWrap
            }

            ComboBox {
                id: thingClassComboBox
                Layout.preferredWidth: app.width - 2*Style.margins
                textRole: "displayName"
                valueRole: "id"
                model: ThingClassesProxy {
                    engine: _engine
                    filterInterface: "solarinverter"
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
            Button {
                id: addButton
                text: qsTr("add")
                //color: Style.accentColor
                Layout.preferredWidth: 200
                //Layout.alignment: Qt.AlignHCenter
                Layout.alignment: Qt.AlignLeft
                onClicked: internalPageStack.push(creatingMethodDecider, {thingClassId: thingClassComboBox.currentValue})
            }

            // Having 0 Solar inverter will be supporter at a later stage
            Button {
                id: nextStepButton
                text: qsTr("Next step")
                font.capitalization: Font.AllUppercase
                font.pixelSize: 15
                Layout.preferredWidth: 200
                Layout.preferredHeight: addButton.height - 9
                opacity: solarInverterRepeater.count > 0 ? 1 : 0.3
                // color: Style.consolinnoMedium
                // background fucks up the margin between the buttons, thats why wee need this topMargin
                Layout.topMargin: 5

                contentItem:Row{
                    Text{
                        id: nextStepButtonText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: nextStepButton.text
                        font: nextStepButton.font
                        opacity: enabled ? 1.0 : 0.3
                        color: Style.consolinnoHighlightForeground
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    Image{
                        id: headerImage
                        anchors.right : parent.right
                        anchors.verticalCenter:  parent.verticalCenter

                        sourceSize.width: 18
                        sourceSize.height: 18
                        source: "../images/next.svg"

                        layer{
                            enabled: true
                            effect: ColorOverlay{
                                color: Style.consolinnoHighlightForeground
                            }
                        }
                    }

                }

                background: Rectangle{
                    height: parent.height
                    width: parent.width
                    border.color: Material.background
                    color: Style.secondButtonColor
                    radius: 4
                }

                Layout.alignment: Qt.AlignHCenter
                onClicked:{
                    if (solarInverterRepeater.count >0){
                        root.done(true, false, false)
                    }
                }

            }
        }

    }


// This Component Looks at the thingClass and decides based on the createMethod, which "Route" of the
// Setup we should take
    // tested and supported are atm:
        // ThingDiscovery
        // ThingDiscovery with discoveryParams
        // User

    Component {
        id: creatingMethodDecider

        Page {
            id: searchInverterPage

            property var thingClassId: null
            property var thingClass: engine.thingManager.thingClasses.getThingClass(thingClassId)


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
                }   // User
                else if (thingClass.createMethods.indexOf("CreateMethodUser") !== -1) {
                    // User where thing known.
                    if (!thing) {
                        pageStack.push(paramsPage, {thingClass: thingClass})
                    } else if (thing) {
                        if (thingClass.paramTypes.count > 0) {
                            pageStack.push(paramsPage, {thingClass: thingClass, thing: thing})
                        } else {
                            switch (thingClass.setupMethod) {
                            case 0:
                                engine.thingManager.reconfigureThing(root.thing.id, [])
                                busyOverlay.shown = true;
                                break;
                            case 1:
                            case 2:
                            case 3:
                            case 4:
                            case 5:
                                engine.thingManager.rePairThing(root.thing.id, []);
                                break;
                            default:
                                console.warn("Unhandled setup method!")
                            }
                        }
                    }
                }

            }





        }
    }


// discoveryParams: Params necessary for Discovery
    Component {
        id: discoveryParamsPage
        SettingsPageBase {

            property ThingClass thingClass

            id: discoveryParamsView
            title: qsTr("Discover %1").arg(thingClass.displayName)

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
                text: "Next"
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
                text: qsTr("The following devices were found:")
                visible: !discovery.busy && discoveryProxy.count > 0

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
                Layout.margins: app.margins
                text: qsTr("Search again")
                onClicked: discovery.discoverThings(thingClass.id, d.discoveryParams)
                visible: !discovery.busy
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
                text: (d.thingName ? d.thingName : thingClass.displayName)
                      + (thingClass.id.toString().match(/\{?f0dd4c03-0aca-42cc-8f34-9902457b05de\}?/) ? " (" + PlatformHelper.machineHostname + ")" : "")
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.bottomMargin: 0
            }

            Label{
                id: nameExplain
                text: qsTr("Please change name if necessary.")
                Layout.alignment: Qt.AlignTop
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                verticalAlignment: Text.AlignTop
                Layout.topMargin: 0
                color: Style.accentColor
                font.pixelSize: 12
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

                text: "OK"
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
        id: setupInverterComponent
        Page {
            id: setupEnergyMeterPage

            property ThingDescriptor thingDescriptor: null

            property int pendingCallId: -1
            property int thingError: Thing.ThingErrorNoError

            property Thing thing: null


            header: NymeaHeader {
                text: qsTr("Solar inverter")
                backButtonVisible: false
                //onBackPressed: pageStack.pop(root)
            }

            Component.onCompleted: {
                pendingCallId = engine.thingManager.addDiscoveredThing(thingDescriptor.thingClassId, thing.id, thing.name, {})
            }



            ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: Style.margins }
                width: Math.min(parent.width - Style.margins * 2, 300)
                spacing: Style.margins


                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: setupEnergyMeterPage.pendingCallId != -1

                    BusyIndicator {
                        anchors.centerIn: parent
                    }
                }


                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: setupEnergyMeterPage.pendingCallId == -1 && setupEnergyMeterPage.thingError == Thing.ThingErrorNoError
                    spacing: Style.margins

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: qsTr("The following solar inverter has been found and set up:")
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                        //text: setupEnergyMeterPage.thingDescriptor.name
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
                    text: qsTr("An unexpected error happened during the setup. Please verify the solar inverter is installed correctly and try again.")
                    visible: setupEnergyMeterPage.thingError != Thing.ThingErrorNoError
                }

                ColumnLayout{
                    spacing: 0
                    Layout.alignment: Qt.AlignHCenter

                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 200
                        text: qsTr("Next")
                        onClicked:{

                            if(thing){
                                var page = pageStack.push("../optimization/PVOptimization.qml", { hemsManager: hemsManager, pvConfiguration:  hemsManager.pvConfigurations.getPvConfiguration(thing.id), thing: thing, directionID: 1} )
                                page.done.connect(function(){
                                    pageStack.pop(root)
                                    //root.done(false, false)
                                })

                            }

                        }

                    }
                }
            }
        }
    }


    Component {
        id: pairingPageComponent
        SettingsPageBase {
            id: pairingPage
            property var thing
            property var transactionId

            title: qsTr("Reconfigure %1").arg(d.thingName)
            property alias text: textLabel.text

            property string setupMethod

            SettingsPageSectionHeader {
                text: qsTr("Login required")
            }

            Label {
                id: textLabel
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                wrapMode: Text.WordWrap
            }

            TextField {
                id: usernameTextField
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                placeholderText: qsTr("Username")
                visible: pairingPage.setupMethod === "SetupMethodUserAndPassword"
            }

            ConsolinnoPasswordTextField {
                id: pinTextField
                Layout.fillWidth: true
                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                visible: pairingPage.setupMethod === "SetupMethodDisplayPin" || pairingPage.setupMethod === "SetupMethodEnterPin" || pairingPage.setupMethod === "SetupMethodUserAndPassword"
                signup: false
            }


            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                text: "OK"
                onClicked: {
                    engine.thingManager.confirmPairing(transactionId, pinTextField.password, usernameTextField.displayText);
                    busyOverlay.shown = true;
                }
            }
        }
    }

    Component {
        id: resultsPage

        Page {
            id: resultsView
            header: NymeaHeader {
                text: qsTr("Reconfigure %1").arg(d.thingName)
                onBackPressed: pageStack.pop()
            }

            property string thingId
            property int thingError
            property string message

            readonly property bool success: thingError === Thing.ThingErrorNoError

            readonly property Thing thing: root.thing ? root.thing : engine.thingManager.things.getThing(thingId)

            ColumnLayout {
                width: Math.min(500, parent.width - app.margins * 2)
                anchors.centerIn: parent
                spacing: app.margins * 2
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: resultsView.success ? root.thing ? qsTr("Thing reconfigured!") : qsTr("Thing added!") : qsTr("Uh oh")
                    font.pixelSize: app.largeFont
                    color: Style.accentColor
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: resultsView.success ? qsTr("All done. You can now start using %1.").arg(resultsView.thing.name) : qsTr("Something went wrong setting up this thing...");
                }

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: resultsView.message
                }


                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    visible: !resultsView.success
                    text: "Retry"
                    onClicked: {
                        //internalPageStack.pop({immediate: true});
                        //internalPageStack.pop({immediate: true});
                        d.pairThing();
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    text: qsTr("Ok")
                    onClicked: {
                        if(thing){
                            var page = pageStack.push("../optimization/PVOptimization.qml", { hemsManager: hemsManager, pvConfiguration:  hemsManager.pvConfigurations.getPvConfiguration(thing.id), thing: thing, directionID: 1} )
                            page.done.connect(function(){
                                pageStack.pop(root)
                                //root.done(false, false)
                            })

                        }
                    }
                }
            }
        }
    }




}
