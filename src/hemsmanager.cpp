#include "hemsmanager.h"

#include <QMetaEnum>
#include <QJsonDocument>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcHems, "Hems")

HemsManager::HemsManager(QObject *parent) : QObject(parent)
{
    m_heatingConfigurations = new HeatingConfigurations(this);
    m_chargingConfigurations = new ChargingConfigurations(this);
    m_pvConfigurations = new PvConfigurations(this);
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
        m_engine->jsonRpcClient()->sendCommand("Hems.GetAvailableUseCases", QVariantMap(), this, "getAvailableUseCasesResponse");
        m_engine->jsonRpcClient()->sendCommand("Hems.GetHousholdPhaseLimit", QVariantMap(), this, "getHousholdPhaseLimitResponse");
        m_engine->jsonRpcClient()->sendCommand("Hems.GetHeatingConfigurations", QVariantMap(), this, "getHeatingConfigurationsResponse");
        m_engine->jsonRpcClient()->sendCommand("Hems.GetChargingConfigurations", QVariantMap(), this, "getChargingConfigurationsResponse");
        m_engine->jsonRpcClient()->sendCommand("Hems.GetPvConfigurations", QVariantMap(), this, "getPvConfigurationsResponse");

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

PvConfigurations *HemsManager::pvConfigurations() const
{
    qCDebug(dcHems()) << "pvConfiguration: " << m_pvConfigurations;
    return m_pvConfigurations;
}

int HemsManager::setPvConfiguration(const QUuid &pvThingId, const int &longitude, const int &latitude, const int &roofPitch, const int &alignment, const float &kwPeak)
{
    QVariantMap pvConfiguration;
    pvConfiguration.insert("pvThingId", pvThingId);
    pvConfiguration.insert("longitude", longitude);
    pvConfiguration.insert("latitude", latitude);
    pvConfiguration.insert("roofPitch", roofPitch);
    pvConfiguration.insert("alignment", alignment);
    pvConfiguration.insert("kwPeak", kwPeak);

    QVariantMap params;
    params.insert("pvConfiguration", pvConfiguration);

    qCDebug(dcHems()) << "Set pv configuration" << params;
    int response = m_engine->jsonRpcClient()->sendCommand("Hems.SetPvConfiguration", params, this, "setPvConfigurationResponse");
    return response;
}


int HemsManager::setHeatingConfiguration(const QUuid &heatPumpThingId, bool optimizationEnabled,  const double &floorHeatingArea , const double &maxElectricalPower, const double &maxThermalEnergy, const QUuid &heatMeterThingId)
{

    QVariantMap heatinConfiguration;
    heatinConfiguration.insert("heatPumpThingId", heatPumpThingId);
    heatinConfiguration.insert("optimizationEnabled", optimizationEnabled);
    heatinConfiguration.insert("floorHeatingArea", floorHeatingArea);
    heatinConfiguration.insert("maxElectricalPower", maxElectricalPower);
    heatinConfiguration.insert("maxThermalEnergy", maxThermalEnergy);

    if (!heatMeterThingId.isNull())
        heatinConfiguration.insert("heatMeterThingId", heatMeterThingId);

    QVariantMap params;
    params.insert("heatingConfiguration", heatinConfiguration);

    qCDebug(dcHems()) << "Set heating configuration" << params;

    return m_engine->jsonRpcClient()->sendCommand("Hems.SetHeatingConfiguration", params, this, "setHeatingConfigurationResponse");
}

int HemsManager::setChargingConfiguration(const QUuid &evChargerThingId, bool optimizationEnabled, const QUuid &carThingId,  int hours,  int minutes, uint targetPercentage, bool zeroReturnPolicyEnabled)
{

    QVariantMap chargingConfiguration;
    chargingConfiguration.insert("evChargerThingId", evChargerThingId);
    chargingConfiguration.insert("optimizationEnabled", optimizationEnabled);
    chargingConfiguration.insert("carThingId", carThingId);
    chargingConfiguration.insert("endTime", QTime(hours,minutes).toString() );
    chargingConfiguration.insert("targetPercentage", targetPercentage);
    chargingConfiguration.insert("zeroReturnPolicyEnabled", zeroReturnPolicyEnabled);

    QVariantMap params;
    params.insert("chargingConfiguration", chargingConfiguration);

    qCDebug(dcHems()) << "Set charging configuration" << params;

    return m_engine->jsonRpcClient()->sendCommand("Hems.SetChargingConfiguration", params, this, "setChargingConfigurationResponse");
}

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
    } else if (notification == "Hems.ChargingConfigurationAdded") {
        addOrUpdateChargingConfiguration(params.value("chargingConfiguration").toMap());
    } else if (notification == "Hems.ChargingConfigurationRemoved") {
        qCDebug(dcHems()) << "Charging configuration removed" << params.value("evChargerThingId").toUuid();
        m_chargingConfigurations->removeConfiguration(params.value("evChargerThingId").toUuid());
    } else if (notification == "Hems.ChargingConfigurationChanged") {
        addOrUpdateChargingConfiguration(params.value("chargingConfiguration").toMap());
    } else if (notification == "Hems.HeatingConfigurationAdded") {
        addOrUpdateHeatingConfiguration(params.value("heatingConfiguration").toMap());
    } else if (notification == "Hems.HeatingConfigurationRemoved") {
        qCDebug(dcHems()) << "Heating configuration removed" << params.value("heatPumpThingId").toUuid();
        m_heatingConfigurations->removeConfiguration(params.value("heatPumpThingId").toUuid());
    } else if (notification == "Hems.HeatingConfigurationChanged") {
        addOrUpdateHeatingConfiguration(params.value("heatingConfiguration").toMap());   
    } else if (notification == "Hems.PvConfigurationAdded") {
        addOrUpdatePvConfiguration(params.value("pvConfiguration").toMap());
    } else if (notification == "Hems.PvConfigurationRemoved") {
        qCDebug(dcHems()) << "Heating configuration removed" << params.value("heatPumpThingId").toUuid();
        m_pvConfigurations->removeConfiguration(params.value("heatPumpThingId").toUuid());
    } else if (notification == "Hems.PvConfigurationChanged") {
        addOrUpdatePvConfiguration(params.value("pvConfiguration").toMap());
    }


}

