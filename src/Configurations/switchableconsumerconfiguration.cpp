#include "switchableconsumerconfiguration.h"

SwitchableConsumerConfiguration::SwitchableConsumerConfiguration(QObject *parent) : QObject(parent)
{
}

QUuid SwitchableConsumerConfiguration::switchableConsumerThingId() const
{
    return m_switchableConsumerThingId;
}

void SwitchableConsumerConfiguration::setSwitchableConsumerThingId(const QUuid &switchableConsumerThingId)
{
    m_switchableConsumerThingId = switchableConsumerThingId;
}

SwitchableConsumerConfiguration::OptimizationMode SwitchableConsumerConfiguration::optimizationMode() const
{
    return m_optimizationMode;
}

void SwitchableConsumerConfiguration::setOptimizationMode(OptimizationMode optimizationMode)
{
    if (m_optimizationMode == optimizationMode) { return; }
    m_optimizationMode = optimizationMode;
    emit optimizationModeChanged(m_optimizationMode);
}

double SwitchableConsumerConfiguration::maxElectricalPower() const
{
    return m_maxElectricalPower;
}

void SwitchableConsumerConfiguration::setMaxElectricalPower(double maxElectricalPower)
{
    if (m_maxElectricalPower == maxElectricalPower) { return; }
    m_maxElectricalPower = maxElectricalPower;
    emit maxElectricalPowerChanged(m_maxElectricalPower);
}

double SwitchableConsumerConfiguration::pvSurplusThreshold() const
{
    return m_pvSurplusThreshold;
}

void SwitchableConsumerConfiguration::setPvSurplusThreshold(double pvSurplusThreshold)
{
    if (m_pvSurplusThreshold == pvSurplusThreshold) { return; }
    m_pvSurplusThreshold = pvSurplusThreshold;
    emit pvSurplusThresholdChanged(m_pvSurplusThreshold);
}

double SwitchableConsumerConfiguration::durationMinAfterTurnOn() const
{
    return m_durationMinAfterTurnOn;
}

void SwitchableConsumerConfiguration::setDurationMinAfterTurnOn(double durationMinAfterTurnOn)
{
    if (m_durationMinAfterTurnOn == durationMinAfterTurnOn) { return; }
    m_durationMinAfterTurnOn = durationMinAfterTurnOn;
    emit durationMinAfterTurnOnChanged(m_durationMinAfterTurnOn);
}

double SwitchableConsumerConfiguration::durationMaxTotal() const
{
    return m_durationMaxTotal;
}

void SwitchableConsumerConfiguration::setDurationMaxTotal(double durationMaxTotal)
{
    if (m_durationMaxTotal == durationMaxTotal) { return; }
    m_durationMaxTotal = durationMaxTotal;
    emit durationMaxTotalChanged(m_durationMaxTotal);
}

bool SwitchableConsumerConfiguration::controllableLocalSystem() const
{
    return m_controllableLocalSystem;
}

void SwitchableConsumerConfiguration::setControllableLocalSystem(bool controllableLocalSystem)
{
    if (m_controllableLocalSystem == controllableLocalSystem) { return; }
    m_controllableLocalSystem = controllableLocalSystem;
    emit controllableLocalSystemChanged(m_controllableLocalSystem);
}
