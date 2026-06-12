import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../components"
import Nymea 1.0

Page {
    id: root
    bottomPadding: 0
    property int navigationFooterHeight: 0

    signal done(bool skip, bool abort)

    header: CoHeader {
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
            contentHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin + root.navigationFooterHeight

            ColumnLayout {
                id: layout
                anchors { left: parent.left; right: parent.right; top: parent.top }

                CoFrostyCard {
                    id: installedDevicesCard
                    Layout.fillWidth: true
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
                            interactive: false
                        }

                        ThingsProxy {
                            id: thingsProxy
                            engine: _engine
                            hideTagId: "hiddenInDeviceView"
                            hiddenInterfaces: ["gridsupport", "epexdatasource"]
                            hiddenThingClassIds: [
                                "7a597210-8f7e-4667-8cf7-82ccdc23c313", // Device claiming plugin
                                "f5f3c387-2482-4154-99ee-7a473f6d81e9" // Eebus information plugin
                            ]
                        }

                        Repeater {
                            id: installedThingsRepeater
                            model: thingsProxy
                            delegate: CoCard {
                                Layout.fillWidth: true
                                text: model.name
                                iconLeft: app.interfacesToIcon(model.interfaces)
                                interactive: false
                            }
                        }
                    }
                }
            }
        }

        Button {
            Layout.fillWidth: true
            Layout.bottomMargin: root.navigationFooterHeight
            text: qsTr("To the Dashboard")
            onClicked: {
                root.done(true, false);
            }
        }
    }
}
