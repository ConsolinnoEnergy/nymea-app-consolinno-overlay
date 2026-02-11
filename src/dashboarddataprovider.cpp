#include "dashboarddataprovider.h"

#include <QDateTime>
#include <QTimeZone>

#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcDashboardDataProvider, "DashboardDataProvider");

DashboardDataProvider::DashboardDataProvider(QObject *parent)
    : QObject{ parent }
    , m_producerThingsProxy{ new ThingsProxy{ this } }
    , m_batteryThingsProxy{ new ThingsProxy{ this } }
    , m_consumerThingsProxy{ new ThingsProxy{ this } }
{
    m_producerThingsProxy->setShownInterfaces({ "smartmeterproducer" });
    connect(m_producerThingsProxy, &ThingsProxy::countChanged,
            this, &DashboardDataProvider::setupPowerProductionStats);

    m_batteryThingsProxy->setShownInterfaces({ "energystorage" });
    connect(m_batteryThingsProxy, &ThingsProxy::countChanged,
            this, &DashboardDataProvider::setupBatteriesStats);

    m_consumerThingsProxy->setShownInterfaces({ "smartmeterconsumer" });
    connect(m_consumerThingsProxy, &ThingsProxy::countChanged,
            this, &DashboardDataProvider::setupConsumersStats);

    // Refresh KPIs every 5 minutes
    m_kpiRefreshTimer.setInterval(5 * 60 * 1000);
    connect(&m_kpiRefreshTimer, &QTimer::timeout,
            this, &DashboardDataProvider::fetchEnergyKPIs);
}

Engine *DashboardDataProvider::engine() const
{
    return m_engine;
}

void DashboardDataProvider::setEngine(Engine *engine)
{
    if (m_engine == engine) { return; }

    if (m_engine) {
        qCCritical(dcDashboardDataProvider()) << "Already have an engine:" << m_engine;
    }

    qCDebug(dcDashboardDataProvider()) << "Setting engine:" << engine;
    m_engine = engine;
    emit engineChanged();

    m_producerThingsProxy->setEngine(m_engine);
    m_batteryThingsProxy->setEngine(m_engine);
    m_consumerThingsProxy->setEngine(m_engine);

    setupPowerProductionStats();
    setupBatteriesStats();
    setupConsumersStats();

    // Fetch KPIs periodically via timer (initial fetch delayed to allow connection to stabilize)
    if (m_engine && m_engine->jsonRpcClient()) {
        QTimer::singleShot(5000, this, [this]() {
            // Extra guard: only fetch if still connected when the timer fires
            if (m_engine && m_engine->jsonRpcClient() && m_engine->jsonRpcClient()->connected()) {
                fetchEnergyKPIs();
            }
        });
        m_kpiRefreshTimer.start();
    }
}

Thing *DashboardDataProvider::rootMeter() const
{
    return m_rootMeter;
}

void DashboardDataProvider::setRootMeter(Thing *rootMeter)
{
    if (m_rootMeter == rootMeter) { return; }

    if (m_currentPowerRootMeterConn) {
        // disconnect from old root meter thing.
        QObject::disconnect(m_currentPowerRootMeterConn);
    }

    m_rootMeter = rootMeter;
    m_currentPowerRootMeter = 0.;
    emit rootMeterChanged();
    emit currentPowerRootMeterChanged(m_currentPowerRootMeter);

    if (m_rootMeter != nullptr) {
        qCDebug(dcDashboardDataProvider()) << "Setting root meter:" << rootMeter->name();
        const auto currentPowerState = m_rootMeter->stateByName("currentPower");
        if (!currentPowerState) {
            qCCritical(dcDashboardDataProvider())
                    << "Got root meter without \"currentPower\" state:"
                    << m_rootMeter->name();
            return;
        }
        updateRootMeterCurrentPower(currentPowerState);
        m_currentPowerRootMeterConn =
                connect(currentPowerState, &State::valueChanged,
                        this, [this, currentPowerState]() {
            updateRootMeterCurrentPower(currentPowerState);
        });
    }
}

double DashboardDataProvider::currentPowerRootMeter() const
{
    return m_currentPowerRootMeter;
}

