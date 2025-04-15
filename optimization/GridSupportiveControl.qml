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
    property string currentState: "limited" // "blocked" "limited" "shutoff"
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
                                    radius: 10  // Makes the rectangle a circle
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
                            pageStack.push(relaisSetUp);
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
                            pageStack.push(selectRelais, {selectedName: buttonGroup.checkedButton.text})
                        }
                    }
                }

                Button {
                    id: cancle
                    Layout.fillWidth: true
                    text: qsTr("Cancle")
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
                    id: nextButton
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
                    id: cancle
                    visible: powerLimitSource === "relais" ? false : true
                    Layout.fillWidth: true
                    text: qsTr("Cancle")
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
