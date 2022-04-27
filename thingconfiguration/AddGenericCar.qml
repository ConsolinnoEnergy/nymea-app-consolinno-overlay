import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import Nymea 1.0

import "../components"
import "../delegates"

Page {
    id: root

    property ThingClass thingClass: thing ? thing.thingClass : null
    property Thing thing: null

    signal aborted();
    signal done();


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

            SettingsPageSectionHeader {
                id: settingsPageSection
                text: qsTr("Thing parameters")
                visible: paramRepeater.count > 0
            }
            // use this to set the states of the Thing
            Repeater {
                id: paramRepeater
                model: engine.jsonRpcClient.ensureServerVersion("1.12") ?  root.thingClass.paramTypes : null
                delegate: ParamDelegate {
                    Layout.fillWidth: true
                    enabled: !model.readOnly
                    paramType: root.thingClass.paramTypes.get(index)
                    value: {
                        // Manual setup, use default value from thing class
                        return root.thingClass.paramTypes.get(index).defaultValue
                    }
                }
            }

            Repeater {
                id: stateRepeater
                model: engine.jsonRpcClient.ensureServerVersion("1.12") ?  root.thingClass.stateTypes : null
                delegate: StateDelegate {


                    visible: {



                        for (var i = 0; i < settingsRepeater.count; i++){
                            // this is due to the integrationplugin of the generic car
                            // got to the integrationplugingenericcar.json file in the generic github and look for yourself
                            if ( param.paramTypeId.toString().match(/\{?20faf2b8-2b40-4bee-b228-97dbaf0cdffc\}?/) )
                            {

                                return false
                            }
                        }
                        return true
                    }
                    Layout.fillWidth: true
                    stateType: root.thingClass.stateTypes.get(index)
                    value: root.thingClass.stateTypes.get(index).defaultValue



                }
            }

            Repeater{
                id: settingsRepeater
                model: root.thingClass.settingsTypes
                delegate: ParamDelegate{
                Layout.fillWidth: true
                paramType: root.thingClass.settingsTypes.get(index)
                value: root.thingClass.settingsTypes.get(index).defaultValue
                writable: true

                }

            }




            Button {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                text: "OK"
                onClicked: {
                    var params = []
                    for (var i = 0; i < paramRepeater.count; i++) {
                        var param = {}
                        var paramType = paramRepeater.itemAt(i).paramType
                        if (!paramType.readOnly) {
                            param.paramTypeId = paramType.id
                            param.value = paramRepeater.itemAt(i).value
                            params.push(param)
                        }
                    }
                    // here we add the params to the QObject d

                    var states = []
                    for (var j = 0; j < stateRepeater.count; j++) {
                        var state = {}
                        var stateType = stateRepeater.itemAt(j).stateType

                            state.stateTypeId = stateType.id
                            state.name = stateType.name
                            state.value = stateRepeater.itemAt(j).value
                            states.push(state)

                    }



                    var settings = []
                    for (var k = 0; k < settingsRepeater.count; k++) {

                        var setting = {}
                        setting["paramTypeId"] = settingsRepeater.itemAt(k).param.paramTypeId
                        setting["value"] = settingsRepeater.itemAt(k).param.value
                        settings.push(setting)
                    }



                    d.settings = settings
                    d.states = states
                    d.params = params
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
                        root.done();
                    }
                }
            }
        }
    }

    BusyOverlay {
        id: busyOverlay
    }
}
