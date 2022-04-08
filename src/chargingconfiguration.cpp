#include "chargingconfiguration.h"

ChargingConfiguration::ChargingConfiguration(QObject *parent) : QObject(parent)
{

}

QUuid ChargingConfiguration::evChargerThingId() const
{
    return m_evChargerThingId;
}

void ChargingConfiguration::setEvChargerThingId(const QUuid &evChargerThingId)
{
    m_evChargerThingId = evChargerThingId;
}

bool ChargingConfiguration::optimizationEnabled() const
{
    return m_optimizationEnabled;
}

void ChargingConfiguration::setOptimizationEnabled(bool optimizationEnabled)
{
    if (m_optimizationEnabled == optimizationEnabled)
        return;

    m_optimizationEnabled = optimizationEnabled;
    emit optimizationEnabledChanged(m_optimizationEnabled);
}

QUuid ChargingConfiguration::carThingId() const
{
    return m_carThingId;
}

void ChargingConfiguration::setCarThingId(const QUuid &carThingId)
{
    if (m_carThingId == carThingId)
        return;

    m_carThingId = carThingId;
    emit carThingIdChanged(m_carThingId);
}
// This was QTime before, but QTime showed some weird behaviour, so for now we use QString and transform it if necessary
QString ChargingConfiguration::endTime() const
{
    return m_endTime;
}

void ChargingConfiguration::setEndTime(const QString &endTime)
{
    if (m_endTime == endTime)
        return;

    m_endTime = endTime;
    emit endTimeChanged(m_endTime);
}

uint ChargingConfiguration::targetPercentage() const
{
    return m_targetPercentage;
}

void ChargingConfiguration::setTargetPercentage(uint targetPercentage)
{
    if (m_targetPercentage == targetPercentage)
        return;

    m_targetPercentage = targetPercentage;
    emit targetPercentageChanged(m_targetPercentage);
}

bool ChargingConfiguration::zeroReturnPolicyEnabled() const
{
    return m_zeroReturnPolicyEnabled;
}

void ChargingConfiguration::setZeroReturnPolicyEnabled(bool zeroReturnPolicyEnabled)
{
    if (m_zeroReturnPolicyEnabled == zeroReturnPolicyEnabled)
        return;

    m_zeroReturnPolicyEnabled = zeroReturnPolicyEnabled;
    emit zeroReturnPolicyEnabledChanged(m_zeroReturnPolicyEnabled);
}



float ChargingConfiguration::necessaryEnergy() const
{
    return m_necessaryEnergy;
}

void ChargingConfiguration::setNecessaryEnergy(float necessaryEnergy)
{
    if (m_necessaryEnergy == necessaryEnergy)
        return;

    m_necessaryEnergy = necessaryEnergy;
    emit necessaryEnergyChanged(m_necessaryEnergy);
}




