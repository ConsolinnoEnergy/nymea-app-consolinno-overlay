import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"

StackView {
    id: root
    initialItem: setUpStart

    property HemsManager hemsManager
    property int directionID: 0
    property bool setupFinishedRelay: false
    property int powerLimit: 1625
    property string powerLimitSource: gridSupport.get(0).settings.get(0).value //"none" // "eebus" "relais"

    property bool eebusState: eebusThing.get(0).stateByName("connected").value
    property string colorsEEBUS: eebusState === false ? "#F37B8E" : eebusState == true ? "#BDD786" : "#F7B772"
    property string textEEBUS: eebusState === false ? qsTr("not connected") : eebusState == true ? qsTr("connected") : qsTr("Confirmation by network operator pending")

    property string currentState: gridSupport.get(0).stateByName("plimStatus").value //"limited" "blocked" "limited" "shutoff"
    property string colorsPlim: currentState === "shutoff" ? "#eb4034" : currentState === "limited" ? "#fc9d03" : "#ffffff"
    property string contentPlim: currentState === "shutoff" ? qsTr("The consumption is <b>temporarily blocked</b> by the network operator.") : currentState === "limited" ? qsTr("The consumption is <b>temporarily reduced</b> to <b>%1 kW</b> according to §14a minimum.").arg(convertToKw(powerLimit)) : ""


    property int relais: 0

    QtObject {
        id: d
        property int pendingCallId: -1
        property var params: []
    }

    Connections {
        target: engine.thingManager
        onPairThingReply: {
            busyOverlay.shown = true
        }
    }

    HemsManager {
        id: hemsManager
        engine: _engine
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
        shownInterfaces: ["gateway"]
    }

    ThingsProxy {
        id: gridSupport
        engine: _engine
        shownInterfaces: ["gridsupport"]
    }

    //start set-up
    Component {
        id: setUpStart

        Page {

            header: NymeaHeader {
                text: qsTr("Grid Supportive Control")
                backButtonVisible: true
                onBackPressed:{
                    if (directionID == 0)
                    {
                        pageStack.pop()
                    }
                }
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                ColumnLayout {
                    Layout.leftMargin: app.bigMargins
                    Layout.rightMargin: app.bigMargins

                    Button {
                        id: setUpButton
                        Layout.fillWidth: true
                        Layout.bottomMargin: 8
                        text: qsTr("Grid supportive-control set-up")
                        implicitHeight: 55
                        onClicked: {
                            pageStack.push(selectComponent)
                        }
                    }

                    Rectangle {
                        visible: currentState !== "unrestricted" && powerLimitSource !== "none"
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        radius: 10
                        color: "#faf9f5"
                        border.width: 1
                        border.color: colorsPlim
                        implicitHeight: alertContainer.implicitHeight + 20

                        ColumnLayout {
                            id: alertContainer
                            anchors.fill: parent
                            spacing: 1

                            Item {
                                Layout.preferredHeight: 10
                            }

                            RowLayout {
                                width: parent.width
                                spacing: 5

                                Item {
                                    Layout.preferredWidth: 10
                                }

                                Rectangle {
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: "white"
                                    border.color: colorsPlim
                                    border.width: 2
                                    RowLayout.alignment: Qt.AlignVCenter

                                    Label {
                                        text: "!"
                                        anchors.centerIn: parent
                                        font.bold: true
                                        color: colorsPlim
                                    }
                                }

                                Label {
                                    font.pixelSize: 16
                                    text: qsTr("Grid-Supportive Control")
                                    font.bold: true
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: parent.width - 20
                                }
                            }

                            Label {
                                font.pixelSize: 16
                                text: contentPlim
                                wrapMode: Text.WordWrap
                                Layout.rightMargin: 20
                                Layout.fillWidth: true
                                Layout.preferredWidth: parent.width - 20
                                leftPadding: 40
                            }

                            Item {
                                Layout.preferredHeight: 10
                            }
                        }
                    }
                }

                ColumnLayout {
                    visible: (powerLimitSource === "eebus" && eebusThing.count > 0) || powerLimitSource === "relais" ? true : false

                    RowLayout {
                        Layout.alignment: Qt.AlignRight
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        Layout.fillWidth: true

                        Text {
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignRight
                            text: qsTr("Control type")
                        }
                    }

                    VerticalDivider{
                        Layout.preferredWidth: app.width
                        dividerColor: Material.accent
                    }

                    ConsolinnoItemDelegate {
                        visible: powerLimitSource === "relais"
                        Layout.fillWidth: true
                        text: "Relais"
                        iconName: "../images/union.svg"
                        onClicked: {
                            pageStack.push(relaisSetUp);
                        }
                    }

                    ConsolinnoItemDelegate {
                        visible: (powerLimitSource === "eebus" && eebusThing.count > 0)
                        Layout.fillWidth: true
                        text: "EEBUS Controlbox"
                        iconName: "../images/eebus.svg"
                        onClicked: {
                            pageStack.push(eebusView);
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

            }
        }
    }

    //relais set-up
    Component {
        id: selectComponent

        Page {
            header: NymeaHeader {
                text: qsTr("Grid supportive-control set-up")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: app.margins
                spacing: 8

                ListModel{
                    id: myListModel
                    ListElement{name: qsTr("Relais"); description: qsTr("")}
                    ListElement{name: qsTr("EEBUS Controlbox"); description: qsTr("Musst be in same Network")}
                }

                ButtonGroup {
                   id: buttonGroup
                }

                Repeater {
                    id: repeater
                    model: myListModel
                    ConsolinnoRadioDelegate {
                       text: name
                       description: model.description
                       value: index
                       size: 20
                       ButtonGroup.group: buttonGroup
                       onCheckedChanged: {
                           if(checked){
                               nextButton.enabled = true
                           }
                       }
                    }
                }

                VerticalDivider{
                    Layout.fillWidth: true
                    Layout.topMargin: app.margins - 12
                    Layout.bottomMargin: app.margins - 12
                    dividerColor: Material.accent
                }

                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins

                    Button {
                        id: nextButton
                        enabled: false
                        Layout.fillWidth: true
                        text: qsTr("Next")

                        onClicked: {
                            if(buttonGroup.checkedButton.value === 0){
                                pageStack.push(relaisSetUp)
                            }else{
                                discovery.discoverThings(thingClassesProxy.get(0).id)
                                pageStack.push(eebusViewSelect, {thingClass: thingClassesProxy.get(0)})
                            }
                        }
                    }

                    Button {
                        id: cancel
                        Layout.fillWidth: true
                        text: qsTr("Cancel")
                        background: Rectangle {
                            color: "transparent"
                        }

                        onClicked: {
                            pageStack.pop()
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }
        }
    }

    //relais finish set-up
    Component {
        id: relaisSetUp

        Page {

            header: NymeaHeader {
                text: qsTr("Grid supportive-control set-up - Relai")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                RowLayout {
                    Layout.topMargin: app.margins
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins

                    Text {
                        Layout.fillWidth: true
                        textFormat: Text.RichText
                        font.pointSize: 20
                        font.bold: true
                        wrapMode: Text.WordWrap
                        text: qsTr("The relays are configured as follows")
                        color: Style.consolinnoDark
                    }
                }

                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins

                    Image {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        fillMode: Image.PreserveAspectFit
                        source: "../images/relais_screen.png"
                        clip: true
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                }

                VerticalDivider {
                    visible: powerLimitSource === "relais" ? false : true
                    Layout.preferredWidth: app.width
                    dividerColor: Material.accent
                }

                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins

                    Button {
                        id: completeSetupButton
                        visible: powerLimitSource === "relais" ? false : true
                        Layout.fillWidth: true
                        text: qsTr("Complete setup")

                        onClicked: {
                            var params = []
                            for (var i = 0; i < gridSupport.get(0).settings.count; i++) {
                                var setting = {}
                                setting["paramTypeId"] = gridSupport.get(0).thingClass.settingsTypes.get(0).id
                                setting["value"] = gridSupport.get(0).param.value = "relais"
                                params.push(setting)
                            }
                            engine.thingManager.setThingSettings(gridSupport.get(0).id, params);

                            pageStack.pop()
                            pageStack.pop()
                        }
                    }

                    Button {
                        id: cancel
                        visible: powerLimitSource === "relais" ? false : true
                        Layout.fillWidth: true
                        text: qsTr("Cancel")
                        background: Rectangle {
                            color: "transparent"
                        }

                        onClicked: {
                            pageStack.pop()
                        }
                    }
                }

                Item {
                    visible: powerLimitSource === "relais" ? false : true
                    Layout.fillHeight: true
                }

            }
        }
    }

    Component {
        id: eebusViewSelect

        Page {

            header: NymeaHeader {
                text: qsTr("Grid supportive-control set-up - EEBUS")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            property var thingClass


            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom


                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.fillHeight: true
                    Text {
                        Layout.fillWidth: true
                        Layout.topMargin: 5
                        Layout.bottomMargin: 0
                        textFormat: Text.RichText
                        font.pointSize: 20
                        font.bold: true
                        wrapMode: Text.WordWrap
                        text: qsTr("The following EEBUS devices were found:")
                        color: Style.consolinnoDark
                    }
                }

                Flickable {
                    id: flick
                    height: parent.height - 300
                    Layout.fillWidth: true
                    clip: true

                    contentWidth: parent.width
                    contentHeight: column.implicitHeight

                    ColumnLayout {
                        id: column
                        width: parent.width
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        spacing: 5

                        Repeater {
                            id: eebuRepeater

                            model: ThingDiscoveryProxy {
                                id: eebusDiscovery
                                thingDiscovery: discovery
                            }
                            delegate: ConsolinnoItemDelegate {
                                Layout.fillWidth: true
                                iconName: "../images/connections/network-wired.svg"
                                text: model.name
                                subText: model.description
                                progressive: true
                                onClicked: {
                                    pageStack.push(eebusSetup, {thingClass: thingClassesProxy.get(0), discoveryThingParams: eebusDiscovery.get(index)});
                                }
                            }
                        }
                    }
                }

                VerticalDivider {
                    Layout.fillWidth: true
                    dividerColor: Material.accent
                }

                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins

                    Button {
                        id: completeSetupButton
                        Layout.fillWidth: true
                        text: qsTr("Search again")
                        onClicked: {
                            discovery.discoverThings(thingClassesProxy.get(0).id)
                        }
                    }

                    Button {
                        id: cancel
                        Layout.fillWidth: true
                        text: qsTr("Cancel")
                        background: Rectangle {
                            color: "transparent"
                        }

                        onClicked: {
                            pageStack.pop()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: eebusSetup

        Page {

            property ThingClass thingClass
            property var discoveryThingParams

            header: NymeaHeader {
                text: qsTr("Grid supportive-control set-up - EEBUS")
                backButtonVisible: true
                menuButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 8

                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins

                    Text {
                        Layout.topMargin: 5
                        Layout.bottomMargin: 0
                        textFormat: Text.RichText
                        font.pointSize: 20
                        font.bold: true
                        wrapMode: Text.WordWrap
                        text: qsTr("Parameter")
                        color: Style.consolinnoDark
                    }
                }

                Flickable {
                    id: flick
                    height: parent.height - 360
                    Layout.fillWidth: true
                    clip: true

                    contentWidth: parent.width
                    contentHeight: column.implicitHeight

                    ColumnLayout {
                        id: column
                        width: parent.width
                        // Margins wie in app definiert
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        spacing: 5

                        Repeater {
                            model: thingClass.paramTypes
                            delegate: ConsolinnoItemDelegate {
                                id: thingParams
                                property var paramType: thingClass.paramTypes.get(index)
                                property string paramValue: isNaN(discoveryThingParams.params.getParam(thingClass.paramTypes.get(index).id)) ? discoveryThingParams.params.getParam(thingClass.paramTypes.get(index).id).value : ""
                                Layout.fillWidth: true
                                text: paramValue !== "" ? paramValue : ""
                                subText: index === 0 ? qsTr("This SKI is required by the network operator.") : ""
                                tertiaryText: model.displayName
                                secondaryIconName: index === 0 ? "../images/edit-copy.svg" : ""
                                secondaryIconColor: Material.accentColor
                                secondaryIconSize: 20
                                progressive: false
                                secondaryIconClickable: true
                                onSecondaryIconClicked: PlatformHelper.toClipBoard(paramValue)
                            }
                        }
                    }
                }

                VerticalDivider {
                    Layout.preferredWidth: app.width
                    Layout.topMargin: app.margins - 12
                    Layout.bottomMargin: app.margins - 12
                    dividerColor: Material.accent
                }


                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins

                    CheckBox {
                        id: deviceConnected
                        Layout.fillWidth: true
                        text: qsTr("Establish a connection with this device.")
                    }
                }

                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins


                    Button {
                        id: eebusSetUpComplete
                        Layout.fillWidth: true
                        enabled: deviceConnected.checked
                        text: qsTr("Complete setup")

                        onClicked: {
                            var params = []
                            for (var i = 0; i < gridSupport.get(0).settings.count; i++) {
                                var setting = {}
                                setting["paramTypeId"] = gridSupport.get(0).thingClass.settingsTypes.get(0).id
                                setting["value"] = gridSupport.get(0).param.value = "eebus"
                                params.push(setting)
                            }

                            for(var i = 0; i < thingClass.paramTypes.count; i++){
                                var param = {}
                                param["paramTypeId"] = thingClass.paramTypes.get(i).id
                                param["value"] = isNaN(discoveryThingParams.params.getParam(thingClass.paramTypes.get(i).id)) ? discoveryThingParams.params.getParam(thingClass.paramTypes.get(i).id).value : ""
                                d.params.push(param)
                            }

                            engine.thingManager.addThing(thingClass.id, thingClass.name, d.params);
                            engine.thingManager.setThingSettings(gridSupport.get(0).id, params);
                            pageStack.push(eebusViewStatus, { thingClass: thingClass, discoveryThingParams: discoveryThingParams });
                        }
                    }

                    Button {
                        id: cancel
                        Layout.fillWidth: true
                        text: qsTr("Cancel")
                        background: Rectangle {
                            color: "transparent"
                        }

                        onClicked: {
                            pageStack.pop()
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

            }
        }
    }


    Component {
        id: eebusView

        Page {

            property ThingClass thingClass
            property var discoveryThingParams

            header: NymeaHeader {
                text: qsTr("Grid supportive-control set-up - EEBUS")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 8

                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins

                    Text {
                        Layout.topMargin: 5
                        Layout.bottomMargin: 0
                        textFormat: Text.RichText
                        font.pointSize: 20
                        font.bold: true
                        wrapMode: Text.WordWrap
                        text: qsTr("Parameter")
                        color: Style.consolinnoDark
                    }
                }

                Flickable {
                    id: flick
                    height: parent.height - 360
                    Layout.fillWidth: true
                    clip: true

                    contentWidth: parent.width
                    contentHeight: column.implicitHeight

                    ColumnLayout {
                        id: column
                        width: parent.width
                        // Margins wie in app definiert
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        spacing: 5

                        Repeater {
                            model: eebusThing.get(0).thingClass.paramTypes
                            delegate: ConsolinnoItemDelegate {
                                id: thingParams
                                property var paramType: eebusThing.get(0).thingClass.paramTypes.get(index)
                                property string paramValue: isNaN(eebusThing.get(0).params.getParam(eebusThing.get(0).thingClass.paramTypes.get(index).id)) ? eebusThing.get(0).params.getParam(eebusThing.get(0).thingClass.paramTypes.get(index).id).value : ""
                                Layout.fillWidth: true
                                text: paramValue !== "" ? paramValue : ""
                                subText: index === 0 ? qsTr("This SKI is required by the network operator.") : ""
                                tertiaryText: model.displayName
                                secondaryIconName: index === 0 ? "../images/edit-copy.svg" : ""
                                secondaryIconColor: Material.accentColor
                                secondaryIconSize: 20
                                progressive: false
                                secondaryIconClickable: true
                                onSecondaryIconClicked: PlatformHelper.toClipBoard(paramValue)
                                onClicked: {

                                }
                            }
                        }
                    }
                }

                VerticalDivider {
                    Layout.preferredWidth: app.width
                    Layout.topMargin: app.margins - 12
                    Layout.bottomMargin: app.margins - 12
                    dividerColor: Material.accent
                }

                RowLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    visible: eebusThing.count > 0

                    Text {
                        Layout.fillWidth: true
                        Layout.topMargin: 5
                        Layout.bottomMargin: 0
                        textFormat: Text.RichText
                        font.pointSize: 20
                        font.bold: true
                        wrapMode: Text.WordWrap
                        text: qsTr("Status")
                        color: Style.consolinnoDark
                    }
                }

                //Status
                RowLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    visible: eebusThing.count > 0

                    Rectangle {
                        width: 25
                        height: 25
                        color: colorsEEBUS
                        border.color: colorsEEBUS
                        radius: 12
                    }

                    Text {
                        Layout.fillWidth: true
                        text: textEEBUS
                        font.pointSize: 12
                        wrapMode: Text.WordWrap
                        color: Style.consolinnoDark
                    }

                }

                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    visible: eebusThing.count > 0 ? false : true

                    CheckBox {
                        id: deviceConnected
                        Layout.fillWidth: true
                        text: qsTr("Establish a connection with this device.")
                    }
                }

                ColumnLayout {
                    visible: eebusThing.count > 0 ? false : true
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins


                    Button {
                        id: eebusSetUpComplete
                        Layout.fillWidth: true
                        enabled: deviceConnected.checked
                        text: qsTr("Complete setup")

                        onClicked: {

                            for(var i = 0; i < thingClass.paramTypes.count; i++){
                                var param = {}
                                param["paramTypeId"] = thingClass.paramTypes.get(i).id
                                param["value"] = isNaN(discoveryThingParams.params.getParam(thingClass.paramTypes.get(i).id)) ? discoveryThingParams.params.getParam(thingClass.paramTypes.get(i).id).value : ""
                                d.params.push(param)
                            }

                            engine.thingManager.addThing(thingClass.id, thingClass.name, d.params);
                            pageStack.push(eebusViewStatus, { thingClass: thingClass, discoveryThingParams: discoveryThingParams });
                        }
                    }

                    Button {
                        id: cancel
                        Layout.fillWidth: true
                        text: qsTr("Cancel")
                        background: Rectangle {
                            color: "transparent"
                        }

                        onClicked: {
                            pageStack.pop()
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

            }
        }

    }

    Component {
        id: eebusViewStatus

        Page {

            property ThingClass thingClass
            property var discoveryThingParams

            header: NymeaHeader {
                text: qsTr("Grid supportive-control set-up - EEBUS")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 8

                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins

                    Text {
                        Layout.fillWidth: true
                        Layout.topMargin: 5
                        Layout.bottomMargin: 0
                        textFormat: Text.RichText
                        font.pointSize: 20
                        font.bold: true
                        wrapMode: Text.WordWrap
                        text: qsTr("Status")
                        color: Style.consolinnoDark
                    }
                }

                RowLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    Layout.topMargin: app.margins - 12
                    spacing: 8

                    Rectangle {
                        width: 20
                        height: 20
                        color: colorsEEBUS
                        border.color: colorsEEBUS
                        radius: 12
                    }

                    Text {
                        Layout.fillWidth: true
                        text: textEEBUS
                        font.pointSize: 12
                        wrapMode: Text.WordWrap
                        color: Style.consolinnoDark
                    }

                }

                VerticalDivider {
                    Layout.preferredWidth: app.width
                    Layout.topMargin: app.margins - 12
                    Layout.bottomMargin: app.margins - 12
                    dividerColor: Material.accent
                }

                ConsolinnoItemDelegate {
                    property var paramType: thingClass.paramTypes.get(0)
                    property string paramValue: discoveryThingParams.params.getParam(paramType.id).value
                    Layout.fillWidth: true
                    text: paramValue
                    subText: qsTr("This SKI is required by the network operator.")
                    tertiaryText: "Local Subject Key Identifier (SKI)"
                    secondaryIconName: "../images/edit-copy.svg"
                    secondaryIconColor: Material.accentColor
                    secondaryIconSize: 20
                    progressive: false
                    secondaryIconClickable: true
                    onSecondaryIconClicked: PlatformHelper.toClipBoard(paramValue)
                }

                VerticalDivider {
                    Layout.preferredWidth: app.width
                    Layout.topMargin: app.margins - 12
                    Layout.bottomMargin: app.margins - 12
                    dividerColor: Material.accent
                }

                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins


                    Button {
                        id: eebusBackToView
                        Layout.fillWidth: true
                        text: qsTr("Back to overview")

                        onClicked: {
                            powerLimitSource = "eebus"
                            pageStack.pop()
                            pageStack.pop()
                            pageStack.pop()
                            pageStack.pop()
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }


        }
    }

    BusyOverlay {
        id: busyOverlay
    }

}
