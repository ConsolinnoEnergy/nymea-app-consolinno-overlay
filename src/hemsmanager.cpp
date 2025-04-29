#include "hemsmanager.h"

#include <QMetaEnum>
#include <QJsonDocument>
#include <QJsonObject>

#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcHems, "Hems");

HemsManager::HemsManager(QObject *parent) : QObject(parent)
{
    m_heatingConfigurations = new HeatingConfigurations(this);
    m_chargingConfigurations = new ChargingConfigurations(this);
    m_chargingOptimizationConfigurations = new ChargingOptimizationConfigurations(this);
    m_pvConfigurations = new PvConfigurations(this);
    m_heatingElementConfigurations = new HeatingElementConfigurations(this);
    m_dynamicElectricPricingConfigurations = new DynamicElectricPricingConfigurations(this);
    m_batteryConfigurations = new BatteryConfigurations(this);
    m_chargingSessionConfigurations = new ChargingSessionConfigurations(this);
    m_conEMSState = new ConEMSState();
    m_userConfigurations = new UserConfigurations(this);
}

HemsManager::~HemsManager()
{
    if (m_engine) {
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }

}

Engine *HemsManager::engine() const
{
    return m_engine;
}

void HemsManager::setEngine(Engine *engine)
{
    if (m_engine == engine)
        return;

    if (m_engine) {
        qCritical() << "Already have an engine:" << m_engine;
        m_engine->jsonRpcClient()->unregisterNotificationHandler(this);
    }

    m_engine = engine;
    emit engineChanged();

    if (m_engine) {

        if (!m_engine->jsonRpcClient()->experiences().contains("Hems")) {
            qCWarning(dcHems()) << "Hems experience not available on core system.";
            m_available = true;
            emit availableChanged();
            return;
        }
        m_available = true;
        emit availableChanged();

        m_fetchingData = true;
        emit fetchingDataChanged();

        // Register notifications
        m_engine->jsonRpcClient()->registerNotificationHandler(this, "Hems", "notificationReceived");

        // Fetch initial data
        m_engine->jsonRpcClient()->sendCommand("Hems.GetUserConfigurations", QVariantMap(), this, "getUserConfigurationsResponse");
        // This will crash if the Hems.GetConEMSState is not implemented on the server. No need to fetch this data initally
        //m_engine->jsonRpcClient()->sendCommand("Hems.GetConEMSState", QVariantMap(), this, "getConEMSStateResponse");
        m_engine->jsonRpcClient()->sendCommand("Hems.GetAvailableUseCases", QVariantMap(), this, "getAvailableUseCasesResponse");
        m_engine->jsonRpcClient()->sendCommand("Hems.GetHousholdPhaseLimit", QVariantMap(), this, "getHousholdPhaseLimitResponse");
        m_engine->jsonRpcClient()->sendCommand("Hems.GetHeatingConfigurations", QVariantMap(), this, "getHeatingConfigurationsResponse");
        m_engine->jsonRpcClient()->sendCommand("Hems.GetChargingConfigurations", QVariantMap(), this, "getChargingConfigurationsResponse");
        m_engine->jsonRpcClient()->sendCommand("Hems.GetChargingOptimizationConfigurations", QVariantMap(), this, "getChargingOptimizationConfigurationsResponse");
        m_engine->jsonRpcClient()->sendCommand("Hems.GetPvConfigurations", QVariantMap(), this, "getPvConfigurationsResponse");
        m_engine->jsonRpcClient()->sendCommand("Hems.GetChargingSessionConfigurations", QVariantMap(), this, "getChargingSessionConfigurationsResponse");

        m_engine->jsonRpcClient()->sendCommand("Hems.GetDynamicElectricPricingConfigurations", QVariantMap(), this, "getDynamicElectricPricingConfigurationResponse");
        m_engine->jsonRpcClient()->sendCommand("Hems.GetBatteryConfigurations", QVariantMap(), this, "getBatteryConfigurationResponse");

        m_engine->jsonRpcClient()->sendCommand("Hems.GetHeatingRodConfigurations", QVariantMap(), this, "getHeatingElementConfigurationsResponse");

    }
}

bool HemsManager::available() const
{
    return m_available;
}

bool HemsManager::fetchingData() const
{
    return m_fetchingData;
}

HemsManager::HemsUseCases HemsManager::availableUseCases() const
{
    return m_availableUseCases;
}

uint HemsManager::housholdPhaseLimit() const
{
    return m_housholdPhaseLimit;
}

int HemsManager::setHousholdPhaseLimit(uint housholdPhaseLimit)
{
    QVariantMap params;
    params.insert("housholdPhaseLimit", housholdPhaseLimit);
    return m_engine->jsonRpcClient()->sendCommand("Hems.SetHousholdPhaseLimit", params, this, "setHousholdPhaseLimitResponse");
}

HeatingConfigurations *HemsManager::heatingConfigurations() const
{
    return m_heatingConfigurations;
}

ChargingConfigurations *HemsManager::chargingConfigurations() const
{
    return m_chargingConfigurations;
}

ChargingOptimizationConfigurations *HemsManager::chargingOptimizationConfigurations() const
{
    return m_chargingOptimizationConfigurations;
}

ChargingSessionConfigurations *HemsManager::chargingSessionConfigurations() const
{

    return m_chargingSessionConfigurations;
}

PvConfigurations *HemsManager::pvConfigurations() const
{
    return m_pvConfigurations;
}

HeatingElementConfigurations *HemsManager::heatingElementConfigurations() const
{
    return m_heatingElementConfigurations;
}

DynamicElectricPricingConfigurations *HemsManager::dynamicElectricPricingConfigurations() const
{
    return m_dynamicElectricPricingConfigurations;
}

BatteryConfigurations *HemsManager::batteryConfigurations() const
{
    return m_batteryConfigurations;
}

ConEMSState *HemsManager::conEMSState() const
{
    return m_conEMSState;
}

UserConfigurations *HemsManager::userConfigurations() const
{
    return m_userConfigurations;
}

