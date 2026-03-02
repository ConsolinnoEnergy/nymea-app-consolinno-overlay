#include "cokpistatsprovider.h"

#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcCoKpiStatsProvider, "CoKpiStatsProvider");

CoKpiStatsProvider::CoKpiStatsProvider(QObject *parent)
    : QObject{ parent }
{
}

Engine *CoKpiStatsProvider::engine() const
{
    return m_engine;
}

void CoKpiStatsProvider::setEngine(Engine *engine)
{
    if (m_engine == engine) { return; }
    m_engine = engine;
    emit engineChanged();
}

bool CoKpiStatsProvider::fetchingKpiSeries() const
{
    return m_fetchingKpiSeries;
}

void CoKpiStatsProvider::fetchKpiSeries(const QVariantList &periods)
{
    if (!m_engine || !m_engine->jsonRpcClient() || !m_engine->jsonRpcClient()->connected()) {
        qCWarning(dcCoKpiStatsProvider()) << "Cannot fetch KPI series: no engine or not connected.";
        return;
    }

    // Discard tracking for any previous in-flight series requests
    m_kpiSeriesCommandToBar.clear();
    m_kpiSeriesTotalBars = periods.count();
    m_kpiSeriesReceivedBars = 0;

    if (m_kpiSeriesTotalBars == 0) {
        if (m_fetchingKpiSeries) {
            m_fetchingKpiSeries = false;
            emit fetchingKpiSeriesChanged(m_fetchingKpiSeries);
        }
        return;
    }

    if (!m_fetchingKpiSeries) {
        m_fetchingKpiSeries = true;
        emit fetchingKpiSeriesChanged(m_fetchingKpiSeries);
    }

    for (int i = 0; i < periods.count(); ++i) {
        const QVariantMap period = periods.at(i).toMap();
        QVariantMap params;
        params.insert("from", period.value("from").toLongLong());
        if (period.contains("to")) {
            params.insert("to", period.value("to").toLongLong());
        }

        qCDebug(dcCoKpiStatsProvider()) << "KPI series bar" << i
                                        << "from:" << params.value("from").toLongLong()
                                        << "to:" << params.value("to").toLongLong();

        const int commandId = m_engine->jsonRpcClient()->sendCommand(
            "Energy.GetEnergyKPIs", params, this, "kpiSeriesBarResponse");
        m_kpiSeriesCommandToBar.insert(commandId, i);
    }
}

void CoKpiStatsProvider::kpiSeriesBarResponse(int commandId, const QVariantMap &data)
{
    if (!m_kpiSeriesCommandToBar.contains(commandId)) {
        // Stale response from a previous (cancelled) series fetch
        return;
    }

    const int barIndex = m_kpiSeriesCommandToBar.take(commandId);
    m_kpiSeriesReceivedBars++;

    double selfSufficiency = 0;
    double selfConsumption = 0;
    bool valid = false;

    if (!data.contains("error") && !data.contains("energyError")
        && data.contains("selfSufficiencyRate") && data.contains("selfConsumptionRate")) {
        valid = data.value("valid").toBool();
        selfSufficiency = data.value("selfSufficiencyRate").toDouble();
        selfConsumption = data.value("selfConsumptionRate").toDouble();
    } else {
        qCWarning(dcCoKpiStatsProvider()) << "KPI series bar" << barIndex
                                          << "request failed or missing fields:"
                                          << data;
    }

    qCDebug(dcCoKpiStatsProvider()) << "KPI series bar" << barIndex
                                    << "-> selfSufficiency:" << selfSufficiency
                                    << "selfConsumption:" << selfConsumption
                                    << "valid:" << valid;

    emit kpiBarResult(barIndex, selfSufficiency, selfConsumption, valid);

    if (m_kpiSeriesReceivedBars >= m_kpiSeriesTotalBars) {
        m_fetchingKpiSeries = false;
        emit fetchingKpiSeriesChanged(m_fetchingKpiSeries);
    }
}
