import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"


Page {
    id: root
    property HemsManager hemsManager

    property ChargingConfiguration chargingConfiguration
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
        /*
        onSetHeatingConfigurationReply: {
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
        */
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: app.margins


        ColumnLayout {
            Layout.fillWidth: true
            Label {
                font: Style.Font
                color: Style.green
                text: qsTr("Grid-supportive-control")
            }

            Text {
                Layout.fillWidth: true
                font: Style.smallFont
                wrapMode: Text.Wrap
                text: qsTr("If the device musst be controlled in accordance with § 14a, the control must be activated.")
            }
        }

        RowLayout{
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: qsTr("activated")

            }

            Switch {
                id: gridSupportControl
                checked: chargingConfiguration.controllableLocalSystem
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
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont

        }


        Button {
            id: savebutton

            Layout.fillWidth: true
            text: qsTr("Save")
            onClicked: {

                if (savebutton.validated)
                {
                    hemsManager.setChargingConfiguration(chargingConfiguration.evChargerThingId, {carThingId: chargingConfiguration.carThingId, controllableLocalSystem: gridSupportControl.checked})
                    root.done()
                }
                else
                {
                    // for now this is the way how we show the user that some attributes are invalid
                    // TO DO: Show which ones are invalid
                    footer.text = qsTr("Some attributes are outside of the allowed range: Configurations were not saved.")
                }

            }
        }

    }
}

