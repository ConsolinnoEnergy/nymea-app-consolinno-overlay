#include "switchconfiguration.h"

SwitchConfiguration::SwitchConfiguration(QObject *parent) : QObject(parent)
{
}

QUuid SwitchConfiguration::switchThingId() const
{
    return m_switchThingId;
}

void SwitchConfiguration::setSwitchThingId(const QUuid &switchThingId)
{
    m_switchThingId = switchThingId;
}

ControlConfig::OperatingMode SwitchConfiguration::operatingMode() const
{
    return m_operatingMode;
}

void SwitchConfiguration::setOperatingMode(ControlConfig::OperatingMode operatingMode)
{
    if (m_operatingMode == operatingMode) { return; }
    m_operatingMode = operatingMode;
    emit operatingModeChanged(m_operatingMode);
}

int SwitchConfiguration::optimizationStrategies() const
{
    return m_optimizationStrategies;
}

void SwitchConfiguration::setOptimizationStrategies(int optimizationStrategies)
{
    if (m_optimizationStrategies == optimizationStrategies) { return; }
    m_optimizationStrategies = optimizationStrategies;
    emit optimizationStrategiesChanged(m_optimizationStrategies);
}

bool SwitchConfiguration::manualEnabled() const
{
    return m_manualEnabled;
}

void SwitchConfiguration::setManualEnabled(bool manualEnabled)
{
    if (m_manualEnabled == manualEnabled) { return; }
    m_manualEnabled = manualEnabled;
    emit manualEnabledChanged(m_manualEnabled);
}

double SwitchConfiguration::maxElectricalPower() const
{
    return m_maxElectricalPower;
}

void SwitchConfiguration::setMaxElectricalPower(double maxElectricalPower)
{
    if (m_maxElectricalPower == maxElectricalPower) { return; }
    m_maxElectricalPower = maxElectricalPower;
    emit maxElectricalPowerChanged(m_maxElectricalPower);
}

double SwitchConfiguration::pvSurplusThreshold() const
{
    return m_pvSurplusThreshold;
}

void SwitchConfiguration::setPvSurplusThreshold(double pvSurplusThreshold)
{
    if (m_pvSurplusThreshold == pvSurplusThreshold) { return; }
    m_pvSurplusThreshold = pvSurplusThreshold;
    emit pvSurplusThresholdChanged(m_pvSurplusThreshold);
}

double SwitchConfiguration::durationMinAfterTurnOn() const
{
    return m_durationMinAfterTurnOn;
}

void SwitchConfiguration::setDurationMinAfterTurnOn(double durationMinAfterTurnOn)
{
    if (m_durationMinAfterTurnOn == durationMinAfterTurnOn) { return; }
    m_durationMinAfterTurnOn = durationMinAfterTurnOn;
    emit durationMinAfterTurnOnChanged(m_durationMinAfterTurnOn);
}

double SwitchConfiguration::durationMaxTotal() const
{
    return m_durationMaxTotal;
}

void SwitchConfiguration::setDurationMaxTotal(double durationMaxTotal)
{
    if (m_durationMaxTotal == durationMaxTotal) { return; }
    m_durationMaxTotal = durationMaxTotal;
    emit durationMaxTotalChanged(m_durationMaxTotal);
}

bool SwitchConfiguration::controllableLocalSystem() const
{
    return m_controllableLocalSystem;
}

void SwitchConfiguration::setControllableLocalSystem(bool controllableLocalSystem)
{
    if (m_controllableLocalSystem == controllableLocalSystem) { return; }
    m_controllableLocalSystem = controllableLocalSystem;
    emit controllableLocalSystemChanged(m_controllableLocalSystem);
}
