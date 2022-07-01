import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import "qrc:/ui/components"
import Nymea 1.0

import "../components"
import "../delegates"

ConsolinnoWizardPageBase {
    id: root

    showBackButton: false
    showNextButton: false

    onNext: pageStack.push(searchHeatPumpComponent, {thingClassId: thingClassComboBox.currentValue})

    content: ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: Style.margins }
        width: Math.min(parent.width - Style.margins * 2, 300)
        spacing: Style.margins
        Label {
            Layout.fillWidth: true
            text: qsTr("Heat pump")
            font: Style.bigFont
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Please select your model:")
        }

        ColumnLayout {
            Layout.topMargin: Style.margins
            Label {
                Layout.fillWidth: true
                text: qsTr("Model:")
            }

            ComboBox {
                id: thingClassComboBox
                Layout.fillWidth: true
                textRole: "displayName"
                valueRole: "id"
                model: ThingClassesProxy {
                    engine: _engine
                    filterInterface: "heatpump"
                }
            }
        }

        ColumnLayout {
            spacing: Style.margins
            Layout.alignment: Qt.AlignHCenter

            ConsolinnoButton {
                text: qsTr("cancel")
                color: Style.yellow
                Layout.alignment: Qt.AlignHCenter
                onClicked: root.done(false, true)
            }
            ConsolinnoButton {
                text: qsTr("next")
                color: Style.accentColor
                Layout.alignment: Qt.AlignHCenter
                onClicked: root.next()
            }
            ConsolinnoButton {
                text: qsTr("skip")
                color: Style.blue
                Layout.alignment: Qt.AlignHCenter
                onClicked: root.done(true, false)
            }
        }

    }

    Component {
        id: searchHeatPumpComponent

        ConsolinnoWizardPageBase {
            id: searchHeatPumpPage
            property string thingClassId: null

            onBack: pageStack.pop()

            showBackButton: false
            showNextButton: false
            onNext: pageStack.push(setupHeatPumpComponent, {thingDescriptors: selectedWallboxes})

            ThingDiscovery {
                id: discovery
                engine: _engine


                onBusyChanged: {
                    if (!busy) {
                        print("discovery finished! Count:", count, discovery.count)
                        if (count == 1) {
                            print("pushing:", discovery.get(0))
                            pageStack.push(setupHeatPumpComponent, {thingDescriptor: discovery.get(0)})
                        }
                        // added to get passed the setup
                        if(count == 0){
                            pageStack.push(setupHeatPumpComponent, {thingClassId: thingClassId})

                        }


                    }
                }
            }

            Component.onCompleted: {
                print("starting discovery")
                discovery.discoverThings(searchHeatPumpPage.thingClassId)
            }

            content: ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: Style.margins }
                width: Math.min(parent.width - Style.margins * 2, 300)
                spacing: Style.margins

                Label {
                    Layout.fillWidth: true
                    //text: qsTr("Heat pump")
                    text: thingClassId
                    font: Style.bigFont
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

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
                        visible:  false //!discovery.busy && discovery.count == 0

                        Label {
                            Layout.fillWidth: true
                            Layout.bottomMargin: Style.bigMargins
                            text: qsTr("No heat pump has been found. Please return to the previous step and verify that your heat pump is installed properly.")
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }

                        ConsolinnoButton {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("back")
                            color: Style.yellow
                            onClicked: pageStack.pop()
                        }
                        ConsolinnoButton {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("cancel")
                            color: Style.yellow
                            onClicked: root.done(false, true)
                        }
                        ConsolinnoButton {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("skip")
                            color: Style.blue
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
                        text: qsTr("Multiple heat pumps have been found in your network. Please select the one you'd like to use with your Leaflet.")
                        horizontalAlignment: Text.AlignHCenter
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
                            }

                            width: parent.width
                            onClicked: {
                                console.warn("clicked")
                                pageStack.push(setupHeatPumpComponent, {thingDescriptor: discovery.get(index)})
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: setupHeatPumpComponent
        ConsolinnoWizardPageBase {
            id: setupHeatPumpPage

            showNextButton: false
            showBackButton: false

            property ThingDescriptor thingDescriptor: null

            //added
            property var thingClassId: null
            property var thingClass: thingClassId ? engine.thingManager.thingClasses.getThingClass(thingClassId) : null

            property int pendingCallId: -1
            property int thingError: Thing.ThingErrorNoError

            property Thing thing: null


            function getParams(){

//                var params = []
//                for (var i = 0; i < paramRepeater.count; i++) {
//                    var param = {}
//                    var paramType = paramRepeater.itemAt(i).paramType
//                    if (!paramType.readOnly) {
//                        param.paramTypeId = paramType.id
//                        param.value = paramRepeater.itemAt(i).value
//                        print("adding param", param.paramTypeId, param.value)
//                        params.push(param)
//                    }
//                }

//                d.params = params
//                d.name = nameTextField.text
//                d.pairThing();

                var params = []
                for (var i = 0; i < thingClass.paramTypes.count; i++)
                {
                    var param = {}
                    param.paramTypeId = thingClass.paramTypes.get(i).id
                    param.value = thingClass.paramTypes.get(i).defaultValue
                    params.push(param)

                }

                return params



            }

            Component.onCompleted: {
                if (thingDescriptor){
                    pendingCallId = engine.thingManager.addDiscoveredThing(thingDescriptor.thingClassId, thingDescriptor.id, thingDescriptor.name, {})
                }
                else{
                    var thingclassparams = getParams()
                    engine.thingManager.addThing(thingClassId, thingClass.displayName , thingclassparams);
                }

                }


            HemsManager{
                id: hemsManager
                engine: _engine
            }


            Connections {
                target: engine.thingManager
                onAddThingReply: {

                    //labelfortesting.text = thingId
                    //if (commandId == setupHeatPumpPage.pendingCallId) {

                        setupHeatPumpPage.thingError = thingError
                        setupHeatPumpPage.pendingCallId = -1
                        setupHeatPumpPage.thing = engine.thingManager.things.getThing(thingId)
                    //}
                }
            }

            content: ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: Style.margins }
                width: Math.min(parent.width - Style.margins * 2, 300)
                spacing: Style.margins

                Label {
                    id: labelfortesting
                    Layout.fillWidth: true
                    text: qsTr("Heat pump")
                    font: Style.bigFont
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: setupHeatPumpPage.pendingCallId != -1

                    BusyIndicator {
                        anchors.centerIn: parent
                    }
                }


                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: setupHeatPumpPage.pendingCallId == -1 && setupHeatPumpPage.thingError == Thing.ThingErrorNoError
                    spacing: Style.margins

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: qsTr("The heat pump has been found and set up.")
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: setupHeatPumpPage.thingClass.name
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
                    text: qsTr("An unexpected error happened during the setup. Please verify the heat pump is installed correctly and try again.")
                    visible: setupHeatPumpPage.thingError != Thing.ThingErrorNoError
                }

                ConsolinnoButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("back")
                    color: Style.yellow
                    onClicked: pageStack.pop(root)
                }

                ConsolinnoButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("next")
                    onClicked:{
                        var page = pageStack.push("../optimization/HeatingOptimization.qml", { hemsManager: hemsManager, heatingConfiguration:  hemsManager.heatingConfigurations.getHeatingConfiguration(thing.id), heatpumpthing: thing, directionID: 1})
                        page.done.connect(function(){
                            root.done(false, false)
                        })

                    } //root.done(false, false)
                }
            }
        }
    }
}
