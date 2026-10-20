import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Nymea
import "../components"

Page {
    id: root

    property string deviceType: ""
    property var schedules: []
    property var slotRows: []

    bottomPadding: 0
    header: null

    function buildSlotRows() {
        const rows = []
        for (const schedule of root.schedules) {
            const slots = schedule.scheduleSlots || []
            const thingId = String(schedule.thingId || "")
            for (const slot of slots) {
                const sources = slot.source || []
                rows.push({
                    deviceId: thingId.slice(0, 8),
                    start: String(slot.start || ""),
                    controlValue: slot.controlValue === null || slot.controlValue === undefined
                                  ? "-" : String(slot.controlValue),
                    source: sources.length > 0 ? sources.join(", ") : "-"
                })
            }
        }
        root.slotRows = rows
    }

    function formatGeneratedAt(value) {
        return String(value || "-").replace("T", " ").split(".")[0]
    }

    Component.onCompleted: buildSlotRows()

    CoHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        text: root.deviceType
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
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: Style.smallMargins
            spacing: Style.smallMargins

            Label {
                Layout.preferredWidth: root.schedules.length > 1 ? 64 : 0
                visible: root.schedules.length > 1
                text: qsTr("Device")
                font.bold: true
                elide: Text.ElideRight
            }
            Label {
                Layout.preferredWidth: 126
                text: qsTr("Start")
                font.bold: true
            }
            Label {
                Layout.preferredWidth: 78
                text: qsTr("Control value")
                font.bold: true
                wrapMode: Text.Wrap
            }
            Label {
                Layout.fillWidth: true
                text: qsTr("Source")
                font.bold: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Style.colors.typography_Basic_Secondary
        }

        Repeater {
            model: root.schedules
            delegate: ColumnLayout {
                required property var modelData
                Layout.fillWidth: true
                Layout.topMargin: Style.smallMargins
                Layout.bottomMargin: Style.smallMargins
                spacing: 2

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Device %1").arg(String(modelData.thingId || ""))
                    font.bold: true
                    wrapMode: Text.WrapAnywhere
                }
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Fahrplan generiert am: %1").arg(root.formatGeneratedAt(modelData.generatedAt))
                    wrapMode: Text.Wrap
                }
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Revision: %1 | Anzahl erzeugter Fahrpläne heute: %2")
                          .arg(String(modelData.revision ?? "-"))
                          .arg(String(modelData.updatesToday ?? "-"))
                    wrapMode: Text.Wrap
                }
            }
        }

        ListView {
            id: slotsListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: root.slotRows
            delegate: Item {
                required property var modelData
                width: slotsListView.width
                height: 48

                RowLayout {
                    anchors.fill: parent
                    spacing: Style.smallMargins

                    Label {
                        Layout.preferredWidth: root.schedules.length > 1 ? 64 : 0
                        visible: root.schedules.length > 1
                        text: modelData.deviceId
                        elide: Text.ElideRight
                    }
                    Label {
                        Layout.preferredWidth: 126
                        text: modelData.start
                        elide: Text.ElideRight
                    }
                    Label {
                        Layout.preferredWidth: 78
                        text: modelData.controlValue
                        elide: Text.ElideRight
                    }
                    Label {
                        Layout.fillWidth: true
                        text: modelData.source
                        elide: Text.ElideRight
                    }
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: Style.colors.typography_Basic_Secondary
                    opacity: 0.25
                }
            }
        }

        Label {
            Layout.fillWidth: true
            visible: root.slotRows.length === 0
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("No schedule slots available.")
        }
    }
}