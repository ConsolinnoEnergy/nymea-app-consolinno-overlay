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
    emit controllableLocalSystemChanged(m_controllableLocalSystem);
}


double HeatingConfiguration::maxElectricalPower() const
{
    return m_maxElectricalPower;
}

void HeatingConfiguration::setMaxElectricalPower(const double &maxElectricalPower)
{
    m_maxElectricalPower = maxElectricalPower;
    emit maxElectricalPowerChanged(m_maxElectricalPower);
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
    emit priceThresholdChanged(m_priceThreshold);
}

void HeatingConfiguration::setRelativePriceEnabled(bool relativePriceEnabled)
{
    m_relativePriceEnabled = relativePriceEnabled;
    emit relativePriceEnabledChanged(m_relativePriceEnabled);
}

HeatingConfiguration::HPOptimizationMode HeatingConfiguration::optimizationMode() const
{
    return m_optimizationMode;
}

void HeatingConfiguration::setOptimizationMode(HPOptimizationMode optimizationMode)
{
    if (m_optimizationMode == optimizationMode)
        return;

    m_optimizationMode = optimizationMode;
    emit optimizationModeChanged(m_optimizationMode);
}

void HeatingConfiguration::setMaxThermalEnergy(const double &maxThermalEnergy)
{
    if (m_maxThermalEnergy == maxThermalEnergy)
        return;

    m_maxThermalEnergy = maxThermalEnergy;
    emit maxThermalEnergyChanged(m_maxThermalEnergy);
}

double HeatingConfiguration::floorHeatingArea() const
{
    return m_floorHeatingArea;
}

void HeatingConfiguration::setFloorHeatingArea(const double &floorHeatingArea)
{
    m_floorHeatingArea = floorHeatingArea;
}

double HeatingConfiguration::pvSurplusThreshold() const
{
    return m_pvSurplusThreshold;
}

void HeatingConfiguration::setPvSurplusThreshold(double pvSurplusThreshold)
{
    if (m_pvSurplusThreshold == pvSurplusThreshold)
        return;

    m_pvSurplusThreshold = pvSurplusThreshold;
    emit pvSurplusThresholdChanged(m_pvSurplusThreshold);
}

int HeatingConfiguration::durationMinAfterTurnOn() const
{
    return m_durationMinAfterTurnOn;
}

void HeatingConfiguration::setDurationMinAfterTurnOn(int durationMinAfterTurnOn)
{
    if (m_durationMinAfterTurnOn == durationMinAfterTurnOn)
        return;

    m_durationMinAfterTurnOn = durationMinAfterTurnOn;
    emit durationMinAfterTurnOnChanged(m_durationMinAfterTurnOn);
}

double HeatingConfiguration::durationMaxTotal() const
{
    return m_durationMaxTotal;
}

void HeatingConfiguration::setDurationMaxTotal(double durationMaxTotal)
{
    if (m_durationMaxTotal == durationMaxTotal)
        return;

    m_durationMaxTotal = durationMaxTotal;
    emit durationMaxTotalChanged(m_durationMaxTotal);
}
