#include <QQmlEngine>

#include "hemsmanager.h"
#include "Configurations/userconfigurations.h"
#include "Configurations/average.h"


void registerOverlayTypes(const char *uri, int versionMajor, int versionMinor) {
    qmlRegisterType<HemsManager>(uri, versionMajor, versionMinor, "HemsManager");
    qmlRegisterUncreatableType<ChargingConfiguration>(uri, versionMajor, versionMinor, "ChargingConfiguration", "Get it from HemsManager");
    qmlRegisterUncreatableType<ChargingConfigurations>(uri, versionMajor, versionMinor, "ChargingConfigurations", "Get it from HemsManager");
    qmlRegisterUncreatableType<HeatingConfiguration>(uri, versionMajor, versionMinor, "HeatingConfiguration", "Get it from HemsManager");
    qmlRegisterUncreatableType<HeatingConfigurations>(uri, versionMajor, versionMinor, "HeatingConfigurations", "Get it from HemsManager");
    qmlRegisterUncreatableType<PvConfiguration>(uri, versionMajor, versionMinor, "PvConfiguration", "Get it from HemsManager");
    qmlRegisterUncreatableType<PvConfigurations>(uri, versionMajor, versionMinor, "PvConfigurations", "Get it from HemsManager");
    qmlRegisterUncreatableType<ChargingSessionConfiguration>(uri, versionMajor, versionMinor, "ChargingSessionConfiguration", "Get it from HemsManager");
    qmlRegisterUncreatableType<ChargingSessionConfigurations>(uri, versionMajor, versionMinor, "ChargingSessionConfigurations", "Get it from HemsManager");
    qmlRegisterUncreatableType<ConEMSState>(uri, versionMajor, versionMinor, "ConEMSState", "Get it from HemsManager");
    qmlRegisterUncreatableType<UserConfiguration>(uri, versionMajor, versionMinor, "UserConfiguration", "Get it from HemsManager");
    qmlRegisterType<Average>(uri, versionMajor, versionMinor, "Average");
    qmlRegisterUncreatableType<UserConfigurations>(uri, versionMajor, versionMinor, "UserConfigurations", "Get it from HemsManager");
    qmlRegisterUncreatableType<ChargingOptimizationConfiguration>(uri, versionMajor, versionMinor, "ChargingOptimizationConfiguration", "Get it from HemsManager");
    qmlRegisterUncreatableType<ChargingOptimizationConfigurations>(uri, versionMajor, versionMinor, "ChargingOptimizationConfigurations", "Get it from HemsManager");
    qmlRegisterUncreatableType<HeatingElementConfiguration>(uri, versionMajor, versionMinor, "HeatingElementConfiguration", "Get it from HemsManager");
    qmlRegisterUncreatableType<HeatingElementConfigurations>(uri, versionMajor, versionMinor, "HeatingElementConfigurations", "Get it from HemsManager");
}
