import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.1
import Nymea 1.0
import QtGraphicalEffects 1.15

Switch {
    id: root
    spacing: 1
    height: 18

    readonly property color selectedColor: Qt.rgba(Style.buttonColor.r, Style.buttonColor.g, Style.buttonColor.b, 0.5)

    indicator: Rectangle {
        implicitWidth: 37
        implicitHeight: 15
        x: root.leftPadding
        y: parent.height / 2 - height / 2
        radius: 13
        color: root.checked ? selectedColor : Style.switchBagroundColor

        Rectangle {
            id: toggleCircle
            x: root.checked ? parent.width - width +1 : -1
            y: -3
            width: 21
            height: 21
            radius: 12
            color: root.checked ? selectedColor : Style.switchCircleColor

            Behavior on x {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
        }

        DropShadow {
            anchors.fill: toggleCircle
            source: toggleCircle
            horizontalOffset: 0
            verticalOffset: 2
            radius: 6
            color: "#52000000"
        }
    }
}
