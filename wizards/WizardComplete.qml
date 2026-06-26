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

    property Component navbarControls: wizardCompleteControls

    Component {
        id: wizardCompleteControls
        CoNavbarButton {
            Layout.fillWidth: true
            text: qsTr("To the Dashboard")
            onClicked: root.done(true, false)
        }
    }

    header: null

    CoHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        blurSource: flickable
        text: qsTr("Installed Devices")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        topMargin: header.height
        clip: true
        contentHeight: layout.implicitHeight + 2 * Style.margins + root.navigationFooterHeight
        Component.onCompleted: Qt.callLater(() => contentY = -topMargin)

        ColumnLayout {
            id: layout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: Style.margins
            anchors.rightMargin: Style.margins
            anchors.topMargin: Style.margins
            spacing: Style.margins

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
}
