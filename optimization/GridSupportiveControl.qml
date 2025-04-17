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
    property int powerLimit: 16255
    property string powerLimitSource: "none" // "eebus" "relais"
    property string currentState: "" // "blocked" "limited" "shutoff"
    property string colorsPlim: currentState === "shutoff" ? "#eb4034" : currentState === "limited" ? "#fc9d03" : "#ffffff"
    property string contentPlim: currentState === "shutoff" ? qsTr("The consumption is <b>temporarily blocked</b> by the network operator.") : currentState === "limited" ? qsTr("The consumption is <b>temporarily reduced</b> to %1 kW according to §14a minimum.").arg(convertToKw(powerLimit)) : ""

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    function convertToKw(numberW){
        return (+(Math.round((numberW / 1000) * 100 ) / 100)).toLocaleString()
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
                anchors.fill: parent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: app.margins
                anchors.margins: app.margins

                Button {
                    id: setUpButton
                    Layout.fillWidth: true
                    text: qsTr("Grid supportive-control set-up")

                    onClicked: {
                        pageStack.push(selectComponent)
                    }
                }

                ColumnLayout {
                    visible: powerLimitSource === "none" ? false : true
                    Layout.topMargin: 16
                    Layout.fillWidth: true

                    Rectangle {
                        visible: currentState !== ""
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
                                Layout.fillWidth: true
                                Layout.preferredWidth: parent.width - 20
                                leftPadding: 40
                            }

                            Item {
                                Layout.preferredHeight: 10
                            }
                        }
                    }


                    Text {
                        Layout.alignment: Qt.AlignRight
                        verticalAlignment: Text.AlignRight
                        text: qsTr("Control type")
                    }

                    VerticalDivider{
                        Layout.fillWidth: true
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
                    Layout.fillWidth: true
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
                anchors.fill: parent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: app.margins
                anchors.margins: app.margins

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
                    dividerColor: Material.accent
                }

                Button {
                    id: nextButton
                    enabled: false
                    Layout.fillWidth: true
                    text: qsTr("Next")

                    onClicked: {
                        if(buttonGroup.checkedButton.value === 0){
                            pageStack.push(relaisSetUp, {selectedName: buttonGroup.checkedButton.text})
                        }else{
                            pageStack.push(eebusViewSelect, {selectedName: buttonGroup.checkedButton.text})
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

            property string selectedName: ""

            header: NymeaHeader {
                text: qsTr("Grid supportive-control set-up - %1").arg(selectedName)
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: app.margins
                anchors.margins: app.margins

                spacing: 0

                Text {
                    Layout.fillWidth: true
                    Layout.topMargin: 5
                    Layout.bottomMargin: 0
                    textFormat: Text.RichText
                    font.pointSize: 20
                    font.bold: true
                    wrapMode: Text.WordWrap
                    text: qsTr("The relays are configured as follows")
                    color: Style.consolinnoDark
                }

                Image {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height / 4
                    Layout.topMargin: 5
                    Layout.bottomMargin: 5
                    fillMode: Image.PreserveAspectFit
                    source: "../images/relais_screen.png"
                }

                VerticalDivider {
                    Layout.fillWidth: true
                    dividerColor: Material.accent
                }

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

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }
        }
    }

    Component {
        id: eebusViewSelect

        Page {
            property string selectedName: ""

            header: NymeaHeader {
                text: qsTr("Grid supportive-control set-up - %1").arg(selectedName)
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }


            ColumnLayout {
                anchors.fill: parent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: app.margins
                anchors.margins: app.margins

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

                Repeater {
                    id: eebuRepeater
                    model: ListModel {
                        ListElement { name: "Consolinno-Leaflet-HEMS-1u0022-co0001"; subtext: "Connected via eebus-go"; }
                        ListElement { name: "Consolinno-Leaflet-HEMS-1u0022-co0002"; subtext: "Connected via eebus-go"; }
                        ListElement { name: "Consolinno-Leaflet-HEMS-1u0022-co0003"; subtext: "Connected via eebus-go"; }
                    }
                    ConsolinnoItemDelegate {
                        Layout.preferredWidth: parent.width
                        text: name
                        subText: model.subtext
                        progressive: true
                        onClicked: {
                            pageStack.push(eebusView, {selectedName: selectedName} );
                        }
                    }
                }

                VerticalDivider {
                    Layout.preferredWidth: app.width - 2* Style.margins
                    dividerColor: Material.accent
                }

                Button {
                    id: completeSetupButton
                    Layout.fillWidth: true
                    text: qsTr("Search again")

                    onClicked: {

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

    Component {
        id: eebusView

        Page {
            property string selectedName: ""

            header: NymeaHeader {
                text: qsTr("Grid supportive-control set-up - %1").arg(selectedName)
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

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

                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins

                    Repeater {
                        model: ListModel{
                            ListElement{name: "b68fb71513772f3d7310c81fc35f6e40"; subtext: "Diese SKI wird vom Netzbetreiber benötigt."; tertiaryText:"Local Subject Key Identifier (SKI)"}
                            ListElement{name: "80b79b54d9f869822637f1f68ee9e893"; subtext:""; tertiaryText: "Remote Subject Key Identifier (SKI)"}
                            ListElement{name: "Consolinno-Leaflet-HEMS-1u0022-co0001"; subtext:""; tertiaryText: "Device Identifier"}
                            ListElement{name: "Consolinno"; subtext:""; tertiaryText: "Device Brand"}
                            ListElement{name: "Energy Management System"; subtext:""; tertiaryText: "Device Type"}
                            ListElement{name: "Leaflet-HEMS"; subtext:""; tertiaryText: "Device Model"}
                            ListElement{name: "???"; subtext:""; tertiaryText: "Device ID"}
                        }
                        ConsolinnoItemDelegate {
                            id: item
                            Layout.fillWidth: true
                            text: name
                            subText: model.subtext.length === 0 ? "" : model.subtext
                            tertiaryText: model.tertiaryText
                            progressive: false
                            onClicked: {
                                PlatformHelper.toClipBoard(name)
                            }
                        }
                    }
                }

                VerticalDivider {
                    Layout.preferredWidth: app.width
                    dividerColor: Material.accent
                }

                ColumnLayout {
                    Layout.fillWidth: true
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
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    visible: powerLimitSource === "eebus" ? true : false

                    Rectangle {
                        width: 25
                        height: 25
                        color: "red"
                        border.color: "red"
                        radius: 12
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("connected")
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
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins


                    Button {
                        id: eebusSetUpComplete
                        Layout.fillWidth: true
                        enabled: deviceConnected.checked
                        text: qsTr("Complete setup")

                        onClicked: {
                            pageStack.push(eebusViewStatus, {selectedName: selectedName} );
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
            property string selectedName: ""

            header: NymeaHeader {
                text: qsTr("Grid supportive-control set-up - %1").arg(selectedName)
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                ColumnLayout {
                    Layout.fillWidth: true
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
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins

                    Rectangle {
                        width: 25
                        height: 25
                        color: "red"
                        border.color: "red"
                        radius: 12
                    }

                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Confirmation from the network operator %1").arg("pending")
                        font.pointSize: 12
                        wrapMode: Text.WordWrap
                        color: Style.consolinnoDark
                    }

                }

                VerticalDivider {
                    Layout.preferredWidth: app.width
                    dividerColor: Material.accent
                }

                ColumnLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins


                    ConsolinnoItemDelegate {
                        Layout.fillWidth: true
                        text: "Test"
                        subText: "subText"
                        tertiaryText: "tertiaryText"
                        progressive: false
                    }
                }


                VerticalDivider {
                    Layout.preferredWidth: app.width
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

}
