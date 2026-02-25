#ifndef DASHBOARDDATAPROVIDER_H
#define DASHBOARDDATAPROVIDER_H

#include <QObject>
#include <QTimer>

#include "engine.h"
#include "thingsproxy.h"

class DashboardDataProvider : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(Thing *rootMeter READ rootMeter WRITE setRootMeter NOTIFY rootMeterChanged)

    Q_PROPERTY(int currentPowerRootMeter READ currentPowerRootMeter NOTIFY currentPowerRootMeterChanged)
    Q_PROPERTY(int currentPowerProduction READ currentPowerProduction NOTIFY currentPowerProductionChanged)
    Q_PROPERTY(int currentPowerBatteries READ currentPowerBatteries NOTIFY currentPowerBatteriesChanged)
    Q_PROPERTY(int currentPowerMeteredConsumption READ currentPowerMeteredConsumption NOTIFY currentPowerMeteredConsumptionChanged)
    Q_PROPERTY(int currentPowerUnmeteredConsumption READ currentPowerUnmeteredConsumption NOTIFY currentPowerUnmeteredConsumptionChanged)
    Q_PROPERTY(int currentPowerTotalConsumption READ currentPowerTotalConsumption NOTIFY currentPowerTotalConsumptionChanged)
    Q_PROPERTY(double totalBatteryLevel READ totalBatteryLevel NOTIFY totalBatteryLevelChanged)

    Q_PROPERTY(double selfSufficiencyRate READ selfSufficiencyRate NOTIFY selfSufficiencyRateChanged)
    Q_PROPERTY(double selfConsumptionRate READ selfConsumptionRate NOTIFY selfConsumptionRateChanged)
    Q_PROPERTY(bool kpiValid READ kpiValid NOTIFY kpiValidChanged)

    Q_PROPERTY(bool fetchingKpiSeries READ fetchingKpiSeries NOTIFY fetchingKpiSeriesChanged)
    Q_PROPERTY(int flowSolarToGrid READ flowSolarToGrid NOTIFY flowSolarToGridChanged)
    Q_PROPERTY(int flowSolarToBattery READ flowSolarToBattery NOTIFY flowSolarToBatteryChanged)
    Q_PROPERTY(int flowSolarToConsumers READ flowSolarToConsumers NOTIFY flowSolarToConsumersChanged)
    Q_PROPERTY(int flowGridToConsumers READ flowGridToConsumers NOTIFY flowGridToConsumersChanged)
    Q_PROPERTY(int flowGridToBattery READ flowGridToBattery NOTIFY flowGridToBatteryChanged)
    Q_PROPERTY(int flowBatteryToConsumers READ flowBatteryToConsumers NOTIFY flowBatteryToConsumersChanged)

public:
    explicit DashboardDataProvider(QObject *parent = nullptr);

    Engine *engine() const;
    void setEngine(Engine *engine);

    Thing *rootMeter() const;
    void setRootMeter(Thing *rootMeter);

    int currentPowerRootMeter() const;
    int currentPowerProduction() const;
    int currentPowerBatteries() const;
    int currentPowerMeteredConsumption() const;
    int currentPowerUnmeteredConsumption() const;
    int currentPowerTotalConsumption() const;
    double totalBatteryLevel() const;

    double selfSufficiencyRate() const;
    double selfConsumptionRate() const;
    bool kpiValid() const;

    bool fetchingKpiSeries() const;
    Q_INVOKABLE void fetchKpiSeries(const QVariantList &periods);
    int flowSolarToGrid() const;
    int flowSolarToBattery() const;
    int flowSolarToConsumers() const;
    int flowGridToConsumers() const;
    int flowGridToBattery() const;
    int flowBatteryToConsumers() const;

signals:
    void engineChanged();
    void rootMeterChanged();
    void currentPowerRootMeterChanged(int currentPowerRootMeter);
    void currentPowerProductionChanged(int currentPowerProduction);
    void currentPowerBatteriesChanged(int currentPowerBatteries);
    void currentPowerMeteredConsumptionChanged(int currentPowerMeteredConsumption);
    void currentPowerUnmeteredConsumptionChanged(int currentPowerUnmeteredConsumption);
    void currentPowerTotalConsumptionChanged(int currentPowerTotalConsumption);
    void totalBatteryLevelChanged(double totalBatteryLevel);

    void selfSufficiencyRateChanged(double selfSufficiencyRate);
    void selfConsumptionRateChanged(double selfConsumptionRate);
    void kpiValidChanged(bool kpiValid);

    void fetchingKpiSeriesChanged(bool fetchingKpiSeries);
    void kpiBarResult(int barIndex, double selfSufficiency, double selfConsumption, bool valid);
    void flowSolarToGridChanged(int flowSolarToGrid);
    void flowSolarToBatteryChanged(int flowSolarToBattery);
    void flowSolarToConsumersChanged(int flowSolarToConsumers);
    void flowGridToConsumersChanged(int flowGridToConsumers);
    void flowGridToBatteryChanged(int flowGridToBattery);
    void flowBatteryToConsumersChanged(int flowBatteryToConsumers);

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
    void updateEnergyFlow();

    void fetchEnergyKPIs();

    Q_INVOKABLE void getEnergyKPIsResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void kpiSeriesBarResponse(int commandId, const QVariantMap &data);

private:
    QPointer<Engine> m_engine = nullptr;

    QPointer<Thing> m_rootMeter = nullptr;
    QUuid m_rootMeterId;
    int m_currentPowerRootMeter = 0;
    QMetaObject::Connection m_currentPowerRootMeterConn;

    QPointer<ThingsProxy> m_producerThingsProxy = nullptr;
    QHash<Thing *, double> m_producerCurrentPowers;
    int m_currentPowerProduction = 0;

    QPointer<ThingsProxy> m_batteryThingsProxy = nullptr;
    QHash<Thing *, double> m_batteryCurrentPowers;
    int m_currentPowerBatteries = 0;
    QHash<Thing *, double> m_batteryCapacities;
    double m_totalBatteryCapacity = 0.;
    QHash<Thing *, double> m_batteryLevels;
    double m_totalBatteryLevel = 0.;

    QPointer<ThingsProxy> m_consumerThingsProxy = nullptr;
    QHash<Thing *, double> m_consumerCurrentPowers;
    int m_currentPowerMeteredConsumption = 0;

    double m_selfSufficiencyRate = 0.;
    double m_selfConsumptionRate = 0.;
    bool m_kpiValid = false;

    QTimer m_kpiRefreshTimer;

    // KPI series (time-bucketed chart data)
    QHash<int, int> m_kpiSeriesCommandToBar;
    int m_kpiSeriesTotalBars = 0;
    int m_kpiSeriesReceivedBars = 0;
    bool m_fetchingKpiSeries = false;
    int m_currentPowerUnmeteredConsumption = 0;
    int m_currentPowerTotalConsumption = 0;

    int m_flowSolarToGrid = 0;
    int m_flowSolarToBattery = 0;
    int m_flowSolarToConsumers = 0;
    int m_flowGridToConsumers = 0;
    int m_flowGridToBattery = 0;
    int m_flowBatteryToConsumers = 0;
};

#endif // DASHBOARDDATAPROVIDER_H