double DashboardDataProvider::currentPowerProduction() const
{
    return m_currentPowerProduction;
}

double DashboardDataProvider::currentPowerBatteries() const
{
    return m_currentPowerBatteries;
}

double DashboardDataProvider::currentPowerMeteredConsumption() const
{
    return m_currentPowerMeteredConsumption;
}

double DashboardDataProvider::currentPowerUnmeteredConsumption() const
{
    return m_currentPowerUnmeteredConsumption;
}

double DashboardDataProvider::currentPowerTotalConsumption() const
{
    return m_currentPowerTotalConsumption;
}

double DashboardDataProvider::totalBatteryLevel() const
{
    return m_totalBatteryLevel;
}

void DashboardDataProvider::updateRootMeterCurrentPower(State *currentPowerState)
{
    auto conversionOk = true;
    const auto currentPower = currentPowerState->value().toDouble(&conversionOk);
    if (!conversionOk) {
        qCWarning(dcDashboardDataProvider())
                << "Root meter -> Can not convert value of state \"currentPower\" to double!"
                << currentPowerState->value().toString();
        return;
    }
    if (!qFuzzyCompare(m_currentPowerRootMeter, currentPower)) {
        m_currentPowerRootMeter = currentPower;
        qCInfo(dcDashboardDataProvider()) << "Root meter:" << m_currentPowerRootMeter;
        emit currentPowerRootMeterChanged(m_currentPowerRootMeter);
        updateConsumptions();
    }
}

void DashboardDataProvider::setupPowerProductionStats()
{
    m_producerCurrentPowers.clear();
    qCDebug(dcDashboardDataProvider()) << "Got" << m_producerThingsProxy->rowCount() << "producers:";
    for (auto i = 0; i < m_producerThingsProxy->rowCount(); ++i) {
        const auto producer = m_producerThingsProxy->get(i);
        qCDebug(dcDashboardDataProvider()) << "  " << producer->name();
        const auto currentPowerState = producer->stateByName("currentPower");
        if (!currentPowerState) {
            qCCritical(dcDashboardDataProvider())
                    << "Got producer without \"currentPower\" state:"
                    << producer->name();
            continue;
        }
        updateProducerCurrentPower(producer, currentPowerState);
        connect(currentPowerState, &State::valueChanged, this, [this, producer, currentPowerState]() {
            updateProducerCurrentPower(producer, currentPowerState);
        });
    }
}

void DashboardDataProvider::updateCurrentPowerProduction()
{
    auto totalProducerPower = 0.;
    for (auto it = m_producerCurrentPowers.constBegin();
         it != m_producerCurrentPowers.constEnd();
         ++it) {
        totalProducerPower += it.value();
    }

    if (!qFuzzyCompare(m_currentPowerProduction, totalProducerPower)) {
        m_currentPowerProduction = totalProducerPower;
        qCInfo(dcDashboardDataProvider()) << "Production:" << m_currentPowerProduction;
        emit currentPowerProductionChanged(m_currentPowerProduction);
        updateConsumptions();
    }
}

void DashboardDataProvider::updateProducerCurrentPower(Thing *producer, State *currentPowerState)
{
    auto conversionOk = true;
    const auto currentPower = currentPowerState->value().toDouble(&conversionOk);
    if (!conversionOk) {
        qCWarning(dcDashboardDataProvider())
                << "Producer"
                << producer->name()
                << "-> Can not convert value of state \"currentPower\" to double!"
                << currentPowerState->value().toString();
        return;
    }
    qCDebug(dcDashboardDataProvider()) << "Updating producer" << producer->name()
                                       << "-> Current power:" << currentPower;
    m_producerCurrentPowers[producer] = currentPower;
    updateCurrentPowerProduction();
}

