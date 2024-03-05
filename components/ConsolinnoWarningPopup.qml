import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9

import Nymea 1.0

Popup {
    id: root

    property alias descriptionText: descriptionText.text

    signal deleteClicked()

    implicitWidth: parent.width / 1.5
    modal: true

    background: Rectangle {
        radius: 8
        height: root.height
    }

    contentItem: ColumnLayout {
        id: contentLayout

        width: root.width
        height: childrenRect.height
        spacing: Style.bigMargins

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: childrenRect.height

            Item {
                id: warningIcon

                height: Style.iconSize * 2
                width: height
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.fill: parent
                    color: "red"
                    radius: Style.iconSize
                    opacity: 0.4
                }

                Image {
                    source: "/ui/images/warning-icon.svg"
                    height: Style.iconSize
                    width: Style.iconSize
                    anchors.centerIn: parent
                }
            }

            Label {
                id: titleText

                width: parent.width
                anchors {
                    top: warningIcon.bottom
                    topMargin: Style.smallMargins
                }

                text: qsTr('Are you sure?')
                font.bold: true
                font.pixelSize: Style.bigFont.pixelSize
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                id: descriptionText

                width: parent.width
                anchors {
                    top: titleText.bottom
                    topMargin: Style.margins
                }
                font.pixelSize: Style.font.pixelSize
                horizontalAlignment: Text.AlignHCenter
                topPadding: Style.smallMargins
                bottomPadding: Style.smallMargins
                wrapMode: Text.WordWrap
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: Style.bigMargins

            Button {
                id: cancelButton

                text: qsTr('Cancel')
                leftPadding: Style.bigMargins
                rightPadding: Style.bigMargins
                contentItem: Label {
                    text: cancelButton.text
                    font.pixelSize: Style.majorFontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    implicitHeight: Style.buttonHeight
                    color: "gray"
                    radius: 4
                }

                onClicked: {
                    root.visible = false
                }
            }

            Button {
                id: deleteButton

                text: qsTr('Delete')
                leftPadding: Style.bigMargins
                rightPadding: Style.bigMargins
                contentItem: Label {
                    text: deleteButton.text
                    color: "white"
                    font.bold: true
                    font.pixelSize: Style.majorFontSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    implicitHeight: Style.buttonHeight
                    color: "#FF0000"
                    radius: 4
                }

                onClicked: {
                    root.deleteClicked();
                }
            }
        }
    }
}
