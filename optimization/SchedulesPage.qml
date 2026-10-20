import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Nymea
import "../components"
import "../delegates"

Page {
    id: root

    bottomPadding: 0
    header: null
    property var deviceTypes: []
    property bool loading: true
    property string errorMessage: ""

    function groupSchedules(schedules) {
        const groups = []
        for (const schedule of schedules) {
            const deviceType = schedule.deviceType || qsTr("Unknown device")
            let group = groups.find(item => item.deviceType === deviceType)
            if (!group) {
                group = { deviceType: deviceType, schedules: [] }
                groups.push(group)
            }
            group.schedules.push(schedule)
        }
        root.deviceTypes = groups
    }

    Component.onCompleted: {
        if (hemsManager.getConEMSDeviceSchedules() < 0) {
            loading = false
            errorMessage = qsTr("Not connected to the system.")
        }
    }

    Connections {
        target: hemsManager
        function onConEMSDeviceSchedulesReceived(deviceSchedules, success) {
            root.loading = false
            if (!success) {
                root.errorMessage = qsTr("Could not load device schedules.")
                return
            }
            root.groupSchedules(deviceSchedules)
        }
    }

    CoHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        blurSource: bodyFlickable
        text: qsTr("Schedules")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            topMargin: header.height + app.margins
            leftMargin: app.margins
            rightMargin: app.margins
            bottomMargin: app.margins
        }

        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: root.loading
            visible: root.loading
        }

        Label {
            Layout.fillWidth: true
            visible: !root.loading && root.errorMessage.length > 0
            horizontalAlignment: Text.AlignHCenter
            text: root.errorMessage
            wrapMode: Text.Wrap
        }

        Label {
            Layout.fillWidth: true
            visible: !root.loading && root.errorMessage.length === 0 && root.deviceTypes.length === 0
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("No device schedules available.")
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !root.loading && root.errorMessage.length === 0 && root.deviceTypes.length > 0
            clip: true
            model: root.deviceTypes
            delegate: NymeaItemDelegate {
                required property var modelData
                width: ListView.view.width
                text: modelData.deviceType
                subText: qsTr("%1 device(s)").arg(modelData.schedules.length)
                iconName: "/icons/configure.svg"
                onClicked: pageStack.push(Qt.resolvedUrl("DeviceSchedulesPage.qml"), {
                    "deviceType": modelData.deviceType,
                    "schedules": modelData.schedules
                })
            }
        }
    }
}