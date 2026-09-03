#ifndef COSTATSKPIPROVIDER_H
#define COSTATSKPIPROVIDER_H

#include <QObject>
#include <QPointer>

#include "engine.h"

// Fetches Energy.GetEnergyKPIs for a single time period (e.g. the period
// currently selected in CoPeriodSelector) and exposes the parsed result as
// plain QML properties. Unlike CoKpiStatsProvider (which fetches a whole
// series of periods for a bar chart), this is a single-shot fetch for
// exactly one [from, to) range.
class CoStatsKpiProvider : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(bool fetching READ fetching NOTIFY fetchingChanged)
    Q_PROPERTY(bool valid READ valid NOTIFY kpisChanged)
    Q_PROPERTY(double selfSufficiencyRate READ selfSufficiencyRate NOTIFY kpisChanged)
    Q_PROPERTY(double selfConsumptionRate READ selfConsumptionRate NOTIFY kpisChanged)
    Q_PROPERTY(double totalConsumption READ totalConsumption NOTIFY kpisChanged)
    Q_PROPERTY(double totalProduction READ totalProduction NOTIFY kpisChanged)
    Q_PROPERTY(double totalAcquisition READ totalAcquisition NOTIFY kpisChanged)
    Q_PROPERTY(double totalReturn READ totalReturn NOTIFY kpisChanged)

public:
    explicit CoStatsKpiProvider(QObject *parent = nullptr);

    Engine *engine() const;
    void setEngine(Engine *engine);

    bool fetching() const;

    bool valid() const;
    double selfSufficiencyRate() const;
    double selfConsumptionRate() const;
    double totalConsumption() const;
    double totalProduction() const;
    double totalAcquisition() const;
    double totalReturn() const;

    // Fetches KPIs for [fromSecs, toSecs) (Unix timestamps, seconds). Any
    // still in-flight request from a previous call is superseded: its
    // response will be discarded when it arrives.
    Q_INVOKABLE void fetchKpis(qlonglong fromSecs, qlonglong toSecs);

signals:
    void engineChanged();
    void fetchingChanged(bool fetching);
    void kpisChanged();

private:
    Q_INVOKABLE void kpisResponse(int commandId, const QVariantMap &data);

private:
    QPointer<Engine> m_engine = nullptr;

    int m_pendingCommandId = -1;
    bool m_fetching = false;

    bool m_valid = false;
    double m_selfSufficiencyRate = 0;
    double m_selfConsumptionRate = 0;
    double m_totalConsumption = 0;
    double m_totalProduction = 0;
    double m_totalAcquisition = 0;
    double m_totalReturn = 0;
};

#endif // COSTATSKPIPROVIDER_H
