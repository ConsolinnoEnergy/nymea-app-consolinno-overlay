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
    property BatteryConfiguration batteryConfiguration
    property Thing thing
    property int directionID: 0
    property bool isSetup: false
    signal done()

    header: NymeaHeader {
        text: thing.name
        backButtonVisible: directionID === 1 ? false : true
        onBackPressed: pageStack.pop()
    }

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onSetBatteryConfigurationReply: {
            if (commandId == d.pendingCallId) {
                d.pendingCallId = -1

                switch (error) {
                case "HemsErrorNoError":
                    pageStack.pop()
                    return;
                case "HemsErrorInvalidParameter":
                    footer.text = qsTr("Could not save configuration. One of the parameters is invalid.");
                    break;
                case "HemsErrorInvalidThing":
                    footer.text = qsTr("Could not save configuration. The thing is not valid.");
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
            visible: thing.thingClass.interfaces.includes("controllablebattery")

            Label {
                Layout.fillWidth: true
                text: qsTr("Grid-supportive-control")
            }

            ConsolinnoSwitch {
                id: gridSupportControl
                Component.onCompleted: checked = batteryConfiguration.controllableLocalSystem
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: thing.thingClass.interfaces.includes("controllablebattery")

            Text {
                Layout.fillWidth: true
                font: Style.smallFont
                color: Style.consolinnoMedium
                wrapMode: Text.Wrap
                text: qsTr("If the device must be controlled in accordance with § 14a, this setting must be enabled.")
            }
        }

        RowLayout{
            Layout.fillWidth: true
            visible: (hemsManager.availableUseCases & HemsManager.HemsUseCaseAvoidZeroCompensation) !== 0

            Label {
                text: qsTr("Avoid zero compensation")
            }

            InfoButton {
                id: avoidZeroCompensationInfo
                Layout.fillWidth: true
                Layout.bottomMargin: 17
                push: "AvoidZeroCompensationInfo.qml"
            }

            ConsolinnoSwitch {
                id: zeroCompensationControl
                Component.onCompleted: checked = batteryConfiguration.avoidZeroFeedInEnabled
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

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
                hemsManager.setBatteryConfiguration(batteryConfiguration.batteryThingId, { controllableLocalSystem: gridSupportControl.checked, avoidZeroFeedInEnabled: zeroCompensationControl.checked})
                if(directionID !== 1){
                    pageStack.pop()
                }
                root.done()
            }
        }
    }
}
