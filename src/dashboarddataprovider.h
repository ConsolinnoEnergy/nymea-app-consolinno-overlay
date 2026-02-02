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

public:
    explicit DashboardDataProvider(QObject *parent = nullptr);

    Engine *engine() const;
    void setEngine(Engine *engine);

    double currentPowerProduction() const;

signals:
    void engineChanged();
    void currentPowerProductionChanged(double currentPowerProduction);

private:
    void setupProducerStats();
    void updateCurrentPowerProduction();
    void updateProducerCurrentPower(Thing *producer, State *state);

    QPointer<Engine> m_engine = nullptr;
    QPointer<ThingsProxy> m_producerThingsProxy = nullptr;

    QHash<Thing *, double> m_producerCurrentPowers;
    double m_currentPowerProduction = 0.;
};

#endif // DASHBOARDDATAPROVIDER_H
