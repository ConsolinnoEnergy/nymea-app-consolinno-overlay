import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.1
import "qrc:/ui/components"
import Nymea 1.0

Page {
    id: root
    signal done(bool skip, bool abort);
    signal countChanged()

    header: NymeaHeader {
        text: qsTr("Setup wallbox")
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right;  margins: Style.margins }
        width: Math.min(parent.width - Style.margins * 2, 300)
        //spacing: Style.margins
        Label {
            Layout.fillWidth: true
            text: qsTr("Integrated wallboxes")
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignLeft
            Layout.alignment: Qt.AlignLeft
        }





        VerticalDivider
        {
            Layout.fillWidth: true
            dividerColor: Material.accent
        }

        Flickable{
            id: evChargerFlickable
            clip: true
            width: parent.width
            height: parent.height
            contentHeight: evChargerList.height
            contentWidth: app.width
            visible: evProxy.count !== 0

            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: app.height/4
            Layout.preferredWidth: app.width/2
            flickableDirection: Flickable.VerticalFlick

            ColumnLayout{
                id: evChargerList
                Layout.preferredWidth: app.width/2
                Layout.fillHeight: true
                Repeater{
                    id: evChargerRepeater
                    Layout.preferredWidth: app.width/2
                    model: ThingsProxy {
                        id: evProxy
                        engine: _engine
                        shownInterfaces: ["evcharger"]
                    }
                    delegate: ItemDelegate{
                        Layout.preferredWidth: app.width/2
                        contentItem: ConsolinnoItemDelegate{
                            Layout.fillWidth: true
                            progressive: false
                            text: evProxy.get(index) ? evProxy.get(index).name : ""
                            onClicked: {
                            }
                        }
                    }


                }
            }

        }


        Rectangle{
        Layout.preferredHeight: app.height/4
        Layout.fillWidth: true
        visible: evProxy.count === 0
        color: Material.background
        Text {
            text: qsTr("There is no wallbox set up yet.")
            color: Material.foreground
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        }


        VerticalDivider
        {
            Layout.fillWidth: true
            dividerColor: Material.accent
        }


        ColumnLayout {
            Layout.topMargin: Style.margins
            Label {
                Layout.fillWidth: true
                text: qsTr("Please select the model you want to add:")
                wrapMode: Text.WordWrap
            }

            ComboBox {
                id: thingClassComboBox
                Layout.fillWidth: true
                textRole: "displayName"
                valueRole: "id"
                model: ThingClassesProxy {
                    engine: _engine
                    filterInterface: "evcharger"
                }
            }
        }

        ColumnLayout {
            spacing: Style.margins
            Layout.alignment: Qt.AlignHCenter

            Button {
                text: qsTr("cancel")
                //color: Style.yellow
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignHCenter
                onClicked: root.done(false, true)
            }
            Button {
                text: qsTr("add")
                //color: Style.accentColor
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignHCenter
                onClicked: pageStack.push(searchEvChargerComponent, {thingClassId: thingClassComboBox.currentValue})
            }
            Button {
                text: qsTr("next")
                //color: Style.blue
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignHCenter
                onClicked: root.done(true, false)
            }
        }

    }

    Component {
        id: searchEvChargerComponent

        Page {
            id: searchEvChargerPage
            property string thingClassId: null

            //onBack: pageStack.pop()

            header: NymeaHeader {
                text: qsTr("Wallbox")
                onBackPressed: pageStack.pop()
            }

            ThingDiscovery {
                id: discovery
                engine: _engine


                onBusyChanged: {
                    if (!busy) {
                        print("discovery finished! Count:", count, discovery.count)
                        if (count == 1) {
                            print("pushing:", discovery.get(0))
                            pageStack.push(setupEvChargerComponent, {thingDescriptor: discovery.get(0)})
                        }
                    }
                }
            }

            Component.onCompleted: {
                print("starting discovery")
                discovery.discoverThings(searchEvChargerPage.thingClassId)
            }

            ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: Style.margins }
                width: Math.min(parent.width - Style.margins * 2, 300)
                spacing: Style.margins


                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        visible: discovery.busy
                        anchors.centerIn: parent
                        spacing: Style.margins

                        BusyIndicator {
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Label {
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("Searching...")
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        width: parent.width
                        spacing: Style.margins
                        visible: !discovery.busy && discovery.count == 0

                        Label {
                            Layout.fillWidth: true
                            Layout.bottomMargin: Style.bigMargins
                            text: qsTr("No charging point or wallbox has been found. Please return to the previous step and verify that your charging point or wallbox is installed properly.")
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("back")
                            Layout.preferredWidth: 200
                            //color: Style.yellow
                            onClicked: pageStack.pop()
                        }
                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("cancel")
                            Layout.preferredWidth: 200
                            //color: Style.yellow
                            onClicked: root.done(false, true)
                        }
                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("skip")
                            Layout.preferredWidth: 200
                            //color: Style.blue
                            onClicked: root.done(true, false)
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    visible: !discovery.busy && discovery.count > 1

                    Label {
                        Layout.fillWidth: true
                        Layout.margins: Style.margins
                        text: qsTr("Multiple charging points or wallboxes have been found in your network. Please select the one you'd like to use with your Leaflet.")
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.bottomMargin: app.margins
                        clip: true
                        model: discovery
                        delegate: ItemDelegate {
                            id: wallboxDelegate
                            contentItem: RowLayout {
                                ColumnLayout {
                                    Label {
                                        Layout.fillWidth: true
                                        text: model.name
                                        elide: Text.ElideRight
                                    }
                                    Label {
                                        Layout.fillWidth: true
                                        text: model.description
                                        elide: Text.ElideRight
                                        font: Style.smallFont
                                    }
                                }
                            }

                            width: parent.width
                            onClicked: {
                                console.warn("clicked")
                                pageStack.push(setupEvChargerComponent, {thingDescriptor: discovery.get(index)})
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: setupEvChargerComponent
        Page {
            id: setupEnergyMeterPage

            property ThingDescriptor thingDescriptor: null

            property int pendingCallId: -1
            property int thingError: Thing.ThingErrorNoError

            property Thing thing: null

            header: NymeaHeader {
                text: qsTr("Wallbox")
                onBackPressed: pageStack.pop(root)
            }

            Component.onCompleted: {
                pendingCallId = engine.thingManager.addDiscoveredThing(thingDescriptor.thingClassId, thingDescriptor.id, thingDescriptor.name, {})
            }

            Connections {
                target: engine.thingManager
                onAddThingReply: {
                    root.countChanged()
                    if (commandId == setupEnergyMeterPage.pendingCallId) {
                        setupEnergyMeterPage.thingError = thingError
                        setupEnergyMeterPage.pendingCallId = -1
                        thing = engine.thingManager.things.getThing(thingId)
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
                        text: qsTr("The following charging point or wallbox has been found and set up:")
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font.bold: true
                        text: setupEnergyMeterPage.thingDescriptor.name
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
                    text: qsTr("An unexpected error happened during the setup. Please verify the chargingpoint or wallbox is installed correctly and try again.")
                    visible: setupEnergyMeterPage.thingError != Thing.ThingErrorNoError
                }

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 200
                    text: qsTr("back")
                    //color: Style.yellow
                    onClicked: pageStack.pop(root)
                }

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 200
                    text: qsTr("next")
                    onClicked: pageStack.pop(root)
                }
            }
        }
    }
}