int HemsManager::setPvConfiguration(const QUuid &pvThingId, const QVariantMap &data)
{
    PvConfiguration *configuration = m_pvConfigurations->getPvConfiguration(pvThingId);
    // if the configuration does not exist yet. Set up a dummy configuration
    // This ensures that if the Thing does not exist that the program wont crash
    if (!configuration){
        qCDebug(dcHems()) << "Adding a dummy Config" << pvThingId;
        QVariantMap dummyConfig;
        dummyConfig.insert("pvThingId", pvThingId);
        dummyConfig.insert("longitude", 0);
        dummyConfig.insert("latitude", 0);
        dummyConfig.insert("roofPitch", 0);
        dummyConfig.insert("alignment", 0);
        dummyConfig.insert("kwPeak", 0);

        addOrUpdatePvConfiguration(dummyConfig);
        // and get the dummy Config
        configuration =  m_pvConfigurations->getPvConfiguration(pvThingId);
    }

    // Make a MetaObject of an configuration
    const QMetaObject *metaObj = configuration->metaObject();
    // add the values from data which match with the MetaObject
    QVariantMap config;
    for (int i = metaObj->propertyOffset(); i < metaObj->propertyCount(); ++i){
        if(data.contains(metaObj->property(i).name()))
            {
                //qCDebug(dcHems()) << "Data value: " << data.value(metaObj->property(i).name());
                config.insert(metaObj->property(i).name(), data.value(metaObj->property(i).name()) );
            }else{
                //qCDebug(dcHems())<< "type: " << metaObj->property(i).type() << "value: " << metaObj->property(i).read(configuration);
                config.insert(metaObj->property(i).name(), metaObj->property(i).read(configuration) );
            }
    }

    QVariantMap params;
    params.insert("pvConfiguration", config);
    qCDebug(dcHems()) << "Set pv configuration" << params;

    return m_engine->jsonRpcClient()->sendCommand("Hems.SetPvConfiguration", params, this, "setPvConfigurationResponse");
}

int HemsManager::setHeatingElementConfiguration(const QUuid &heatingRodThingId, const QVariantMap &data)
{
qCritical() << "setHeatingElementConfiguration" << data;
    HeatingElementConfiguration *configuration = m_heatingElementConfigurations->getHeatingElementConfiguration(heatingRodThingId);
    // if the configuration does not exist yet. Set up a dummy configuration
    // This ensures that if the Thing does not exist that the program wont crash
    if (!configuration){
        qCDebug(dcHems()) << "Adding a dummy Config" << heatingRodThingId;
        QVariantMap dummyConfig;
        dummyConfig.insert("heatingRodThingId", heatingRodThingId);
        dummyConfig.insert("maxElectricalPower", 0);
        dummyConfig.insert("optimizationEnabled", false);
        dummyConfig.insert("controllableLocalSystem", false);

        addOrUpdateHeatingElementConfiguration(dummyConfig);
        // and get the dummy Config
        configuration =  m_heatingElementConfigurations->getHeatingElementConfiguration(heatingRodThingId);
    }

    // Make a MetaObject of an configuration
    const QMetaObject *metaObj = configuration->metaObject();
    // add the values from data which match with the MetaObject
    QVariantMap config;
    for (int i = metaObj->propertyOffset(); i < metaObj->propertyCount(); ++i){
        if(data.contains(metaObj->property(i).name()))
            {
                //qCDebug(dcHems()) << "Data value: " << data.value(metaObj->property(i).name());
                config.insert(metaObj->property(i).name(), data.value(metaObj->property(i).name()) );
            }else{
                //qCDebug(dcHems())<< "type: " << metaObj->property(i).type() << "value: " << metaObj->property(i).read(configuration);
                config.insert(metaObj->property(i).name(), metaObj->property(i).read(configuration) );
            }
    }

    QVariantMap params;
    params.insert("heatingRodConfiguration", config);
    qCWarning(dcHems()) << "Set heatingelement configuration" << params;

    return m_engine->jsonRpcClient()->sendCommand("Hems.SetHeatingRodConfiguration", params, this, "setHeatingElementConfigurationResponse");
}


int HemsManager::setHeatingConfiguration(const QUuid &heatPumpThingId, const QVariantMap &data)
{

    HeatingConfiguration *configuration = m_heatingConfigurations->getHeatingConfiguration(heatPumpThingId);
    // if the configuration does not exist yet. Set up a dummy configuration
    // This ensures that if the Thing does not exist that the program wont crash
    if (!configuration){
        qCDebug(dcHems()) << "Adding a dummy Config" << heatPumpThingId;
        QVariantMap dummyConfig;
        dummyConfig.insert("heatPumpThingId", heatPumpThingId);
        dummyConfig.insert("optimizationEnabled", false);
        dummyConfig.insert("floorHeatingArea", 0);
        dummyConfig.insert("maxElectricalPower", 0);
        dummyConfig.insert("maxThermalEnergy",  0);
        dummyConfig.insert("controllableLocalSystem", false);

        addOrUpdateHeatingConfiguration(dummyConfig);
        // and get the dummy Config
        configuration =  m_heatingConfigurations->getHeatingConfiguration(heatPumpThingId);
    }

    // Make a MetaObject of an configuration
    const QMetaObject *metaObj = configuration->metaObject();
    // add the values from data which match with the MetaObject
    QVariantMap config;
    for (int i = metaObj->propertyOffset(); i < metaObj->propertyCount(); ++i){
        if(data.contains(metaObj->property(i).name()))
            {
                //qCDebug(dcHems()) << "Data value: " << data.value(metaObj->property(i).name());
                config.insert(metaObj->property(i).name(), data.value(metaObj->property(i).name()) );
            }else{
                //qCDebug(dcHems())<< "type: " << metaObj->property(i).type() << "value: " << metaObj->property(i).read(configuration);
                config.insert(metaObj->property(i).name(), metaObj->property(i).read(configuration) );
            }
    }

    QVariantMap params;
    params.insert("heatingConfiguration", config);
    qCWarning(dcHems()) << "Set heating configuration" << params;

    return m_engine->jsonRpcClient()->sendCommand("Hems.SetHeatingConfiguration", params, this, "setHeatingConfigurationResponse");
}


int HemsManager::setDynamicElectricPricingConfiguration(const QUuid &electricThingId, const QVariantMap &data)
{

    DynamicElectricPricingConfiguration *configuration = m_dynamicElectricPricingConfigurations->getElectricConfiguration(electricThingId);
    // if the configuration does not exist yet. Set up a dummy configuration
    // This ensures that if the Thing does not exist that the program wont crash
    if (!configuration){
        qCDebug(dcHems()) << "Adding a dummy Config" << electricThingId;
        QVariantMap dummyConfig;
        dummyConfig.insert("electricThingId", electricThingId);
        dummyConfig.insert("optimizationEnabled", false);
        dummyConfig.insert("maxElectricalPower", 0);

        addOrUpdateDynamicElectricPricingConfiguration(dummyConfig);

        // and get the dummy Config
        configuration =  m_dynamicElectricPricingConfigurations->getElectricConfiguration(electricThingId);
    }

    // Make a MetaObject of an configuration
    const QMetaObject *metaObj = configuration->metaObject();
    // add the values from data which match with the MetaObject
    QVariantMap config;
    for (int i = metaObj->propertyOffset(); i < metaObj->propertyCount(); ++i){
        if(data.contains(metaObj->property(i).name()))
        {
            //qCDebug(dcHems()) << "Data value: " << data.value(metaObj->property(i).name());
            config.insert(metaObj->property(i).name(), data.value(metaObj->property(i).name()) );
        }else{
            //qCDebug(dcHems())<< "type: " << metaObj->property(i).type() << "value: " << metaObj->property(i).read(configuration);
            config.insert(metaObj->property(i).name(), metaObj->property(i).read(configuration) );
        }
    }

    QVariantMap params;
    params.insert("dynamicElectricPricingConfiguration", config);
    qCWarning(dcHems()) << "Set electric configuration" << params;

    return m_engine->jsonRpcClient()->sendCommand("Hems.setDynamicElectricPricingConfiguration", params, this, "setDynamicElectricPricingConfigurationResponse");
}


