import QtQuick 2.8
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import Nymea 1.0

import "../components"
import "../delegates"

Page {
    id: root

    property ThingClass thingClass: thing ? thing.thingClass : null
    property Thing thing: null

    signal aborted();
    signal done(var attr);


    QtObject {
        id: d
        property var vendorId: null
        property ThingDescriptor thingDescriptor: null
        property var discoveryParams: []
        property string thingName: ""
        property int pairRequestId: 0
        property var pairingTransactionId: null
        property int addRequestId: 0
        property var name: ""
        property var params: []
        property var states: []
        property var settings: []
        property var attr: []


        function pairThing() {
            engine.thingManager.addThing(root.thingClass.id, d.name, params);
            //busyOverlay.shown = true;
        }
    }

    Component.onCompleted: {
        // Setting up a new thing
        internalPageStack.push(paramsPage)

    }

    Connections {
        target: engine.thingManager

        onAddThingReply: {
            busyOverlay.shown = false;
            internalPageStack.push(resultsPage, {thingError: thingError, thingId: thingId, message: displayMessage})
        }

        onThingAdded:{

            for(var i = 0; i < d.states.length; i++){
                thing.executeAction( d.states[i].name, [{ paramName: d.states[i].name , value: d.states[i].value }])

            }

            for (var j = 0; j < d.settings.length; j++){
                engine.thingManager.setThingSettings(thing.id, [{ paramTypeId: d.settings[j].paramTypeId , value: d.settings[j].value }])
            }

        }

    }

    StackView {
        id: internalPageStack
        anchors.fill: parent
    }
    property QtObject pageStack: QtObject {
        function pop(item) {
            if (internalPageStack.depth > 1) {
                internalPageStack.pop(item)
            } else {
                root.aborted()
            }
        }
    }

    Component {
        id: paramsPage
        SettingsPageBase {
            id: paramsView
            title: qsTr("Set up %1").arg(root.thingClass.displayName)

            SettingsPageSectionHeader {
                text: qsTr("Name the thing:")
            }

            TextField {
                id: nameTextField
                text: (d.thingName ? d.thingName : root.thingClass.displayName)
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
            }


            Repeater{
                id: customRepeater
                Layout.fillWidth: true
                property var attributes: ({})
                // if you want to add atribute:
                // add one in the model
                model:[

                    {id: "batteryLevel", name: "Battery Level", component: batteryLevelComponent, type: "state", Uuid: "3f1cca10-8988-4ec6-b937-0775653cde12", info: "BatteryLevel.qml" },
                    {id: "capacity", name: "Capacity", component: capacityComponent, type: "state", Uuid: "363a2a39-61b6-4109-9cd9-aca7367d12c7", info: "Capacity.qml"  },
                    {id: "minChargingCurrent", name: "Minimum charging current", component: minimumChargingCurrentComponent, type: "setting", Uuid: "0c55516d-4285-4d02-8926-1dae03649e18", info: "MinimumChargingCurrent.qml"},
                    {id: "maxChargingLimit", name: "Maximum charging limit" , component: maximumAllowedChargingLimitComponent, type: "attr", Uuid: "", info: "MaximumAllowedChargingLimit.qml" },


                ]

                delegate: ItemDelegate
                {
                    id: attribute


                    Layout.fillWidth: true
                    contentItem: ColumnLayout{
                        id: contentItemColumn
                        Layout.fillWidth: true
                        RowLayout{
                            Layout.fillWidth: true
                            spacing: app.margins

                            Row{
                                Layout.fillWidth: true
                                Label{
                                    id: customRepeaterModelName
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignLeft
                                    text: modelData.name

                                }

                                InfoButton{
                                    property var infoPage: modelData.info
                                    visible: modelData.info ? true : false
                                    push: infoPage
                                    stack: internalPageStack
                                    anchors.left: customRepeaterModelName.right
                                    anchors.leftMargin:  5
                                }



                            }
                            // define the case in the Loader
                            Loader{
                                id: paramLoader

                                Layout.fillWidth: true
                                Layout.rightMargin: 0
                                sourceComponent: {
                                    switch(modelData.name){
                                    case "Maximum charging limit":
                                        {
                                            return maximumAllowedChargingLimitComponent
                                        }
                                    case "Minimum charging current":
                                        {
                                            return minimumChargingCurrentComponent
                                        }
                                    case "Capacity":
                                        {
                                            return capacityComponent
                                        }
                                    case "Battery Level":
                                        {
                                            return batteryLevelComponent
                                        }

                                    }

                                }
                            }

                        }

                    }
                }

            }

// individual Components for the different attributes
            // and build a component
            Component{
                id: maximumAllowedChargingLimitComponent
                RowLayout{
                    Layout.fillWidth: true
                    Slider
                    {
                        id: maximumChargingSlider
                        Layout.fillWidth: true
                        Layout.maximumWidth: 170
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: 0
                        from: 0
                        to: 100
                        stepSize: 1
                        value: 100

                        onPositionChanged:{
                          customRepeater.attributes["maxChargingLimit"] = value
                        }

                    }
                    Label{

                        Layout.fillWidth: true
                        Layout.maximumWidth: 40
                        Layout.rightMargin: 0
                        horizontalAlignment: Text.AlignRight
                        id: maximumChargingLimitLabel
                        text: maximumChargingSlider.value + "%"
                    }

                }

            }

            Component{
                id: minimumChargingCurrentComponent

                RowLayout{

                    Layout.fillWidth: true
                    Slider
                    {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignRight
                        Layout.maximumWidth: 170
                        id: minimumChargingCurrentSlider
                        from: 6
                        to: 16
                        stepSize: 1

                        onPositionChanged:{
                          customRepeater.attributes["minChargingCurrent"] = value
                        }

                    }

                    Label{
                        Layout.preferredWidth: 40
                        Layout.rightMargin: 0
                        horizontalAlignment: Text.AlignRight
                        id: minimumChargingCurrentLabel
                        text: minimumChargingCurrentSlider.value + " A"
                    }

                }

            }

            Component{
                id: capacityComponent
                RowLayout{
                    Layout.fillWidth: true
                    // at some time replace this one
                    NymeaSpinBox
                    {
                        property var capacity: value
                        Layout.fillWidth: true
                        Layout.maximumWidth: 150
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: 0

                        value: 50
                        id: capacitySpinbox
                        from: 0
                        to: 100

                        onCapacityChanged:{

                            if (value >= 0){
                                customRepeater.attributes["capacity"] = value
                            }else{
                                value = 0
                            }

                        }



                    }

                    Label{
                        Layout.preferredWidth: 20
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: 0
                        horizontalAlignment: Text.AlignRight
                        id: capacityComponentLabel
                        text: " kWh"
                    }

                }

            }

            Component{
                id: batteryLevelComponent
                RowLayout{
                    Layout.fillWidth: true
                    Slider
                    {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignRight
                        Layout.maximumWidth: 170
                        id: batteryLevelSlider
                        from: 0
                        to: 100
                        stepSize: 1
                        onPositionChanged:{
                            customRepeater.attributes["batteryLevel"] = value
                        }

                    }

                    Label{
                        Layout.preferredWidth: 30
                        Layout.rightMargin: 0
                        Layout.alignment: Qt.AlignRight
                        horizontalAlignment: Text.AlignRight
                        id: batteryLevelLabel
                        text: batteryLevelSlider.value + "%"
                    }

                }

            }



            Button {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                text: "OK"
                onClicked: {
                    var states = []
                    var settings = []
                    var attrs = []

                    for(var i = 0; i < customRepeater.count; i++)
                    {
                        var state   = {}
                        var setting = {}
                        var attr   = {}

                        var attribute = customRepeater.model[i]
                        if (attribute.type === "state")
                        {

                            state.value = customRepeater.attributes[attribute.id]
                            state.name = attribute.id
                            states.push(state)

                        }else if(attribute.type === "setting"){

                            setting.paramTypeId = attribute.Uuid

                            setting.value = customRepeater.attributes[attribute.id]
                            settings.push(setting)

                        }else if(attribute.type === "attr"){

                            attr.id = attribute.id
                            attr.value = customRepeater.attributes[attribute.id]
                            attrs.push(attr)
                        }

                    }






                    d.settings = settings
                    d.states = states
                    d.attr = attrs
                    d.name = nameTextField.text
                    d.pairThing();

                }
            }
        }
    }


    Component {
        id: resultsPage

        Page {
            id: resultsView
            header: NymeaHeader {
                text: root.thing ? qsTr("Reconfigure %1").arg(root.thing.name) : qsTr("Set up %1").arg(root.thingClass.displayName)
                onBackPressed: pageStack.pop()
            }

            property string thingId
            property int thingError
            property string message

            readonly property bool success: thingError === Thing.ThingErrorNoError

            readonly property Thing thing: root.thing ? root.thing : engine.thingManager.things.getThing(thingId)

            ColumnLayout {
                width: Math.min(500, parent.width - app.margins * 2)
                anchors.centerIn: parent
                spacing: app.margins * 2
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: resultsView.success ? root.thing ? qsTr("Thing reconfigured!") : qsTr("Thing added!") : qsTr("Uh oh")
                    font.pixelSize: app.largeFont
                    color: Style.accentColor
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: resultsView.success ? qsTr("All done. You can now start using %1.").arg(resultsView.thing.name) : qsTr("Something went wrong setting up this thing...");
                }

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: resultsView.message
                }


                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    visible: !resultsView.success
                    text: "Retry"
                    onClicked: {
                        internalPageStack.pop({immediate: true});
                        internalPageStack.pop({immediate: true});
                        d.pairThing();
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                    text: qsTr("Ok")
                    onClicked: {
                        root.done(d.attr);
                    }
                }
            }
        }
    }

    BusyOverlay {
        id: busyOverlay
    }
}
