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
    height: 80//layout.implicitHeight
    width: 80

    property color color: "white"
    property color negativeColor: root.color
    property Thing thing: null
    readonly property State currentPowerState: thing ? thing.stateByName("currentPower") : null
    readonly property bool isProducer: thing && thing.thingClass.interfaces.indexOf("smartmeterproducer") >= 0
    readonly property bool isBattery: thing && thing.thingClass.interfaces.indexOf("energystorage") >= 0

    readonly property double currentPower: root.currentPowerState ? root.currentPowerState.value.toFixed(0) : 0
    readonly property State batteryLevelState: isBattery ? thing.stateByName("batteryLevel") : null

    readonly property color currentColor: currentPower <= 0 ? root.negativeColor : root.color
    Rectangle {
        id: background
        anchors.fill: parent
        radius: Style.cornerRadius
        color: root.currentColor
        Behavior on color { ColorAnimation { duration: 200 } }
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

        print("*** isDark", root.thing.name, color.constructor.name, color.r, color.g, color.b)
        print("isDar;", ((r * 299 + g * 587 + b * 114) / 1000) < 200)
        return ((r * 299 + g * 587 + b * 114) / 1000) < 200
    }

    Item {
        id: content
        anchors.fill: parent
//        visible: false
        ColumnLayout {
            id: layout
            width: parent.width
            spacing: Style.smallMargins

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: headerLabel.height + Style.margins
                color: Qt.darker(root.currentColor, 1.3)

                Label {
                    id: headerLabel
                    width: parent.width
                    text: Math.abs(root.currentPower) + " W"
                    elide: Text.ElideRight
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            ColorIcon {
                size: Style.iconSize
                Layout.alignment: Qt.AlignCenter
                name: !root.thing || root.isBattery ? "" : app.interfacesToIcon(root.thing.thingClass.interfaces)
                color: "black"
                visible: !root.isBattery
            }

            Rectangle {
                id: batteryRect
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins + 3
                Layout.rightMargin: Style.margins
                Layout.topMargin: Style.smallMargins
                Layout.preferredHeight: 20
                visible: root.isBattery

                radius: 2
                color: "#2f2e2d"
                Rectangle {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        horizontalCenter: parent.left
                    }
                    height: 8
                    width: 6
                    radius: 2
                    color: parent.color
                }
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 2
                    spacing: 2
                    Repeater {
                        model: 10
                        delegate: Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: root.batteryLevelState && root.batteryLevelState.value >= (10 - index) * 10 ? "#98b945" : batteryRect.color
                            radius: 2
                        }
                    }
                }
            }
        }
    }

    OpacityMask {
        anchors.fill: parent
        source: ShaderEffectSource {
            anchors.fill: parent
            sourceItem: content
            live: true
            hideSource: true
        }
        maskSource: background
    }
}