int HemsManager::setChargingOptimizationConfiguration(const QUuid &evChargerThingId, const QVariantMap &data )
{

    ChargingOptimizationConfiguration *configuration = m_chargingOptimizationConfigurations->getChargingOptimizationConfiguration(evChargerThingId);
    // if the configuration does not exist yet. Set up a dummy configuration
    // This ensures that if the Thing does not exist that the program wont crash
    if (!configuration){
        qCDebug(dcHems()) << "Adding a dummy Config" << evChargerThingId;
        QVariantMap dummyConfig;
        QUuid DummyIdentifier;
        dummyConfig.insert("evChargerThingId", evChargerThingId);
        dummyConfig.insert("reenableChargepoint", false);
        dummyConfig.insert("p_value", 0.001);
        dummyConfig.insert("i_value", 0.001);
        dummyConfig.insert("d_value", 0);
        dummyConfig.insert("setpoint", 0);
        dummyConfig.insert("controllableLocalSystem", false);
        addOrUpdateChargingOptimizationConfiguration(dummyConfig);
        // and get the dummy Config
        configuration =  m_chargingOptimizationConfigurations->getChargingOptimizationConfiguration(evChargerThingId);
    }

    // Make a MetaObject of an configuration
    const QMetaObject *metaObj = configuration->metaObject();
    // add the values from data which match with the MetaObject
    QVariantMap config;
    for (int i = metaObj->propertyOffset(); i < metaObj->propertyCount(); ++i){
        if(data.contains(metaObj->property(i).name()))
            {
                //qCDebug(dcHems()) << "Data value: " << data.value(metaObj->property(i).name());
                config.insert(metaObj->property(i).name(), data.value(metaObj->property(i).name()) );
            }else{
                //qCDebug(dcHems())<< "type: " << metaObj->property(i).type() << "value: " << metaObj->property(i).read(configuration);
                config.insert(metaObj->property(i).name(), metaObj->property(i).read(configuration) );
            }
    }



    QVariantMap params;
    params.insert("chargingOptimizationConfiguration", config);

    qCWarning(dcHems()) << "Set charging Optimization configuration" << params;
    return m_engine->jsonRpcClient()->sendCommand("Hems.SetChargingOptimizationConfiguration", params, this, "setChargingOptimizationConfigurationResponse");
}

int HemsManager::setChargingConfiguration(const QUuid &evChargerThingId, const QVariantMap &data )
{

    ChargingConfiguration *configuration = m_chargingConfigurations->getChargingConfiguration(evChargerThingId);
    // if the configuration does not exist yet. Set up a dummy configuration
    // This ensures that if the Thing does not exist that the program wont crash
    if (!configuration){
        qCDebug(dcHems()) << "Adding a dummy Config" << evChargerThingId;
        QVariantMap dummyConfig;
        QUuid DummyIdentifier;
        dummyConfig.insert("uniqueIdentifier", DummyIdentifier.createUuid());
        dummyConfig.insert("evChargerThingId", evChargerThingId);
        dummyConfig.insert("optimizationEnabled", false);
        dummyConfig.insert("optimizationMode", 0);
        dummyConfig.insert("carThingId", "{00000000-0000-0000-0000-000000000000}");
        dummyConfig.insert("endTime", "0:00:00");
        dummyConfig.insert("targetPercentage", 100);
        dummyConfig.insert("controllableLocalSystem", false);
        dummyConfig.insert("priceThreshold", 0);

        addOrUpdateChargingConfiguration(dummyConfig);
        // and get the dummy Config
        configuration =  m_chargingConfigurations->getChargingConfiguration(evChargerThingId);
    }

    // Make a MetaObject of an configuration
    const QMetaObject *metaObj = configuration->metaObject();

    // add the values from data which match with the MetaObject
    QVariantMap config;
    for (int i = metaObj->propertyOffset(); i < metaObj->propertyCount(); ++i){
        if(data.contains(metaObj->property(i).name()))
            {
                qCDebug(dcHems()) << "Data value: " << data.value(metaObj->property(i).name());
                config.insert(metaObj->property(i).name(), data.value(metaObj->property(i).name()) );
            }else{
                qCDebug(dcHems())<< "type: " << metaObj->property(i).type() << "value: " << metaObj->property(i).read(configuration);
                config.insert(metaObj->property(i).name(), metaObj->property(i).read(configuration) );
            }
    }

    QVariantMap params;
    params.insert("chargingConfiguration", config);

    qCWarning(dcHems()) << "Set charging configuration" << params;
    return m_engine->jsonRpcClient()->sendCommand("Hems.SetChargingConfiguration", params, this, "setChargingConfigurationResponse");
}


int HemsManager::setChargingSessionConfiguration(const QUuid carThingId, const QUuid evChargerThingid, const QString started_at, const QString finished_at, const float initial_battery_energy, const int duration, const float energy_charged, const float energy_battery, const int battery_level, const QUuid sessionId, const int state, const int timestamp)
{
    Q_UNUSED(sessionId);
    QUuid chargingSession;

    QVariantMap chargingSessionConfiguration;
    chargingSessionConfiguration.insert("carThingId", carThingId);
    chargingSessionConfiguration.insert("evChargerThingId", evChargerThingid);
    chargingSessionConfiguration.insert("startedAt", started_at );
    chargingSessionConfiguration.insert("finishedAt", finished_at );
    chargingSessionConfiguration.insert("initialBatteryEnergy", initial_battery_energy);
    chargingSessionConfiguration.insert("duration", duration);
    chargingSessionConfiguration.insert("energyCharged", energy_charged);
    chargingSessionConfiguration.insert("energyBattery", energy_battery);
    chargingSessionConfiguration.insert("batteryLevel", battery_level);
    chargingSessionConfiguration.insert("sessionId", chargingSession.createUuid());
    chargingSessionConfiguration.insert("state", state);
    chargingSessionConfiguration.insert("timestamp", timestamp);

    QVariantMap params;
    params.insert("chargingSessionConfiguration", chargingSessionConfiguration);

    qCDebug(dcHems()) << "Set chargingSession configuration" << params;

    return m_engine->jsonRpcClient()->sendCommand("Hems.SetChargingSessionConfiguration", params, this, "setChargingSessionConfigurationResponse");
}

