import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea

import "../components"
import "../utils/DateUtils.js" as DateUtils

Page {
    id: root
    bottomPadding: 0
    property int navigationFooterHeight: 0

    property string dayLabel: ""
    property string initialStartTime: ""
    property string initialEndTime: ""

    signal timeSelected(string startTime, string endTime)
    signal entryRemoved()

    readonly property var minuteValues: [0, 15, 30, 45]

    // Initial times are rounded to full quarter hours (start down, end up)
    readonly property string normalizedStart: initialStartTime && initialStartTime.indexOf(":") > 0
                                              ? DateUtils.floorToQuarter(initialStartTime) : "12:00"
    readonly property string normalizedEnd: initialEndTime && initialEndTime.indexOf(":") > 0
                                            ? DateUtils.ceilToQuarter(initialEndTime) : "12:00"

    property int initStartHour: parseInt(normalizedStart.split(":")[0])
    property int initStartMinuteIndex: parseInt(normalizedStart.split(":")[1]) / 15
    property int initEndHour: parseInt(normalizedEnd.split(":")[0])
    property int initEndMinuteIndex: parseInt(normalizedEnd.split(":")[1]) / 15

    header: null

    property Component navbarControls: dayTimePickerNavbarControls

    Component {
        id: dayTimePickerNavbarControls
        ColumnLayout {
            spacing: Style.smallMargins

            CoNavbarButton {
                Layout.fillWidth: true
                text: qsTr("Confirm")
                onClicked: root.confirm()
            }

            CoNavbarButton {
                Layout.alignment: Qt.AlignCenter
                flat: true
                text: qsTr("Remove entry")
                onClicked: {
                    root.entryRemoved()
                    pageStack.pop()
                }
            }
        }
    }

    function confirm() {
        var sh = startHourTumbler.currentIndex
        var sm = root.minuteValues[startMinuteTumbler.currentIndex]
        var eh = endHourTumbler.currentIndex
        var em = root.minuteValues[endMinuteTumbler.currentIndex]

        var startTotal = sh * 60 + sm
        var endTotal = eh * 60 + em
        if (startTotal >= endTotal) {
            errorLabel.visible = true
            return
        }

        errorLabel.visible = false
        var startStr = (sh < 10 ? "0" : "") + sh + ":" + (sm < 10 ? "0" : "") + sm
        var endStr = (eh < 10 ? "0" : "") + eh + ":" + (em < 10 ? "0" : "") + em
        root.timeSelected(startStr, endStr)
        pageStack.pop()
    }

    CoHeader {
        id: coHeader
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        blurSource: bodyFlickable
        text: qsTr("Time window") + " " + root.dayLabel
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Flickable {
        id: bodyFlickable
        anchors.fill: parent
        topMargin: coHeader.height
        contentHeight: mainColumn.implicitHeight + mainColumn.anchors.topMargin + mainColumn.anchors.bottomMargin + root.navigationFooterHeight
        clip: true

        Component.onCompleted: Qt.callLater(() => contentY = -topMargin)

        ColumnLayout {
            id: mainColumn
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: Style.margins
            spacing: 30

            // "Von" (From) section
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 160

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Label {
                        text: qsTr("From")
                        font.pixelSize: 18
                        font.bold: true
                        color: Style.foregroundColor
                        Layout.preferredWidth: 60
                        Layout.alignment: Qt.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 15

                            Tumbler {
                                id: startHourTumbler
                                model: 24
                                wrap: false
                                visibleItemCount: 3
                                implicitWidth: 70
                                implicitHeight: 120
                                currentIndex: root.initStartHour

                                delegate: Label {
                                    text: (modelData < 10 ? "0" : "") + modelData
                                    font.pixelSize: Tumbler.tumbler.currentIndex === index ? 22 : 16
                                    color: Tumbler.tumbler.currentIndex === index ? Style.foregroundColor : Style.subTextColor
                                    opacity: Tumbler.tumbler.currentIndex === index ? 1.0 : 0.5
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Tumbler {
                                id: startMinuteTumbler
                                model: root.minuteValues
                                wrap: false
                                visibleItemCount: 3
                                implicitWidth: 70
                                implicitHeight: 120
                                currentIndex: root.initStartMinuteIndex

                                delegate: Label {
                                    text: (modelData < 10 ? "0" : "") + modelData
                                    font.pixelSize: Tumbler.tumbler.currentIndex === index ? 22 : 16
                                    color: Tumbler.tumbler.currentIndex === index ? Style.foregroundColor : Style.subTextColor
                                    opacity: Tumbler.tumbler.currentIndex === index ? 1.0 : 0.5
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        // Separator lines around selected item
                        Rectangle {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -20
                            width: 170
                            height: 1
                            color: Style.subTextColor
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: 20
                            width: 170
                            height: 1
                            color: Style.subTextColor
                        }
                    }
                }
            }

            // "Bis" (To) section
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 160

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Label {
                        text: qsTr("To")
                        font.pixelSize: 18
                        font.bold: true
                        color: Style.foregroundColor
                        Layout.preferredWidth: 60
                        Layout.alignment: Qt.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 15

                            Tumbler {
                                id: endHourTumbler
                                model: 24
                                wrap: false
                                visibleItemCount: 3
                                implicitWidth: 70
                                implicitHeight: 120
                                currentIndex: root.initEndHour

                                delegate: Label {
                                    text: (modelData < 10 ? "0" : "") + modelData
                                    font.pixelSize: Tumbler.tumbler.currentIndex === index ? 22 : 16
                                    color: Tumbler.tumbler.currentIndex === index ? Style.foregroundColor : Style.subTextColor
                                    opacity: Tumbler.tumbler.currentIndex === index ? 1.0 : 0.5
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Tumbler {
                                id: endMinuteTumbler
                                model: root.minuteValues
                                wrap: false
                                visibleItemCount: 3
                                implicitWidth: 70
                                implicitHeight: 120
                                currentIndex: root.initEndMinuteIndex

                                delegate: Label {
                                    text: (modelData < 10 ? "0" : "") + modelData
                                    font.pixelSize: Tumbler.tumbler.currentIndex === index ? 22 : 16
                                    color: Tumbler.tumbler.currentIndex === index ? Style.foregroundColor : Style.subTextColor
                                    opacity: Tumbler.tumbler.currentIndex === index ? 1.0 : 0.5
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }

                        // Separator lines around selected item
                        Rectangle {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -20
                            width: 170
                            height: 1
                            color: Style.subTextColor
                        }
                        Rectangle {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: 20
                            width: 170
                            height: 1
                            color: Style.subTextColor
                        }
                    }
                }
            }

            // Error label shown when start time >= end time
            Label {
                id: errorLabel
                Layout.fillWidth: true
                visible: false
                text: qsTr("The start time must be before the end time.")
                color: "red"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
