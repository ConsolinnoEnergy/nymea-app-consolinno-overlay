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
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right;  margins: Style.margins }
        width: Math.min(parent.width - Style.margins * 2, 300)


        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
            Layout.fillWidth: true
            text: qsTr("Submitted Rate:")
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
            Layout.preferredWidth: app.width - 2* Style.margins
            dividerColor: Material.accent
        }

    }

        ColumnLayout {
            Layout.topMargin: Style.margins
            visible: erProxy.count === 0
            Label {
                Layout.fillWidth: true
                text: qsTr("Add Rate: ")
                wrapMode: Text.WordWrap
            }

            ComboBox {
                id: energyRateComboBox
                Layout.preferredWidth: app.width - 2*Style.margins
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

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
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
                    currentThing.engine.thingManager.addThing(energyRateComboBox.currentValue, energyRateComboBox.currentText, 0)
                    pageStack.push(Qt.resolvedUrl("../optimization/DynamicElectricityRateFeedback.qml"), {thingName: energyRateComboBox.currentText} )
                }
            }


        }

        VerticalDivider
        {
            Layout.preferredWidth: app.width - 2* Style.margins
            dividerColor: Material.accent
            visible: erProxy.count !== 0
        }

        ColumnLayout {
            visible: false
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: 200
            Text {
               text: qsTr("There are currently no settings options available")
            }
        }


    }
}
