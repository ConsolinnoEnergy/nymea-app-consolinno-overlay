#include "dashboarddataprovider.h"

#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcDashboardDataProvider, "DashboardDataProvider");

DashboardDataProvider::DashboardDataProvider(QObject *parent)
    : QObject{ parent }
    , m_producerThingsProxy{ new ThingsProxy{ this } }
    , m_batteryThingsProxy{ new ThingsProxy{ this } }
    , m_consumerThingsProxy{ new ThingsProxy{ this } }
{
    m_producerThingsProxy->setShownInterfaces({ "smartmeterproducer" });
    connect(m_producerThingsProxy, &ThingsProxy::engineChanged,
            this, &DashboardDataProvider::setupPowerProductionStats);
    connect(m_producerThingsProxy, &ThingsProxy::countChanged,
            this, &DashboardDataProvider::setupPowerProductionStats);

    m_batteryThingsProxy->setShownInterfaces({ "energystorage" });
    connect(m_producerThingsProxy, &ThingsProxy::engineChanged,
            this, &DashboardDataProvider::setupBatteriesStats);
    connect(m_producerThingsProxy, &ThingsProxy::countChanged,
            this, &DashboardDataProvider::setupBatteriesStats);

    m_consumerThingsProxy->setShownInterfaces({ "smartmeterconsumer" });
    connect(m_consumerThingsProxy, &ThingsProxy::engineChanged,
            this, &DashboardDataProvider::setupConsumersStats);
    connect(m_consumerThingsProxy, &ThingsProxy::countChanged,
            this, &DashboardDataProvider::setupConsumersStats);
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
        // #TODO disconnect from old engine's thing manager
    }

    qCDebug(dcDashboardDataProvider()) << "Setting engine:" << engine;
    m_engine = engine;
    emit engineChanged();

    m_producerThingsProxy->setEngine(m_engine);
    m_batteryThingsProxy->setEngine(m_engine);
    m_consumerThingsProxy->setEngine(m_engine);

    if (m_engine) {
        // #TODO grab thing manager and connect to stuff needed
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
