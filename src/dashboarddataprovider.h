#ifndef DASHBOARDDATAPROVIDER_H
#define DASHBOARDDATAPROVIDER_H

#include <QObject>

#include "engine.h"
#include "thingsproxy.h"

class DashboardDataProvider : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(Thing *rootMeter READ rootMeter WRITE setRootMeter NOTIFY rootMeterChanged)

    Q_PROPERTY(double currentPowerRootMeter READ currentPowerRootMeter NOTIFY currentPowerRootMeterChanged)
    Q_PROPERTY(double currentPowerProduction READ currentPowerProduction NOTIFY currentPowerProductionChanged)
    Q_PROPERTY(double currentPowerBatteries READ currentPowerBatteries NOTIFY currentPowerBatteriesChanged)
    Q_PROPERTY(double currentPowerMeteredConsumption READ currentPowerMeteredConsumption NOTIFY currentPowerMeteredConsumptionChanged)
    Q_PROPERTY(double currentPowerUnmeteredConsumption READ currentPowerUnmeteredConsumption NOTIFY currentPowerUnmeteredConsumptionChanged)
    Q_PROPERTY(double currentPowerTotalConsumption READ currentPowerTotalConsumption NOTIFY currentPowerTotalConsumptionChanged)
    Q_PROPERTY(double totalBatteryLevel READ totalBatteryLevel NOTIFY totalBatteryLevelChanged)

public:
    explicit DashboardDataProvider(QObject *parent = nullptr);

    Engine *engine() const;
    void setEngine(Engine *engine);

    Thing *rootMeter() const;
    void setRootMeter(Thing *rootMeter);

    double currentPowerRootMeter() const;
    double currentPowerProduction() const;
    double currentPowerBatteries() const;
    double currentPowerMeteredConsumption() const;
    double currentPowerUnmeteredConsumption() const;
    double currentPowerTotalConsumption() const;
    double totalBatteryLevel() const;

signals:
    void engineChanged();
    void rootMeterChanged();
    void currentPowerRootMeterChanged(double currentPowerRootMeter);
    void currentPowerProductionChanged(double currentPowerProduction);
    void currentPowerBatteriesChanged(double currentPowerBatteries);
    void currentPowerMeteredConsumptionChanged(double currentPowerMeteredConsumption);
    void currentPowerUnmeteredConsumptionChanged(double currentPowerUnmeteredConsumption);
    void currentPowerTotalConsumptionChanged(double currentPowerTotalConsumption);
    void totalBatteryLevelChanged(double totalBatteryLevel);

private:
    void updateRootMeterCurrentPower(State *currentPowerState);

    void setupPowerProductionStats();
    void updateCurrentPowerProduction();
    void updateProducerCurrentPower(Thing *producer, State *currentPowerState);

    void setupBatteriesStats();
    void updateCurrentPowerBatteries();
    void updateBatteryCurrentPower(Thing *battery, State *currentPowerState);
    void updateTotalBatteryLevel();
    void updateBatteryCapacity(Thing *battery, State *capacityState);
    void updateBatteryLevel(Thing *battery, State *batteryLevelState);

    void setupConsumersStats();
    void updateCurrentPowerConsumption();
    void updateConsumerCurrentPower(Thing *consumer, State *currentPowerState);

    void updateConsumptions();

    QPointer<Engine> m_engine = nullptr;

    QPointer<Thing> m_rootMeter = nullptr;
    QUuid m_rootMeterId;
    double m_currentPowerRootMeter = 0.;
    QMetaObject::Connection m_currentPowerRootMeterConn;

    QPointer<ThingsProxy> m_producerThingsProxy = nullptr;
    QHash<Thing *, double> m_producerCurrentPowers;
    double m_currentPowerProduction = 0.;

    QPointer<ThingsProxy> m_batteryThingsProxy = nullptr;
    QHash<Thing *, double> m_batteryCurrentPowers;
    double m_currentPowerBatteries = 0.;
    QHash<Thing *, double> m_batteryCapacities;
    double m_totalBatteryCapacity = 0.;
    QHash<Thing *, double> m_batteryLevels;
    double m_totalBatteryLevel = 0.;

    QPointer<ThingsProxy> m_consumerThingsProxy = nullptr;
    QHash<Thing *, double> m_consumerCurrentPowers;
    double m_currentPowerMeteredConsumption = 0.;

    double m_currentPowerUnmeteredConsumption = 0.;
    double m_currentPowerTotalConsumption = 0.;
};

#endif // DASHBOARDDATAPROVIDER_H
