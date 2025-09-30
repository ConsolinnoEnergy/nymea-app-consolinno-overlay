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
        Layout.alignment: Qt.AlignHCenter
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 56

            // Außencontainer: keine Layout-Steuerung, daher anchors hier ok
            Item {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                RowLayout {
                    id: rowContainer
                    anchors.fill: parent
                    spacing: 0

                    HeaderButton {
                        id: backButton
                        Layout.preferredWidth: 40
                        Layout.minimumWidth: 40
                        Layout.maximumWidth: 40
                        objectName: "backButton"
                        imageSource: "../images/back.svg"
                        onClicked: pageStack.pop()
                    }

                    Label {
                        id: titleText
                        Layout.fillWidth: true
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        wrapMode: Text.NoWrap
                    }

                    Item {
                        id: headerOptionsButton
                        Layout.preferredWidth: 48
                        Layout.minimumWidth: 48
                        Layout.maximumWidth: 48
                        Layout.fillHeight: true

                        Image {
                            width: 24
                            height: 24
                            anchors.centerIn: parent
                            source: Configuration.menuIcon !== "" ?
                                        "../images/" + Configuration.menuIcon :
                                        "../images/navigation-menu.svg"
                            visible: parent.enabled
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: parent.enabled
                            onClicked: menu.open()
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

}
