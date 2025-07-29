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
    property bool newTariff: false

    readonly property Thing thing: currentThing ? currentThing.get(0) : null

    property int directionID: 0

    signal done(bool skip, bool abort, bool back);

    header: NymeaHeader {
        text: qsTr("Dynamic electricity tariff")
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
        target: currentThing.engine.thingManager

        onAddThingReply: {
            if(!thingError)
            {
                pageStack.push(Qt.resolvedUrl("../optimization/DynamicElectricityRateFeedback.qml"), {thingName: energyRateComboBox.currentText})
            }else{
                let props = qsTr("Failed to add thing: ThingErrorHardwareFailure");
                var comp = Qt.createComponent("../components/ErrorDialog.qml")
                var popup = comp.createObject(app, {props} )
                popup.open();
            }
        }
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
              Layout.alignment: Qt.AlignRight
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
                                id: energyIcon
                                Layout.fillWidth: true
                                iconName: {
                                    if(Configuration.energyIcon !== ""){
                                        return "/ui/images/"+Configuration.energyIcon;
                                    }else{
                                        return "../images/energy.svg"
                                    }
                                }
                                progressive: false
                                text: erProxy.get(index) ? erProxy.get(index).name : ""
                                onClicked: {
                                }

                                Image {
                                    id: icons
                                    height: 24
                                    width: 24
                                    source: energyIcon.iconName
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 16
                                    z: 2
                                }

                                ColorOverlay {
                                    anchors.fill: icons
                                    source: icons
                                    color: Style.consolinnoMedium
                                    z: 3
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
            visible: root.newTariff
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

        ColumnLayout {
            spacing: 0
            Layout.alignment: Qt.AlignHCenter
            visible: true

            Button {
                id: addButton
                text: qsTr("Add Rate")
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                  //timer1.start()
                  if(!root.NewTariff) {
                    root.newTariff = true;
                    addButton.text = qsTr("Next");
                    return;
                  }


                }
            }

            ConsolinnoSetUpButton {
                text: qsTr("Cancel")
                backgroundColor: "transparent"
                onClicked: {
                  if(directionID == 0) {
                      pageStack.pop()
                  }
                }
            }


            Timer {
                id: timer1

                interval: 300
                running: false
                repeat: false

                onTriggered: {
                    currentThing.engine.thingManager.addThing(energyRateComboBox.currentValue, energyRateComboBox.currentText, 0)
                }
            }

        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
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