int HemsManager::setConEMSState( int currentState, int operationMode, int timestamp)
{
    QString state;
    if(currentState == 1){
        state = "Running";
    } else if( currentState == 2){
        state = "Optimizer_Busy";
    } else if( currentState == 3){
        state = "Restarting";
    } else if( currentState == 4){
        state = "Error";
    } else{
        state = "Unknown";
    }

    QVariantMap conEMSState;
    conEMSState.insert("ConEMSStateID", "f002d80e-5f90-445c-8e95-a0256a0b464e");
    conEMSState.insert("currentState", state);
    conEMSState.insert("operationMode", operationMode);
    conEMSState.insert("timestamp", timestamp);
    QVariantMap params;
    params.insert("conEMSState", conEMSState);

    qCDebug(dcHems()) << "Set CONEMSState" << params;

    return m_engine->jsonRpcClient()->sendCommand("Hems.SetConEMSState", params, this, "setConEMSStateResponse");

}

int HemsManager::setUserConfiguration(const QVariantMap &data){

// We need this because the UserConfig is a bit special in the sense that it is not bound to a Thing
    UserConfiguration *configuration = m_userConfigurations->getUserConfiguration("528b3820-1b6d-4f37-aea7-a99d21d42e72");
    if (!configuration){
        QVariantMap userConfig;
        userConfig.insert("userConfigID", "528b3820-1b6d-4f37-aea7-a99d21d42e72");
        userConfig.insert("lastSelectedCar", "282d39a8-3537-4c22-a386-b31faeebbb55");
        userConfig.insert("defaultChargingMode", 2);
        userConfig.insert("installerName", "");
        userConfig.insert("installerEmail", "");
        userConfig.insert("installerPhoneNr", "");
        userConfig.insert("installerWorkplace", "");

        addOrUpdateUserConfiguration(userConfig);
        configuration = m_userConfigurations->getUserConfiguration("528b3820-1b6d-4f37-aea7-a99d21d42e72");
    }

    // Make a MetaObject of an configuration
    const QMetaObject *metaObj = configuration->metaObject();
    // add the values from data which match with the MetaObject
    QVariantMap userConfiguration;
    for (int i = metaObj->propertyOffset(); i < metaObj->propertyCount(); ++i){
        if(data.contains(metaObj->property(i).name()))
            {
                //qCDebug(dcHems()) << "Data value: " << data.value(metaObj->property(i).name());
                userConfiguration.insert(metaObj->property(i).name(), data.value(metaObj->property(i).name()) );
            }else{
                //qCDebug(dcHems())<< "type: " << metaObj->property(i).type() << "value: " << metaObj->property(i).read(configuration);
                userConfiguration.insert(metaObj->property(i).name(), metaObj->property(i).read(configuration) );
            }
    }
    QVariantMap params;
    params.insert("userConfiguration", userConfiguration);

    qCWarning(dcHems())<< "sent userConfiguration" << params;
    return  m_engine->jsonRpcClient()->sendCommand("Hems.SetUserConfiguration", params, this, "setUserConfigurationResponse");
}

int HemsManager::setBatteryConfiguration(const QUuid &batteryThingId, const QVariantMap &data){

    BatteryConfiguration *configuration = m_batteryConfigurations->getBatteryConfiguration(batteryThingId);
    // if the configuration does not exist yet. Set up a dummy configuration
    // This ensures that if the Thing does not exist that the program wont crash
    if (!configuration){
        qCWarning(dcHems()) << "Adding a dummy Config" << batteryThingId;
        QVariantMap dummyConfig;
        dummyConfig.insert("batteryThingId", batteryThingId);
        dummyConfig.insert("avoidZeroFeedInActive", false);
        dummyConfig.insert("avoidZeroFeedInEnabled", false);
        dummyConfig.insert("optimizationEnabled", true);
        dummyConfig.insert("priceThreshold", 0);
        dummyConfig.insert("relativePriceEnabled", false);
        dummyConfig.insert("chargeOnce", false);
        dummyConfig.insert("controllableLocalSystem", false);

        addOrUpdateBatteryConfiguration(dummyConfig);
        // and get the dummy Config
        configuration =  m_batteryConfigurations->getBatteryConfiguration(batteryThingId);
    }

    // Make a MetaObject of an configuration
    const QMetaObject *metaObj = configuration->metaObject();
    // add the values from data which match with the MetaObject
    QVariantMap config;
    for (int i = metaObj->propertyOffset(); i < metaObj->propertyCount(); ++i){
        if(data.contains(metaObj->property(i).name()))
        {
            config.insert(metaObj->property(i).name(), data.value(metaObj->property(i).name()) );
        }else{
            config.insert(metaObj->property(i).name(), metaObj->property(i).read(configuration) );
        }
    }

    QVariantMap params;
    params.insert("batteryConfiguration", config);
    qCWarning(dcHems()) << "Set Battery configuration" << params;

    return m_engine->jsonRpcClient()->sendCommand("Hems.SetBatteryConfiguration", params, this, "setBatteryConfigurationResponse");
}

