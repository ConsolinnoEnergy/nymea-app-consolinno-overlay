import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import "../components"
import "../delegates"


Page {
    id: root
    bottomPadding: 0
    property int navigationFooterHeight: 0
    property Thing thing
    property ChargingOptimizationConfiguration chargingOptimizationConfiguration: hemsManager.chargingOptimizationConfigurations.getChargingOptimizationConfiguration(thing.id)
    property int directionID: 0
    signal done()

    function applyChanges() {
        hemsManager.setChargingOptimizationConfiguration(chargingOptimizationConfiguration.evChargerThingId,
                                                         {
                                                             controllableLocalSystem: gridSupportControl.checked
                                                         });
        if (directionID !== 1) {
            pageStack.pop();
        }
        root.done();
    }

    header: null

    CoHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        blurSource: bodyFlickable
        text: qsTr("Charging")
        backButtonVisible: directionID === 1 ? false : true
        onBackPressed: pageStack.pop()
    }

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onSetChargingOptimizationConfigurationReply: function(commandId, error) {
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

    Flickable {
        id: bodyFlickable
        anchors.fill: parent
        topMargin: header.height
        clip: true
        contentHeight: contentColumn.implicitHeight +
                       contentColumn.anchors.topMargin +
                       contentColumn.anchors.bottomMargin + root.navigationFooterHeight
        Component.onCompleted: Qt.callLater(() => contentY = -topMargin)

        ColumnLayout {
            id: contentColumn
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: app.margins

            CoFrostyCard {
                Layout.fillWidth: true
                contentTopMargin: Style.smallMargins
                headerText: thing.name

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoSwitch {
                        id: gridSupportControl
                        Layout.fillWidth: true
                        text: qsTr("Grid-supportive-control")
                        helpText: qsTr("If the device must be controlled according to §14a, then this setting must be enabled.")

                        Component.onCompleted: {
                            checked = chargingOptimizationConfiguration.controllableLocalSystem;
                        }
                    }
                }
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
        }
    }

    property Component navbarControls: evChargerNavbarControls

    Component {
        id: evChargerNavbarControls
        CoNavbarButton {
            text: qsTr("Apply changes")
            onClicked: root.applyChanges()
        }
    }
}

