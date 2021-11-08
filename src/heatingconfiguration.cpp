#include "heatingconfiguration.h"

HeatingConfiguration::HeatingConfiguration(QObject *parent) : QObject(parent)
{

}

QUuid HeatingConfiguration::heatPumpThingId() const
{
    return m_heatPumpThingId;
}

void HeatingConfiguration::setHeatPumpThingId(const QUuid &heatPumpThingId)
{
    m_heatPumpThingId = heatPumpThingId;
}

bool HeatingConfiguration::optimizationEnabled() const
{
    return m_optimizationEnabled;
}

void HeatingConfiguration::setOptimizationEnabled(bool optimizationEnabled)
{
    if (m_optimizationEnabled == optimizationEnabled)
        return;

    m_optimizationEnabled = optimizationEnabled;
    emit optimizationEnabledChanged(m_optimizationEnabled);
}

QUuid HeatingConfiguration::heatMeterThingId() const
{
    return m_heatMeterThingId;
}

void HeatingConfiguration::setHeatMeterThingId(const QUuid &heatMeterThingId)
{
    if (m_heatMeterThingId == heatMeterThingId)
        return;

    m_heatMeterThingId = heatMeterThingId;
    emit heatMeterThingIdChanged(m_heatMeterThingId);
}
