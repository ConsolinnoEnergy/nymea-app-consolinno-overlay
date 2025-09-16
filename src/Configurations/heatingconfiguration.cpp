#include "heatingconfiguration.h"

HeatingConfiguration::HeatingConfiguration(QObject *parent) : QObject(parent)
{

}

QUuid HeatingConfiguration::heatPumpThingId() const
{
    return m_heatPumpThingId;
}

void HeatingConfiguration::setHeatPumpThingId(const QUuid &heatPumpThingId)
{
    m_heatPumpThingId = heatPumpThingId;
}

bool HeatingConfiguration::optimizationEnabled() const
{
    return m_optimizationEnabled;
}

void HeatingConfiguration::setOptimizationEnabled(bool optimizationEnabled)
{
    if (m_optimizationEnabled == optimizationEnabled)
        return;

    m_optimizationEnabled = optimizationEnabled;
    emit optimizationEnabledChanged(m_optimizationEnabled);
}

QUuid HeatingConfiguration::heatMeterThingId() const
{
    return m_heatMeterThingId;
}

void HeatingConfiguration::setHeatMeterThingId(const QUuid &heatMeterThingId)
{
    if (m_heatMeterThingId == heatMeterThingId)
        return;

    m_heatMeterThingId = heatMeterThingId;
    emit heatMeterThingIdChanged(m_heatMeterThingId);
}

bool HeatingConfiguration::controllableLocalSystem() const
{
    return m_controllableLocalSystem;
}

void HeatingConfiguration::setControllableLocalSystem(bool controllableLocalSystem)
{
    m_controllableLocalSystem = controllableLocalSystem;
}


double HeatingConfiguration::maxElectricalPower() const
{
    return m_maxElectricalPower;
}

void HeatingConfiguration::setMaxElectricalPower(const double &maxElectricalPower)
{
    m_maxElectricalPower = maxElectricalPower;
}

double HeatingConfiguration::maxThermalEnergy() const
{
    return m_maxThermalEnergy;
}

double HeatingConfiguration::priceThreshold() const
{
    return m_priceThreshold;
}

bool HeatingConfiguration::relativePriceEnabled() const
{
    return m_relativePriceEnabled;
}

void HeatingConfiguration::setPriceThreshold(double priceThreshold)
{
    m_priceThreshold = priceThreshold;
}

void HeatingConfiguration::setRelativePriceEnabled(bool relativePriceEnabled)
{
    m_relativePriceEnabled = relativePriceEnabled;
}

HeatingConfiguration::HPOptimizationMode HeatingConfiguration::optimizationMode() const
{
    return m_optimizationMode;
}

void HeatingConfiguration::setOptimizationMode(HPOptimizationMode optimizationMode)
{
    m_optimizationMode = optimizationMode;
}

void HeatingConfiguration::setMaxThermalEnergy(const double &maxThermalEnergy)
{
    m_maxThermalEnergy = maxThermalEnergy;
}

double HeatingConfiguration::floorHeatingArea() const
{
    return m_floorHeatingArea;
}

void HeatingConfiguration::setFloorHeatingArea(const double &floorHeatingArea)
{
    m_floorHeatingArea = floorHeatingArea;
}
