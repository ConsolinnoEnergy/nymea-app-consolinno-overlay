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

bool HeatingElementConfiguration::controllableLocalSystem() const
{
    return m_controllableLocalSystem;
}

void HeatingElementConfiguration::setControllableLocalSystem(const bool &controllableLocalSystem)
{
    m_controllableLocalSystem = controllableLocalSystem;
}

ControlConfig::OperatingMode HeatingElementConfiguration::operatingMode() const
{
    return m_operatingMode;
}

void HeatingElementConfiguration::setOperatingMode(ControlConfig::OperatingMode operatingMode)
{
    if (m_operatingMode == operatingMode)
        return;

    m_operatingMode = operatingMode;
    emit operatingModeChanged(m_operatingMode);
}

int HeatingElementConfiguration::optimizationStrategies() const
{
    return m_optimizationStrategies;
}

void HeatingElementConfiguration::setOptimizationStrategies(int optimizationStrategies)
{
    if (m_optimizationStrategies == optimizationStrategies)
        return;

    m_optimizationStrategies = optimizationStrategies;
    emit optimizationStrategiesChanged(m_optimizationStrategies);
}
