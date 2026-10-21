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

ControlConfig::OperatingMode HeatingConfiguration::operatingMode() const
{
    return m_operatingMode;
}

void HeatingConfiguration::setOperatingMode(ControlConfig::OperatingMode operatingMode)
{
    if (m_operatingMode == operatingMode)
        return;

    m_operatingMode = operatingMode;
    emit operatingModeChanged(m_operatingMode);
}

int HeatingConfiguration::optimizationStrategies() const
{
    return m_optimizationStrategies;
}

void HeatingConfiguration::setOptimizationStrategies(int optimizationStrategies)
{
    if (m_optimizationStrategies == optimizationStrategies)
        return;

    m_optimizationStrategies = optimizationStrategies;
    emit optimizationStrategiesChanged(m_optimizationStrategies);
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

uint HeatingConfiguration::durationMinDwell() const
{
    return m_durationMinDwell;
}

void HeatingConfiguration::setDurationMinDwell(uint durationMinDwell)
{
    if (m_durationMinDwell == durationMinDwell)
        return;

    m_durationMinDwell = durationMinDwell;
    emit durationMinDwellChanged(m_durationMinDwell);
}

double HeatingConfiguration::meanSgr2() const
{
    return m_meanSgr2;
}

void HeatingConfiguration::setMeanSgr2(double meanSgr2)
{
    if (m_meanSgr2 == meanSgr2)
        return;

    m_meanSgr2 = meanSgr2;
    emit meanSgr2Changed(m_meanSgr2);
}

double HeatingConfiguration::meanSgr3() const
{
    return m_meanSgr3;
}

void HeatingConfiguration::setMeanSgr3(double meanSgr3)
{
    if (m_meanSgr3 == meanSgr3)
        return;

    m_meanSgr3 = meanSgr3;
    emit meanSgr3Changed(m_meanSgr3);
}

uint HeatingConfiguration::sgReadyState() const
{
    return m_sgReadyState;
}

void HeatingConfiguration::setSgReadyState(uint sgReadyState)
{
    if (m_sgReadyState == sgReadyState) {
        return;
    }

    m_sgReadyState = sgReadyState;
    emit sgReadyStateChanged(m_sgReadyState);
}
