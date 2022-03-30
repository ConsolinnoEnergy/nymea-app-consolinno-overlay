#include <QQmlEngine>

#include "hemsmanager.h"
#include "chargingconfigurations.h"
#include "heatingconfigurations.h"
#include "pvconfigurations.h"

void registerOverlayTypes(const char *uri, int versionMajor, int versionMinor) {
    qmlRegisterType<HemsManager>(uri, versionMajor, versionMinor, "HemsManager");
    qmlRegisterUncreatableType<ChargingConfiguration>(uri, versionMajor, versionMinor, "ChargingConfiguration", "Get it from HemsManager");
    qmlRegisterUncreatableType<ChargingConfigurations>(uri, versionMajor, versionMinor, "ChargingConfigurations", "Get it from HemsManager");
    qmlRegisterUncreatableType<HeatingConfiguration>(uri, versionMajor, versionMinor, "HeatingConfiguration", "Get it from HemsManager");
    qmlRegisterUncreatableType<HeatingConfigurations>(uri, versionMajor, versionMinor, "HeatingConfigurations", "Get it from HemsManager");
    qmlRegisterUncreatableType<PvConfiguration>(uri, versionMajor, versionMinor, "PvConfiguration", "Get it from HemsManager");
    qmlRegisterUncreatableType<PvConfigurations>(uri, versionMajor, versionMinor, "PvConfigurations", "Get it from HemsManager");
}