// notification Handling -> atm mostly for added, removed, changed
void HemsManager::notificationReceived(const QVariantMap &data)
{
    QString notification = data.value("notification").toString();
    QVariantMap params = data.value("params").toMap();

    qCDebug(dcHems()) << "Hems notification received" << notification << params;

    if (notification == "Hems.AvailableUseCasesChanged") {
        updateAvailableUsecases(params.value("availableUseCases").toStringList());
        qCDebug(dcHems()) << "Available use cases changed" << m_availableUseCases;
    } else if (notification == "Hems.HousholdPhaseLimitChanged") {
        uint phaseLimit = params.value("housholdPhaseLimit").toUInt();
        if (m_housholdPhaseLimit != phaseLimit) {
            m_housholdPhaseLimit = phaseLimit;
            emit housholdPhaseLimitChanged(m_housholdPhaseLimit);
        }
    } else if (notification == "Hems.PluggedInChanged") {
        qCDebug(dcHems()) << "the PluggedInEventTriggered";

    } else if (notification == "Hems.ChargingConfigurationAdded") {
        addOrUpdateChargingConfiguration(params.value("chargingConfiguration").toMap());
    } else if (notification == "Hems.ChargingConfigurationRemoved") {
        qCDebug(dcHems()) << "Charging configuration removed" << params.value("evChargerThingId").toUuid();
        m_chargingConfigurations->removeConfiguration(params.value("evChargerThingId").toUuid());
    } else if (notification == "Hems.ChargingConfigurationChanged") {
        addOrUpdateChargingConfiguration(params.value("chargingConfiguration").toMap());

    } else if (notification == "Hems.ChargingOptimizationConfigurationAdded") {
        addOrUpdateChargingOptimizationConfiguration(params.value("chargingOptimizationConfiguration").toMap());
    } else if (notification == "Hems.ChargingOptimizationConfigurationRemoved") {
        qCDebug(dcHems()) << "Charging configuration removed" << params.value("evChargerThingId").toUuid();
        m_chargingOptimizationConfigurations->removeConfiguration(params.value("evChargerThingId").toUuid());
    } else if (notification == "Hems.ChargingOptimizationConfigurationChanged") {
        addOrUpdateChargingOptimizationConfiguration(params.value("chargingOptimizationConfiguration").toMap());
    } else if (notification == "Hems.ConEMSStateChanged") {
        qCDebug(dcHems()) << "ConEMSStateChanged Notification";
        addOrUpdateConEMSState(params.value("conEMSState").toMap());
    } else if (notification == "Hems.ChargingSessionConfigurationAdded") {
        addOrUpdateChargingSessionConfiguration(params.value("chargingSessionConfiguration").toMap());
    } else if (notification == "Hems.ChargingSessionConfigurationRemoved") {
        qCDebug(dcHems()) << "Charging Session configuration removed" << params.value("evChargerThingId").toUuid();
        m_chargingSessionConfigurations->removeConfiguration(params.value("evChargerThingId").toUuid());
    } else if (notification == "Hems.ChargingSessionConfigurationChanged") {
        addOrUpdateChargingSessionConfiguration(params.value("chargingSessionConfiguration").toMap());

    } else if (notification == "Hems.UserConfigurationAdded") {
        addOrUpdateUserConfiguration(params.value("userConfiguration").toMap());
    } else if (notification == "Hems.UserConfigurationRemoved") {
        qCDebug(dcHems()) << "User configuration removed" << params.value("userConfigId").toUuid();
        m_userConfigurations->removeConfiguration(params.value("userConfigId").toUuid());
    } else if (notification == "Hems.UserConfigurationChanged") {
        addOrUpdateUserConfiguration(params.value("userConfiguration").toMap());

    } else if (notification == "Hems.HeatingConfigurationAdded") {
        addOrUpdateHeatingConfiguration(params.value("heatingConfiguration").toMap());
    } else if (notification == "Hems.HeatingConfigurationRemoved") {
        qCDebug(dcHems()) << "Heating configuration removed" << params.value("heatPumpThingId").toUuid();
        m_heatingConfigurations->removeConfiguration(params.value("heatPumpThingId").toUuid());
    } else if (notification == "Hems.HeatingConfigurationChanged") {
        addOrUpdateHeatingConfiguration(params.value("heatingConfiguration").toMap());


    } else if (notification == "Hems.ElectricConfigurationAdded") {
        addOrUpdateDynamicElectricPricingConfiguration(params.value("dynamicElectricPricingConfiguration").toMap());
    } else if (notification == "Hems.ElectricConfigurationRemoved") {
        qCDebug(dcHems()) << "Electric configuration removed" << params.value("electricThingId").toUuid();
        m_dynamicElectricPricingConfigurations->removeConfiguration(params.value("electricThingId").toUuid());
    } else if (notification == "Hems.ElectricConfigurationChanged") {
        addOrUpdateDynamicElectricPricingConfiguration(params.value("dynamicElectricPricingConfiguration").toMap());

    } else if (notification == "Hems.BatteryConfigurationAdded") {
        addOrUpdateBatteryConfiguration(params.value("batteryConfiguration").toMap());
    } else if (notification == "Hems.BatteryConfigurationRemoved") {
        qCDebug(dcHems()) << "Battery configuration removed" << params.value("batteryThingId").toUuid();
        m_batteryConfigurations->removeConfiguration(params.value("batteryThingId").toUuid());
    } else if (notification == "Hems.BatteryConfigurationChanged") {
        addOrUpdateBatteryConfiguration(params.value("batteryConfiguration").toMap());

    } else if (notification == "Hems.PvConfigurationAdded") {
        addOrUpdatePvConfiguration(params.value("pvConfiguration").toMap());
    } else if (notification == "Hems.PvConfigurationRemoved") {
        qCDebug(dcHems()) << "PV configuration removed" << params.value("pvThingId").toUuid();
        m_pvConfigurations->removeConfiguration(params.value("pvThingId").toUuid());
    } else if (notification == "Hems.PvConfigurationChanged") {
        addOrUpdatePvConfiguration(params.value("pvConfiguration").toMap());
    } else if (notification == "Hems.HeatingRodConfigurationAdded") {
        addOrUpdateHeatingElementConfiguration(params.value("heatingRodConfiguration").toMap());
    } else if (notification == "Hems.HeatingRodConfigurationRemoved") {
        qCDebug(dcHems()) << "HeatingElement configuration removed" << params.value("heatingRodThingId").toUuid();
        m_heatingElementConfigurations->removeConfiguration(params.value("heatingRodThingId").toUuid());
    } else if (notification == "Hems.HeatingRodConfigurationChanged") {
        addOrUpdateHeatingElementConfiguration(params.value("heatingRodConfiguration").toMap());
    }


}

void HemsManager::getAvailableUseCasesResponse(int commandId, const QVariantMap &data)
{
    Q_UNUSED(commandId);
    updateAvailableUsecases(data.value("availableUseCases").toStringList());
    qCDebug(dcHems()) << "Available use cases" << m_availableUseCases;
}

void HemsManager::getHousholdPhaseLimitResponse(int commandId, const QVariantMap &data)
{
    Q_UNUSED(commandId);
    uint phaseLimit = data.value("housholdPhaseLimit").toUInt();
    qCDebug(dcHems()) << "Houshold phase limit" << phaseLimit << "A";
    if (m_housholdPhaseLimit != phaseLimit) {
        m_housholdPhaseLimit = phaseLimit;
        emit housholdPhaseLimitChanged(m_housholdPhaseLimit);
    }
}

void HemsManager::getHeatingConfigurationsResponse(int commandId, const QVariantMap &data)
{

    Q_UNUSED(commandId);
    qCDebug(dcHems()) << "Heating configurations" << data;
    foreach (const QVariant &configurationVariant, data.value("heatingConfigurations").toList()) {
        addOrUpdateHeatingConfiguration(configurationVariant.toMap());
    }
}

void HemsManager::getDynamicElectricPricingConfigurationResponse(int commandId, const QVariantMap &data)
{

    Q_UNUSED(commandId);
    qCDebug(dcHems()) << "Electric configurations" << data;
    foreach (const QVariant &configurationVariant, data.value("dynamicElectricPricingConfiguration").toList()) {
        addOrUpdateDynamicElectricPricingConfiguration(configurationVariant.toMap());
    }
}

void HemsManager::getBatteryConfigurationResponse(int commandId, const QVariantMap &data)
{

    Q_UNUSED(commandId);
    foreach (const QVariant &configurationVariant, data.value("batteryConfigurations").toList()) {
        addOrUpdateBatteryConfiguration(configurationVariant.toMap());
    }
}

void HemsManager::getPvConfigurationsResponse(int commandId, const QVariantMap &data)
{


    Q_UNUSED(commandId);
    qCDebug(dcHems()) << "Pv configurations" << data;
    foreach (const QVariant &configurationVariant, data.value("pvConfigurations").toList()) {

        addOrUpdatePvConfiguration(configurationVariant.toMap());
    }
}

