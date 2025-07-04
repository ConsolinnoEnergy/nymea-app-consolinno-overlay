import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import QtGraphicalEffects 1.15

CheckBox {
    id: root

    indicator: Rectangle {
        implicitWidth: 20
        implicitHeight: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        border.color: parent.checked ? Style.buttonColor : "gray"
        border.width: 2
        color: parent.checked ? Style.buttonColor : "transparent"

        // Bounce animation on click
        SequentialAnimation on scale {
            id: bounceAnim
            NumberAnimation { to: 0.90; duration: 80; easing.type: Easing.OutQuad }
            NumberAnimation { to: 1.1; duration: 100; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1.0; duration: 60; easing.type: Easing.OutQuad }
        }

        Rectangle {
            id: hoverCircle
            anchors.centerIn: parent
            width: 40
            height: 40
            radius: width / 2
            color: "#000000"
            opacity: 0.1
            visible: false
            scale: 0.5

            Behavior on scale {
                NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
            }

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }

        Canvas {
            anchors.fill: parent
            visible: root.checked

            onPaint: {
                var ctx = getContext("2d");
                ctx.strokeStyle = Style.backgroundColor;
                ctx.lineWidth = 2;
                ctx.beginPath();
                ctx.moveTo(4, 10);
                ctx.lineTo(8, 14);
                ctx.lineTo(16, 6);
                ctx.stroke();
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onEntered: {
                hoverCircle.visible = true
                hoverCircle.opacity = 0.1
                hoverCircle.scale = 1.0
            }

            onExited: {
                hoverCircle.opacity = 0
                hoverCircle.scale = 0.5
                hoverCircle.visible = false
            }

            onPressed: {
                hoverCircle.color = Style.buttonColor
                hoverCircle.opacity= 0.2
            }

            onReleased: {
                hoverCircle.color = "#000000"
                hoverCircle.opacity= 0.1
            }

            onClicked: {
                root.checked = !root.checked

                bounceAnim.restart()
            }
        }
    }
}
