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
    readonly property State currentWhiteGoodState: thing ? thing.stateByName("operationState") : null
    readonly property bool isProducer: thing && thing.thingClass.interfaces.indexOf("smartmeterproducer") >= 0
    readonly property bool isBattery: thing && thing.thingClass.interfaces.indexOf("energystorage") >= 0
    readonly property bool isHeatingRod: thing && thing.thingClass.interfaces.indexOf("smartmeterconsumer") >= 0

    readonly property bool isWashingMachine: thing && thing.thingClass.interfaces.indexOf("smartwashingmachine") >= 0
    readonly property bool isDryer: thing && thing.thingClass.interfaces.indexOf("smartdryer") >= 0
    readonly property bool isDishWasher: thing && thing.thingClass.interfaces.indexOf("smartdishwasher") >= 0

    property bool isRootmeter: false

    property bool isPowerConnection: false
    property bool isElectric: false
    property bool isWhiteGood: false

    readonly property double currentPower: root.currentPowerState ? root.currentPowerState.value.toFixed(0) : 0
    readonly property double currentMarketPrice: root.currentMarketPriceState ? root.currentMarketPriceState.value.toFixed(2) : 0
    readonly property string currentSmartWhiteGoodState: root.currentWhiteGoodState ? root.currentWhiteGoodState.value : "-"
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

    function getLabeltext(value) {
        let unit = ""
        if (currentPowerState != null) {
            value = Math.abs(value)
            unit = " W"
            return value + unit // No need for localization here
        }else if(isElectric == true) {
            // Round to fit in 3 digits for prices smaller 1000 ct/kWh
            unit = " ct/kWh"
            if (Math.abs(value) < 10.0) {
                value = Math.round(value * 100) / 100
            }else if (Math.abs(value) < 100.0) {
                value = Math.round(value * 10) / 10
            }else{
                value = Math.round(value)
            }
        }else if(isWhiteGood == true) {
            let whiteGoodStateText = "";

            if (value === "Inactive") {
                whiteGoodStateText = qsTr("Inactive");
            } else if (value === "Ready") {
                whiteGoodStateText = qsTr("Ready");
            } else if (value === "Delayed start") {
                whiteGoodStateText = qsTr("Delayed Start");
            } else if (value === "Run") {
                whiteGoodStateText = qsTr("Run");
            } else if (value === "Pause") {
                whiteGoodStateText = qsTr("Pause");
            } else if (value === "Actionrequired") {
                whiteGoodStateText = qsTr("Action required");
            } else if (value === "Finished") {
                whiteGoodStateText = qsTr("Finished");
            } else if (value === "Error") {
                whiteGoodStateText = qsTr("Error");
            } else if (value === "Aborting") {
                whiteGoodStateText = qsTr("Aborting");
            }
            return whiteGoodStateText;
        }else{
            return "–"
        }
        return value.toLocaleString() + unit
    }


    function ifacesToIcon(interfaces) {
        for (var i = 0; i < interfaces.length; i++) {
            var icon = ifaceToIcon(interfaces[i]);
            console.error(icon)
            if (icon !== "") {
                return icon;
            }
        }
        return Qt.resolvedUrl("images/select-none.svg")
    }

    function ifaceToIcon(name) {
        let icon = "";
        let heatpumpName = "";

        (name === "pvsurplusheatpump") ? heatpumpName = "pvsurplusheatpump" : (name === "smartgridheatpump") ? heatpumpName = "smartgridheatpump" : heatpumpName = "heatpump"

        switch (name) {
        case heatpumpName:
            if(Configuration.heatpumpIcon !== ""){
                icon = "qrc:/ui/images/"+Configuration.heatpumpIcon
            }else{
                icon = "qrc:/ui/images/heatpump.svg"
            }
            return Qt.resolvedUrl(icon)
        case "smartheatingrod":
            if(Configuration.heatingRodIcon !== ""){
                icon = "/ui/images/"+Configuration.heatingRodIcon
            }else{
                icon = "/ui/images/heating_rod.svg"
            }
            return Qt.resolvedUrl(icon)
        case "energystorage":
            if(Configuration.batteryIcon !== ""){
                icon = "/ui/images/"+Configuration.batteryIcon
                return Qt.resolvedUrl(icon)
            }
        case "evcharger":
            if(Configuration.evchargerIcon !== ""){
                icon = "/ui/images/"+Configuration.evchargerIcon
                return Qt.resolvedUrl(icon)
            }
        case "solarinverter":
            if(Configuration.inverterIcon !== ""){
                icon = "/ui/images/"+Configuration.inverterIcon
                return Qt.resolvedUrl(icon)
            }
        case "solarinverter":
            if(Configuration.inverterIcon !== ""){
                icon = "/ui/images/"+Configuration.inverterIcon
                return Qt.resolvedUrl(icon)
            }
        default:
            return app.interfaceToIcon(name)
        }
    }


    function thingToIcon(thing) {
        let icon = ""
        if(isRootmeter){
            if(Configuration.gridIcon !== ""){
                icon = "/ui/images/"+Configuration.gridIcon;
            }else{
                icon = "/ui/images/grid.svg"
            }
            return Qt.resolvedUrl(icon);
        }else if(isElectric){
            if(Configuration.energyIcon !== ""){
                icon = "/ui/images/"+Configuration.energyIcon;
            }else{
                icon = "/ui/images/energy.svg"
            }
            return Qt.resolvedUrl(icon);
        }else if(isBattery){
            return Qt.resolvedUrl("/ui/images/"+Configuration.batteryIcon)
        }else if(isWashingMachine){
            if(Configuration.washingMachineIcon !== ""){
                icon = "/ui/images/"+Configuration.washingMachineIcon
            }else{
                icon = "/ui/images/washingMachine.svg"
            }
            return Qt.resolvedUrl(icon)
        }else if(isDishWasher){
            if(Configuration.dishwasherIcon !== ""){
                icon = "/ui/images/"+Configuration.dishwasherIcon
            }else{
                icon = "/ui/images/dishwasher.svg"
            }
            return Qt.resolvedUrl(icon)
        }else if(isDryer){
            if(Configuration.dryerIcon !== ""){
                icon = "/ui/images/"+Configuration.dryerIcon
            }else{
                icon = "/ui/images/dryer.svg"
            }
            return Qt.resolvedUrl(icon)
        }
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
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: root.currentPower.toString().length >= 5 ? 1 : 10

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
                    text: isElectric == true ? getLabeltext(root.currentMarketPrice) : isWhiteGood == true ? getLabeltext(root.currentSmartWhiteGoodState) : getLabeltext(root.currentPower)
                    elide: Text.ElideRight
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    anchors.verticalCenter: parent.verticalCenter
                }


            }

            ColorIcon {
                size: Style.iconSize
                Layout.alignment: Qt.AlignCenter
                name: !root.thing || Configuration.batteryIcon === "" && root.isBattery ? "" : thingToIcon(root.thing)
                color: "#3b3b3b"
                visible: !root.isBattery || root.isBattery && Configuration.batteryIcon !== ""
            }

            Rectangle {
                id: batteryRect
                Layout.fillWidth: true
                Layout.leftMargin: Style.margins + 5
                Layout.rightMargin: Style.margins + 8
                Layout.topMargin: Style.smallMargins
                Layout.preferredHeight: 15
                visible: root.isBattery && Configuration.batteryIcon === ""

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
                    visible: root.isBattery && Configuration.batteryIcon === ""
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
                color: Configuration.mainMenuThingName
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
