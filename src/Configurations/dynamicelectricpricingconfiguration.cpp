#include "dynamicelectricpricingconfiguration.h"

DynamicElectricPricingConfiguration::DynamicElectricPricingConfiguration(QObject *parent) : QObject(parent)
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
    if (m_optimizationEnabled == optimizationEnabled)
        return;

    m_optimizationEnabled = optimizationEnabled;
    emit optimizationEnabledChanged(m_optimizationEnabled);
}

double DynamicElectricPricingConfiguration::maxElectricalPower() const
{
    return m_maxElectricalPower;
}

void DynamicElectricPricingConfiguration::setMaxElectricalPower(double maxElectricalPower)
{
    m_maxElectricalPower = maxElectricalPower;
}
