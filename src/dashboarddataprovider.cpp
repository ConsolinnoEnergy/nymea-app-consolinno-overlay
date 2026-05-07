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
    m_batteryThingsProxy->setShownInterfaces({ "energystorage" });
    m_consumerThingsProxy->setShownInterfaces({ "smartmeterconsumer" });

    m_energyFlowRefreshTimer.setInterval(2000);
    connect(&m_energyFlowRefreshTimer, &QTimer::timeout,
            this, &DashboardDataProvider::updateEnergyValues);
    m_energyFlowRefreshTimer.start();

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

    m_kpiRefreshTimer.stop();

    if (m_engine) {
        qCCritical(dcDashboardDataProvider()) << "Already have an engine:" << m_engine;
    }

    qCDebug(dcDashboardDataProvider()) << "Setting engine:" << engine;
    m_engine = engine;
    emit engineChanged();

    m_producerThingsProxy->setEngine(m_engine);
    m_batteryThingsProxy->setEngine(m_engine);
    m_consumerThingsProxy->setEngine(m_engine);

    // Fetch KPIs periodically via timer (initial fetch delayed to allow connection to stabilize)
    if (m_engine && m_engine->jsonRpcClient()) {
        QTimer::singleShot(5000, this, &DashboardDataProvider::fetchEnergyKPIs);
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
    m_rootMeter = rootMeter;
    m_currentPowerRootMeter = 0;
    emit rootMeterChanged();
    emit currentPowerRootMeterChanged(m_currentPowerRootMeter);
}

int DashboardDataProvider::currentPowerRootMeter() const
{
    return m_currentPowerRootMeter;
}

int DashboardDataProvider::currentPowerProduction() const
{
    return m_currentPowerProduction;
}

int DashboardDataProvider::currentPowerBatteries() const
{
    return m_currentPowerBatteries;
}

int DashboardDataProvider::currentPowerAllocatedConsumption() const
{
    return m_currentPowerAllocatedConsumption;
}

int DashboardDataProvider::currentPowerUnallocatedConsumption() const
{
    return m_currentPowerUnallocatedConsumption;
}

int DashboardDataProvider::currentPowerTotalConsumption() const
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

