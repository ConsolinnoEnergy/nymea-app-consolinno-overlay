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

float ChargingOptimizationConfiguration::p_value() const
{
    return m_p_value;
}

void ChargingOptimizationConfiguration::setP_value(const float p_value)
{
    m_p_value = p_value;
}

float ChargingOptimizationConfiguration::i_value() const
{
    return m_i_value;
}

void ChargingOptimizationConfiguration::setI_value(const float i_value)
{
    m_i_value = i_value;
}

float ChargingOptimizationConfiguration::d_value() const
{
    return m_d_value;
}

void ChargingOptimizationConfiguration::setD_value(const float d_value)
{
    m_d_value = d_value;
}

float ChargingOptimizationConfiguration::setpoint() const
{
    return m_setpoint;
}

void ChargingOptimizationConfiguration::setSetpoint(const float setpoint)
{
    m_setpoint = setpoint;
}
