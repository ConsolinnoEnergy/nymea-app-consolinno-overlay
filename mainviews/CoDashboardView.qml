
// #TODO copyright notice

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.3
import Nymea 1.0
import Qt.labs.settings 1.1
import QtGraphicalEffects 1.15

import "../components"
import "../delegates"

MainViewBase {
    id: root

    contentY: flickable.contentY + topMargin

    headerButtons: []

    function thingToIcon(thing) {
        let ifaces = thing.thingClass.interfaces;
        for (var i = 0; i < ifaces.length; i++) {
            let iface = ifaces[i];
            let icon = ""

            switch (iface) {
            case "pvsurplusheatpump":
            case "smartgridheatpump":
            case "heatpump":
                if (Configuration.heatpumpIcon !== ""){
                    icon = "qrc:/ui/images/" + Configuration.heatpumpIcon;
                } else {
                    icon = "qrc:/icons/heatpump.svg";
                }
                break;
            case "heatingrod":
                if (Configuration.heatingRodIcon !== ""){
                    icon = "qrc:/ui/images/" + Configuration.heatingRodIcon;
                } else {
                    icon = "qrc:/icons/heating_rod.svg";
                }
                break;
            case "energystorage":
                if (Configuration.batteryIcon !== ""){
                    icon = "qrc:/ui/images/" + Configuration.batteryIcon
                } else {
                    icon = "qrc:/icons/battery/battery-060.svg";
                }
                break;
            case "evcharger":
                if (Configuration.evchargerIcon !== ""){
                    icon = "qrc:/ui/images/" + Configuration.evchargerIcon
                } else {
                    icon = "qrc:/icons/ev-charger.svg";
                }
                break;
            case "solarinverter":
                if (Configuration.inverterIcon !== ""){
                    icon = "qrc:/ui/images/" + Configuration.inverterIcon
                } else {
                    icon = "qrc:/icons/weathericons/weather-clear-day.svg";
                }
                break;
            default:
                icon = app.interfaceToIcon(iface)
            }

            if (icon !== "") {
                return Qt.resolvedUrl(icon);
            }
        }
        console.warn("thingToIcon: unable to determine icon for thing",
                     thing.name);
        return Qt.resolvedUrl("qrc:/icons/select-none.svg");
    }

    EnergyManager {
        id: energyManager
        engine: _engine
    }

    HemsManager {
        id: hemsManager
        engine: _engine
    }

    ThingsProxy {
        id: producerThings
        engine: _engine
        shownInterfaces: ["smartmeterproducer"]
    }

    ThingsProxy {
        id: batteriesThings
        engine: _engine
        shownInterfaces: ["energystorage"]
    }

    ThingsProxy {
        id: heatingThings
        engine: _engine
        shownInterfaces: ["heatpump", "heatingrod"]
    }

    ThingsProxy {
        id: evChargerThings
        engine: _engine
        shownInterfaces: ["evcharger"]
    }

    ThingsProxy {
        id: otherConsumerThings
        engine: _engine
        shownInterfaces: ["smartmeterconsumer"]
        hiddenInterfaces: ["heatpump", "heatingrod", "evcharger"]
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: dashboardRoot.implicitHeight
        topMargin: root.topMargin
        bottomMargin: root.bottomMargin

        Item {
            anchors.fill: parent

            Rectangle {
                id: background
                anchors.fill: parent
                color: "#FFFFFF" // #TODO color from new style

                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop{ position: 0.0; color: "#80BDD786" } // #TODO color from new style
                        GradientStop{ position: 1.0; color: "#8083BC32" } // #TODO color from new style
                    }
                }
            }

            Item {
                id: dashboardRoot
                anchors.fill: parent
                anchors.margins: 16 // #TODO use value from new style

                implicitHeight: dashboardLayout.childrenRect.height + anchors.margins * 2

                ColumnLayout {
                    id: dashboardLayout
                    anchors.fill: parent

                    CoFrostyCard {
                        Layout.fillWidth: true

                        headerText: qsTr("Live status")

                        GridLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 8 // #TODO use values from new style
                            anchors.bottomMargin: 8 // #TODO use values from new style
                            anchors.leftMargin: 16 // #TODO use values from new style
                            anchors.rightMargin: 16 // #TODO use values from new style
                            rowSpacing: 0
                            columnSpacing: 0

                            CoInfoCard {
                                Layout.fillWidth: true
                                Layout.row: 0
                                Layout.column: 0
                                text: qsTr("Solar") // #TODO English name
                                value: "678 W" // #TODO value
                                compactLayout: true
                                icon: Qt.resolvedUrl("qrc:/icons/weathericons/weather-clear-day.svg") // #TODO icon
                                onClicked: {
                                    // #TODO
                                    console.warn("Clicked solar card");
                                }
                            }

                            CoInfoCard {
                                Layout.fillWidth: true
                                Layout.row: 0
                                Layout.column: 2
                                text: qsTr("Grid") // #TODO English name
                                value: "300 W" // #TODO value
                                compactLayout: true
                                icon: {
                                    if (Configuration.gridIcon !== "") {
                                        return Qt.resolvedUrl("/ui/images/" + Configuration.gridIcon)
                                    } else {
                                        return Qt.resolvedUrl("/icons/grid.svg")
                                    }
                                }
                                onClicked: {
                                    // #TODO
                                    console.warn("Clicked grid card");
                                }
                            }

                            CoInfoCard {
                                Layout.fillWidth: true
                                Layout.row: 2
                                Layout.column: 0
                                text: qsTr("Battery") // #TODO English name
                                value: "100 W" // #TODO value
                                compactLayout: true
                                icon: {
                                    if (Configuration.batteryIcon !== ""){
                                        return Qt.resolvedUrl("qrc:/ui/images/" + Configuration.batteryIcon)
                                    } else {
                                        return Qt.resolvedUrl("qrc:/icons/battery/battery-060.svg")
                                    }
                                }
                                onClicked: {
                                    // #TODO
                                    console.warn("Clicked battery card");
                                }
                            }

                            CoInfoCard {
                                Layout.fillWidth: true
                                Layout.row: 2
                                Layout.column: 2
                                text: qsTr("Consumption") // #TODO English name
                                value: "500 W" // #TODO value
                                compactLayout: true
                                icon: Qt.resolvedUrl("qrc:/icons/energy.svg") // #TODO icon
                                onClicked: {
                                    // #TODO
                                    console.warn("Clicked consumption card");
                                }
                            }

                            Item {
                                id: liveStatusSpacer
                                Layout.row: 1
                                Layout.column: 1
                                width: 64
                                height: 64
                            }
                        }
                    }

                    CoFrostyCard {
                        Layout.fillWidth: true

                        headerText: qsTr("Energy status")
                    }

                    CoFrostyCard {
                        Layout.fillWidth: true

                        headerText: qsTr("Inverters")
                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 8 // #TODO use values from new style
                            anchors.bottomMargin: 8 // #TODO use values from new style
                            anchors.leftMargin: 16 // #TODO use values from new style
                            anchors.rightMargin: 16 // #TODO use values from new style

                            spacing: 16 // #TODO use value from new style

                            Repeater {
                                model: producerThings

                                delegate: CoInfoCard {
                                    // #TODO specialize CoInfoCard to avoid repetition
                                    Layout.fillWidth: true
                                    property Thing thing: producerThings.get(index)
                                    readonly property State currentPowerState: thing ? thing.stateByName("currentPower") : null
                                    readonly property double currentPower: currentPowerState ? currentPowerState.value.toFixed(0) : 0
                                    text: thing.name
                                    value: currentPowerState ? Math.abs(currentPower) + " W" : "-"
                                    icon: thingToIcon(thing)
                                    // #TODO warning indicator for LPP
                                    onClicked: {
                                        // #TODO open thing detail page here
                                        console.warn("Clicked thing:", index, thing.name);
                                    }
                                }
                            }
                        }
                    }

                    CoFrostyCard {
                        Layout.fillWidth: true

                        headerText: qsTr("Batteries")
                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 8 // #TODO use values from new style
                            anchors.bottomMargin: 8 // #TODO use values from new style
                            anchors.leftMargin: 16 // #TODO use values from new style
                            anchors.rightMargin: 16 // #TODO use values from new style

                            spacing: 16 // #TODO use value from new style

                            Repeater {
                                model: batteriesThings

                                delegate: CoInfoCard {
                                    // #TODO specialize CoInfoCard to avoid repetition
                                    Layout.fillWidth: true
                                    property Thing thing: batteriesThings.get(index)
                                    readonly property State currentPowerState: thing ? thing.stateByName("currentPower") : null
                                    readonly property double currentPower: currentPowerState ? currentPowerState.value.toFixed(0) : 0
                                    text: thing.name
                                    value: currentPowerState ? Math.abs(currentPower) + " W" : "-"
                                    icon: thingToIcon(thing)
                                    onClicked: {
                                        // #TODO open thing detail page here
                                        console.warn("Clicked thing:", index, thing.name);
                                    }
                                }
                            }
                        }
                    }

                    CoFrostyCard {
                        Layout.fillWidth: true

                        headerText: qsTr("Heating")
                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 8 // #TODO use values from new style
                            anchors.bottomMargin: 8 // #TODO use values from new style
                            anchors.leftMargin: 16 // #TODO use values from new style
                            anchors.rightMargin: 16 // #TODO use values from new style

                            spacing: 16 // #TODO use value from new style

                            Repeater {
                                model: heatingThings

                                delegate: CoInfoCard {
                                    Layout.fillWidth: true
                                    property Thing thing: heatingThings.get(index)
                                    readonly property State currentPowerState: thing ? thing.stateByName("currentPower") : null
                                    readonly property double currentPower: currentPowerState ? currentPowerState.value.toFixed(0) : 0
                                    text: thing.name
                                    value: currentPowerState ? Math.abs(currentPower) + " W" : "-"
                                    icon: thingToIcon(thing)
                                    onClicked: {
                                        // #TODO open thing detail page here
                                        console.warn("Clicked thing:", index, thing.name);
                                    }
                                }
                            }
                        }
                    }

                    CoFrostyCard {
                        Layout.fillWidth: true

                        headerText: qsTr("Mobility")
                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 8 // #TODO use values from new style
                            anchors.bottomMargin: 8 // #TODO use values from new style
                            anchors.leftMargin: 16 // #TODO use values from new style
                            anchors.rightMargin: 16 // #TODO use values from new style

                            spacing: 16 // #TODO use value from new style

                            Repeater {
                                model: evChargerThings

                                delegate: CoInfoCard {
                                    Layout.fillWidth: true
                                    property Thing thing: evChargerThings.get(index)
                                    readonly property State currentPowerState: thing ? thing.stateByName("currentPower") : null
                                    readonly property double currentPower: currentPowerState ? currentPowerState.value.toFixed(0) : 0
                                    text: thing.name
                                    value: currentPowerState ? Math.abs(currentPower) + " W" : "-"
                                    icon: thingToIcon(thing)
                                    onClicked: {
                                        // #TODO open thing detail page here
                                        console.warn("Clicked thing:", index, thing.name);
                                    }
                                }
                            }
                        }
                    }

                    CoFrostyCard {
                        Layout.fillWidth: true

                        headerText: qsTr("Other consumers")
                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 8 // #TODO use values from new style
                            anchors.bottomMargin: 8 // #TODO use values from new style
                            anchors.leftMargin: 16 // #TODO use values from new style
                            anchors.rightMargin: 16 // #TODO use values from new style

                            spacing: 16 // #TODO use value from new style

                            Repeater {
                                model: otherConsumerThings

                                delegate: CoInfoCard {
                                    Layout.fillWidth: true
                                    property Thing thing: otherConsumerThings.get(index)
                                    readonly property State currentPowerState: thing ? thing.stateByName("currentPower") : null
                                    readonly property double currentPower: currentPowerState ? currentPowerState.value.toFixed(0) : 0
                                    text: thing.name
                                    value: currentPowerState ? Math.abs(currentPower) + " W" : "-"
                                    icon: thingToIcon(thing)
                                    onClicked: {
                                        // #TODO open thing detail page here
                                        console.warn("Clicked thing:", index, thing.name);
                                    }
                                }
                            }

                            CoInfoCard {
                                Layout.fillWidth: true
                                text: qsTr("Non-controllable") // #TODO name
                                value: "678 W" // #TODO value
                                icon: Qt.resolvedUrl("qrc:/icons/select-none.svg") // #TODO icon
                                onClicked: {
                                    // #TODO is there a detail page for non-controllable consumers?
                                    console.warn("Clicked non-controllable");
                                }
                            }
                        }
                    }

                    CoFrostyCard {
                        Layout.fillWidth: true

                        headerText: "Card component"
                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 8 // #TODO use values from new style
                            anchors.bottomMargin: 8 // #TODO use values from new style
                            spacing: 0

                            CoCard {
                                Layout.fillWidth: true

                                text: "Text"
                                helpText: "Help text"
                                labelText: "Label"
                                iconLeft: Qt.resolvedUrl("qrc:/icons/up.svg")
                                iconRight: Qt.resolvedUrl("qrc:/icons/down.svg")
                                showChildrenIndicator: true

                                onClicked: {
                                    console.warn("======= CLICKED");
                                }
                            }

                            CoCard {
                                Layout.fillWidth: true

                                text: "Text"
                                helpText: "Some very very very very very very very very very very very long text"
                                labelText: "Another  very very very very very very very very very very long text"
                                iconLeft: Qt.resolvedUrl("qrc:/icons/up.svg")
                            }
                        }
                    }

                    Rectangle {
                        id: spacer
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"
                        border.color: "red"
                        border.width: 1
                    }
                }
            }
        }
    }
}
