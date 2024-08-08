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

    property color color: "white"
    property color negativeColor: root.color
    property Thing thing: null
    property string isNotify: ""
    readonly property State currentPowerState: thing ? thing.stateByName("currentPower") : null
    readonly property State currentMarketPriceState: thing ? thing.stateByName("currentMarketPrice") : null
    readonly property bool isProducer: thing && thing.thingClass.interfaces.indexOf("smartmeterproducer") >= 0
    readonly property bool isBattery: thing && thing.thingClass.interfaces.indexOf("energystorage") >= 0
    property bool isRootmeter: false

    property bool isPowerConnection: false
    property bool isElectric: false

    readonly property double currentPower: root.currentPowerState ? root.currentPowerState.value.toFixed(0) : 0
    readonly property double currentMarketPrice: root.currentMarketPriceState ? root.currentMarketPriceState.value.toFixed(2) : 0
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

    function getLabeltext(power) {
        if (currentPowerState != null) {
            return Math.abs(power) + " W"
        }else if(isElectric == true) {
            // Round to fit in 3 digits for prices smaller 1000 ct/kWh
            if (Math.abs(power) < 10.0) {
                return Math.round(power * 100) / 100 + " ct/kWh"
            }else if (Math.abs(power) < 100.0) {
                return Math.round(power * 10) / 10 + " ct/kWh"
            }else{
                return Math.round(power) + " ct/kWh"
            }

        }else{
            return "–"
        }
    }


    function ifacesToIcon(interfaces) {
        for (var i = 0; i < interfaces.length; i++) {
            var icon = ifaceToIcon(interfaces[i]);
            if (icon !== "") {
                return icon;
            }
        }
        return Qt.resolvedUrl("images/select-none.svg")
    }

    function ifaceToIcon(name) {
        switch (name) {
        case "smartgridheatpump":
            return Qt.resolvedUrl("/ui/images/heatpump.svg")
        case "smartheatingrod":
            return Qt.resolvedUrl("/ui/images/heating_rod.svg")
        default:
            return app.interfaceToIcon(name)
        }
    }


    function thingToIcon(thing) {
        if(isRootmeter)
            return Qt.resolvedUrl("/ui/images/grid.svg")
        if(isElectric)
            return Qt.resolvedUrl("/ui/images/energy.svg")
        return ifacesToIcon(thing.thingClass.interfaces)
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
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        Layout.fillWidth: true
                        color: "white"
                        width: 19
                        height: 19
                        radius: 180
                        border.width: 2
                        border.color: Style.red
                        visible: (isNotify === "shutoff" || isNotify === "limited") && isRootmeter

                        Image {
                            anchors.fill: parent
                            anchors.margins: border.width
                            fillMode: Image.PreserveAspectFit
                            source: "/ui/images/attention.svg"
                            visible: (isNotify === "shutoff" || isNotify === "limited") && isRootmeter

                            layer {
                                enabled: true
                                effect: ColorOverlay {
                                    color: Style.red
                                }
                            }
                        }
                    }
                }


                Label {

                    // here is the issue with the different textsizes
                    id: headerLabel
                    width: parent.width //- Style.margins
                    text: isElectric == true ? getLabeltext(root.currentMarketPrice) : getLabeltext(root.currentPower)
                    elide: Text.ElideRight
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                }


            }

            ColorIcon {
                size: Style.iconSize
                Layout.alignment: Qt.AlignCenter
                name: !root.thing || root.isBattery ? "" : thingToIcon(root.thing)
                color: "#3b3b3b"
                visible: !root.isBattery
            }

            Rectangle {
                id: batteryRect
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins + 5
                Layout.rightMargin: Style.margins + 8
                Layout.topMargin: Style.smallMargins
                Layout.preferredHeight: 15
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
                // those are the rectangles, which show how much the batterie is loaded
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

            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                Layout.leftMargin: Style.smallMargins
                Layout.rightMargin: Style.smallMargins
                Layout.bottomMargin: Style.smallMargins
                font: Style.smallFont
                text: root.thing ? root.thing.name : ""
                elide: Text.ElideRight
                color: "black"
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
