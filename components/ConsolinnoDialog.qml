import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"

Dialog {
    id: root
    width: Math.min(parent.width * .8, Math.max(contentLabel.implicitWidth, 400))
    height: 600
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    property alias headerIcon: headerColorIcon.name
    property alias text: contentLabel.text
    property alias source: picture.source
    default property alias children: content.children

    standardButtons: Dialog.Ok

    onClosed: root.destroy()

    Connections {
        target: root.parent
        onDestroyed: root.destroy()
    }

    MouseArea {
        parent: app.overlay
        anchors.fill: parent
        z: -1
        onPressed: {
            mouse.accepted = true
        }
    }

    header: Item {
        implicitHeight: headerRow.height + app.margins
        implicitWidth: parent.width
        visible: root.title.length > 0
        RowLayout {
            id: headerRow
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: app.margins }
            spacing: app.margins

            ColorIcon {
                id: headerColorIcon
                Layout.preferredHeight: Style.hugeIconSize
                Layout.preferredWidth: height
                color: Style.accentColor
                visible: name.length > 0
            }

            Label {
                id: titleLabel
                Layout.fillWidth: true
                Layout.margins: app.margins
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: root.title
                color: Style.accentColor
                font.pixelSize: app.largeFont
            }
        }
    }
    contentItem: Flickable {
        id: content
        clip: true
        anchors.margins: app.margins
        anchors.fill: parent
        contentHeight: container.implicitHeight + 100

        ColumnLayout {
            id: container
            width: content.width

            Label {
                id: contentLabel
                Layout.fillWidth: true
                wrapMode: "WordWrap"
                visible: text.length > 0
            }

            Image {
                id: picture
                fillMode: Image.PreserveAspectFit
                Layout.fillWidth: true
                Layout.topMargin: 10
                sourceSize.width: 250
                sourceSize.height: 250
                visible: picture.source
            }
        }
    }

    Rectangle {
        parent: app.overlay
        anchors.fill: parent
        color: "#99303030"
    }
}
