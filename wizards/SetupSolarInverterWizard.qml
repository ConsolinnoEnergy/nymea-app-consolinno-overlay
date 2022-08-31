import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.15

import "qrc:/ui/components"
import Nymea 1.0

import "../components"
import "../delegates"

Page {
    id: root

    signal done(bool skip, bool abort, bool back);

    header: NymeaHeader {
        text: qsTr("Setup solar inverter")
        backButtonVisible: true
        onBackPressed: root.done(false, false, true)
    }


    ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right;  margins: Style.margins }
        width: Math.min(parent.width - Style.margins * 2, 300)


    ColumnLayout{
        Layout.fillWidth: true
        Layout.fillHeight: true

        Label {
            Layout.fillWidth: true
            text: qsTr("Integrated solar inverter:")
            //Layout.leftMargin: 0
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
            id: energyMeterFlickable
            clip: true
            width: parent.width
            height: parent.height
            contentHeight: energyMeterList.height
            contentWidth: app.width
            visible: emProxy.count !== 0

            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: app.height/3
            Layout.preferredWidth: app.width
            flickableDirection: Flickable.VerticalFlick

            ColumnLayout{
                id: energyMeterList
                Layout.preferredWidth: app.width
                Layout.fillHeight: true
                Repeater{
                    id: solarInverterRepeater
                    Layout.preferredWidth: app.width
                    model: ThingsProxy {
                        id: emProxy
                        engine: _engine
                        shownInterfaces: ["solarinverter"]
                    }
                    delegate: ItemDelegate{
                        Layout.preferredWidth: app.width
                        contentItem: ConsolinnoItemDelegate{
                            Layout.fillWidth: true
                            iconName: "../images/weathericons/weather-clear-day.svg"
                            progressive: false
                            text: emProxy.get(index) ? emProxy.get(index).name : ""
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
        visible: emProxy.count === 0
        color: Material.background
        Text {
            text: qsTr("There is no inverter set up yet.")
            color: Material.foreground
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
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
            Label {
                Layout.fillWidth: true
                text: qsTr("Add solar Inverter: ")
                wrapMode: Text.WordWrap
            }

            ComboBox {
                id: thingClassComboBox
                Layout.preferredWidth: app.width - 2*Style.margins
                textRole: "displayName"
                valueRole: "id"
                model: ThingClassesProxy {
                    engine: _engine
                    filterInterface: "solarinverter"
                    includeProvidedInterfaces: true
                }
            }
        }

        ColumnLayout {
            spacing: 0
            Layout.alignment: Qt.AlignHCenter

            Button {
                text: qsTr("cancel")
                //color: Style.yellow
                Layout.preferredWidth: 200
                //Layout.alignment: Qt.AlignHCenter
//                contentItem: Text {
//                    text: parent.text
//                    font: parent.font
//                    horizontalAlignment : Text.AlignLeft
//                    verticalAlignment: Text.AlignVCenter
//                }

                onClicked: root.done(false, true, false)
            }
            Button {
                id: addButton
                text: qsTr("add")
                //color: Style.accentColor
                Layout.preferredWidth: 200
                //Layout.alignment: Qt.AlignHCenter
                Layout.alignment: Qt.AlignLeft
                onClicked: pageStack.push(searchInverterComponent, {thingClassId: thingClassComboBox.currentValue})
            }

            // Having 0 Solar inverter will be supporter at a later stage
            Button {
                id: nextStepButton
                text: qsTr("Next step")
                Layout.preferredWidth: 200
                Layout.preferredHeight: addButton.height - 9
                // background fucks up the margin between the buttons, thats why wee need this topMargin
                Layout.topMargin: 5

                contentItem:Row{
                    Text{
                        id: nextStepButtonText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: nextStepButton.text
                        font: nextStepButton.font
                        opacity: enabled ? 1.0 : 0.3
                        color: Material.foreground
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    Image{
                        id: headerImage
                        anchors.right : parent.right
                        anchors.verticalCenter:  parent.verticalCenter

                        sourceSize.width: 18
                        sourceSize.height: 18
                        source: "../images/next.svg"

                        layer{
                            enabled: true
                            effect: ColorOverlay{
                                color: Material.foreground
                            }
                        }
                    }

                }




                background: Rectangle{
                    height: parent.height
                    width: parent.width
                    border.color: Material.background
                    color: solarInverterRepeater.count > 0  ? Style.consolinnoHighlight : "grey"
                    radius: 4
                }

                Layout.alignment: Qt.AlignHCenter
                onClicked:{
                    if (solarInverterRepeater.count >0){
                        root.done(true, false, false)
                    }
                }

            }
        }

    }

    Component {
        id: searchInverterComponent

        Page {
            id: searchInverterPage
            property var thingClassId: null


            header: NymeaHeader {
                text: qsTr("Solar inverter")
                backButtonVisible: false
                Layout.topMargin: 10
                //onBackPressed: pageStack.pop()
            }

            ThingDiscovery {
                id: discovery
                engine: _engine


                onBusyChanged: {
                    if (!busy) {
                        print("discovery finished! Count:", count, discovery.count)
                        if (count === 1) {
                            print("pushing:", discovery.get(0))
                            pageStack.push(setupInverterComponent, {thingDescriptor: discovery.get(0)})
                        }
                    }
                }
            }

            Component.onCompleted: {
                print("starting discovery")
                discovery.discoverThings(searchInverterPage.thingClassId)
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
                        visible: !discovery.busy && discovery.count === 0

                        Label {
                            Layout.fillWidth: true
                            Layout.bottomMargin: Style.bigMargins
                            text: qsTr("No solar inverter has been found. Please return to the previous step and verify that your solar inverter is installed properly.")
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 200
                            text: qsTr("back")
                            //color: Style.yellow
                            onClicked: pageStack.pop()
                        }
                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 200
                            text: qsTr("cancel")
                            //color: Style.yellow
                            onClicked: root.done(false, true, false)
                        }
                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 200
                            text: qsTr("skip")
                            //color: Style.blue
                            onClicked: root.done(true, false, false)
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
                        text: qsTr("Multiple solar inverters have been found in your network. Please select the one you'd like to use with your Leaflet.")
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
                                pageStack.push(setupInverterComponent, {thingDescriptor: discovery.get(index)})
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: setupInverterComponent
        Page {
            id: setupEnergyMeterPage

            property ThingDescriptor thingDescriptor: null

            property int pendingCallId: -1
            property int thingError: Thing.ThingErrorNoError

            property Thing thing: null


            header: NymeaHeader {
                text: qsTr("Solar inverter")
                backButtonVisible: false
                //onBackPressed: pageStack.pop(root)
            }

            Component.onCompleted: {
                pendingCallId = engine.thingManager.addDiscoveredThing(thingDescriptor.thingClassId, thingDescriptor.id, thingDescriptor.name, {})
            }

            HemsManager{
                id: hemsManager
                engine: _engine
            }

            Connections {
                target: engine.thingManager
                onAddThingReply: {
                    if (commandId === setupEnergyMeterPage.pendingCallId) {
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
                        text: qsTr("The following solar inverter has been found and set up:")
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
                    text: qsTr("An unexpected error happened during the setup. Please verify the solar inverter is installed correctly and try again.")
                    visible: setupEnergyMeterPage.thingError != Thing.ThingErrorNoError
                }

                ColumnLayout{
                    spacing: 0
                    Layout.alignment: Qt.AlignHCenter

                    Button {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 200
                        text: qsTr("Next")
                        onClicked:{
                            var page = pageStack.push("../optimization/PVOptimization.qml", { hemsManager: hemsManager, pvConfiguration:  hemsManager.pvConfigurations.getPvConfiguration(thing.id), thing: thing, directionID: 1} )
                            page.done.connect(function(){
                                pageStack.pop(root)
                                //root.done(false, false)
                            })
                        }

                    }
                }
            }
        }
    }
}