void HemsManager::getHeatingElementConfigurationsResponse(int commandId, const QVariantMap &data)
{
    Q_UNUSED(commandId);
    qCDebug(dcHems()) << "Heating Element configurations" << data;
    foreach (const QVariant &configurationVariant, data.value("heatingRodConfigurations").toList()) {
        addOrUpdateHeatingElementConfiguration(configurationVariant.toMap());
    }
}


void HemsManager::getChargingConfigurationsResponse(int commandId, const QVariantMap &data)
{
    Q_UNUSED(commandId);
    qCDebug(dcHems()) << "Charging configuration" << data;
    foreach (const QVariant &configurationVariant, data.value("chargingConfigurations").toList()) {
        addOrUpdateChargingConfiguration(configurationVariant.toMap());
    }

    // Last call from init sequence
    m_fetchingData = false;
    emit fetchingDataChanged();
}


void HemsManager::getChargingOptimizationConfigurationsResponse(int commandId, const QVariantMap &data)
{
    Q_UNUSED(commandId);
    qCDebug(dcHems()) << "Charging Optimization configuration" << data;
    foreach (const QVariant &configurationVariant, data.value("chargingOptimizationConfigurations").toList()) {
        addOrUpdateChargingOptimizationConfiguration(configurationVariant.toMap());
    }

    // Last call from init sequence
    m_fetchingData = false;
    emit fetchingDataChanged();
}


void HemsManager::getChargingSessionConfigurationsResponse(int commandId, const QVariantMap &data)
{
    Q_UNUSED(commandId);
    qCDebug(dcHems()) << "ChargingSession configuration" << data;
    foreach (const QVariant &configurationVariant, data.value("chargingSessionConfigurations").toList()) {
        addOrUpdateChargingSessionConfiguration(configurationVariant.toMap());
    }

    // Last call from init sequence
    m_fetchingData = false;
    emit fetchingDataChanged();
}

void HemsManager::getConEMSStateResponse(int commandId, const QVariantMap &data)
{
    Q_UNUSED(commandId);
    qCDebug(dcHems()) << "ConEMS State" << data;
    addOrUpdateConEMSState(data.value("conEMSState").toList()[0].toMap());

    // Last call from init sequence
    m_fetchingData = false;
    emit fetchingDataChanged();
}

void HemsManager::getUserConfigurationsResponse(int commandId, const QVariantMap &data)
{

    Q_UNUSED(commandId);
    qCDebug(dcHems()) << "User configurations" << data;
    foreach (const QVariant &configurationVariant, data.value("userConfigurations").toList()) {
        addOrUpdateUserConfiguration(configurationVariant.toMap());
    }
}

void HemsManager::setHousholdPhaseLimitResponse(int commandId, const QVariantMap &data)
{
    qCDebug(dcHems()) << "Set houshold phase limit response" << data.value("hemsError").toString();
    emit setHousholdPhaseLimitReply(commandId, data.value("hemsError").toString());
}

void HemsManager::setHeatingConfigurationResponse(int commandId, const QVariantMap &data)
{
    qCDebug(dcHems()) << "Set heating configuration response" << data.value("hemsError").toString();
    emit setHeatingConfigurationReply(commandId, data.value("hemsError").toString());
}

void HemsManager::setDynamicElectricPricingConfigurationResponse(int commandId, const QVariantMap &data)
{
    qCDebug(dcHems()) << "Set electric configuration response" << data.value("hemsError").toString();
    emit setDynamicElectricPricingConfigurationReply(commandId, data.value("hemsError").toString());
}

void HemsManager::setBatteryConfigurationResponse(int commandId, const QVariantMap &data)
{
    qCDebug(dcHems()) << "Set battery configuration response" << data.value("hemsError").toString();
    emit setBatteryConfigurationReply(commandId, data.value("hemsError").toString());
}


void HemsManager::setPvConfigurationResponse(int commandId, const QVariantMap &data)
{
    qCDebug(dcHems()) << "Set pv configuration response" << data.value("pvError").toString();
    emit setPvConfigurationReply(commandId, data.value("hemsError").toString());

}

void HemsManager::setHeatingElementConfigurationResponse(int commandId, const QVariantMap &data)
{
    qCDebug(dcHems()) << "Set HeatingElement configuration response" << data.value("heatingElementError").toString();
    emit setHeatingElementConfigurationReply(commandId, data.value("hemsError").toString());

}

void HemsManager::setChargingConfigurationResponse(int commandId, const QVariantMap &data)
{

    qCDebug(dcHems()) << "Set charging configuration response" << data.value("hemsError").toString();
    emit setChargingConfigurationReply(commandId, data.value("hemsError").toString());
}


void HemsManager::setChargingOptimizationConfigurationResponse(int commandId, const QVariantMap &data)
{

    qCDebug(dcHems()) << "Set charging Optimization configuration response" << data.value("hemsError").toString();
    emit setChargingOptimizationConfigurationReply(commandId, data.value("hemsError").toString());
}


void HemsManager::setChargingSessionConfigurationResponse(int commandId, const QVariantMap &data)
{

    qCDebug(dcHems()) << "Set charging configuration response" << data.value("hemsError").toString();
    emit setChargingSessionConfigurationReply(commandId, data.value("hemsError").toString());
}

void HemsManager::setConEMSStateResponse(int commandId, const QVariantMap &data)
{

    qCDebug(dcHems()) << "Set CONEMSSTATE response" << data.value("hemsError").toString();
    emit setConEMSStateReply(commandId, data.value("hemsError").toString());
}

void HemsManager::setUserConfigurationResponse(int commandId, const QVariantMap &data)
{

    qCDebug(dcHems()) << "Set UserConfiguration response" << data.value("hemsError").toString();
    emit setUserConfigurationReply(commandId, data.value("hemsError").toString());
}

void HemsManager::addOrUpdateHeatingConfiguration(const QVariantMap &configurationMap)
{
    qCDebug(dcHems()) << "add or Update Heatpump Config configurationMap: " << configurationMap;
    QUuid heatPumpUuid = configurationMap.value("heatPumpThingId").toUuid();

    HeatingConfiguration *configuration = m_heatingConfigurations->getHeatingConfiguration(heatPumpUuid);
    bool newConfiguration = false;
    if (!configuration) {
        newConfiguration = true;
        configuration = new HeatingConfiguration(this);
        configuration->setHeatPumpThingId(heatPumpUuid);
    }

    configuration->setOptimizationEnabled(configurationMap.value("optimizationEnabled").toBool());
    configuration->setHeatMeterThingId(configurationMap.value("heatMeterThingId").toUuid());
    configuration->setFloorHeatingArea(configurationMap.value("floorHeatingArea").toDouble());
    configuration->setMaxThermalEnergy(configurationMap.value("maxThermalEnergy").toDouble());
    configuration->setMaxElectricalPower(configurationMap.value("maxElectricalPower").toDouble());
    configuration->setControllableLocalSystem(configurationMap.value("controllableLocalSystem").toBool());


    if (newConfiguration) {
        qCDebug(dcHems()) << "Heating configuration added" << configuration->heatPumpThingId();
        m_heatingConfigurations->addConfiguration(configuration);

    } else {
        qCDebug(dcHems()) << "Heating configuration changed" << configuration->heatPumpThingId();

    }
}

