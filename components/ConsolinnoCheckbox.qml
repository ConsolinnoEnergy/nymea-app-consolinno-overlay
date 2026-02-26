import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea 1.0
import Qt5Compat.GraphicalEffects

RowLayout {
    id: root
    property alias text: labelContainer.text
    property alias checked: checkbox.checked
    property int sizeFont: 16
    property int position: Qt.AlignLeft
    property bool useFillWidth: true
    property real labelPreferredWidth: 160


    Layout.alignment: position

    CheckBox {
        id: checkbox
        font.pixelSize: sizeFont

        indicator: Rectangle {
            implicitWidth: 20
            implicitHeight: 20
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            border.color: checked ? Style.buttonColor : Style.textfield
            border.width: 2
            color: checked ? Style.buttonColor : "transparent"
            radius: 2

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
                visible: checked
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
                    checkbox.checked = !checked
                    bounceAnim.restart()
                }
            }
        }
    }

    Label {
        id: labelContainer
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignLeft
        font.pixelSize: sizeFont

        Layout.fillWidth: root.useFillWidth
        Layout.preferredWidth: root.useFillWidth ? 0 : root.labelPreferredWidth

        MouseArea {
            anchors.fill: labelContainer
            onClicked: {
                checkbox.checked = !checkbox.checked
            }
        }
    }
}
