import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import Nymea 1.0

import "../components"

Page {
    id: root

    property string dayLabel: ""
    property string initialStartTime: ""
    property string initialEndTime: ""

    signal timeSelected(string startTime, string endTime)
    signal entryRemoved()

    // Parse initial times
    property int initStartHour: {
        if (initialStartTime && initialStartTime.indexOf(":") > 0)
            return parseInt(initialStartTime.split(":")[0])
        return 12
    }
    property int initStartMinute: {
        if (initialStartTime && initialStartTime.indexOf(":") > 0)
            return parseInt(initialStartTime.split(":")[1])
        return 0
    }
    property int initEndHour: {
        if (initialEndTime && initialEndTime.indexOf(":") > 0)
            return parseInt(initialEndTime.split(":")[0])
        return 12
    }
    property int initEndMinute: {
        if (initialEndTime && initialEndTime.indexOf(":") > 0)
            return parseInt(initialEndTime.split(":")[1])
        return 0
    }

    header: Item {
        height: 56
        width: parent.width

        // Back button (chevron left)
        MouseArea {
            id: backButton
            width: 48
            height: 48
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            onClicked: pageStack.pop()

            ConsolinnoColorIcon {
                anchors.centerIn: parent
                height: Style.smallIconSize
                width: height
                name: "/icons/back.svg"
                color: Style.foregroundColor
            }
        }

        // Title
        Label {
            anchors.centerIn: parent
            text: qsTr("Zeitfenster") + " " + root.dayLabel
            font.pixelSize: 18
            font.bold: true
            color: Style.foregroundColor
        }

        // Bottom border
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: "#E0E0E0"
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: mainColumn.implicitHeight + 40

        ColumnLayout {
            id: mainColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: app.margins
            spacing: 30

            // "Von" (From) section
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                Layout.topMargin: 20

                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Label {
                        text: qsTr("Von")
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
                                wrap: true
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
                                model: 60
                                wrap: true
                                visibleItemCount: 3
                                implicitWidth: 70
                                implicitHeight: 120
                                currentIndex: root.initStartMinute

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
                        text: qsTr("Bis")
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
                                wrap: true
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
                                model: 60
                                wrap: true
                                visibleItemCount: 3
                                implicitWidth: 70
                                implicitHeight: 120
                                currentIndex: root.initEndMinute

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

            // Confirm button (green, at bottom)
            Button {
                id: confirmButton
                Layout.fillWidth: true
                Layout.topMargin: 20
                text: qsTr("Bestätigen")

                onClicked: {
                    var sh = startHourTumbler.currentIndex
                    var sm = startMinuteTumbler.currentIndex
                    var eh = endHourTumbler.currentIndex
                    var em = endMinuteTumbler.currentIndex
                    var startStr = (sh < 10 ? "0" : "") + sh + ":" + (sm < 10 ? "0" : "") + sm
                    var endStr = (eh < 10 ? "0" : "") + eh + ":" + (em < 10 ? "0" : "") + em
                    root.timeSelected(startStr, endStr)
                    pageStack.pop()
                }
            }

            // "Eintrag entfernen" (Remove entry) button - secondary style
            Button {
                id: removeButton
                Layout.fillWidth: true
                text: qsTr("Eintrag entfernen")
                flat: true

                contentItem: Label {
                    text: removeButton.text
                    color: Style.buttonTextColorNoBg
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: Style.buttonFontSize
                }

                background: Rectangle {
                    color: "transparent"
                    implicitHeight: 48
                }

                onClicked: {
                    root.entryRemoved()
                    pageStack.pop()
                }
            }
        }
    }
}