void HemsManager::addOrUpdateDynamicElectricPricingConfiguration(const QVariantMap &configurationMap)
{
    qCDebug(dcHems()) << "add or Update Electric Config configurationMap: " << configurationMap;
    QUuid electricUuid = configurationMap.value("electricThingId").toUuid();

    DynamicElectricPricingConfiguration *configuration = m_dynamicElectricPricingConfigurations->getElectricConfiguration(electricUuid);
    bool newConfiguration = false;
    if (!configuration) {
        newConfiguration = true;
        configuration = new DynamicElectricPricingConfiguration(this);
        configuration->setDynamicElectricPricingThingID(electricUuid);
    }

    configuration->setOptimizationEnabled(configurationMap.value("optimizationEnabled").toBool());
    configuration->setMaxElectricalPower(configurationMap.value("maxElectricalPower").toDouble());

    if (newConfiguration) {
        qCDebug(dcHems()) << "Electric configuration added" << configuration->dynamicElectricPricingThingID();
        m_dynamicElectricPricingConfigurations->addConfiguration(configuration);

    } else {
        qCDebug(dcHems()) << "Electric configuration changed" << configuration->dynamicElectricPricingThingID();

    }
}

void HemsManager::addOrUpdateBatteryConfiguration(const QVariantMap &configurationMap)
{
    qCDebug(dcHems()) << "add or Update Battery Config configurationMap: " << configurationMap;
    QUuid batteryUuid = configurationMap.value("batteryThingId").toUuid();

    BatteryConfiguration *configuration = m_batteryConfigurations->getBatteryConfiguration(batteryUuid);
    bool newConfiguration = false;
    if (!configuration) {
        newConfiguration = true;
        configuration = new BatteryConfiguration(this);
        configuration->setBatteryThingId(batteryUuid);
    }

    configuration->setOptimizationEnabled(configurationMap.value("optimizationEnabled").toBool());
    configuration->setAvoidZeroFeedInEnabled(configurationMap.value("avoidZeroFeedInEnabled").toBool());
    configuration->setAvoidZeroFeedInActive(configurationMap.value("avoidZeroFeedInActive").toBool());
    configuration->setPriceThreshold(configurationMap.value("priceThreshold").toFloat());
    configuration->setRelativePriceEnabled(configurationMap.value("relativePriceEnabled").toBool());
    configuration->setChargeOnce(configurationMap.value("chargeOnce").toBool());
    configuration->setControllableLocalSystem(configurationMap.value("controllableLocalSystem").toBool());

    if (newConfiguration) {
        qCDebug(dcHems()) << "Battery configuration added" << configuration->batteryThingId();
        m_batteryConfigurations->addConfiguration(configuration);

    } else {
        qCDebug(dcHems()) << "Battery configuration changed" << configuration->batteryThingId();
        emit batteryConfigurationChanged(configuration);
    }
}

void HemsManager::addOrUpdateChargingConfiguration(const QVariantMap &configurationMap)
{
    QUuid evChargerUuid = configurationMap.value("evChargerThingId").toUuid();
    ChargingConfiguration *configuration = m_chargingConfigurations->getChargingConfiguration(evChargerUuid);
    bool newConfiguration = false;
    if (!configuration) {
        newConfiguration = true;
        configuration = new ChargingConfiguration(this);
        configuration->setEvChargerThingId(evChargerUuid);
    }

    configuration->setOptimizationEnabled(configurationMap.value("optimizationEnabled").toBool());
    configuration->setOptimizationMode(configurationMap.value("optimizationMode").toInt());
    configuration->setCarThingId(configurationMap.value("carThingId").toUuid());
    configuration->setEndTime(configurationMap.value("endTime").toString());
    configuration->setTargetPercentage(configurationMap.value("targetPercentage").toUInt());
    configuration->setUniqueIdentifier(configurationMap.value("uniqueIdentifier").toUuid());
    configuration->setControllableLocalSystem(configurationMap.value("controllableLocalSystem").toBool());
    configuration->setPriceThreshold(configurationMap.value("priceThreshold").toFloat());

    if (newConfiguration) {
        qCDebug(dcHems()) << "Charging configuration added" << configuration->evChargerThingId();
        m_chargingConfigurations->addConfiguration(configuration);
    } else {
        qCDebug(dcHems()) << "Charging configuration changed" << configuration->evChargerThingId();
        emit chargingConfigurationChanged(configuration);
    }
}

void HemsManager::addOrUpdateChargingOptimizationConfiguration(const QVariantMap &configurationMap)
{
    QUuid evChargerUuid = configurationMap.value("evChargerThingId").toUuid();
    ChargingOptimizationConfiguration *configuration = m_chargingOptimizationConfigurations->getChargingOptimizationConfiguration(evChargerUuid);
    bool newConfiguration = false;
    if (!configuration) {
        newConfiguration = true;
        configuration = new ChargingOptimizationConfiguration(this);
        configuration->setEvChargerThingId(evChargerUuid);
    }

    configuration->setReenableChargepoint(configurationMap.value("reenableChargepoint").toBool());
    configuration->setP_value(configurationMap.value("p_value").toFloat());
    configuration->setI_value(configurationMap.value("i_value").toFloat());
    configuration->setD_value(configurationMap.value("d_value").toFloat());
    configuration->setSetpoint(configurationMap.value("setpoint").toFloat());
    configuration->setControllableLocalSystem(configurationMap.value("controllableLocalSystem").toBool());

    if (newConfiguration) {
        qCDebug(dcHems()) << "Charging Optimization configuration added" << configuration->evChargerThingId();
        m_chargingOptimizationConfigurations->addConfiguration(configuration);
    } else {
        qCDebug(dcHems()) << "Charging Optimization configuration changed" << configuration->evChargerThingId();
        emit chargingOptimizationConfigurationChanged(configuration);
    }
}


