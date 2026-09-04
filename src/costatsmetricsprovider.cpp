#include "costatsmetricsprovider.h"

#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcCoStatsMetricsProvider, "CoStatsMetricsProvider");

CoStatsMetricsProvider::CoStatsMetricsProvider(QObject *parent)
    : QObject{ parent }
{
}

Engine *CoStatsMetricsProvider::engine() const
{
    return m_engine;
}

void CoStatsMetricsProvider::setEngine(Engine *engine)
{
    if (m_engine == engine) { return; }
    m_engine = engine;
    emit engineChanged();
}

bool CoStatsMetricsProvider::fetching() const
{
    return m_fetching;
}

bool CoStatsMetricsProvider::valid() const
{
    return m_valid;
}

double CoStatsMetricsProvider::selfSufficiencyRate() const
{
    return m_selfSufficiencyRate;
}

double CoStatsMetricsProvider::selfConsumptionRate() const
{
    return m_selfConsumptionRate;
}

double CoStatsMetricsProvider::totalConsumption() const
{
    return m_totalConsumption;
}

double CoStatsMetricsProvider::totalProduction() const
{
    return m_totalProduction;
}

double CoStatsMetricsProvider::totalAcquisition() const
{
    return m_totalAcquisition;
}

double CoStatsMetricsProvider::totalReturn() const
{
    return m_totalReturn;
}

void CoStatsMetricsProvider::fetchKpis(qlonglong fromSecs, qlonglong toSecs)
{
    if (!m_engine || !m_engine->jsonRpcClient()) {
        qCWarning(dcCoStatsMetricsProvider()) << "Cannot fetch KPIs: no engine or JSON-RPC client";
        return;
    }

    if (!m_engine->jsonRpcClient()->connected()) {
        qCDebug(dcCoStatsMetricsProvider()) << "Cannot fetch KPIs: not connected.";
        return;
    }

    QVariantMap params;
    params.insert("from", fromSecs);
    params.insert("to", toSecs);

    qCDebug(dcCoStatsMetricsProvider()) << "Fetching KPIs from:" << fromSecs << "to:" << toSecs;

    if (!m_fetching) {
        m_fetching = true;
        emit fetchingChanged(m_fetching);
    }

    m_pendingCommandId = m_engine->jsonRpcClient()->sendCommand(
        "Energy.GetEnergyKPIs", params, this, "kpisResponse");
}

void CoStatsMetricsProvider::kpisResponse(int commandId, const QVariantMap &data)
{
    if (commandId != m_pendingCommandId) {
        // Stale response from a previous (superseded) fetch
        return;
    }
    m_pendingCommandId = -1;

    if (m_fetching) {
        m_fetching = false;
        emit fetchingChanged(m_fetching);
    }

    if (data.contains("error") || data.contains("energyError")) {
        qCWarning(dcCoStatsMetricsProvider()) << "KPIs request failed:"
                                          << data.value("error").toString()
                                          << data.value("energyError").toString();
        return;
    }

    if (!data.contains("selfSufficiencyRate") || !data.contains("selfConsumptionRate")) {
        if (data.isEmpty()) {
            // Empty response means "No such method" — backend does not support this API yet (version mismatch)
            qCDebug(dcCoStatsMetricsProvider()) << "KPIs not supported by this backend (empty response).";
        } else {
            qCWarning(dcCoStatsMetricsProvider()) << "KPIs response missing expected fields. Keys:" << data.keys();
        }
        return;
    }

    m_valid = data.value("valid").toBool();
    m_selfSufficiencyRate = data.value("selfSufficiencyRate").toDouble();
    m_selfConsumptionRate = data.value("selfConsumptionRate").toDouble();
    m_totalConsumption = data.value("totalConsumption").toDouble();
    m_totalProduction = data.value("totalProduction").toDouble();
    m_totalAcquisition = data.value("totalAcquisition").toDouble();
    m_totalReturn = data.value("totalReturn").toDouble();

    qCDebug(dcCoStatsMetricsProvider()) << "KPIs parsed -> valid:" << m_valid
                                    << "selfSufficiency:" << m_selfSufficiencyRate << "%"
                                    << "selfConsumption:" << m_selfConsumptionRate << "%"
                                    << "totalAcquisition:" << m_totalAcquisition
                                    << "totalReturn:" << m_totalReturn;

    emit kpisChanged();
}
