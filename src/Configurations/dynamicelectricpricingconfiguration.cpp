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