void DashboardDataProvider::setupBatteriesStats()
{
    m_batteryCurrentPowers.clear();
    m_batteryCapacities.clear();
    m_batteryLevels.clear();
    qCDebug(dcDashboardDataProvider()) << "Got" << m_batteryThingsProxy->rowCount() << "batteries:";
    for (auto i = 0; i < m_batteryThingsProxy->rowCount(); ++i) {
        const auto battery = m_batteryThingsProxy->get(i);
        qCDebug(dcDashboardDataProvider()) << "  " << battery->name();

        const auto currentPowerState = battery->stateByName("currentPower");
        if (!currentPowerState) {
            qCCritical(dcDashboardDataProvider())
                    << "Got battery without \"currentPower\" state:"
                    << battery->name();
            continue;
        }
        updateBatteryCurrentPower(battery, currentPowerState);
        connect(currentPowerState, &State::valueChanged, this, [this, battery, currentPowerState]() {
            updateBatteryCurrentPower(battery, currentPowerState);
        });

        const auto capacityState = battery->stateByName("capacity");
        if (!capacityState) {
            qCCritical(dcDashboardDataProvider())
                    << "Got battery without \"capacity\" state:"
                    << battery->name();
            continue;
        }
        updateBatteryCapacity(battery, capacityState);
        connect(capacityState, &State::valueChanged, this, [this, battery, capacityState]() {
            updateBatteryCapacity(battery, capacityState);
        });

        const auto batteryLevelState = battery->stateByName("batteryLevel");
        if (!batteryLevelState) {
            qCCritical(dcDashboardDataProvider())
                    << "Got battery without \"batteryLevel\" state:"
                    << battery->name();
            continue;
        }
        updateBatteryLevel(battery, batteryLevelState);
        connect(batteryLevelState, &State::valueChanged, this, [this, battery, batteryLevelState]() {
            updateBatteryLevel(battery, batteryLevelState);
        });
    }
}

void DashboardDataProvider::updateCurrentPowerBatteries()
{
    auto totalBatteryPower = 0.;
    for (auto it = m_batteryCurrentPowers.constBegin();
         it != m_batteryCurrentPowers.constEnd();
         ++it) {
        totalBatteryPower += it.value();
    }

    if (!qFuzzyCompare(m_currentPowerBatteries, totalBatteryPower)) {
        m_currentPowerBatteries = totalBatteryPower;
        qCInfo(dcDashboardDataProvider()) << "Batteries:" << m_currentPowerBatteries;
        emit currentPowerBatteriesChanged(m_currentPowerBatteries);
        updateConsumptions();
    }
}

void DashboardDataProvider::updateBatteryCurrentPower(Thing *battery, State *currentPowerState)
{
    auto conversionOk = true;
    const auto currentPower = currentPowerState->value().toDouble(&conversionOk);
    if (!conversionOk) {
        qCWarning(dcDashboardDataProvider())
                << "Battery"
                << battery->name()
                << "-> Can not convert value of state \"currentPower\" to double!"
                << currentPowerState->value().toString();
        return;
    }
    qCDebug(dcDashboardDataProvider()) << "Updating battery" << battery->name()
                                       << "-> Current power:" << currentPower;
    m_batteryCurrentPowers[battery] = currentPower;
    updateCurrentPowerBatteries();
}

void DashboardDataProvider::updateTotalBatteryLevel()
{
    if (m_batteryLevels.isEmpty() || m_batteryCapacities.isEmpty()) { return; }

    auto totalBatteryCapacity = 0.;
    auto totalBatteryLevel = 0.;
    const auto batteryThings = m_batteryLevels.keys();
    for (const auto &batteryThing : batteryThings) {
        totalBatteryCapacity += m_batteryCapacities[batteryThing];
        totalBatteryLevel += m_batteryCapacities[batteryThing] * m_batteryLevels[batteryThing];
    }
    totalBatteryLevel /= totalBatteryCapacity;
    if (!qFuzzyCompare(m_totalBatteryLevel, totalBatteryLevel)) {
        m_totalBatteryLevel = totalBatteryLevel;
        qCInfo(dcDashboardDataProvider()) << "Total battery level:" << m_totalBatteryLevel;
        emit totalBatteryLevelChanged(m_totalBatteryLevel);
    }
}

