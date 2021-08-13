import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import "qrc:/ui/components"
import Nymea 1.0

ConsolinnoWizardPageBase {
    id: root

    showBackButton: false

    onNext: pageStack.push(findWallboxComponent)

    content: ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.margins
        Label {
            Layout.fillWidth: true
            font: Style.bigFont
            text: qsTr("Wallbox")
            horizontalAlignment: Text.AlignHCenter
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 3

            rowSpacing: Style.margins

            Label {
                text: "•"
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("The <i>SmartHome Interface</i> is enabled")
                wrapMode: Text.WordWrap
            }
            ColorIcon {
                size: Style.iconSize
                name: "question"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var text = qsTr('Activate UDP communication protocol (SmartHome interface):') + "<br>"
                        text += qsTr("DIP switch 1.3 = ON") + "<br><br>"
                        text += qsTr('Please find the details on section 8.1 of the <a href="https://www.keba.com/download/x/5f05ed5aca/kecontactp30_ihen_web.pdf">installation handbook</a>.') + "<br><br>"
                        text += "<b>" + qsTr("Note") + "</b><br>"
                        text += qsTr("Changes will be effective only after a restart of the wallbox.") + "<br><br>"
                        text += "<b>" + qsTr("Warning!") + "</b><br>"
                        text += qsTr("When in doubt, please consult a professional service technician. A wrong configuration of the wallbox may potentially cause severe damage.")

                        var dialog = infoDialogComponent.createObject(root, {text: text})
                        dialog.open()
                    }
                }
            }

            Label {
                text: "•"
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("<i>Obtain IP Address via DHCP</i> is enabled")
                wrapMode: Text.WordWrap
            }
            ColorIcon {
                size: Style.iconSize
                name: "question"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var text = qsTr('Get IP address via DHCP server:') + "<br>"
                        text += qsTr("DIP switches 2.1 - 2.4 = OFF") + "<br><br>"
                        text += qsTr('Please find the details on section 8.1 of the <a href="https://www.keba.com/download/x/5f05ed5aca/kecontactp30_ihen_web.pdf">installation handbook</a>.') + "<br><br>"
                        text += "<b>" + qsTr("Note") + "</b><br>"
                        text += qsTr("Changes will be effective only after a restart of the wallbox.") + "<br><br>"
                        text += "<b>" + qsTr("Warning!") + "</b><br>"
                        text += qsTr("When in doubt, please consult a professional service technician. A wrong configuration of the wallbox may potentially cause severe damage.")

                        var dialog = infoDialogComponent.createObject(root, {text: text})
                        dialog.open()
                    }
                }
            }

            Label {
                text: "•"
            }
            Label {
                Layout.fillWidth: true
                text: qsTr("Wallbox and gateway are in the same network")
                wrapMode: Text.WordWrap
            }
            ColorIcon {
                size: Style.iconSize
                name: "question"

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var text = qsTr('It is recommended to connect both, the wallbox and the nymea.energy gateway, to your network (router) by using an ethernet cable. However, provided good WiFi coverage, using a wireless connection is possible too.') + "<br>"
                        text += qsTr('Please find the details on section 7.6 of the <a href="https://www.keba.com/download/x/5f05ed5aca/kecontactp30_ihen_web.pdf">installation handbook</a>.') + "<br><br>"
                        text += "<b>" + qsTr("Warning!") + "</b><br>"
                        text += qsTr("When in doubt, please consult a professional service technician. A wrong configuration of the wallbox may potentially cause severe damage.")
                        var dialog = infoDialogComponent.createObject(root, {text: text})
                        dialog.open()
                    }
                }
            }

            Label {
                text: "•"
            }
            Label {
                Layout.fillWidth: true
                text: qsTr("The wallbox is properly set up and operational")
                wrapMode: Text.WordWrap
            }
    //        ColorIcon {
    //            size: Style.iconSize
    //            name: "question"
    //        }
        }
    }

    Component {
        id: infoDialogComponent
        MeaDialog {
            id: infoDialog
            property string text: ""
            contentItem: Label {
                text: infoDialog.text
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                onLinkActivated: Qt.openUrlExternally(link)
            }
        }
    }

    Component {
        id: findWallboxComponent
        ConsolinnoWizardPageBase {
            id: searchWallboxPage

            onBack: pageStack.pop()

            showNextButton: !discovery.busy && searchWallboxPage.selectedWallboxes.length > 0

            onNext: pageStack.push(setupWallboxComponent, {thingDescriptors: selectedWallboxes})

            ThingDiscovery {
                id: discovery
                engine: _engine

                onBusyChanged: {
                    if (!busy) {
                        print("discovery finished! Count:", count, discovery.count)
                        if (count == 1) {
                            print("pushing:", discovery.get(0))
                            searchWallboxPage.selectedWallboxes.push(discovery.get(0))
                            pageStack.push(setupWallboxComponent, {thingDescriptors: searchWallboxPage.selectedWallboxes})
                        }
                    }
                }
            }

            Component.onCompleted: {
                print("starting discovery")
//                discovery.discoverThings(root.kebaThingClassId)
                discovery.discoverThingsByInterface("evcharger")
            }

            property var selectedWallboxes: []

            content: Item {
                anchors.fill: parent

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


                Label {
                    anchors.centerIn: parent
                    visible: !discovery.busy && discovery.count == 0
                    width: parent.width - Style.margins * 2
                    text: qsTr("No wallbox has been found. Please return to the previous step and verify that your wallbox is installed properly.")
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                ColumnLayout {
                    anchors.fill: parent
                    visible: !discovery.busy && discovery.count > 1

                    Label {
                        Layout.fillWidth: true
                        Layout.margins: Style.margins
                        text: qsTr("Multiple wallboxes have been found in your network. Please select the ones you'd like to use with nymea.energy.")
                        wrapMode: Text.WordWrap
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
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
                                CheckBox {
                                    checked: searchWallboxPage.selectedWallboxes.indexOf(discovery.get(index)) >= 0
                                    onClicked: wallboxDelegate.clicked()
                                }
                            }

                            width: parent.width
                            onClicked: {
                                console.warn("clicked")
                                var list = searchWallboxPage.selectedWallboxes
                                var idx = list.indexOf(discovery.get(index))
                                if (idx < 0) {
                                    list.push(discovery.get(index))
                                } else {
                                    list.splice(idx, 1)
                                }
                                console.warn("new list:", list)
                                searchWallboxPage.selectedWallboxes = list
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: setupWallboxComponent
        ConsolinnoWizardPageBase {
            id: setupWallboxPage

            showBackButton: false

            onNext: root.done()

            property var thingDescriptors: []

            readonly property ThingDescriptor thingDescriptor: thingDescriptors[0]

            property int pendingCallId: -1
            property int thingError: Thing.ThingErrorNoError

            property Thing thing: null

            Component.onCompleted: {
                print("SetupWallboxPage created")
                pendingCallId = engine.thingManager.addDiscoveredThing(thingDescriptor.thingClassId, thingDescriptor.id, thingDescriptor.name, {})
            }

            Connections {
                target: engine.thingManager
                onAddThingReply: {
                    if (commandId == setupWallboxPage.pendingCallId) {
                        setupWallboxPage.thingError = thingError
                        setupWallboxPage.pendingCallId = -1
                        thing = engine.thingManager.things.getThing(thingId)
                    }
                }
            }

            content: Item {
                anchors.fill: parent

                BusyIndicator {
                    anchors.centerIn: parent
                    visible: setupWallboxPage.pendingCallId != -1
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    width: parent.width - Style.margins * 2
                    visible: setupWallboxPage.pendingCallId == -1 && setupWallboxPage.thingError == Thing.ThingErrorNoError

                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: setupWallboxPage.thingDescriptors[0].name
                    }
                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: setupWallboxPage.thingDescriptors[0].description
                        font: Style.smallFont
                    }

                    Image {
                        Layout.preferredWidth: 200
                        // w : h = ssw : ssh
                        Layout.preferredHeight: width * sourceSize.height / sourceSize.width
                        Layout.alignment: Qt.AlignHCenter
                        source: "/images/wallboxes/keba/P30_Typ1_ml.png"
                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: qsTr("The wallbox has been found and set up.")
                        horizontalAlignment: Text.AlignHCenter
                    }

                    TextField {
                        Layout.alignment: Qt.AlignHCenter
                        text: setupWallboxPage.thing.name
                        horizontalAlignment: Text.AlignHCenter
                        onEditingFinished: {
                            engine.thingManager.editThing(setupWallboxPage.thing.id, text)
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    wrapMode: Text.WordWrap
                    text: qsTr("An unexpected error happened during the setup. Please verify the wallbox is installed correctly and try again.")
                    visible: setupWallboxPage.thingError != Thing.ThingErrorNoError
                }
            }
        }
    }
}
