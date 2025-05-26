import QtQuick 2.4
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.12
import "../components"
import "../delegates"
import Nymea 1.0

Page {
    id: root
    signal startWizard()
    property HemsManager hemsManager


    header: NymeaHeader {
        text: qsTr("Device Overview")
        onBackPressed: {
            if (hemsManager.availableUseCases === 0){
                pageStack.pop()
                pageStack.pop()
            }
            else{
                pageStack.pop()
            }

        }

        HeaderButton {
            imageSource: "../images/find.svg"
            color: filterInput.shown ? Style.accentColor : Style.iconColor
            onClicked: filterInput.shown = !filterInput.shown

        }

    }

    QtObject {
        id: d
        property var thingToRemove: null
    }

    Connections {
        target: engine.thingManager
        onRemoveThingReply: {
            if (!d.thingToRemove) {
                return;
            }

            switch (thingError) {
            case Thing.ThingErrorNoError:
                d.thingToRemove = null;
                return;
            case Thing.ThingErrorThingInRule:
                var removeMethodComponent = Qt.createComponent(Qt.resolvedUrl("../components/RemoveThingMethodDialog.qml"))
                var popup = removeMethodComponent.createObject(root, {thing: d.thingToRemove, rulesList: ruleIds});
                popup.open();
                return;
            default:
                var errorDialog = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"))
                var popup = errorDialog.createObject(root, {error: thingError})
                popup.open();
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent


        Button{
            id: startWizardButton
            text: qsTr("Start Wizard")
            Layout.alignment: Qt.AlignHCenter

            Layout.preferredWidth: 300
            Layout.minimumWidth: 100
            Layout.topMargin: 10
            onClicked:{
                // go back to ConsolinnoView.qml
                root.startWizard()
            }

            }



        Button{
            id: addDevice
            text: qsTr("Set up new device")
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 300
            Layout.minimumWidth: 100
            onClicked:{
                pageStack.push( "../wizards/AuthorisationView.qml", {directionID: 1, hemsManager: hemsManager})
            }
        }

        GroupedListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            model: ThingsProxy {
                id: thingsProxy
                engine: _engine
                groupByInterface: true
                nameFilter: filterInput.shown ? filterInput.text : ""
                hideTagId: "hiddenInDeviceView"
                hiddenInterfaces: ["gridsupport"]
            }

            delegate: ConsolinnoThingDelegate {
                property string iconPath: ""
                thing: thingsProxy.getThing(model.id)
                // FIXME: This isn't entirely correct... we should have a way to know if a particular thing is in fact autocreated
                // This check might be wrong for thingClasses with multiple create methods...

                canDelete: !thing.isChild || thing.thingClass.createMethods.indexOf("CreateMethodAuto") < 0
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("ConfigureThingPage.qml"), {thing: thing})
                }
                onDeleteClicked: {
                    d.thingToRemove = thing;
                    engine.thingManager.removeThing(d.thingToRemove.id)
                }
            }
        }
    }


    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: engine.thingManager.things.count === 0 && !engine.thingManager.fetchingData
        title: qsTr("There are no things set up yet.")
        text: qsTr("In order for your %1 system to be useful, go ahead and add some things.").arg(Configuration.systemName)
        imageSource: "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
        //buttonText: qsTr("Add a thing")
        buttonVisible: false
        //onButtonClicked: pageStack.push(Qt.resolvedUrl("NewThingPage.qml"))

    }
}
