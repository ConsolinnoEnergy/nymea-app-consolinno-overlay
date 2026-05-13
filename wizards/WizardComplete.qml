import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../components"
import Nymea 1.0

Page {
    id: root

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
            contentHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin

            ColumnLayout {
                id: layout
                anchors.fill: parent

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
            text: qsTr("To the Dashboard")
            onClicked: {
                root.done(true, false);
            }
        }
    }
}
