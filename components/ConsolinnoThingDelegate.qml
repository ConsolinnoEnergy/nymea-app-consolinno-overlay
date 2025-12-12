import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.12
import "../components"
import Nymea 1.0

ConsolinnoSwipeDelegate {
    id: root
    width: parent.width
    iconName: {
        let thingInterface = thing.thingClass.interfaces

        if (thingInterface.indexOf("energymeter") >= 0) {
            if(Configuration.gridIcon === ""){
                iconPath = "/icons/grid.svg";
            }else{
                iconPath = "../images/" + Configuration.gridIcon;
            }
            return iconPath;
        } else if (thingInterface.indexOf("heatpump") >= 0) {
            if (Configuration.heatpumpIcon !== "") {
                iconPath = "../images/" + Configuration.heatpumpIcon;
            } else {
                iconPath = "/icons/heatpump.svg";
            }
            return iconPath;
        } else if (thingInterface.indexOf("heatingrod") >= 0) {
            if (Configuration.heatingRodIcon !== "") {
                iconPath = "../images/" + Configuration.heatingRodIcon;
            } else {
                iconPath = "/icons/heating_rod.svg";
            }
            return iconPath;
        } else if (thingInterface.indexOf("energystorage") >= 0 && Configuration.batteryIcon !== "") {
            if (Configuration.batteryIcon !== "") {
                iconPath = "../images/" + Configuration.batteryIcon;
            }
            return iconPath;
        } else if (thingInterface.indexOf("evcharger") >= 0 && Configuration.evchargerIcon !== "") {
            if (Configuration.evchargerIcon !== "") {
                iconPath = "../images/" + Configuration.evchargerIcon;
            }
            return iconPath;
        } else if (thingInterface.indexOf("solarinverter") >= 0 && Configuration.inverterIcon !== "") {
            if (Configuration.inverterIcon !== "") {
                iconPath = "../images/" + Configuration.inverterIcon;
            }
            return iconPath;
        } else if (thingInterface.indexOf("dynamicelectricitypricing") >= 0) {
            if (Configuration.energyIcon !== "") {
                iconPath = "../images/" + Configuration.energyIcon;
            }else{
                iconPath = "/icons/energy.svg"
            }
            return iconPath;
        } else {
            return app.interfacesToIcon(thing.thingClass.interfaces);
        }

    }
    property var thingSetupStatus: thing ? thing.setupStatus : ""
    iconColor: Style.consolinnoMedium
    text: thing ? thing.name : ""
    progressive: true
    secondaryIconName: thingSetupStatus === Thing.ThingSetupStatusComplete && batteryCritical ? "/icons/battery/battery-010.svg" : ""
    tertiaryIconName: {
        if (thingSetupStatus === Thing.ThingSetupStatusFailed) {
            return "/icons/dialog-warning-symbolic.svg";
        }
        if (thingSetupStatus === Thing.ThingSetupStatusInProgress) {
            return "/icons/settings.svg"
        }
        if (connectedState && connectedState.value === false) {
            if (!isWireless) {
                return "/icons/connections/network-wired-offline.svg"
            }
            return "/icons/connections/nm-signal-00.svg"
        }
        return ""
    }

    tertiaryIconColor: {
        if (thingSetupStatus === Thing.ThingSetupStatusFailed) {
            return Style.red
        }
        if (thingSetupStatus === Thing.ThingSetupStatusInProgress) {
            return Style.iconColor
        }
        if (connectedState && connectedState.value === false) {
            return Style.red
        }
        return Style.iconColor
    }

    property Thing thing: null
    property alias device: root.thing

    readonly property bool hasBatteryInterface: thing && thing.thingClass.interfaces.indexOf("battery") >= 0
    readonly property StateType batteryCriticalStateType: hasBatteryInterface ? thing.thingClass.stateTypes.findByName("batteryCritical") : null
    readonly property State batteryCriticalState: batteryCriticalStateType ? thing.states.getState(batteryCriticalStateType.id) : null
    readonly property bool batteryCritical: batteryCriticalState && batteryCriticalState.value === true

    readonly property bool hasConnectableInterface: thing && thing.thingClass.interfaces.indexOf("connectable") >= 0
    readonly property StateType connectedStateType: hasConnectableInterface ? thing.thingClass.stateTypes.findByName("connected") : null
    readonly property State connectedState: connectedStateType ? thing.states.getState(connectedStateType.id) : null
    readonly property bool disconnected: connectedState && connectedState.value === false ? true : false

    readonly property bool isWireless: isNaN(root.thing) ? root.thing.thingClass.interfaces.indexOf("wirelessconnectable") >= 0 : false
    readonly property State signalStrengthState: isNaN(root.thing) ? root.thing.stateByName("signalStrength") : null
}
