#include "selfconsumptionconfiguration.h"

SelfConsumptionConfiguration::SelfConsumptionConfiguration(QObject *parent) : QObject(parent)
{

}

bool SelfConsumptionConfiguration::selfConsumptionEnabled() const
{
    return m_selfConsumptionEnabled;
}

void SelfConsumptionConfiguration::setSelfConsumptionEnabled(bool selfConsumptionEnabled)
{
    if (m_selfConsumptionEnabled == selfConsumptionEnabled)
        return;

    m_selfConsumptionEnabled = selfConsumptionEnabled;
    emit selfConsumptionEnabledChanged(m_selfConsumptionEnabled);
}

int SelfConsumptionConfiguration::selfConsumptionTargetPower() const
{
    return m_selfConsumptionTargetPower;
}

void SelfConsumptionConfiguration::setSelfConsumptionTargetPower(int selfConsumptionTargetPower)
{
    if (m_selfConsumptionTargetPower == selfConsumptionTargetPower)
        return;

    m_selfConsumptionTargetPower = selfConsumptionTargetPower;
    emit selfConsumptionTargetPowerChanged(m_selfConsumptionTargetPower);
}

float SelfConsumptionConfiguration::selfConsumptionKp() const
{
    return m_selfConsumptionKp;
}

void SelfConsumptionConfiguration::setSelfConsumptionKp(float selfConsumptionKp)
{
    if (qFuzzyCompare(m_selfConsumptionKp, selfConsumptionKp))
        return;

    m_selfConsumptionKp = selfConsumptionKp;
    emit selfConsumptionKpChanged(m_selfConsumptionKp);
}

float SelfConsumptionConfiguration::selfConsumptionKi() const
{
    return m_selfConsumptionKi;
}

void SelfConsumptionConfiguration::setSelfConsumptionKi(float selfConsumptionKi)
{
    if (qFuzzyCompare(m_selfConsumptionKi, selfConsumptionKi))
        return;

    m_selfConsumptionKi = selfConsumptionKi;
    emit selfConsumptionKiChanged(m_selfConsumptionKi);
}

float SelfConsumptionConfiguration::selfConsumptionKd() const
{
    return m_selfConsumptionKd;
}

void SelfConsumptionConfiguration::setSelfConsumptionKd(float selfConsumptionKd)
{
    if (qFuzzyCompare(m_selfConsumptionKd, selfConsumptionKd))
        return;

    m_selfConsumptionKd = selfConsumptionKd;
    emit selfConsumptionKdChanged(m_selfConsumptionKd);
}
