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
    signal countChanged()

    header: NymeaHeader {
        text: qsTr("Setup heat pump")
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
            // If any Plugin comes up with one of those setupMethods to be implemented, Look up SetupSolarInverterWizard and look at
            // the implementation there. Its more than just this case and you need a bit of stuff
            // However I couldnt implement it yet, since there is no Heatpump yet, which needs this Method.

            // Display Pin
            case 1:
            // EnterPin
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

            pageStack.push(setupHeatPumpComponent, {thingError: thingError, thing: thing, message: displayMessage})

        }
    }




    ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom;left: parent.left; right: parent.right; margins: Style.margins }
        width: Math.min(parent.width - Style.margins * 2, 300)
        //spacing: Style.margins


        ColumnLayout{
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Integrated heat pumps")
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
                id: heatpumpFlickable
                clip: true
                width: parent.width
                height: parent.height
                contentHeight: heatpumpList.height
                contentWidth: app.width
                visible: hpProxy.count !== 0

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: app.height/3
                Layout.preferredWidth: app.width
                flickableDirection: Flickable.VerticalFlick

                ColumnLayout{
                    id: heatpumpList
                    Layout.preferredWidth: app.width
                    Layout.fillHeight: true
                    Repeater{
                        id: heatpumpRepeater
                        Layout.preferredWidth: app.width
                        model: ThingsProxy {
                            id: hpProxy
                            engine: _engine
                            // smartgridheatpump and simpleheatpump extend heatpump
                            shownInterfaces: ["heatpump", "smartgridheatpump", "simpleheatpump"]
                        }
                        delegate: ItemDelegate{
                            Layout.preferredWidth: app.width
                            contentItem: ConsolinnoItemDelegate{
                                Layout.fillWidth: true
                                iconName: "../images/thermostat/heating.svg"
                                progressive: false
                                text: hpProxy.get(index) ? hpProxy.get(index).name : ""
                                onClicked: {
                                }
                            }
                        }


                    }
                }

            }

            Rectangle{
                Layout.preferredHeight: app.height/3
                Layout.fillWidth: true
                visible: hpProxy.count === 0
                color: Material.background
                Text {
                    text: qsTr("There is no heat pump set up yet.")
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
                text: qsTr("Add heat pumps:")
                wrapMode: Text.WordWrap
            }

            ComboBox {
                id: thingClassComboBox
                Layout.preferredWidth: app.width - 2*Style.margins
                textRole: "displayName"
                valueRole: "id"
                model: ThingClassesProxy {
                    engine: _engine
                    filterInterface: "heatpump"
                }
            }
        }

        ColumnLayout {
            spacing: 0
            Layout.alignment: Qt.AlignHCenter

            Button {
                text: qsTr("cancel")
                //color: Style.yellow
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                onClicked: root.done(false, true, false)
            }

            Popup {
                id: heatpumpLimitPopup
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
                    text: qsTr("At the moment, %1 HEMS can only control one heatpump. Support for multiple heatpumps is planned for future releases.").arg(Configuration.appBranding)
                }
            }

            Button {
                id: addButton
                text: qsTr("add")
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignHCenter
                opacity:  (heatpumpRepeater.model.count > 0) ? 0.3 : 1.0
                onClicked:    {
                    // Actually not needed when button is
                    if (heatpumpRepeater.model.count > 0)  {
                        heatpumpLimitPopup.open()
                        return
                    }
                    internalPageStack.push(creatingMethodDecider, {thingClassId: thingClassComboBox.currentValue})
                }
            }

            Button {
                id: nextStepButton
                text: qsTr("Next step")
                font.capitalization: Font.AllUppercase
                font.pixelSize: 15
                Layout.preferredWidth: 200
                Layout.preferredHeight: addButton.height - 9
                Layout.alignment: Qt.AlignHCenter
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
                    color: Style.consolinnoHighlight
                    radius: 4
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
            id: searchHeatPumpPage

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
                }// User
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

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    horizontalAlignment: Text.AlignHCenter
                    text: discovery.displayMessage.length === 0 ?
                              qsTr("Make sure your things are set up and connected, try searching again or go back and pick a different kind of thing.")
                            : discovery.displayMessage
                    wrapMode: Text.WordWrap
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
            }

            Label{
                id: nameExplain
                text: qsTr("Please change name if necessary")
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
        id: setupHeatPumpComponent
        Page {
            id: setupHeatPumpPage

            header: NymeaHeader {
                text: qsTr("Heat pump")
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
                    if (commandId == setupHeatPumpPage.pendingCallId) {

                        setupHeatPumpPage.thingError = thingError
                        setupHeatPumpPage.pendingCallId = -1
                        setupHeatPumpPage.thing = engine.thingManager.things.getThing(thingId)
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
                    visible: setupHeatPumpPage.pendingCallId != -1

                    BusyIndicator {
                        anchors.centerIn: parent
                    }
                }


                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: setupHeatPumpPage.pendingCallId == -1 && setupHeatPumpPage.thingError == Thing.ThingErrorNoError
                    spacing: Style.margins

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: qsTr("The following heat pump has been found and set up:")
                        horizontalAlignment: Text.AlignHCenter
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
                    text: qsTr("An unexpected error happened during the setup. Please verify the heat pump is installed correctly and try again.")
                    visible: setupHeatPumpPage.thingError != Thing.ThingErrorNoError
                }

                ColumnLayout{
                    spacing: 0
                    Layout.alignment: Qt.AlignHCenter


                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Next")
                        Layout.preferredWidth: 200
                        onClicked:{

                            if (thing){
                                var page = pageStack.push("../optimization/HeatingOptimization.qml", { hemsManager: hemsManager, heatingConfiguration:  hemsManager.heatingConfigurations.getHeatingConfiguration(thing.id), heatPumpThing: thing, isSetup: true, directionID: 1})
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