void HemsManager::getAvailableUseCasesResponse(int commandId, const QVariantMap &data)
{
    Q_UNUSED(commandId)
    updateAvailableUsecases(data.value("availableUseCases").toStringList());
    qCDebug(dcHems()) << "Available use cases" << m_availableUseCases;
}

void HemsManager::getHousholdPhaseLimitResponse(int commandId, const QVariantMap &data)
{
    Q_UNUSED(commandId)
    uint phaseLimit = data.value("housholdPhaseLimit").toUInt();
    qCDebug(dcHems()) << "Houshold phase limit" << phaseLimit << "A";
    if (m_housholdPhaseLimit != phaseLimit) {
        m_housholdPhaseLimit = phaseLimit;
        emit housholdPhaseLimitChanged(m_housholdPhaseLimit);
    }
}

void HemsManager::getHeatingConfigurationsResponse(int commandId, const QVariantMap &data)
{

    Q_UNUSED(commandId)
    qCDebug(dcHems()) << "Heating configurations" << data;
    foreach (const QVariant &configurationVariant, data.value("heatingConfigurations").toList()) {
        addOrUpdateHeatingConfiguration(configurationVariant.toMap());
    }
}

void HemsManager::getPvConfigurationsResponse(int commandId, const QVariantMap &data)
{


    Q_UNUSED(commandId)

    qCDebug(dcHems()) << "Pv configurations" << data;
    foreach (const QVariant &configurationVariant, data.value("pvConfigurations").toList()) {

        addOrUpdatePvConfiguration(configurationVariant.toMap());
    }
}


void HemsManager::getChargingConfigurationsResponse(int commandId, const QVariantMap &data)
{
    Q_UNUSED(commandId)

    qCDebug(dcHems()) << "Charging configurations" << data;
    foreach (const QVariant &configurationVariant, data.value("chargingConfigurations").toList()) {
        addOrUpdateChargingConfiguration(configurationVariant.toMap());
    }

    // Last call from init sequence
    m_fetchingData = false;
    emit fetchingDataChanged();
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

void HemsManager::setPvConfigurationResponse(int commandId, const QVariantMap &data)
{
    qCDebug(dcHems()) << "Set pv configuration response" << data.value("pvError").toString();
    emit setPvConfigurationReply(commandId, data.value("hemsError").toString());

}



void HemsManager::setChargingConfigurationResponse(int commandId, const QVariantMap &data)
{

    qCDebug(dcHems()) << "Set charging configuration response" << data.value("hemsError").toString();
    emit setChargingConfigurationReply(commandId, data.value("hemsError").toString());
}

void HemsManager::addOrUpdateHeatingConfiguration(const QVariantMap &configurationMap)
{
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



    if (newConfiguration) {
        qCDebug(dcHems()) << "Heating configuration added" << configuration->heatPumpThingId();
        m_heatingConfigurations->addConfiguration(configuration);

    } else {
        qCDebug(dcHems()) << "Heating configuration changed" << configuration->heatPumpThingId();

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
    configuration->setCarThingId(configurationMap.value("carThingId").toUuid());
    configuration->setEndTime(configurationMap.value("endTime").toString());
    configuration->setTargetPercentage(configurationMap.value("targetPercentage").toUInt());
    configuration->setZeroReturnPolicyEnabled(configurationMap.value("zeroReturnPolicyEnabled").toBool());

    if (newConfiguration) {
        qCDebug(dcHems()) << "Charging configuration added" << configuration->evChargerThingId();
        m_chargingConfigurations->addConfiguration(configuration);
    } else {
        qCDebug(dcHems()) << "Charging configuration changed" << configuration->evChargerThingId();
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
        configuration->setLongitude(configurationMap.value("longitude").toDouble());
        configuration->setLatitude(configurationMap.value("latitude").toDouble());
        configuration->setRoofPitch(configurationMap.value("roofPitch").toInt());
        configuration->setAlignment(configurationMap.value("alignment").toInt());
        configuration->setKwPeak(configurationMap.value("kwPeak").toFloat());

    }



     if (newConfiguration){
         qCDebug(dcHems()) << "Pv configuration added" << configuration->PvThingId();
         m_pvConfigurations->addConfiguration(configuration);

     }else{
        qCDebug(dcHems()) << "Pv configuration changed" << configuration->PvThingId();

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

