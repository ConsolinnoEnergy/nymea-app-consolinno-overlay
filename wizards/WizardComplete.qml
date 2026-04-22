import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../components"
import Nymea 1.0

Page {
    id: root

    signal done(bool skip, bool abort)

    header: NymeaHeader {
        text: qsTr("Installed Devices")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.margins
        spacing: Style.margins

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentHeight: installedThingsLayout.implicitHeight + installedThingsLayout.anchors.topMargin + installedThingsLayout.anchors.bottomMargin

            CoFrostyCard {
                id: installedDevicesCard
                anchors.fill: parent
                anchors.topMargin: Style.margins
                anchors.bottomMargin: Style.margins
                contentTopMargin: 8
                headerText: qsTr("Installed Devices")

                ColumnLayout {
                    id: installedThingsLayout
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoCard {
                        Layout.fillWidth: true
                        text: qsTr("Your %1 is now configured. The following devices are set up:").arg(Configuration.deviceName)
                    }

                    Repeater {
                        id: installedThingsRepeater
                        model: engine.thingManager.things
                        delegate: CoCard {
                            Layout.fillWidth: true
                            text: model.name
                            iconLeft: app.interfacesToIcon(model.interfaces)
                        }
                    }
                }
            }
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("To the Dashboard")
            onClicked: {
                root.done(true, false);
            }
        }
    }
}
