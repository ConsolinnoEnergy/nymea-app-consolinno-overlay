import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Nymea 1.0

Dialog {
    id: root

    modal: true
    closePolicy: Popup.NoAutoClose

    parent: Overlay.overlay
    x: 0
    y: 0 // #TODO is 0 good or do we need an offset?
    width: parent.width
    height: parent.height - y + bg.radius

    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: bg.radius

    enter: Transition {
        NumberAnimation {
            property: "y"
            from: parent.height
            to: 0 // #TODO is 0 good or do we need an offset?
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "y"
            from: 0 // #TODO is 0 good or do we need an offset?
            to: parent.height
            duration: 300
            easing.type: Easing.InCubic
        }
    }

    header: Rectangle {
        id: headerRect
        Layout.fillWidth: true
        color: Style.colors.menu_Header_Footer_Background
        implicitHeight: headerLayout.implicitHeight

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: headerMaskSource
        }

        RowLayout {
            id: headerLayout
            anchors.fill: parent
            Layout.margins: 4
            spacing: Style.smallMargins

            RoundButton {
                id: rejectButton
                icon.source: Qt.resolvedUrl("/icons/close.svg")
                secondary: true
                onClicked: root.reject()
            }

            Text {
                id: titleText
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font: Style.newH2Font
                color: Style.colors.typography_Headlines_H2
                text: root.title
            }

            RoundButton {
                id: acceptButton
                icon.source: Qt.resolvedUrl("/icons/check.svg")
                onClicked: root.accept()
            }
        }
    }

    background: Rectangle {
        id: bg
        radius: 24
    }

    Item {
        id: headerRoundedMask
        width: headerRect.width
        height: headerRect.height * 2
        layer.enabled: true
        visible: false
        Rectangle {
            anchors.fill: parent
            radius: bg.radius
        }
    }

    ShaderEffectSource {
        id: headerMaskSource
        sourceItem: headerRoundedMask
        sourceRect: Qt.rect(0, 0, headerRoundedMask.width, headerRoundedMask.height / 2)
    }
}
