#ifndef DASHBOARDDATAPROVIDER_H
#define DASHBOARDDATAPROVIDER_H

#include <QObject>

#include "engine.h"
#include "thingsproxy.h"

class DashboardDataProvider : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(double currentPowerProduction READ currentPowerProduction NOTIFY currentPowerProductionChanged)
    Q_PROPERTY(double currentPowerBatteries READ currentPowerBatteries NOTIFY currentPowerBatteriesChanged)

public:
    explicit DashboardDataProvider(QObject *parent = nullptr);

    Engine *engine() const;
    void setEngine(Engine *engine);

    double currentPowerProduction() const;
    double currentPowerBatteries() const;

signals:
    void engineChanged();
    void currentPowerProductionChanged(double currentPowerProduction);
    void currentPowerBatteriesChanged(double currentPowerBatteries);

private:
    void setupPowerProductionStats();
    void updateCurrentPowerProduction();
    void updateProducerCurrentPower(Thing *producer, State *currentPowerState);

    void setupBatteriesStats();
    void updateCurrentPowerBatteries();
    void updateBatteryCurrentPower(Thing *battery, State *currentPowerState);

    QPointer<Engine> m_engine = nullptr;

    QPointer<ThingsProxy> m_producerThingsProxy = nullptr;
    QHash<Thing *, double> m_producerCurrentPowers;
    double m_currentPowerProduction = 0.;

    QPointer<ThingsProxy> m_batteryThingsProxy = nullptr;
    QHash<Thing *, double> m_batteryCurrentPowers;
    double m_currentPowerBatteries = 0.;
};

#endif // DASHBOARDDATAPROVIDER_H
