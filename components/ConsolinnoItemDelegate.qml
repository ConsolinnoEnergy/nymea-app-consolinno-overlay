import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.2
import Nymea 1.0

// There's a bug in QtQuick.Controls' SwipeDelegate in that it appears with wrong
// background when used in Popups/Dialogs So we need a non-swipable one for those cases

// FIXME: Eventually consoldate this again somehow

ItemDelegate {
    id: root
    implicitHeight: Style.smallDelegateHeight

    property var primetextColor: Material.foreground
    property var primetextElide: Text.ElideRight


    property string subText
    property string tertiaryText
    property bool progressive: true
    property bool canDelete: false

    property bool wrapTexts: true
    property bool prominentSubText: true
    property int textAlignment: Text.AlignLeft

    property string iconName
    property string thumbnail
    property int iconSize: Style.iconSize
    property color iconColor: Style.accentColor
    property alias secondaryIconName: secondaryIcon.name
    property alias secondaryIconColor: secondaryIcon.color
    property alias secondaryIconClickable: secondaryIconMouseArea.enabled
    property int secondaryIconSize: 0
    property alias tertiaryIconName: tertiaryIcon.name
    property alias tertiaryIconColor: tertiaryIcon.color
    property alias tertiaryIconClickable: tertiaryIconMouseArea.enabled
    property var progressionsIcon: "next"

    property var contextOptions: []

    property alias additionalItem: additionalItemContainer.children
    property var holdingItem: false

    property alias busy: busyIndicator.running

    signal deleteClicked()
    signal secondaryIconClicked()

    onPressAndHold: swipe.open(SwipeDelegate.Right)

    QtObject {
        id: d
        property var deleteContextOption: [{
            text: qsTr("Delete"),
            icon: "../images/delete.svg",
            backgroundColor: "red",
            foregroundColor: "white",
            visible: canDelete,
            callback: function deleteClicked() {
                root.deleteClicked();
                swipe.close();
            }
        }]

        property var finalContextOptions: root.contextOptions.concat(d.deleteContextOption)
    }

    contentItem: RowLayout {
        id: innerLayout
        spacing: app.margins
        Item {
            Layout.preferredHeight: root.iconSize
            Layout.preferredWidth: height
            visible: root.iconName.length > 0 || root.thumbnail.length > 0

            ColorIcon {
                id: icon
                anchors.fill: parent
                name: root.iconName
                color: root.iconColor
                visible: root.iconName && thumbnailImage.status !== Image.Ready
            }

            Image {
                id: thumbnailImage
                anchors.fill: parent
                source: root.thumbnail
                visible: root.thumbnail.length > 0
                fillMode: Image.PreserveAspectFit
                horizontalAlignment: Image.AlignHCenter
                verticalAlignment: Image.AlignVCenter
            }

            BusyIndicator {
                id: busyIndicator
                anchors.centerIn: parent
                visible: running
                running: false
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.text
                wrapMode: root.wrapTexts ? Text.WordWrap : Text.NoWrap
                maximumLineCount: root.wrapTexts ? 3 : 1
                elide: primetextElide
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: root.textAlignment
                color: primetextColor
            }
            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.subText
                font.pixelSize: root.prominentSubText ? app.smallFont : app.extraSmallFont
                color: root.prominentSubText ? Material.foreground : Material.color(Material.Grey)
                wrapMode: root.wrapTexts ? Text.WordWrap : Text.NoWrap
                maximumLineCount: root.wrapTexts ? 3 : 1
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                visible: root.subText.length > 0
            }
            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: root.tertiaryText
                font.pixelSize: app.extraSmallFont
                color: Style.subTextColor
                wrapMode: root.wrapTexts ? Text.WordWrap : Text.NoWrap
                maximumLineCount: root.wrapTexts ? 3 : 1
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                visible: root.tertiaryText.length > 0
            }
        }

        ColorIcon {
            id: secondaryIcon
            Layout.preferredHeight: secondaryIconSize > 0 ? secondaryIconSize : Style.smallIconSize
            Layout.preferredWidth: height
            visible: name.length > 0
            MouseArea {
                id: secondaryIconMouseArea
                enabled: false
                anchors.fill: parent
                anchors.margins: -app.margins
                onClicked: root.secondaryIconClicked();
            }
        }

        ColorIcon {
            id: tertiaryIcon
            Layout.preferredHeight: Style.smallIconSize
            Layout.preferredWidth: height
            visible: name.length > 0
            MouseArea {
                id: tertiaryIconMouseArea
                enabled: false
                anchors.fill: parent
                anchors.margins: -app.margins
                onClicked: root.tertiaryIconClicked();
            }
        }

        ColorIcon {
            id: progressionIcon
            Layout.preferredHeight: Style.smallIconSize
            Layout.preferredWidth: height
            name: "../images/" + progressionsIcon +  ".svg"
            visible: root.progressive
            color: Material.foreground
        }

        Item {
            id: additionalItemContainer
            Layout.fillHeight: true
            Layout.preferredWidth: childrenRect.width
            visible: children.length > 0
        }
    }
}
