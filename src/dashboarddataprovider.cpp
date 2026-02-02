#include "dashboarddataprovider.h"

#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcDashboardDataProvider, "DashboardDataProvider");

DashboardDataProvider::DashboardDataProvider(QObject *parent)
    : QObject{ parent }
    , m_producerThingsProxy{ new ThingsProxy{ this } }
    , m_batteryThingsProxy{ new ThingsProxy{ this } }
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

    if (m_engine) {
        // #TODO grab thing manager and connect to stuff needed
    }
}

double DashboardDataProvider::currentPowerProduction() const
{
    return m_currentPowerProduction;
}

double DashboardDataProvider::currentPowerBatteries() const
{
    return m_currentPowerBatteries;
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
        connect(currentPowerState, &State::valueChanged, producer, [this, producer, currentPowerState]() {
            updateProducerCurrentPower(producer, currentPowerState);
        });
    }
}

void DashboardDataProvider::updateCurrentPowerProduction()
{
    auto totalCurrentPower = 0.;
    for (auto it = m_producerCurrentPowers.constBegin();
         it != m_producerCurrentPowers.constEnd();
         ++it) {
        totalCurrentPower += it.value();
    }

    if (!qFuzzyCompare(m_currentPowerProduction, totalCurrentPower)) {
        m_currentPowerProduction = totalCurrentPower;
        emit currentPowerProductionChanged(m_currentPowerProduction);
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
        connect(currentPowerState, &State::valueChanged, battery, [this, battery, currentPowerState]() {
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
        emit currentPowerBatteriesChanged(m_currentPowerBatteries);
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
    }
    qCDebug(dcDashboardDataProvider()) << "Updating battery" << battery->name()
                                       << "-> Current power:" << currentPower;
    m_batteryCurrentPowers[battery] = currentPower;
    updateCurrentPowerBatteries();
}
