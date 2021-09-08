import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import QtCharts 2.3
import Nymea 1.0
import "../components"
import "../delegates"

MouseArea {
    id: root
    height: layout.implicitHeight
    width: 100

    property alias color: background.color
    property Thing thing: null
    readonly property State currentPowerState: thing ? thing.stateByName("currentPower") : null

    Rectangle {
        id: background
        anchors.fill: parent
        radius: Style.cornerRadius
    }

    function isDark(color) {
        var r, g, b;
        if (color.constructor.name === "Object") {
            r = color.r * 255;
            g = color.g * 255;
            b = color.b * 255;
        } else if (color.constructor.name === "String") {
            var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(color);
            r = parseInt(result[1], 16)
            g = parseInt(result[2], 16)
            b = parseInt(result[3], 16)
        }

        return ((r * 299 + g * 587 + b * 114) / 1000) < 200
    }

    Item {
        id: content
        anchors.fill: parent
        visible: false
        ColumnLayout {
            id: layout
            width: parent.width
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: headerLabel.height + Style.margins
                color: Qt.darker(root.color, 1.3)

                Label {
                    id: headerLabel
                    width: parent.width
                    text: root.thing.name
                    elide: Text.ElideRight
                    color: root.isDark(root.color) ? "white" : "black"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.margins: Style.margins
                text: root.currentPowerState.value.toFixed(0) + " W"
                horizontalAlignment: Text.AlignHCenter
                font: Style.bigFont
                color: root.isDark(root.color) ? "white" : "black"
            }
        }
    }

    OpacityMask {
        anchors.fill: parent
        source: content
        maskSource: background
    }
}
