#include "heatingelementconfiguration.h"

HeatingElementConfiguration::HeatingElementConfiguration(QObject *parent)
    : QObject{parent}
{

}

QUuid HeatingElementConfiguration::heatingRodThingId() const
{
    return m_heatingRodThingId;
}

void HeatingElementConfiguration::setHeatingRodThingId(const QUuid &heatingRodThingId)
{
    m_heatingRodThingId = heatingRodThingId;
}

double HeatingElementConfiguration::maxElectricalPower() const
{
    return m_maxElectricalPower;
}

void HeatingElementConfiguration::setMaxElectricalPower(const double &maxElectricalPower)
{
     if (m_maxElectricalPower == maxElectricalPower)
         return;

     m_maxElectricalPower = maxElectricalPower;
     emit maxElectricalPowerChanged(m_maxElectricalPower);
}

bool HeatingElementConfiguration::optimizationEnabled() const
{
    return m_optimizationEnabled;
}

bool HeatingElementConfiguration::controllableLocalSystem() const
{
    return m_controllableLocalSystem;
}

void HeatingElementConfiguration::setControllableLocalSystem(const bool &controllableLocalSystem)
{
    m_controllableLocalSystem = controllableLocalSystem;
}

void HeatingElementConfiguration::setOptimizationEnabled(const bool &optimizationEnabled)
{
     if (m_optimizationEnabled == optimizationEnabled)
         return;

     m_optimizationEnabled = optimizationEnabled;
     emit optimizationEnabledChanged(m_optimizationEnabled);
}
