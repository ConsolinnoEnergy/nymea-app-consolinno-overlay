#include "chargingoptimizationconfiguration.h"

ChargingOptimizationConfiguration::ChargingOptimizationConfiguration(QObject *parent) : QObject(parent)
{

}

QUuid ChargingOptimizationConfiguration::evChargerThingId() const
{
    return m_evChargerThingId;
}

void ChargingOptimizationConfiguration::setEvChargerThingId(const QUuid &evChargerThingId)
{
    m_evChargerThingId = evChargerThingId;
}

bool ChargingOptimizationConfiguration::reenableChargepoint() const
{
    return m_reenableChargepoint;
}

void ChargingOptimizationConfiguration::setReenableChargepoint(const bool reenableChargepoint)
{
    m_reenableChargepoint = reenableChargepoint;
}
