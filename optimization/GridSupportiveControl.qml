import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../components"
import "../delegates"

StackView {
    id: root
    initialItem: setUpStart

    property HemsManager hemsManager
    property int directionID: 0
    property bool setupFinishedRelay: false
    property Thing gridSupportThing: gridSupport.get(0)
    property Thing eeBusThing: eebusThing.get(0)
    property int powerLimit: gridSupportThing.stateByName("plim").value
    property string powerLimitSource: gridSupportThing.settings.get(0).value //"none" // "eebus" "relais"

    property bool eebusState: eeBusThing ? eeBusThing.stateByName("connected").value : false
    property string colorsEEBUS: eebusState === false ? "#F7B772" : eebusState == true ? "#BDD786" : "#F37B8E"
    property string textEEBUS: eebusState === false ? qsTr("Confirmation by network operator pending") : eebusState == true ? qsTr("connected") : qsTr("not connected")

    property string currentState: gridSupportThing.stateByName("plimStatus").value //"limited" "blocked" "limited" "shutoff"
    property string colorsPlim: currentState === "shutoff" ? "#eb4034" : currentState === "limited" ? "#fc9d03" : "#ffffff"
    property string contentPlim: currentState === "shutoff" ? qsTr("The consumption is <b>temporarily blocked</b> by the network operator.") : currentState === "limited" ? qsTr("The consumption is <b>temporarily reduced</b> to <b>%1 kW</b> according to §14a minimum.").arg(convertToKw(powerLimit)) : ""

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
        var params = []
        for (var i = 0; i < gridSupportThing.settings.count; i++) {
            var setting = {}
            setting["paramTypeId"] = gridSupportThing.thingClass.settingsTypes.get(0).id
            setting["value"] = gridSupportThing.param.value = param
            params.push(setting)
        }
        engine.thingManager.setThingSettings(gridSupportThing.id, params);
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

                        Label {
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
                        iconName: "../images/relais.svg"
                        onClicked: {
                            pageStack.push(relaisSetUpFinish);
                        }
                    }

                    ConsolinnoItemDelegate {
                        visible: (powerLimitSource === "eebus" && eebusThing.count > 0)
                        Layout.fillWidth: true
                        text: qsTr("EEBUS Controlbox")
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

    //set-up select
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
                    ListElement{name: qsTr("EEBUS Controlbox"); description: qsTr("Must be in same Network.")}
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

    //relais set-up
    Component {
        id: relaisSetUp

        Page {

            header: NymeaHeader {
                text: qsTr("Grid supportive-control set-up – Relais")
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
                        text: qsTr("The relays are configured as follows:")
                        color: Style.consolinnoDark
                    }
                }

                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    spacing: 0
                    Image {
                        Layout.topMargin: 0
                        Layout.preferredHeight: width * (implicitHeight/implicitWidth)
                        Layout.fillWidth: true
                        fillMode: Image.PreserveAspectFit
                        source: "../images/relais_screen.png"
                        clip: true
                    }
                }

                VerticalDivider {
                    Layout.preferredWidth: app.width
                    dividerColor: Material.accent
                }

                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins

                   ConsolinnoGridSupportiveControlAlert {
                        visible: powerLimitSource === "relais"
                    }
                }

                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins

                    Button {
                        id: completeSetupButton
                        Layout.fillWidth: true
                        text: qsTr("Complete setup")

                        onClicked: {        
                            root.setGridSupportSettings("relais");
                            pageStack.pop()
                            pageStack.pop()
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

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    //relais set-up finished view
    Component {
        id: relaisSetUpFinish

        Page {

            header: ConsolinnoHeader {
                text: qsTr("Grid supportive-control – Relais")
                backButtonVisible: true
                menuOptionsButtonVisible: true
                onBackPressed: pageStack.pop()
                onMenuOptionsPressed: menu.open()
            }

            ListModel {
                id: menuListModel

                ListElement {
                    icon: "/ui/images/delete.svg"
                    text: qsTr("Delete")
                }

                ListElement {
                    icon: "/ui/images/configure.svg"
                    text: qsTr("Reconfigure")
                }
            }

            Menu {
                id: menu

                x:root.width - width
                modal: true

                Repeater {
                    id: menuListRepeater

                    model: menuListModel

                    Item {
                        width: ListView.view.width
                        height: 56

                        RowLayout {
                            anchors {
                                left: parent.left
                                right: parent.right
                                leftMargin: 16
                                rightMargin: 16
                            }

                            height: parent.height / 2
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 24

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
                                if(index === 0){
                                    root.setGridSupportSettings("none");
                                    pageStack.pop()
                                }else if(index === 1){
                                    pageStack.push(relaisSetUp);
                                }
                                menu.close();
                            }
                        }
                    }
                }
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
                        text: qsTr("The relays are configured as follows:")
                        color: Style.consolinnoDark
                    }
                }

                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    spacing: 0
                    Image {
                        Layout.fillWidth: true
                        Layout.topMargin: 0
                        Layout.preferredHeight: width * (implicitHeight/implicitWidth)
                        fillMode: Image.PreserveAspectFit
                        source: "../images/relais_screen.png"
                        clip: true
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    Component {
        id: eebusViewSelect

        Page {

            header: NymeaHeader {
                text: qsTr("Grid supportive-control set-up – EEBUS")
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
                text: qsTr("Grid supportive-control set-up – EEBUS")
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
                                onSecondaryIconClicked: {
                                    PlatformHelper.toClipBoard(paramValue)
                                    ToolTip.show(qsTr("SKI copied to clipboard"), 500);

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


                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins

                    ConsolinnoGridSupportiveControlAlert {
                        visible: powerLimitSource === "eebus"
                    }

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
                            if(eebusThing.count > 0){
                               engine.thingManager.removeThing(eeBusThing.id)
                            }

                            for(var i = 0; i < thingClass.paramTypes.count; i++){
                                var param = {}
                                param["paramTypeId"] = thingClass.paramTypes.get(i).id
                                param["value"] = isNaN(discoveryThingParams.params.getParam(thingClass.paramTypes.get(i).id)) ? discoveryThingParams.params.getParam(thingClass.paramTypes.get(i).id).value : ""
                                d.params.push(param)
                            }

                            engine.thingManager.addThing(thingClass.id, thingClass.name, d.params);
                            root.setGridSupportSettings("eebus");
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

            header: ConsolinnoHeader {
                text: qsTr("Grid supportive-control – EEBUS")
                backButtonVisible: true
                menuOptionsButtonVisible: true
                onBackPressed: pageStack.pop()
                onMenuOptionsPressed: menu.open()
            }

            ListModel {
                id: menuListModel

                ListElement {
                    icon: "/ui/images/delete.svg"
                    text: qsTr("Delete")
                }

                ListElement {
                    icon: "/ui/images/configure.svg"
                    text: qsTr("Reconfigure")
                }
            }

            Menu {
                id: menu

                x:root.width - width
                modal: true

                Repeater {
                    id: menuListRepeater

                    model: menuListModel

                    Item {
                        width: ListView.view.width
                        height: 56

                        RowLayout {
                            anchors {
                                left: parent.left
                                right: parent.right
                                leftMargin: 16
                                rightMargin: 16
                            }

                            height: parent.height / 2
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 24

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
                                if(index === 0){
                                    engine.thingManager.removeThing(eeBusThing.id)
                                    root.setGridSupportSettings("none");
                                    pageStack.pop()
                                }else if(index === 1){
                                    discovery.discoverThings(thingClassesProxy.get(0).id)
                                    pageStack.push(eebusViewSelect, {thingClass: thingClassesProxy.get(0)})
                                }

                                menu.close();
                            }
                        }
                    }
                }
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
                            model: eeBusThing.thingClass.paramTypes
                            delegate: ConsolinnoItemDelegate {
                                id: thingParams
                                property var paramType: eeBusThing.thingClass.paramTypes.get(index)
                                property string paramValue: isNaN(eeBusThing.params.getParam(eeBusThing.thingClass.paramTypes.get(index).id)) ? eeBusThing.params.getParam(eeBusThing.thingClass.paramTypes.get(index).id).value : ""
                                Layout.fillWidth: true
                                text: paramValue !== "" ? paramValue : ""
                                subText: index === 0 ? qsTr("This SKI is required by the network operator.") : ""
                                tertiaryText: model.displayName
                                secondaryIconName: index === 0 ? "../images/edit-copy.svg" : ""
                                secondaryIconColor: Material.accentColor
                                secondaryIconSize: 20
                                progressive: false
                                secondaryIconClickable: true
                                onSecondaryIconClicked: {
                                    PlatformHelper.toClipBoard(paramValue)
                                    ToolTip.show(qsTr("SKI copied to clipboard"), 500);
                                    //ToolTip.y = -300
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
                        Layout.topMargin: 8
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
                    Layout.topMargin: 20
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    visible: eebusThing.count > 0
                    spacing: 18
                    Rectangle {
                        Layout.leftMargin: 2
                        width: 19
                        height: 19
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
                text: qsTr("Grid supportive-control set-up – EEBUS")
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
                    onSecondaryIconClicked: {
                        PlatformHelper.toClipBoard(paramValue)
                        ToolTip.show(qsTr("SKI copied to clipboard"), 500);
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


                    Button {
                        id: eebusBackToView
                        Layout.fillWidth: true
                        text: qsTr("Back to overview")

                        onClicked: {
                            eeBusThing = eebusThing.get(0)
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
