#include "dynamicelectricpricingconfiguration.h"

DynamicElectricPricingConfiguration::DynamicElectricPricingConfiguration()
{

}

QUuid DynamicElectricPricingConfiguration::dynamicElectricPricingThingID() const
{
    return m_dynamicElectricPricingThingID;
}

void DynamicElectricPricingConfiguration::setDynamicElectricPricingThingID(const QUuid &dynamicElectricPricingThingID)
{
    m_dynamicElectricPricingThingID = dynamicElectricPricingThingID;
}

bool DynamicElectricPricingConfiguration::optimizationEnabled() const
{
    return m_optimizationEnabled;
}

void DynamicElectricPricingConfiguration::setOptimizationEnabled(bool optimizationEnabled)
{
    m_optimizationEnabled = optimizationEnabled;
}

double DynamicElectricPricingConfiguration::maxElectricalPower() const
{
    return m_maxElectricalPower;
}

void DynamicElectricPricingConfiguration::setMaxElectricalPower(double maxElectricalPower)
{
    m_maxElectricalPower = maxElectricalPower;
}
