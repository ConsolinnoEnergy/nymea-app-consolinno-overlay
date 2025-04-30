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
    property string powerLimitSource: "none" // "eebus" "relais"
    property string currentState: gridSupport.get(0).stateByName("plimStatus").value //"limited" "blocked" "limited" "shutoff"
    property string eebusState: "warning"
    property string colorsEEBUS: eebusState == "error" ? "#F37B8E" : eebusState == "warning" ? "#F7B772" : "#BDD786"
    property string textEEBUS: eebusState == "error" ? qsTr("not connected") : eebusState == "warning" ? qsTr("Confirmation by network operator pending") : qsTr("connected")
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
            busyOverlay.shown = false
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
                        visible: currentState !== "" && powerLimitSource !== "none"
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
                    visible: powerLimitSource === "none" ? false : true

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
                        visible: powerLimitSource === "eebus"
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
                            powerLimitSource = "relais"
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
                                    pageStack.push(eebusView, {thingClass: thingClassesProxy.get(0), discoveryThingParams: eebusDiscovery.get(index)});
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
                            model: thingClass.paramTypes
                            delegate: ConsolinnoItemDelegate {
                                property var paramType: thingClass.paramTypes.get(index)
                                property string paramValue: typeof(discoveryThingParams.params.getParam(paramType.id).value) !== null ? discoveryThingParams.params.getParam(paramType.id).value : ""
                                Layout.fillWidth: true
                                text: paramValue !== "" ? paramValue : ""
                                subText: index === 0 ? qsTr("This SKI is required by the network operator.") : ""
                                tertiaryText: model.displayName
                                secondaryIconName: index === 0 ? "../images/edit-copy.svg" : ""
                                secondaryIconColor: Material.accentColor
                                secondaryIconSize: 20
                                progressive: false
                                secondaryIconClickable: true
                                onSecondaryIconClicked: PlatformHelper.toClipBoard(name)
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
                    visible: powerLimitSource === "eebus" ? true : false

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
                    visible: powerLimitSource === "eebus" ? true : false

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
                    visible: powerLimitSource === "eebus" ? false : true

                    CheckBox {
                        id: deviceConnected
                        Layout.fillWidth: true
                        text: qsTr("Establish a connection with this device.")
                    }
                }

                ColumnLayout {
                    visible: powerLimitSource === "eebus" ? false : true
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
                            pageStack.push(eebusViewStatus);
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
                    Layout.fillWidth: true
                    text: "b68fb71513772f3d7310c81fc35f6e40"
                    subText: "Diese SKI wird vom Netzbetreiber benötigt."
                    tertiaryText: "Local Subject Key Identifier (SKI)"
                    secondaryIconName: "../images/edit-copy.svg"
                    secondaryIconColor: Material.accentColor
                    secondaryIconSize: 20
                    progressive: false
                    secondaryIconClickable: true
                    onSecondaryIconClicked: PlatformHelper.toClipBoard(name)
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
                        text: qsTr("Complete setup")

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