void DashboardDataProvider::updateConsumptions()
{
    const auto currentPowerTotalConsumption =
        m_currentPowerRootMeter -
        m_currentPowerProduction -
        m_currentPowerBatteries;
    const auto currentPowerUnallocatedConsumption =
        currentPowerTotalConsumption -
        m_currentPowerAllocatedConsumption;
    if (m_currentPowerUnallocatedConsumption != currentPowerUnallocatedConsumption) {
        m_currentPowerUnallocatedConsumption = currentPowerUnallocatedConsumption;
        qCInfo(dcDashboardDataProvider()) << "Unmetered consumption:" << m_currentPowerUnallocatedConsumption;
        emit currentPowerUnallocatedConsumptionChanged(m_currentPowerUnallocatedConsumption);
    }
    if (m_currentPowerTotalConsumption != currentPowerTotalConsumption) {
        m_currentPowerTotalConsumption = currentPowerTotalConsumption;
        qCInfo(dcDashboardDataProvider()) << "Total consumption:" << m_currentPowerTotalConsumption;
        emit currentPowerTotalConsumptionChanged(m_currentPowerTotalConsumption);
    }
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

    qCInfo(dcDashboardDataProvider()) << "Energy flows:";
    qCInfo(dcDashboardDataProvider()) << "  solar -> battery:" << m_flowSolarToBattery << " W";
    qCInfo(dcDashboardDataProvider()) << "  solar -> consumers:" << m_flowSolarToConsumers << " W";
    qCInfo(dcDashboardDataProvider()) << "  solar -> grid:" << m_flowSolarToGrid << " W";
    qCInfo(dcDashboardDataProvider()) << "  battery -> consumers:" << m_flowBatteryToConsumers << " W";
    qCInfo(dcDashboardDataProvider()) << "  grid -> battery:" << m_flowGridToBattery << " W";
    qCInfo(dcDashboardDataProvider()) << "  grid -> consumers:" << m_flowGridToConsumers << " W";
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

    if (!m_engine->jsonRpcClient()->authenticated()) {
        qCDebug(dcDashboardDataProvider()) << "Cannot fetch Energy KPIs: not authenticated.";
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
        if (data.isEmpty()) {
            // Empty response means "No such method" — backend does not support this API yet (version mismatch)
            qCDebug(dcDashboardDataProvider()) << "Energy KPIs not supported by this backend (empty response).";
        } else {
            qCWarning(dcDashboardDataProvider()) << "Energy KPIs response missing expected fields. Keys:" << data.keys();
        }
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

void DashboardDataProvider::updateEnergyValues()
{
    qCDebug(dcDashboardDataProvider()) << "Updating energy flow";
    if (!canUpdateEnergyFlow()) {
        resetValues();
        return;
    }

    updateRootMeterValues();
    updatePowerProductionValues();
    updateBatteryValues();
    updatePowerConsumptionValues();
    updateConsumptions();
    updateEnergyFlow();
}

bool DashboardDataProvider::canUpdateEnergyFlow() const
{
    return m_engine != nullptr && m_rootMeter != nullptr;
}

void DashboardDataProvider::updateRootMeterValues()
{
    const auto currentPower = qRound(stateValueDouble(m_rootMeter, "currentPower"));
    if (m_currentPowerRootMeter != currentPower) {
        m_currentPowerRootMeter = currentPower;
        qCInfo(dcDashboardDataProvider()) << "Root meter:" << m_currentPowerRootMeter << "W";
        emit currentPowerRootMeterChanged(m_currentPowerRootMeter);
    }
}

void DashboardDataProvider::updatePowerProductionValues()
{
    auto totalCurrentPower = 0.;
    qCDebug(dcDashboardDataProvider()) << "Got" << m_producerThingsProxy->rowCount() << "producers:";
    for (auto i = 0; i < m_producerThingsProxy->rowCount(); ++i) {
        const auto producer = m_producerThingsProxy->get(i);
        const auto currentPower = stateValueDouble(producer, "currentPower");
        qCDebug(dcDashboardDataProvider()) << "  " << producer->name() << "=>" << currentPower << "W";
        totalCurrentPower += currentPower;
    }
    const auto totalCurrentPowerRounded = qRound(totalCurrentPower);
    if (m_currentPowerProduction != totalCurrentPowerRounded) {
        m_currentPowerProduction = totalCurrentPowerRounded;
        qCInfo(dcDashboardDataProvider()) << "Production:" << m_currentPowerProduction << "W";
        emit currentPowerProductionChanged(m_currentPowerProduction);
    }
}

void DashboardDataProvider::updateBatteryValues()
{
    auto totalCurrentPower = 0.;
    auto capacities = QList<double>{};
    auto levels = QList<double>{};
    qCDebug(dcDashboardDataProvider()) << "Got" << m_batteryThingsProxy->rowCount() << "batteries:";
    for (auto i = 0; i < m_batteryThingsProxy->rowCount(); ++i) {
        const auto battery = m_batteryThingsProxy->get(i);
        const auto currentPower = stateValueDouble(battery, "currentPower");
        totalCurrentPower += currentPower;
        const auto capacity = stateValueDouble(battery, "capacity");
        capacities << capacity;
        const auto level = stateValueDouble(battery, "batteryLevel");
        levels << level;
        qCDebug(dcDashboardDataProvider())
            << "  " << battery->name() << "=>"
            << currentPower << "W"
            << level << "%"
            << capacity << "kWh";
    }

    const auto totalCurrentPowerRounded = qRound(totalCurrentPower);
    if (m_currentPowerBatteries != totalCurrentPowerRounded) {
        m_currentPowerBatteries = totalCurrentPowerRounded;
        qCInfo(dcDashboardDataProvider()) << "Batteries:" << m_currentPowerBatteries << "W";
        emit currentPowerBatteriesChanged(m_currentPowerBatteries);
    }
    updateTotalBatteryLevel(capacities, levels);
}

void DashboardDataProvider::updatePowerConsumptionValues()
{
    auto totalCurrentPower = 0.;
    qCDebug(dcDashboardDataProvider()) << "Got" << m_consumerThingsProxy->rowCount() << "consumers:";
    for (auto i = 0; i < m_consumerThingsProxy->rowCount(); ++i) {
        const auto consumer = m_consumerThingsProxy->get(i);
        if (isHidden(consumer)) { continue; }
        const auto currentPower = stateValueDouble(consumer, "currentPower");
        qCDebug(dcDashboardDataProvider()) << "  " << consumer->name() << "=>" << currentPower << "W";
        totalCurrentPower += currentPower;
    }
    const auto totalCurrentPowerRounded = qRound(totalCurrentPower);
    if (m_currentPowerAllocatedConsumption != totalCurrentPowerRounded) {
        m_currentPowerAllocatedConsumption = totalCurrentPowerRounded;
        qCInfo(dcDashboardDataProvider()) << "Metered consumption:" << m_currentPowerAllocatedConsumption << "W";
        emit currentPowerAllocatedConsumptionChanged(m_currentPowerAllocatedConsumption);
    }
}

void DashboardDataProvider::updateTotalBatteryLevel(const QList<double> &capacities,
                                                    const QList<double> &levels)
{
    if (capacities.isEmpty() || levels.isEmpty()) { return; }

    auto totalBatteryCapacity = 0.;
    auto totalBatteryLevel = 0.;

    if (capacities.size() == levels.size()) {
        for (qsizetype i = 0; i < capacities.size(); ++i) {
            totalBatteryCapacity += capacities[i];
            totalBatteryLevel += capacities[i] * levels[i];
        }

        if (totalBatteryCapacity > 0.) {
            totalBatteryLevel /= totalBatteryCapacity;
        } else {
            qCCritical(dcDashboardDataProvider()) << "Invalid total battery capacity:" << totalBatteryCapacity;
            totalBatteryLevel = 0.;
        }
    } else {
        qCCritical(dcDashboardDataProvider()) << "Got different numbers of battery capacities and levels!";
        totalBatteryLevel = 0.;
    }

    if (!qFuzzyCompare(m_totalBatteryLevel, totalBatteryLevel)) {
        m_totalBatteryLevel = totalBatteryLevel;
        qCInfo(dcDashboardDataProvider()) << "Total battery level:" << m_totalBatteryLevel << "%";
        emit totalBatteryLevelChanged(m_totalBatteryLevel);
    }
}

bool DashboardDataProvider::isHidden(Thing *thing) const
{
    if (!thing->thingClass()->interfaces().contains("hideable")) { return false; }
    const auto hiddenState = thing->stateByName("hidden");
    if (!hiddenState) { return false; }
    const auto hidden = hiddenState->value().toBool();
    qCDebug(dcDashboardDataProvider()) << "Thing" << thing->name() << "hidden?" << hidden;
    return hidden;
}

double DashboardDataProvider::stateValueDouble(Thing *thing, const QString &stateName) const
{
    if (!isConnected(thing)) { return 0.; }
    const auto state = thing->stateByName(stateName);
    if (!state) {
        qCWarning(dcDashboardDataProvider())
        << "Thing"
        << thing->name()
        << "does not have a"
        << stateName
        << "state!";
        return 0.;
    }
    auto conversionOk = true;
    const auto doubleValue = state->value().toDouble(&conversionOk);
    if (!conversionOk) {
        qCWarning(dcDashboardDataProvider())
        << "Thing"
        << thing->name()
        << "-> Can not convert value of state"
        << stateName
        << "to double!"
        << state->value().toString();
        return 0.;
    }
    return doubleValue;
}

bool DashboardDataProvider::isConnected(Thing *thing) const
{
    const auto connectedState = thing->stateByName("connected");
    if (!connectedState) {
        qCDebug(dcDashboardDataProvider())
        << "Thing"
        << thing->name()
        << "does not have a \"connected\" state";
        // We can't tell. Assume connected.
        return true;
    }
    const auto connected = connectedState->value().toBool();
    if (connected) {
        qCDebug(dcDashboardDataProvider()) << "Thing" << thing->name() << " is connected";
    } else {
        qCWarning(dcDashboardDataProvider()) << "Thing" << thing->name() << "is not connected!";
    }
    return connected;
}

void DashboardDataProvider::resetValues()
{
    qCInfo(dcDashboardDataProvider()) << "Resetting power and energy flow values";
    if (m_currentPowerRootMeter != 0) {
        m_currentPowerRootMeter = 0;
        emit currentPowerRootMeterChanged(m_currentPowerRootMeter);
    }
    if (m_currentPowerProduction != 0) {
        m_currentPowerProduction = 0;
        emit currentPowerProductionChanged(m_currentPowerProduction);
    }
    if (m_currentPowerBatteries != 0) {
        m_currentPowerBatteries = 0;
        emit currentPowerBatteriesChanged(m_currentPowerBatteries);
    }
    if (m_totalBatteryLevel != 0.) {
        m_totalBatteryLevel = 0.;
        emit totalBatteryLevelChanged(m_totalBatteryLevel);
    }
    if (m_currentPowerAllocatedConsumption != 0) {
        m_currentPowerAllocatedConsumption = 0;
        emit currentPowerAllocatedConsumptionChanged(m_currentPowerAllocatedConsumption);
    }
    // Will reset other power values and energy flow values to 0.
    updateConsumptions();
    updateEnergyFlow();
}

