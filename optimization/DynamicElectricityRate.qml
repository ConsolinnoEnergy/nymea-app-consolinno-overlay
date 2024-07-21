import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.15

import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

Page {
    id: root

    property HemsManager hemsManager
    property string name

    readonly property Thing thing: currentThing ? currentThing.get(0) : null

    property int directionID: 0

    signal done(bool skip, bool abort, bool back);

    header: NymeaHeader {
        text: qsTr("Dynamic Electricity Rate")
        backButtonVisible: true
        onBackPressed: {
            if(directionID == 0) {
                pageStack.pop()
            }

        }

    }

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
    }


    ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right }
        width: parent.width


        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 5
            Layout.rightMargin: 5

            Label {
            Layout.fillWidth: true
            text: qsTr("Submitted Rate:")
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignLeft
            horizontalAlignment: Text.AlignLeft
        }


        VerticalDivider
        {
            Layout.preferredWidth: app.width
            dividerColor: Material.accent
        }

        Flickable{
            id: energyRateFlickable
            clip: true
            width: parent.width
            height: parent.height
            contentHeight: energyRateFlickable.height
            contentWidth: app.width
            visible: erProxy.count !== 0

            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: app.height/3
            Layout.preferredWidth: app.width
            flickableDirection: Flickable.VerticalFlick

            ColumnLayout{
                id: energyRateFlickableList
                Layout.preferredWidth: app.width
                Layout.fillHeight: true
                Repeater{
                    id: energyRateRepeater
                    Layout.preferredWidth: app.width
                    model: ThingsProxy {
                        id: erProxy
                        engine: _engine
                        shownInterfaces: ["dynamicelectricitypricing"]
                    }
                    delegate: ItemDelegate{
                        Layout.preferredWidth: app.width
                        contentItem: ConsolinnoItemDelegate{
                            Layout.fillWidth: true
                            iconName: "../images/energy.svg"
                            progressive: false
                            text: erProxy.get(index) ? erProxy.get(index).name : ""
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
        visible: erProxy.count === 0
        color: Material.background
            Text {
                text: qsTr("There is no rate set up yet")
                color: Material.foreground
                anchors.fill: parent
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignLeft
            }
        }

        VerticalDivider
        {
            Layout.preferredWidth: app.width
            dividerColor: Material.accent
        }

    }

        ColumnLayout {
            Layout.topMargin: Style.margins
            visible: erProxy.count === 0
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: 5
                text: qsTr("Add Rate: ")
                wrapMode: Text.WordWrap
            }

            ComboBox {
                id: energyRateComboBox
                Layout.preferredWidth: app.width
                textRole: "displayName"
                valueRole: "id"
                model: ThingClassesProxy {
                    id: currentThing
                    engine: _engine
                    filterInterface: "dynamicelectricitypricing"
                    includeProvidedInterfaces: true
                }
            }
        }

        ColumnLayout {
            visible: erProxy.count !== 0

            Layout.preferredWidth: app.width

            RowLayout {
                Layout.topMargin: 10
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                Label {
                    text: qsTr("Settings:")
                }
            }

            VerticalDivider
            {
                Layout.preferredWidth: app.width
                dividerColor: Material.accent
            }

            RowLayout {
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                Label {
                    text: qsTr("Charges")
                    Layout.fillWidth: true
                }

                TextField {
                    text: "12"
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    Layout.preferredWidth: 60
                    maximumLength: 100
                }

                Label {
                    Layout.rightMargin: 10
                    text: qsTr("ct/kWh")
                }

            }

            RowLayout {
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                Label {
                    text: qsTr("Includes taxes")
                    Layout.fillWidth: true
                }

                Switch {
                    id: includeTaxes
                }

            }

            ColumnLayout {
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                Label {
                    text: qsTr("The electricity price is made up of the current stock market price as well as grid fees, taxes and charges.")
                    Layout.fillWidth: true
                    leftPadding: 5
                    rightPadding: 5
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width

                }
            }

        }


        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        VerticalDivider
        {
            Layout.preferredWidth: app.width
            dividerColor: Material.accent
        }

        ColumnLayout {
            spacing: 0
            Layout.alignment: Qt.AlignHCenter
            visible: true
            Button {
                text: qsTr("cancel")
                Layout.preferredWidth: 200
                onClicked:
                    if(directionID == 0) {
                        pageStack.pop()
                    }
            }
            Button {
                id: addButton
                text: qsTr("add")
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignLeft
                visible: erProxy.count === 0
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("../optimization/DynamicElectricityRateSettings.qml"), {thing: currentThing, thingValue: energyRateComboBox.currentValue, thingName: energyRateComboBox.currentText, } )
                }
            }
        }
    }
}