void HemsManager::addOrUpdateChargingSessionConfiguration(const QVariantMap &configurationMap)
{
    QUuid chargingSessionUuid = configurationMap.value("evChargerThingId").toUuid();
    ChargingSessionConfiguration *configuration = m_chargingSessionConfigurations->getChargingSessionConfiguration(chargingSessionUuid);
    bool newConfiguration = false;
    if (!configuration) {
        newConfiguration = true;
        configuration = new ChargingSessionConfiguration(this);
        configuration->setEvChargerThingId(chargingSessionUuid);
    }

    configuration->setCarThingId(configurationMap.value("carThingId").toUuid());
    configuration->setStartedAt(configurationMap.value("startedAt").toTime());
    configuration->setFinishedAt(configurationMap.value("finishedAt").toString());
    configuration->setInitialBatteryEnergy(configurationMap.value("initialBatteryEnergy").toFloat());
    configuration->setDuration(configurationMap.value("duration").toInt());
    configuration->setEnergyCharged(configurationMap.value("energyCharged").toFloat());
    configuration->setEnergyBattery(configurationMap.value("energyBattery").toFloat());
    configuration->setBatteryLevel(configurationMap.value("batteryLevel").toInt());
    configuration->setSessionId(configurationMap.value("sessionId").toUuid());
    configuration->setState(configurationMap.value("state").toInt());
    configuration->setTimestamp(configurationMap.value("timestamp").toInt());


    if (newConfiguration) {
        qCDebug(dcHems()) << "ChargingSession configuration added" << configuration->evChargerThingId();
        m_chargingSessionConfigurations->addConfiguration(configuration);
    } else {
        qCDebug(dcHems()) << "ChargingSession configuration changed" << configuration->evChargerThingId();
        emit chargingSessionConfigurationChanged(configuration);


    }
}

void HemsManager::addOrUpdatePvConfiguration(const QVariantMap &configurationMap)
{

    QUuid pvUuid = configurationMap.value("pvThingId").toUuid();
    PvConfiguration *configuration = m_pvConfigurations->getPvConfiguration(pvUuid);
    bool newConfiguration = false;
    if(!configuration){
        newConfiguration = true;
        configuration = new PvConfiguration(this);
        configuration->setPvThingId(pvUuid);
    }

    configuration->setLongitude(configurationMap.value("longitude").toDouble());
    configuration->setLatitude(configurationMap.value("latitude").toDouble());
    configuration->setRoofPitch(configurationMap.value("roofPitch").toInt());
    configuration->setAlignment(configurationMap.value("alignment").toInt());
    configuration->setKwPeak(configurationMap.value("kwPeak").toFloat());


     if (newConfiguration){
         qCDebug(dcHems()) << "Pv configuration added" << configuration->pvThingId();
         m_pvConfigurations->addConfiguration(configuration);

     }else{
        qCDebug(dcHems()) << "Pv configuration changed" << configuration->pvThingId();
        emit pvConfigurationChanged(configuration);

     }
}

void HemsManager::addOrUpdateHeatingElementConfiguration(const QVariantMap &configurationMap)
{

    QUuid heatingElementUuid = configurationMap.value("heatingRodThingId").toUuid();
    HeatingElementConfiguration *configuration = m_heatingElementConfigurations->getHeatingElementConfiguration(heatingElementUuid);
    bool newConfiguration = false;
    if(!configuration){
        newConfiguration = true;
        configuration = new HeatingElementConfiguration(this);


        configuration->setHeatingRodThingId(heatingElementUuid);
    }

    configuration->setMaxElectricalPower(configurationMap.value("maxElectricalPower").toDouble());
    configuration->setOptimizationEnabled(configurationMap.value("optimizationEnabled").toBool());
    configuration->setControllableLocalSystem(configurationMap.value("controllableLocalSystem").toBool());

     if (newConfiguration){
         qCDebug(dcHems()) << "HeatingElement configuration added" << configuration->heatingRodThingId();
         m_heatingElementConfigurations->addConfiguration(configuration);

     }else{
        qCDebug(dcHems()) << "Heating Element configuration changed" << configuration->heatingRodThingId();
        emit heatingElementConfigurationChanged(configuration);

     }
}

void HemsManager::addOrUpdateConEMSState(const QVariantMap &ConEMSStateMap)
{

    qCDebug(dcHems()) << ConEMSStateMap.value("currentState").toMap();
    qCDebug(dcHems()) << ConEMSStateMap.value("timestamp");

    QJsonDocument jsonResponse = QJsonDocument::fromVariant(ConEMSStateMap.value("currentState").toMap());

    if(m_conEMSState->timestamp() != ConEMSStateMap.value("timestamp").toLongLong())
    {

        m_conEMSState->setTimestamp(ConEMSStateMap.value("timestamp").toLongLong());
        // Also check if the state iteself has changed
        if(m_conEMSState->currentState() != ConEMSStateMap.value("currentState"))
        {
            m_conEMSState->setCurrentState(jsonResponse.object());
            emit conEMSOperatingStateChanged(m_conEMSState);
        }

        qCDebug(dcHems()) << "ConEMS state changed (" << m_conEMSState->timestamp() << ")";
        emit conEMSStateChanged(m_conEMSState);
    }

}

void HemsManager::addOrUpdateUserConfiguration(const QVariantMap &configurationMap)
{
    QUuid userConfigId = configurationMap.value("userConfigID").toUuid();
    qCDebug(dcHems()) << "addOrUpdateUserConfig" << configurationMap;
    UserConfiguration *configuration = m_userConfigurations->getUserConfiguration(userConfigId);
    bool newConfiguration = false;
    if (!configuration) {
        newConfiguration = true;
        configuration = new UserConfiguration(this);
        // I think I dont need that since the UUid is set default and should not be changed
        //configuration->set(evChargerUuid);
    }
    configuration->setLastSelectedCar(configurationMap.value("lastSelectedCar").toUuid());
    configuration->setDefaultChargingMode(configurationMap.value("defaultChargingMode").toInt());

    configuration->setInstallerName(configurationMap.value("installerName").toString());
    configuration->setInstallerEmail(configurationMap.value("installerEmail").toString());
    configuration->setInstallerPhoneNr(configurationMap.value("installerPhoneNr").toString());
    configuration->setInstallerWorkplace(configurationMap.value("installerWorkplace").toString());


    if (newConfiguration) {
        qCDebug(dcHems()) << "User configuration added" << configuration->userConfigID();
        m_userConfigurations->addConfiguration(configuration);
    } else {
        qCDebug(dcHems()) << "User configuration changed" << configuration->userConfigID();
        emit userConfigurationChanged(configuration);
    }
}

void HemsManager::updateAvailableUsecases(const QStringList &useCasesList)
{
    HemsUseCases availableUseCases;
    QMetaEnum metaFlag = QMetaEnum::fromType<HemsManager::HemsUseCase>();
    foreach (const QString &flagValueString, useCasesList) {
        HemsUseCase usecase = static_cast<HemsManager::HemsUseCase>(metaFlag.keyToValue(flagValueString.toUtf8()));
        availableUseCases = availableUseCases.setFlag(usecase);
    }

    if (m_availableUseCases != availableUseCases) {
        m_availableUseCases = availableUseCases;
        emit availableUseCasesChanged(m_availableUseCases);
    }
}

