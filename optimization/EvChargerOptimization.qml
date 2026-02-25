import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts
import Nymea 1.0
import "../components"
import "../delegates"


Page {
    id: root
    property HemsManager hemsManager
    property Thing thing
    property ChargingOptimizationConfiguration chargingOptimizationConfiguration: hemsManager.chargingOptimizationConfigurations.getChargingOptimizationConfiguration(thing.id)
    property ChargingConfiguration chargingConfiguration: hemsManager.chargingConfigurations.getChargingConfiguration(thing.id)
    property int directionID: 0
    signal done()

    header: NymeaHeader {
        text: qsTr("Wallbox configuration")
        backButtonVisible: directionID === 1 ? false : true
        onBackPressed: pageStack.pop()
    }

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onSetChargingOptimizationConfigurationReply: {
            if (commandId == d.pendingCallId) {
                d.pendingCallId = -1

                switch (error) {
                case "HemsErrorNoError":
                    pageStack.pop()
                    return;
                case "HemsErrorInvalidParameter":
                    props.text = qsTr("Could not save configuration. One of the parameters is invalid.");
                    break;
                case "HemsErrorInvalidThing":
                    props.text = qsTr("Could not save configuration. The thing is not valid.");
                    break;
                default:
                    props.errorCode = error;
                }
                var comp = Qt.createComponent("../components/ErrorDialog.qml")
                var popup = comp.createObject(app, props)
                popup.open();
            }
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: app.margins


        RowLayout{
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: qsTr("Grid-supportive control")

            }

            ConsolinnoSwitch {
                id: gridSupportControl
                Component.onCompleted: checked = chargingOptimizationConfiguration.controllableLocalSystem
            }
        }


        ColumnLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                font: Style.smallFont
                wrapMode: Text.Wrap
                color: Style.consolinnoMedium
                text: qsTr("If the device must be controlled according to §14a, then this setting must be enabled.")
            }
        }

        Item {
            // place holder
            Layout.fillHeight: true
            Layout.fillWidth: true
        }



        // potential footer for the config app, as a way to show the user that certain attributes where invalid.
        Label {
            id: footer
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            color: Style.dangerAccent
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont

        }


        Button {
            id: savebutton
            Layout.fillWidth: true
            text: qsTr("Save")
            onClicked: {
                    hemsManager.setChargingOptimizationConfiguration(chargingConfiguration.evChargerThingId, {controllableLocalSystem: gridSupportControl.checked,})
                    if(directionID !== 1){
                        pageStack.pop()
                    }
                    root.done()
            }
        }
    }
}

