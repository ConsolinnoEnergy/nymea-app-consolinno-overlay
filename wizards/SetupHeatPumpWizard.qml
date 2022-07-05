import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.12
import "qrc:/ui/components"
import Nymea 1.0

import "../components"
import "../delegates"

Page {
    id: root

    signal done(bool skip, bool abort);

    header: NymeaHeader {
        text: qsTr("Setup heat pump")
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom;left: parent.left; right: parent.right; margins: Style.margins }
        width: Math.min(parent.width - Style.margins * 2, 300)
        spacing: Style.margins


        Label {
            Layout.fillWidth: true
            text: qsTr("Integrated heat pumps")
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignLeft
            horizontalAlignment: Text.AlignLeft
        }


        VerticalDivider
        {
            Layout.fillWidth: true
            dividerColor: Material.accent
        }

        Flickable{
            id: heatpumpFlickable
            clip: true
            width: parent.width
            height: parent.height
            contentHeight: heatpumpList.height
            contentWidth: app.width

            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: app.height/4
            Layout.preferredWidth: app.width/2
            flickableDirection: Flickable.VerticalFlick

            ColumnLayout{
                id: heatpumpList
                Layout.preferredWidth: app.width/2
                Layout.fillHeight: true
                Repeater{
                    id: heatpumpRepeater
                    Layout.preferredWidth: app.width/2
                    model: ThingsProxy {
                        id: hpProxy
                        engine: _engine
                        shownInterfaces: ["heatpump"]
                    }
                    delegate: ItemDelegate{
                        Layout.preferredWidth: app.width/2
                        contentItem: ConsolinnoItemDelegate{
                            Layout.fillWidth: true
                            progressive: false
                            text: hpProxy.get(index) ? hpProxy.get(index).name : ""
                            onClicked: {
                            }
                        }
                    }


                }
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

            Button {
                text: qsTr("cancel")
                //color: Style.yellow
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                onClicked: root.done(false, true)
            }
            Button {
                text: qsTr("add")
                //color: Style.accentColor
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignHCenter
                onClicked:  pageStack.push(searchHeatPumpComponent, {thingClassId: thingClassComboBox.currentValue})
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
        id: searchHeatPumpComponent

        Page {
            id: searchHeatPumpPage
            property string thingClassId: null

            //onBack: pageStack.pop()

            //showBackButton: false
            //showNextButton: false
            //onNext: pageStack.push(setupHeatPumpComponent, {thingDescriptors: selectedWallboxes})

            header: NymeaHeader {
                text: qsTr("Heatpump")
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

            ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; margins: Style.margins }
                width: Math.min(parent.width - Style.margins * 2, 300)
                spacing: Style.margins

//                Label {
//                    Layout.fillWidth: true
//                    //text: qsTr("Heat pump")
//                    text: thingClassId
//                    font: Style.bigFont
//                    wrapMode: Text.WordWrap
//                    horizontalAlignment: Text.AlignHCenter
//                }

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

                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("back")
                            //color: Style.yellow
                            Layout.preferredWidth: 200
                            onClicked: pageStack.pop()
                        }
                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("cancel")
                            //color: Style.yellow
                            Layout.preferredWidth: 200
                            onClicked: root.done(false, true)
                        }
                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("skip")
                            //color: Style.blue
                            Layout.preferredWidth: 200
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
        Page {
            id: setupHeatPumpPage

            header: NymeaHeader {
                text: qsTr("Heatpump")
                onBackPressed: pageStack.pop(root)
            }

            //showNextButton: false
            //showBackButton: false

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

            ColumnLayout {
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
                        text: setupHeatPumpPage.thingClass.displayName
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

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("back")
                    //color: Style.yellow
                    Layout.preferredWidth: 200
                    onClicked: pageStack.pop(root)
                }

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("next")
                    Layout.preferredWidth: 200
                    onClicked:{
                        var page = pageStack.push("../optimization/HeatingOptimization.qml", { hemsManager: hemsManager, heatingConfiguration:  hemsManager.heatingConfigurations.getHeatingConfiguration(thing.id), heatPumpThing: thing, directionID: 1})
                        page.done.connect(function(){
                            pageStack.pop(root)
                            //root.done(false, false)
                        })

                    } //root.done(false, false)
                }
            }
        }
    }
}
