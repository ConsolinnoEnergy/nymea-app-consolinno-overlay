
// #TODO copyright notice

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.3
import Nymea 1.0
import NymeaApp.Utils 1.0
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

    DashboardDataProvider {
        id: dataProvider
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

    ThingsProxy {
        id: dynamicPricingThings
        engine: _engine
        shownInterfaces: ["dynamicelectricitypricing"]
    }

    ThingsProxy {
        id: gridSupportThings
        engine: _engine
        shownInterfaces: ["gridsupport"]
    }

    ThingsProxy {
        id: electricVehicleThings
        engine: _engine
        shownInterfaces: ["electricvehicle"]
    }

    readonly property Thing gridSupport: gridSupportThings.count > 0 ? gridSupportThings.get(0) : null
    readonly property Thing rootMeter: engine.thingManager.fetchingData ?
                                           null :
                                           engine.thingManager.things.getThing(energyManager.rootMeterId)
    readonly property Thing dynamicPricingThing: dynamicPricingThings.count > 0 ? dynamicPricingThings.get(0) : null

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
                    spacing: 16 // #TODO use value from new style

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
                                value: NymeaUtils.floatToLocaleString(Math.abs(dataProvider.currentPowerProduction), 0)
                                compactLayout: true
                                icon: Qt.resolvedUrl("qrc:/icons/weathericons/weather-clear-day.svg") // #TODO icon
                                clickable: false
                            }

                            CoPowerThingInfoCard {
                                Layout.fillWidth: true
                                Layout.row: 0
                                Layout.column: 2
                                text: qsTr("Grid")
                                thing: rootMeter
                                compactLayout: true
                                // #TODO LPP/LPC indicator
                                icon: {
                                    if (Configuration.gridIcon !== "") {
                                        return Qt.resolvedUrl("/ui/images/" + Configuration.gridIcon)
                                    } else {
                                        return Qt.resolvedUrl("/icons/grid.svg")
                                    }
                                }
                                onClicked: {
                                    console.info("Clicked grid card");
                                    pageStack.push(
                                                "/ui/devicepages/GenericSmartDeviceMeterPage.qml",
                                                {
                                                    "thing": thing,
                                                    "isRootmeter": true,
                                                    "isNotify": false, // #TODO LPP/LPC notification
                                                    "gridSupportThing": gridSupport
                                                });
                                }
                            }

                            CoInfoCard {
                                Layout.fillWidth: true
                                Layout.row: 2
                                Layout.column: 0
                                text: qsTr("Battery") // #TODO English name
                                value: NymeaUtils.floatToLocaleString(Math.abs(dataProvider.currentPowerBatteries), 0)
                                compactLayout: true
                                icon: {
                                    // #TODO icon via loaded battery capacity
                                    if (Configuration.batteryIcon !== ""){
                                        return Qt.resolvedUrl("qrc:/ui/images/" + Configuration.batteryIcon)
                                    } else {
                                        return Qt.resolvedUrl("qrc:/icons/battery/battery-060.svg")
                                    }
                                }
                                clickable: false
                            }

                            CoInfoCard {
                                Layout.fillWidth: true
                                Layout.row: 2
                                Layout.column: 2
                                text: qsTr("Consumption") // #TODO English name
                                value: "500 W" // #TODO value
                                compactLayout: true
                                icon: Qt.resolvedUrl("qrc:/icons/energy.svg") // #TODO icon
                                clickable: false
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

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.topMargin: 8 // #TODO use values from new style
                            anchors.bottomMargin: 8 // #TODO use values from new style
                            anchors.leftMargin: 16 // #TODO use values from new style
                            anchors.rightMargin: 16 // #TODO use values from new style

                            spacing: 16 // #TODO use value from new style

                            CoInfoCard {
                                Layout.fillWidth: true
                                text: qsTr("Self-sufficiency") // #TODO English name
                                value: "70 %" // #TODO value
                                icon: Qt.resolvedUrl("qrc:/icons/energy.svg") // #TODO icon
                                clickable: false
                            }

                            CoInfoCard {
                                Layout.fillWidth: true
                                text: qsTr("Self-consumption") // #TODO English name
                                value: "93 %" // #TODO value
                                icon: Qt.resolvedUrl("qrc:/icons/energy.svg") // #TODO icon
                                clickable: false
                            }

                            CoInfoCard {
                                Layout.fillWidth: true
                                property Thing thing: dynamicPricingThing
                                readonly property State currentMarketPriceState: thing ? thing.stateByName("currentTotalCost") : null
                                readonly property double currentMarketPrice: currentMarketPriceState ? currentMarketPriceState.value.toFixed(2) : 0
                                visible: dynamicPricingThing ? true : false
                                text: thing ? thing.name : ""
                                value: {
                                    let v = currentMarketPrice;
                                    let decimals = 0;
                                    if (Math.abs(v) < 10.0) {
                                        decimals = 2;
                                    } else if (Math.abs(v) < 100.0) {
                                        decimals = 1;
                                    } else {
                                        decimals = 0;
                                    }
                                    return v.toLocaleString(Qt.locale(), 'f', decimals) + " ct/kWh";
                                }
                                icon: {
                                    if (Configuration.energyIcon !== "") {
                                        return Qt.resolvedUrl("/ui/images/" + Configuration.energyIcon)
                                    } else {
                                        return Qt.resolvedUrl("/icons/energy.svg")
                                    }
                                }
                                onClicked: {
                                    console.info("Clicked dynamic tariff");
                                    pageStack.push("/ui/devicepages/PageWraper.qml",
                                                   { "thing": thing });
                                }
                            }
                        }
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

                                delegate: CoPowerThingInfoCard {
                                    Layout.fillWidth: true
                                    thing: producerThings.get(index)
                                    icon: thingToIcon(thing)
                                    // #TODO warning indicator for LPP
                                    onClicked: {
                                        console.info("Clicked inverter:", thing.name);
                                        pageStack.push(
                                                    "/ui/devicepages/GenericSmartDeviceMeterPage.qml",
                                                    {
                                                        "thing": thing,
                                                        "isNotify": false, // #TODO LPP active
                                                        "gridSupportThing": gridSupport
                                                    });
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

                                delegate: CoPowerThingInfoCard {
                                    Layout.fillWidth: true
                                    thing: batteriesThings.get(index)
                                    icon: thingToIcon(thing)
                                    onClicked: {
                                        console.info("Clicked battery:", thing.name);
                                        let batteryView = thing.thingClass.interfaces.indexOf("controllablebattery") >= 0 ?
                                                "/ui/optimization/BatteryConfigView.qml" :
                                                "/ui/devicepages/GenericSmartDeviceMeterPage.qml";
                                        pageStack.push(batteryView,
                                                       {
                                                           "hemsManager": hemsManager,
                                                           "thing": thing,
                                                           "isBatteryView": true
                                                       });
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

                                delegate: CoPowerThingInfoCard {
                                    Layout.fillWidth: true
                                    thing: heatingThings.get(index)
                                    icon: thingToIcon(thing)
                                    onClicked: {
                                        console.info("Clicked heating thing:", thing.name);
                                        if (thing.thingClass.interfaces.indexOf("heatpump") >= 0) {
                                            pageStack.push(
                                                        "/ui/optimization/HeatingConfigView.qml",
                                                        {
                                                            "hemsManager": hemsManager,
                                                            "thing": thing
                                                        });
                                        } else if (thing.thingClass.interfaces.indexOf("heatingrod") >= 0) {
                                            pageStack.push(
                                                        "/ui/devicepages/HeatingElementDevicePage.qml",
                                                        {
                                                            "hemsManager": hemsManager,
                                                            "thing": thing
                                                        });
                                        } else {
                                            console.warn("Neither heatpump nor heatingrod interface found in thing interfaces:",
                                                         thing.thingClass.interfaces);
                                            pageStack.push(
                                                        "/ui/devicepages/GenericSmartDeviceMeterPage.qml",
                                                        {
                                                            "thing": thing
                                                        });
                                        }
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

                                delegate: CoPowerThingInfoCard {
                                    Layout.fillWidth: true
                                    thing: evChargerThings.get(index)
                                    icon: thingToIcon(thing)
                                    onClicked: {
                                        console.info("Clicked EV charger thing:", thing.name);
                                        // Check if these states are provided by the thing
                                        let pluggedIn = thing.stateByName("pluggedIn");
                                        let maxChargingCurrent = thing.stateByName("maxChargingCurrent");
                                        let phaseCount = thing.stateByName("phaseCount");

                                        // If yes, you can use the optimization else you have to
                                        // resort to the EvChargerThingPage
                                        if (pluggedIn !== null &&
                                                maxChargingCurrent !== null &&
                                                phaseCount !== null) {
                                            let carThingId =
                                                hemsManager.chargingConfigurations.getChargingConfiguration(thing.id).carThingId;
                                            pageStack.push(
                                                        "../optimization/ChargingConfigView.qml",
                                                        {
                                                            "hemsManager": hemsManager,
                                                            "thing": thing,
                                                            "carThing": electricVehicleThings.getThing(carThingId)
                                                        });
                                        } else {
                                            pageStack.push(
                                                        "/ui/devicepages/EvChargerThingPage.qml",
                                                        {
                                                            "thing": thing
                                                        });
                                        }
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

                                delegate: CoPowerThingInfoCard {
                                    Layout.fillWidth: true
                                    thing: otherConsumerThings.get(index)
                                    icon: thingToIcon(thing)
                                    onClicked: {
                                        console.info("Clicked thing:", thing.name);
                                        pageStack.push(
                                                    "/ui/devicepages/GenericSmartDeviceMeterPage.qml",
                                                    {
                                                        "thing": thing
                                                    });
                                    }
                                }
                            }

                            CoInfoCard {
                                Layout.fillWidth: true
                                text: qsTr("Non-controllable") // #TODO name
                                value: "678 W" // #TODO value
                                icon: Qt.resolvedUrl("qrc:/icons/select-none.svg") // #TODO icon
                                clickable: false
                            }
                        }
                    }
                }
            }
        }
    }
}
