import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Nymea 1.0

ComboBox {
    id: root

    property color boxColor: Style.boxColor
    property color borderColor: Style.borderColor
    property color highlightColor: Style.highlightColor

    delegate: ItemDelegate {
        width: root.width
        contentItem: Text {
            text: root.textAt(index)
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            color: root.currentIndex === index ? Style.currentItemColor : Style.textColor
            leftPadding: 4
            topPadding: 4
            bottomPadding: 4
        }
        background: Rectangle {
            width: parent.width
            height: parent.height
            color: root.highlightedIndex === index ? root.highlightColor : root.boxColor
            border.color: "transparent"
        }
    }

    indicator: Canvas {
        id: canvas
        x: root.width - width - 8
        y: (root.height - height) / 2
        width: 10
        height: 6
        contextType: "2d"
        onPaint: {
            context.reset();
            context.beginPath();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = Style.textColor;
            context.fill();
        }
    }

    contentItem: Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 24
        color: Style.textColor
        text: root.displayText
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        id: dropDownSelect
        implicitWidth: 102
        implicitHeight: 35
        color: root.boxColor
        border.color: root.borderColor
        border.width: 1
        radius: 2
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 1
            radius: 6
            color: "#40000000"
        }
    }

    popup: Popup {
        y: root.height - 40
        width: root.width
        implicitHeight: contentItem.implicitHeight
        padding: 0
        contentItem: ListView {
            implicitHeight: Math.min(contentHeight, 250)
            model: root.popup.visible ? root.delegateModel : null
            clip: true
            currentIndex: root.highlightedIndex
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
        }
        background: Rectangle {
            id: dropDownPopUp
            color: root.boxColor
            border.color: root.borderColor
            border.width: 1
            radius: 2
            layer.enabled: true
            layer.effect: DropShadow {
                horizontalOffset: 0
                verticalOffset: 1
                radius: 6
                color: "#40000000"
            }
        }
    }
}
