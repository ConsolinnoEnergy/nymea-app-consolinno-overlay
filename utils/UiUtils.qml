pragma Singleton

import QtQuick
import Nymea
import NymeaApp.Utils

Item {
    id: root

    function energyDisplayValue(energyState) {
        return energyState ?
                    NymeaUtils.floatToLocaleString((+energyState.value), 2) :
                    "-";
    }

    function powerDisplayValue(powerValue) {
        return Math.abs(powerValue) >= 1000 ?
                    NymeaUtils.floatToLocaleString(powerValue / 1000, 2) :
                    NymeaUtils.floatToLocaleString(powerValue, 0);
    }

    function powerDisplayUnit(powerValue) {
        return Math.abs(powerValue) >= 1000 ? "kW" : "W";
    }

    function convertToKw(numberW){
        return (+(Math.round((numberW / 1000) * 100 ) / 100)).toLocaleString()
    }

    function batteryIconByLevel(batteryLevel) {
        let batteryLevelForIcon = NymeaUtils.pad(Math.round(batteryLevel / 10) * 10, 3);
        return Qt.resolvedUrl("qrc:/icons/battery/battery-" + batteryLevelForIcon + ".svg");
    }

    function thingToIcon(thing) {
        let ifaces = thing.thingClass.interfaces;
        if (ifaces.indexOf("battery") >= 0) {
            let batteryLevelState = thing.stateByName("batteryLevel");
            if (batteryLevelState) {
                let batteryLevel = batteryLevelState.value;
                return batteryIconByLevel(batteryLevel);
            } else {
                return Qt.resolvedUrl("qrc:/icons/battery/battery-060.svg");
            }
        }
        return interfacesToIcon(ifaces);
    }

    function interfacesToIcon(interfaces) {
        for (var i = 0; i < interfaces.length; i++) {
            var icon = interfaceToIcon(interfaces[i]);
            if (icon !== "") {
                return icon;
            }
        }
        return Qt.resolvedUrl("qrc:/icons/select-none.svg")
    }

    function interfaceToIcon(name) {
        switch (name) {
        case "energystorage":
            return Qt.resolvedUrl("/icons/battery/battery-060.svg")
        case "heatingrod":
        case "smartheatingrod":
            return Qt.resolvedUrl("/icons/water_heater.svg")
        case "pvsurplusheatpump":
        case "heatpump":
        case "smartgridheatpump":
        case "simpleheatpump":
            return Qt.resolvedUrl("/icons/heat_pump.svg")
        case "gridsupport":
            return Qt.resolvedUrl("/icons/select-none.svg")
        case "light":
        case "colorlight":
        case "dimmablelight":
        case "colortemperaturelight":
            return Qt.resolvedUrl("qrc:/icons/light-on.svg")
        case "sensor":
            return Qt.resolvedUrl("qrc:/icons/sensors.svg")
        case "temperaturesensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/temperature.svg")
        case "humiditysensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/humidity.svg")
        case "moisturesensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/moisture.svg")
        case "lightsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/light.svg")
        case "conductivitysensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/conductivity.svg")
        case "pressuresensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/pressure.svg")
        case "noisesensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/noise.svg")
        case "cosensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/co.svg")
        case "co2sensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/co2.svg")
        case "no2sensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/no2.svg")
        case "o3sensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/o3.svg")
        case "vocsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/voc.svg")
        case "pm10sensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/pm10.svg")
        case "pm25sensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/pm25.svg")
        case "gassensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/gas.svg")
        case "daylightsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/light.svg")
        case "presencesensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/presence.svg")
        case "closablesensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/window-closed.svg")
        case "windspeedsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/windspeed.svg")
        case "watersensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/water.svg")
        case "vibrationsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/vibration.svg")
        case "waterlevelsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/water.svg")
        case "firesensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/fire.svg")
        case "o2sensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/o2.svg")
        case "phsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/ph.svg")
        case "orpsensor":
            return Qt.resolvedUrl("qrc:/icons/sensors/orp.svg")
        case "media":
        case "mediacontroller":
        case "mediaplayer":
            return Qt.resolvedUrl("qrc:/icons/media.svg")
        case "powersocket":
            return Qt.resolvedUrl("qrc:/icons/powersocket.svg")
        case "button":
        case "longpressbutton":
        case "simplemultibutton":
        case "longpressmultibutton":
        case "powerswitch":
            return Qt.resolvedUrl("qrc:/icons/system-shutdown.svg")
        case "weather":
            return Qt.resolvedUrl("qrc:/icons/weather-app-symbolic.svg")
        case "gateway":
            return Qt.resolvedUrl("qrc:/icons/cable.svg")
        case "notifications":
            return Qt.resolvedUrl("qrc:/icons/messaging-app-symbolic.svg")
        case "inputtrigger":
            return Qt.resolvedUrl("qrc:/icons/attention.svg")
        case "outputtrigger":
            return Qt.resolvedUrl("qrc:/icons/send.svg")
        case "shutter":
        case "extendedshutter":
            return Qt.resolvedUrl("qrc:/icons/shutter/shutter-040.svg")
        case "blind":
        case "extendedblind":
            return Qt.resolvedUrl("qrc:/icons/shutter/shutter-060.svg")
        case "garagedoor":
        case "impulsegaragedoor":
        case "statefulgaragedoor":
        case "extendedstatefulgaragedoor":
        case "garagegate":
            return Qt.resolvedUrl("qrc:/icons/garage/garage-100.svg")
        case "awning":
        case "extendedawning":
            return Qt.resolvedUrl("qrc:/icons/awning/awning-100.svg")
        case "battery":
        case "controllablebattery":
            return Qt.resolvedUrl("qrc:/icons/battery/battery-060.svg")
        case "uncategorized":
            return Qt.resolvedUrl("qrc:/icons/select-none.svg")
        case "simpleclosable":
            return Qt.resolvedUrl("qrc:/icons/closable-move.svg")
        case "fingerprintreader":
            return Qt.resolvedUrl("qrc:/icons/fingerprint.svg")
        case "accesscontrol":
            return Qt.resolvedUrl("qrc:/icons/lock-closed.svg")
        case "solarinverter":
            return Qt.resolvedUrl("qrc:/icons/solar_power.svg")
        case "smartmeterconsumer":
            return Qt.resolvedUrl("qrc:/icons/interests.svg")
        case "smartmeter":
        case "smartmeterproducer":
        case "energymeter":
            return Qt.resolvedUrl("qrc:/icons/electric_meter.svg")
        case "dynamicelectricitypricing":
            return Qt.resolvedUrl("qrc:/icons/electric_bolt.svg")
        case "heating":
            return Qt.resolvedUrl("qrc:/icons/thermostat/heating.svg")
        case "cooling":
            return Qt.resolvedUrl("qrc:/icons/thermostat/cooling.svg")
        case "thermostat":
            return Qt.resolvedUrl("qrc:/icons/dial.svg")
        case "evcharger":
            return Qt.resolvedUrl("qrc:/icons/ev_station.svg")
        case "doorbell":
            return Qt.resolvedUrl("qrc:/icons/notification.svg")
        case "irrigation":
            return Qt.resolvedUrl("qrc:/icons/irrigation.svg")
        case "ventilation":
            return Qt.resolvedUrl("qrc:/icons/ventilation.svg")
        case "power":
            return Qt.resolvedUrl("qrc:/icons/system-shutdown.svg")
        case "smartlock":
            return Qt.resolvedUrl("qrc:/icons/smartlock.svg")
        case "navigationpad":
        case "extendednavigationpad":
            return Qt.resolvedUrl("qrc:/icons/navigationpad.svg")
        case "volumecontroller":
            return Qt.resolvedUrl("qrc:/icons/audio-speakers-symbolic.svg")
        case "shufflerepeat":
            return Qt.resolvedUrl("qrc:/icons/media-playlist-shuffle.svg")
        case "alert":
            return Qt.resolvedUrl("qrc:/icons/notification.svg")
        case "barcodescanner":
            return Qt.resolvedUrl("qrc:/icons/qrcode.svg")
        case "cleaningrobot":
            return Qt.resolvedUrl("qrc:/icons/cleaning-robot.svg")
        case "account":
            return Qt.resolvedUrl("qrc:/icons/account.svg")
        case "wirelessconnectable":
            return Qt.resolvedUrl("qrc:/icons/connections/network-wifi.svg")
        case "connectable":
            return Qt.resolvedUrl("qrc:/icons/stock_link.svg")
        case "electricvehicle":
            return Qt.resolvedUrl("qrc:/icons/electric_car.svg")
        case "update":
            return Qt.resolvedUrl("qrc:/icons/system-update.svg")
        default:
            console.warn("UiUtils.interfaceToIcon: Unhandled interface", name)
        }
        return "";
    }
}
