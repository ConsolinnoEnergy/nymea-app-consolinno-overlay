#include "whitegoodconfiguration.h"

WhiteGoodConfiguration::WhiteGoodConfiguration(QObject *parent) : QObject(parent)
{

}

QUuid WhiteGoodConfiguration::whiteGoodThingId() const
{
    return m_whiteGoodThingId;
}

void WhiteGoodConfiguration::setWhiteGoodThingId(const QUuid &whiteGoodThingId)
{
    m_whiteGoodThingId = whiteGoodThingId;
}

ControlConfig::OperatingMode WhiteGoodConfiguration::operatingMode() const
{
    return m_operatingMode;
}

void WhiteGoodConfiguration::setOperatingMode(ControlConfig::OperatingMode operatingMode)
{
    if (m_operatingMode == operatingMode)
        return;
    m_operatingMode = operatingMode;
    emit operatingModeChanged(m_operatingMode);
}

int WhiteGoodConfiguration::optimizationStrategies() const
{
    return m_optimizationStrategies;
}

void WhiteGoodConfiguration::setOptimizationStrategies(int optimizationStrategies)
{
    if (m_optimizationStrategies == optimizationStrategies)
        return;
    m_optimizationStrategies = optimizationStrategies;
    emit optimizationStrategiesChanged(m_optimizationStrategies);
}

bool WhiteGoodConfiguration::controllableLocalSystem() const
{
    return m_controllableLocalSystem;
}

void WhiteGoodConfiguration::setControllableLocalSystem(bool controllableLocalSystem)
{
    if (m_controllableLocalSystem == controllableLocalSystem)
        return;
    m_controllableLocalSystem = controllableLocalSystem;
    emit controllableLocalSystemChanged(m_controllableLocalSystem);
}

double WhiteGoodConfiguration::priceThreshold() const
{
    return m_priceThreshold;
}

void WhiteGoodConfiguration::setPriceThreshold(double priceThreshold)
{
    if (m_priceThreshold == priceThreshold)
        return;
    m_priceThreshold = priceThreshold;
    emit priceThresholdChanged(m_priceThreshold);
}

QVariant WhiteGoodConfiguration::dischargePriceThreshold() const
{
    return m_dischargePriceThreshold;
}

void WhiteGoodConfiguration::setDischargePriceThreshold(const QVariant &dischargePriceThreshold)
{
    if (m_dischargePriceThreshold == dischargePriceThreshold)
        return;
    m_dischargePriceThreshold = dischargePriceThreshold;
    emit dischargePriceThresholdChanged(m_dischargePriceThreshold);
}

QString WhiteGoodConfiguration::timeSchedule() const
{
    return m_timeSchedule;
}

void WhiteGoodConfiguration::setTimeSchedule(const QString &timeSchedule)
{
    if (m_timeSchedule == timeSchedule)
        return;
    m_timeSchedule = timeSchedule;
    emit timeScheduleChanged(m_timeSchedule);
}
