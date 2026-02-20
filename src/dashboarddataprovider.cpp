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
    connect(m_producerThingsProxy, &ThingsProxy::countChanged,
            this, &DashboardDataProvider::setupPowerProductionStats);

    m_batteryThingsProxy->setShownInterfaces({ "energystorage" });
    connect(m_batteryThingsProxy, &ThingsProxy::countChanged,
            this, &DashboardDataProvider::setupBatteriesStats);

    m_consumerThingsProxy->setShownInterfaces({ "smartmeterconsumer" });
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

int DashboardDataProvider::flowSolarToGrid() const
{
    return m_flowSolarToGrid;
}

int DashboardDataProvider::flowSolarToBattery() const
{
    return m_flowSolarToBattery;
}

int DashboardDataProvider::flowSolarToConsumers() const
{
    return m_flowSolarToConsumers;
}

int DashboardDataProvider::flowGridToConsumers() const
{
    return m_flowGridToConsumers;
}

int DashboardDataProvider::flowGridToBattery() const
{
    return m_flowGridToBattery;
}

int DashboardDataProvider::flowBatteryToConsumers() const
{
    return m_flowBatteryToConsumers;
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
            currentPowerTotalConsumption -
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
    updateEnergyFlow();
}

void DashboardDataProvider::updateEnergyFlow()
{
    // Using the current power values of root meter, producers, batteries and consumers,
    // we can calculate the energy flow between these entities.
    //
    //   -------------         -------------
    //   | Producers |         |    Grid   |
    //   |  (Solar)  |-------->|           |
    //   |  P_prod   |         |   P_grid  |
    //   -------------\       /-------------
    //      |          \     /        |
    //      |           \   /         |
    //      |            \ /          |
    //      |             \           |
    //      |            / \          |
    //      |           /   \         |
    //      |          /     \        |
    //      v         v       v       v
    //   -------------         -------------
    //   | Batteries |         | Consumers |
    //   |           |-------->|           |
    //   |  P_batt   |         |   P_cons  |
    //   -------------         -------------
    //
    //
    // Notes:
    // - Consumption values are positive, production values are negative, i.e.
    //   - P_prod (= m_currentPowerProduction) is always negative
    //   - P_batt (= m_currentPowerBatteries) is positive when battery is charged, negative when it is discharged
    //   - P_grid (= m_currentPowerRootMeter) is positive when energy is drawn from the grid, negative when energy is fed into the grid
    //   - P_cons (= m_currentPowerTotalConsumption) is always positive
    //
    // The system of linear equations (4 power values given, 6 flow values to be determined) is underdetermined
    // in the general case but we can apply restrictions to solve all cases which can happen realistically.
    // This is done in the code below.

    // #TODO make m_currentPower* values int instead of double

    auto flowSolarToGrid = 0;
    auto flowSolarToBattery = 0;
    auto flowSolarToConsumers = 0;
    auto flowGridToConsumers = 0;
    auto flowGridToBattery = 0;
    auto flowBatteryToConsumers = 0;

    if (m_currentPowerRootMeter > 0) { // We draw energy from the grid
        if (m_currentPowerBatteries > 0) { // Batteries are currently charging
            // This case is basically underdetermined but we add the following restriction:
            // The solar production primarily goes to the consumers, then to the batteries.
            if (m_currentPowerTotalConsumption < -m_currentPowerProduction) {
                // Energy consumption is smaller than solar energy production, so we have
                // some solar energy left for the batteries.
                flowGridToBattery = m_currentPowerRootMeter;
                flowSolarToConsumers = m_currentPowerTotalConsumption;
                flowSolarToBattery = -m_currentPowerProduction - m_currentPowerTotalConsumption;
            } else if (m_currentPowerTotalConsumption == -m_currentPowerProduction) {
                // Solar energy production is exactly the same as total consumption.
                // Batteries are charged from the grid.
                flowSolarToConsumers = m_currentPowerTotalConsumption;
                flowGridToBattery = m_currentPowerRootMeter;
            } else {
                // Solar energy production is smaller than total consumption.
                // We have consumption and battery charging from grid.
                flowGridToBattery = m_currentPowerBatteries;
                flowSolarToConsumers = -m_currentPowerProduction;
                flowGridToConsumers = m_currentPowerRootMeter - m_currentPowerBatteries;
            }
        } else if (m_currentPowerBatteries == 0) { // Batteries are idle
            flowSolarToConsumers = -m_currentPowerProduction;
            flowGridToConsumers = m_currentPowerRootMeter;
        } else { // Batteries are currently discharging
            flowSolarToConsumers = -m_currentPowerProduction;
            flowGridToConsumers = m_currentPowerRootMeter;
            flowBatteryToConsumers = -m_currentPowerBatteries;
        }
    } else if (m_currentPowerRootMeter == 0) { // We don't draw or feed in enegry from/into the grid.
        if (m_currentPowerBatteries > 0) { // Batteries are currently charging
            flowSolarToBattery = m_currentPowerBatteries;
            flowSolarToConsumers = m_currentPowerTotalConsumption;
        } else if (m_currentPowerBatteries == 0) { // Batteries are idle
            flowSolarToConsumers = m_currentPowerTotalConsumption;
        } else { // Batteries are currently discharging
            flowSolarToConsumers = -m_currentPowerProduction;
            flowBatteryToConsumers = -m_currentPowerBatteries;
        }
    } else { // We feed energy into the grid
        if (m_currentPowerBatteries > 0) { // Batteries are currently charging
            flowSolarToBattery = m_currentPowerBatteries;
            flowSolarToConsumers = m_currentPowerTotalConsumption;
            flowSolarToGrid = -m_currentPowerRootMeter;
        } else if (m_currentPowerBatteries == 0) { // Batteries are idle
            flowSolarToConsumers = m_currentPowerTotalConsumption;
            flowSolarToGrid = -m_currentPowerRootMeter;
        } else { // Batteries are currently discharging
            // This case is basically underdetermined but we add the following restriction:
            // The battery power primarily goes to consumption, and only then is it fed
            // into the grid. (In practice, this should never happen.)
            if (m_currentPowerTotalConsumption < -m_currentPowerBatteries) {
                // The batteries discharges with more power than the consumers need.
                // Solar production and the excess energy from the batteries are fed
                // into the grid.
                flowBatteryToConsumers = m_currentPowerTotalConsumption;
                flowSolarToGrid = -m_currentPowerProduction;
                flowGridToBattery = m_currentPowerTotalConsumption + m_currentPowerBatteries;
            } else if (m_currentPowerTotalConsumption == -m_currentPowerBatteries) {
                // Battery power is exactly the same as consumption. Solar production
                // is fed into the grid.
                flowBatteryToConsumers = m_currentPowerTotalConsumption;
                flowSolarToGrid = -m_currentPowerProduction;
            } else {
                // Battery power is less than the consumers need. A part of the solar
                // production goes into the consumers, the rest to the grid.
                flowBatteryToConsumers = -m_currentPowerBatteries;
                flowSolarToGrid = -m_currentPowerRootMeter;
                flowSolarToConsumers = -m_currentPowerProduction + m_currentPowerRootMeter;
            }
        }
    }


    if (flowSolarToGrid != m_flowSolarToGrid) {
        m_flowSolarToGrid = flowSolarToGrid;
        emit flowSolarToGridChanged(m_flowSolarToGrid);
    }
    if (flowSolarToBattery != m_flowSolarToBattery) {
        m_flowSolarToBattery = flowSolarToBattery;
        emit flowSolarToBatteryChanged(m_flowSolarToBattery);
    }
    if (flowSolarToConsumers != m_flowSolarToConsumers) {
        m_flowSolarToConsumers = flowSolarToConsumers;
        emit flowSolarToConsumersChanged(m_flowSolarToConsumers);
    }
    if (flowGridToConsumers != m_flowGridToConsumers) {
        m_flowGridToConsumers = flowGridToConsumers;
        emit flowGridToConsumersChanged(m_flowGridToConsumers);
    }
    if (flowGridToBattery != m_flowGridToBattery) {
        m_flowGridToBattery = flowGridToBattery;
        emit flowGridToBatteryChanged(m_flowGridToBattery);
    }
    if (flowBatteryToConsumers != m_flowBatteryToConsumers) {
        m_flowBatteryToConsumers = flowBatteryToConsumers;
        emit flowBatteryToConsumersChanged(m_flowBatteryToConsumers);
    }

    qCDebug(dcDashboardDataProvider()) << "Energy flows:";
    qCDebug(dcDashboardDataProvider()) << "  solar -> battery:" << m_flowSolarToBattery << " W";
    qCDebug(dcDashboardDataProvider()) << "  solar -> consumers:" << m_flowSolarToConsumers << " W";
    qCDebug(dcDashboardDataProvider()) << "  solar -> grid:" << m_flowSolarToGrid << " W";
    qCDebug(dcDashboardDataProvider()) << "  battery -> consumers:" << m_flowBatteryToConsumers << " W";
    qCDebug(dcDashboardDataProvider()) << "  grid -> battery:" << m_flowGridToBattery << " W";
    qCDebug(dcDashboardDataProvider()) << "  grid -> consumers:" << m_flowGridToConsumers << " W";
}
