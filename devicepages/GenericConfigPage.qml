import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Nymea 1.0
import "../components"
import "../customviews"

Item {
    id: root

    property alias content: content.data
    property alias title: header.text
    property alias headerOptionsModel: menuListRepeater.model
    property alias headerOptionsVisible: header.menuButtonVisible

    // Set overrideBack to true to intercept the back button. When true,
    // backRequested() is emitted instead of automatically calling pageStack.pop().
    // The handler is then responsible for popping (or not).
    property bool overrideBack: false
    signal backRequested()

    property int navigationFooterHeight: 0

    Rectangle {
        anchors.fill: parent
        color: Style.backgroundColor
    }

    ListModel {
        id: menuListModel

        ListElement {
            icon: "/icons/info.svg"
            text: "Details"
            page: "GenericDeviceHistoryPage.qml"
        }

        ListElement {
            icon: "/icons/logs.svg"
            text: "Logs"
            page: "../devicepages/DeviceLogPage.qml"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        Layout.alignment: Qt.AlignHCenter
        spacing: 0

        CoHeader {
            id: header
            Layout.fillWidth: true
            menuButtonVisible: true

            onBackPressed: {
                if (root.overrideBack) {
                    root.backRequested();
                } else {
                    pageStack.pop();
                }
            }
            onMenuPressed: menu.open();
        }

        Item {
            id: content
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    Menu {
        id: menu

        x: root.width - width - Style.margins
        y: 56
        modal: true

        Repeater {
            id: menuListRepeater

            model: menuListModel

            Item {
                width: menu.width
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
