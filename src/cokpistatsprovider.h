#ifndef COKPISTATSPROVIDER_H
#define COKPISTATSPROVIDER_H

#include <QObject>
#include <QHash>
#include <QPointer>

#include "engine.h"

class CoKpiStatsProvider : public QObject
{
    Q_OBJECT

    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(bool fetchingKpiSeries READ fetchingKpiSeries NOTIFY fetchingKpiSeriesChanged)

public:
    explicit CoKpiStatsProvider(QObject *parent = nullptr);

    Engine *engine() const;
    void setEngine(Engine *engine);

    bool fetchingKpiSeries() const;
    Q_INVOKABLE void fetchKpiSeries(const QVariantList &periods);

signals:
    void engineChanged();
    void fetchingKpiSeriesChanged(bool fetchingKpiSeries);
    void kpiBarResult(int barIndex, double selfSufficiency, double selfConsumption, bool valid);

private:
    Q_INVOKABLE void kpiSeriesBarResponse(int commandId, const QVariantMap &data);

private:
    QPointer<Engine> m_engine = nullptr;

    QHash<int, int> m_kpiSeriesCommandToBar;
    int m_kpiSeriesTotalBars = 0;
    int m_kpiSeriesReceivedBars = 0;
    bool m_fetchingKpiSeries = false;
};

#endif // COKPISTATSPROVIDER_H
