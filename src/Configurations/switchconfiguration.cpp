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

SwitchConfiguration::OptimizationMode SwitchConfiguration::optimizationMode() const
{
    return m_optimizationMode;
}

void SwitchConfiguration::setOptimizationMode(OptimizationMode optimizationMode)
{
    if (m_optimizationMode == optimizationMode) { return; }
    m_optimizationMode = optimizationMode;
    emit optimizationModeChanged(m_optimizationMode);
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
