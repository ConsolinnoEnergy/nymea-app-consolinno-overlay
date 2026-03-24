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

    enum ActionType {
        None,
        Dismissable,
        Collapsible
    }

    required property int type
    property int actionType: CoNotification.ActionType.None
    property alias title: titleText.text
    property alias message: messageText.text
    property alias messageTextFormat: messageText.textFormat
    property bool clickable: false
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

    TapHandler {
        enabled: root.clickable
        onTapped: root.clicked()
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: Style.smallMargins
        spacing: 0

        // ── Title row: [TypeIcon] [Title] [ActionButton] ──────────
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.smallMargins

            ColorIcon {
                id: typeIcon
                Layout.alignment: Qt.AlignTop
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

            Text {
                id: titleText
                Layout.fillWidth: true
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
                font: Style.newH3Font
                color: root.accentColor()

                TapHandler {
                    enabled: root.actionType === CoNotification.ActionType.Collapsible
                    onTapped: root.collapsed = !root.collapsed
                }
            }

            ColorIcon {
                id: actionButton
                Layout.alignment: Qt.AlignTop
                visible: root.actionType !== CoNotification.ActionType.None
                size: 20
                color: root.accentColor()
                name: root.actionType === CoNotification.ActionType.Collapsible
                      ? (root.collapsed
                         ? Qt.resolvedUrl("qrc:/icons/keyboard_arrow_down.svg")
                         : Qt.resolvedUrl("qrc:/icons/keyboard_arrow_up.svg"))
                      : Qt.resolvedUrl("qrc:/icons/close.svg")

                TapHandler {
                    onTapped: {
                        if (root.actionType === CoNotification.ActionType.Dismissable) {
                            root.dismiss()
                        } else if (root.actionType === CoNotification.ActionType.Collapsible) {
                            root.collapsed = !root.collapsed
                        }
                    }
                }
            }
        }

        // ── Message row: [spacer] [message] [spacer?] ─────────────
        // Right spacer only shown when actionButton is visible,
        // so messageText stays aligned with titleText in both cases.
        RowLayout {
            Layout.fillWidth: true
            spacing: Style.smallMargins

            Item {
                Layout.preferredWidth: typeIcon.size
                Layout.preferredHeight: 1
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

            Item {
                Layout.preferredWidth: actionButton.size
                Layout.preferredHeight: 1
                visible: root.actionType !== CoNotification.ActionType.None
            }
        }
    }
}
