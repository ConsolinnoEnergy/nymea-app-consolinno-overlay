import QtQuick
import QtQuick.Layouts
import Nymea 1.0

Item {
    id: root

    enum Type {
        Information,
        Warning,
        Danger
    }

    required property int type
    property alias title: titleText.text
    property alias message: messageText.text
    property alias messageTextFormat: messageText.textFormat
    property bool dismissable: false
    property bool clickable: false
    property bool collapsible: false
    property bool collapsed: false

    signal dismiss()
    signal clicked()

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin

    function accentColor() {
        if (root.type === CoNotification.Type.Information) {
            return Style.colors.system_Success_Accent
        } else if (root.type === CoNotification.Type.Warning) {
            return Style.colors.system_Warning_Accent
        } else if (root.type === CoNotification.Type.Danger) {
            return Style.colors.system_Danger_Accent
        } else {
            console.warn("CoNotification: unknown type:", root.type);
            return Style.colors.system_Warning_Accent
        }
    }

    function backgroundColor() {
        if (root.type === CoNotification.Type.Information) {
            return Style.colors.system_Success_Background
        } else if (root.type === CoNotification.Type.Warning) {
            return Style.colors.system_Warning_Background
        } else if (root.type === CoNotification.Type.Danger) {
            return Style.colors.system_Danger_Background
        } else {
            console.warn("CoNotification: unknown type:", root.type);
            return Style.colors.system_Warning_Background
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent

        radius: Style.cornerRadius
        color: root.backgroundColor()
        border.width: 1
        border.color: root.accentColor()
    }

    MouseArea {
        id: mouseAreaClick
        anchors.fill: parent
        onClicked: {
            if (root.clickable) {
                root.clicked()
            }
        }
    }

    Row {
        id: buttonRow
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 11
            rightMargin: 11
        }
        spacing: 6
        layoutDirection: Qt.RightToLeft

        ColorIcon {
            id: closeButton
            visible: root.dismissable
            size: 20
            color: root.accentColor()
            name: Qt.resolvedUrl("qrc:/icons/close.svg")

            MouseArea {
                id: mouseAreaDismiss
                anchors.fill: parent
                onClicked: {
                    if (root.dismissable) {
                        root.dismiss()
                    }
                }
            }
        }

        ColorIcon {
            id: collapseButton
            visible: root.collapsible
            size: 24
            color: root.accentColor()
            name: root.collapsed
                  ? Qt.resolvedUrl("qrc:/icons/keyboard_arrow_down.svg")
                  : Qt.resolvedUrl("qrc:/icons/keyboard_arrow_up.svg")

        }
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.topMargin: Style.smallMargins
        anchors.bottomMargin: Style.smallMargins
        anchors.leftMargin: Style.smallMargins
        anchors.rightMargin: Style.smallMargins
        spacing: Style.smallMargins

        ColorIcon {
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            size: 24
            color: root.accentColor()
            name: {
                if (root.type === CoNotification.Type.Information) {
                    return Qt.resolvedUrl("qrc:/icons/check.svg")
                } else if (root.type === CoNotification.Type.Warning) {
                    return Qt.resolvedUrl("qrc:/icons/error.svg")
                } else if (root.type === CoNotification.Type.Danger) {
                    return Qt.resolvedUrl("qrc:/icons/warning.svg")
                } else {
                    console.warn("CoNotification: unknown type:", root.type);
                    return Qt.resolvedUrl("qrc:/icons/error.svg")
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                id: titleText
                Layout.fillWidth: true
                Layout.bottomMargin: Style.smallMargins
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                font: Style.newH3Font
                color: root.accentColor()

                MouseArea {
                    id: mouseAreaCollapse
                    anchors.fill: parent
                    enabled: root.collapsible
                    propagateComposedEvents: !root.collapsible
                    onClicked: root.collapsed = !root.collapsed
                }
            }


            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.collapsed ? 0 : messageText.implicitHeight
                clip: true

                Behavior on Layout.preferredHeight {
                    NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
                }

                Text {
                    id: messageText
                    width: parent.width
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    font: Style.newParagraphFont
                    color: root.accentColor()

                    onLinkActivated: {
                        Qt.openUrlExternally(link)
                    }
                }
            }
        }
    }
}