void DashboardDataProvider::updateBatteryCapacity(Thing *battery, State *capacityState)
{
    auto conversionOk = true;
    const auto capacity = capacityState->value().toDouble(&conversionOk);
    if (!conversionOk) {
        qCWarning(dcDashboardDataProvider())
                << "Battery"
                << battery->name()
                << "-> Can not convert value of state \"capacity\" to double!"
                << capacityState->value().toString();
        return;
    }
    qCDebug(dcDashboardDataProvider()) << "Updating battery" << battery->name()
                                       << "-> Capacity:" << capacity;
    m_batteryCapacities[battery] = capacity;
    updateTotalBatteryLevel();
}

void DashboardDataProvider::updateBatteryLevel(Thing *battery, State *batteryLevelState)
{
    auto conversionOk = true;
    const auto batteryLevel = batteryLevelState->value().toDouble(&conversionOk);
    if (!conversionOk) {
        qCWarning(dcDashboardDataProvider())
                << "Battery"
                << battery->name()
                << "-> Can not convert value of state \"batteryLevel\" to double!"
                << batteryLevelState->value().toString();
        return;
    }
    qCDebug(dcDashboardDataProvider()) << "Updating battery" << battery->name()
                                       << "-> battery level:" << batteryLevel;
    m_batteryLevels[battery] = batteryLevel;
    updateTotalBatteryLevel();
}

void DashboardDataProvider::setupConsumersStats()
{
    m_consumerCurrentPowers.clear();
    qCDebug(dcDashboardDataProvider()) << "Got" << m_consumerThingsProxy->rowCount() << "consumers:";
    for (auto i = 0; i < m_consumerThingsProxy->rowCount(); ++i) {
        const auto consumer = m_consumerThingsProxy->get(i);
        qCDebug(dcDashboardDataProvider()) << "  " << consumer->name();
        const auto currentPowerState = consumer->stateByName("currentPower");
        if (!currentPowerState) {
            qCCritical(dcDashboardDataProvider())
                    << "Got consumer without \"currentPower\" state:"
                    << consumer->name();
            continue;
        }
        updateConsumerCurrentPower(consumer, currentPowerState);
        connect(currentPowerState, &State::valueChanged, this, [this, consumer, currentPowerState]() {
            updateConsumerCurrentPower(consumer, currentPowerState);
        });
    }
}

void DashboardDataProvider::updateCurrentPowerConsumption()
{
    auto totalMeasuredConsumerPower = 0.;
    for (auto it = m_consumerCurrentPowers.constBegin();
         it != m_consumerCurrentPowers.constEnd();
         ++it) {
        totalMeasuredConsumerPower += it.value();
    }

    if (!qFuzzyCompare(m_currentPowerMeteredConsumption, totalMeasuredConsumerPower)) {
        m_currentPowerMeteredConsumption = totalMeasuredConsumerPower;
        qCInfo(dcDashboardDataProvider()) << "Metered consumption:" << m_currentPowerMeteredConsumption;
        emit currentPowerMeteredConsumptionChanged(m_currentPowerMeteredConsumption);
        updateConsumptions();
    }
}

void DashboardDataProvider::updateConsumerCurrentPower(Thing *consumer, State *currentPowerState)
{
    auto conversionOk = true;
    const auto currentPower = currentPowerState->value().toDouble(&conversionOk);
    if (!conversionOk) {
        qCWarning(dcDashboardDataProvider())
                << "Consumer"
                << consumer->name()
                << "-> Can not convert value of state \"currentPower\" to double!"
                << currentPowerState->value().toString();
        return;
    }
    qCDebug(dcDashboardDataProvider()) << "Updating consumer" << consumer->name()
                                       << "-> Current power:" << currentPower;
    m_consumerCurrentPowers[consumer] = currentPower;
    updateCurrentPowerConsumption();
}

