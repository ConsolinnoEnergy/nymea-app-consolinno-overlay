import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../components"
import "../customviews"

Item {
    id: root

    property alias content: content.data
    property alias title: titleText.text
    property alias headerOptionsModel: menuListRepeater.model
    property alias headerOptionsVisible: headerOptionsButton.enabled

    //attribute for disconnect Error
    readonly property State connectedState: thing ? thing.stateByName("connected") : null
    readonly property double connected: root.connectedState ? root.connectedState.value.toFixed(0) : 1

    ListModel {
        id: menuListModel

        ListElement {
            icon: "/ui/images/info.svg"
            text: "Details"
            page: "GenericDeviceHistoryPage.qml"
        }

        ListElement {
            icon: "/ui/images/logs.svg"
            text: "Logs"
            page: "../devicepages/DeviceLogPage.qml"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillHeight: false
            Layout.fillWidth: true
            Layout.preferredHeight: 56

            Item {
                height: parent.height
                anchors {
                    left: parent.left
                    leftMargin: 16
                    right: parent.right
                    rightMargin: 16
                }

                RowLayout {
                    anchors.fill: parent

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: false
                        Layout.preferredWidth: 48

                        Image {
                            width: 24
                            height: 24
                            anchors.centerIn: parent
                            source: "/ui/images/back.svg"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                pageStack.pop()
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true

                        Label {
                            id: titleText

                            anchors.centerIn: parent
                            font.pixelSize: 20
                        }
                    }

                    Item {
                        id: headerOptionsButton

                        Layout.fillHeight: true
                        Layout.fillWidth: false
                        Layout.preferredWidth: 48

                        Image {
                            width: 24
                            height: 24
                            anchors.centerIn: parent
                            source: "/ui/images/navigation-menu.svg"
                            visible: parent.enabled
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: parent.enabled
                            onClicked: {
                                menu.open();
                            }
                        }
                    }
                }
            }
        }
        Item {
            id: content

            Layout.fillHeight: true
            Layout.fillWidth: true

        }
    }

    Menu {
        id: menu

        x:root.width - width
        y: 56
        modal: true

        Repeater {
            id: menuListRepeater

            model: menuListModel

            Item {
                width: ListView.view.width
                height: 56

                RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        leftMargin: 16
                        rightMargin: 16
                    }

                    height: parent.height / 2
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 24

                    ColorIcon {
                        Layout.fillHeight: false
                        Layout.fillWidth: false
                        Layout.preferredHeight: 24
                        Layout.preferredWidth: 24
                        source: model.icon
                    }

                    Label {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: model.text
                        font.pixelSize: app.mediumFont
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        menu.close();
                        pageStack.push(Qt.resolvedUrl(model.page), {thing: root.thing })
                    }
                }
            }
        }
    }
    Item {
        visible: root.connectedState
        width: parent.width
        height: connectedText.height
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 20
        }
        Label {
            id: connectedText
            width: parent.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            textFormat: Text.RichText
            padding: 20;
            font.pixelSize: 16
            color: "#194D25"
            background: Rectangle {
                border.color: "#ffa31c"
                border.width: 2
                radius: 8
            }
            leftPadding: 45
            text: qsTr("Data unavailable from the device. Displayed values may not be accurate. HEMS functioning properly.").arg(qsTr("Disconnected"))
        }
        Image {
            id: icon
            source: "/ui/images/connections/cloud-error-red.svg" // Set the path to your icon
            width: 24
            height: 24
            anchors {
                top: parent.top
                left: parent.left
                leftMargin: 15
                topMargin: 18
            }
        }
    }

}
