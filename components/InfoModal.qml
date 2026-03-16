import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.2
import QtQuick.Controls.Material 2.15
import QtGraphicalEffects 1.15
import Nymea 1.0

Popup {
    id: root

    property alias title: titleLabel.text
    property alias contentSource: loader.sourceComponent

    signal closeRequested()

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // Center the popup and size it to content
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    // Let the popup size to its content with some constraints
    width: Math.min(parent.width - 32, 500)
    height: Math.min(implicitHeight, parent.height * 0.8)

    padding: 0

    background: Rectangle {
        color: Style.colors.background_Default
        radius: 12
        border.width: 1
        border.color: Style.colors.typography_States_Hover
    }

    contentItem: ColumnLayout {
        spacing: 0

        // Header with title and close button
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 16
            spacing: 16

            Label {
                id: titleLabel
                Layout.fillWidth: true
                font.bold: true
                font.pixelSize: 18
                color: Style.colors.typography_Basic_Default
                wrapMode: Text.WordWrap
            }

            MouseArea {
                id: closeButton
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24

                Image {
                    anchors.fill: parent
                    source: "/icons/close.svg"
                    sourceSize.width: 24
                    sourceSize.height: 24
                }

                ColorOverlay {
                    anchors.fill: parent
                    source: parent.children[0]
                    color: Style.colors.typography_Basic_Default
                }

                onClicked: root.close()
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Style.colors.typography_States_Hover
        }

        // Content area with loader
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: loader.implicitHeight
            clip: true

            Loader {
                id: loader
                width: parent.width
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 16
                    rightMargin: 16
                    topMargin: 8
                    bottomMargin: 16
                }
            }
        }
    }
}