void DashboardDataProvider::updateConsumptions()
{
    const auto currentPowerTotalConsumption =
            m_currentPowerRootMeter -
            m_currentPowerProduction -
            m_currentPowerBatteries;
    const auto currentPowerUnmeteredConsumption =
            m_currentPowerTotalConsumption -
            m_currentPowerMeteredConsumption;
    if (!qFuzzyCompare(m_currentPowerUnmeteredConsumption, currentPowerUnmeteredConsumption)) {
        m_currentPowerUnmeteredConsumption = currentPowerUnmeteredConsumption;
        qCInfo(dcDashboardDataProvider()) << "Unmetered consumption:" << m_currentPowerUnmeteredConsumption;
        emit currentPowerUnmeteredConsumptionChanged(m_currentPowerUnmeteredConsumption);
    }
    if (!qFuzzyCompare(m_currentPowerTotalConsumption, currentPowerTotalConsumption)) {
        m_currentPowerTotalConsumption = currentPowerTotalConsumption;
        qCInfo(dcDashboardDataProvider()) << "Total consumption:" << m_currentPowerTotalConsumption;
        emit currentPowerTotalConsumptionChanged(m_currentPowerTotalConsumption);
    }
}

double DashboardDataProvider::selfSufficiencyRate() const
{
    return m_selfSufficiencyRate;
}

double DashboardDataProvider::selfConsumptionRate() const
{
    return m_selfConsumptionRate;
}

bool DashboardDataProvider::kpiValid() const
{
    return m_kpiValid;
}

void DashboardDataProvider::fetchEnergyKPIs()
{
    if (!m_engine || !m_engine->jsonRpcClient()) {
        qCWarning(dcDashboardDataProvider()) << "Cannot fetch Energy KPIs: no engine or JSON-RPC client.";
        return;
    }

    if (!m_engine->jsonRpcClient()->connected()) {
        qCDebug(dcDashboardDataProvider()) << "Cannot fetch Energy KPIs: not connected.";
        return;
    }

    // Calculate midnight today (local time) as Unix timestamp in seconds
    const QDateTime now = QDateTime::currentDateTime();
    QDateTime midnightToday(now.date(), QTime(0, 0, 0), now.timeZone());
    const qint64 fromTimestamp = midnightToday.toSecsSinceEpoch();

    QVariantMap params;
    params.insert("from", fromTimestamp);

    qCDebug(dcDashboardDataProvider()) << "Fetching Energy KPIs from" << fromTimestamp
                                       << "(" << midnightToday.toString(Qt::ISODate) << ")";

    m_engine->jsonRpcClient()->sendCommand("Energy.GetEnergyKPIs", params, this, "getEnergyKPIsResponse");
}

void DashboardDataProvider::getEnergyKPIsResponse(int commandId, const QVariantMap &data)
{
    Q_UNUSED(commandId);

    // Check for error in response
    if (data.contains("error") || data.contains("energyError")) {
        qCWarning(dcDashboardDataProvider()) << "Energy KPIs request failed:"
                                              << data.value("error").toString()
                                              << data.value("energyError").toString();
        return;
    }

    // Guard: if the expected fields are missing, don't update
    if (!data.contains("selfSufficiencyRate") || !data.contains("selfConsumptionRate")) {
        qCWarning(dcDashboardDataProvider()) << "Energy KPIs response missing expected fields. Keys:" << data.keys();
        return;
    }

    const bool valid = data.value("valid").toBool();
    const double selfSufficiencyRate = data.value("selfSufficiencyRate").toDouble();
    const double selfConsumptionRate = data.value("selfConsumptionRate").toDouble();

    qCDebug(dcDashboardDataProvider()) << "Energy KPIs parsed -> valid:" << valid
                                       << "selfSufficiency:" << selfSufficiencyRate << "%"
                                       << "selfConsumption:" << selfConsumptionRate << "%";

    if (m_kpiValid != valid) {
        m_kpiValid = valid;
        emit kpiValidChanged(m_kpiValid);
    }

    if (!qFuzzyCompare(m_selfSufficiencyRate, selfSufficiencyRate)) {
        m_selfSufficiencyRate = selfSufficiencyRate;
        emit selfSufficiencyRateChanged(m_selfSufficiencyRate);
    }

    if (!qFuzzyCompare(m_selfConsumptionRate, selfConsumptionRate)) {
        m_selfConsumptionRate = selfConsumptionRate;
        emit selfConsumptionRateChanged(m_selfConsumptionRate);
    }
}

