import QtQuick 2.0
import Nymea 1.0

Item {
    id: root

    enum Type {
        Info,
        Warning,
        Danger
    }

    required property int type
    property alias title: titleText.text
    property alias message: messageText.text
    property bool dismissable: false

    signal dismiss()

    implicitHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin

    function accentColor() {
        if (root.type === CoNotification.Type.Info) {
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
        if (root.type === CoNotification.Type.Info) {
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

        radius: 8 // #TODO use value from new style
        color: root.backgroundColor()
        border.width: 1
        border.color: root.accentColor()
    }

    ColorIcon {
        id: closeButton
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 11
            rightMargin: 11
        }
        visible: root.dismissable
        size: 17
        color: root.accentColor()
        name: Qt.resolvedUrl("qrc:/icons/close.svg")

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                if (root.dismissable) {
                    root.clicked()
                }
            }
        }
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.topMargin: 8 // #TODO use value from new design
        anchors.bottomMargin: 8 // #TODO use value from new design
        anchors.leftMargin: 8 // #TODO use value from new design
        anchors.rightMargin: 8 // #TODO use value from new design
        spacing: 8 // #TODO use value from new style

        ColorIcon {
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            size: 24
            color: root.accentColor()
            name: {
                if (root.type === CoNotification.Type.Info) {
                    return Qt.resolvedUrl("qrc:/icons/tick.svg") // #TODO icon from new style
                } else if (root.type === CoNotification.Type.Warning) {
                    return Qt.resolvedUrl("qrc:/icons/attention.svg") // #TODO icon from new style
                } else if (root.type === CoNotification.Type.Danger) {
                    return Qt.resolvedUrl("qrc:/icons/dialog-warning-symbolic.svg") // #TODO icon from new style
                } else {
                    console.warn("CoNotification: unknown type:", root.type);
                    return Qt.resolvedUrl("qrc:/icons/attention.svg") // #TODO icon from new style
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8 // #TODO use value from new style

            Text {
                id: titleText
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                font: Style.newH3Font
                color: root.accentColor()
            }

            Text {
                id: messageText
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                font: Style.newParagraphFont
                color: root.accentColor()
            }
        }
    }
}
