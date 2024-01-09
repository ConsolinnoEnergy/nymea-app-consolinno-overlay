#include "heatingelementconfiguration.h"

HeatingElementConfiguration::HeatingElementConfiguration(QObject *parent)
    : QObject{parent}
{

}

QUuid HeatingElementConfiguration::heatingRodThingId() const
{
    return m_heatingRodThingId;
}

void HeatingElementConfiguration::setHeatingRodThingId(const QUuid &heatingRodThingId)
{
    m_heatingRodThingId = heatingRodThingId;
}

double HeatingElementConfiguration::maxPower() const
{
    return m_maxPower;
}

void HeatingElementConfiguration::setMaxPower(const double &maxPower)
 {
     if (m_maxPower == maxPower)
         return;

     m_maxPower = maxPower;
     emit maxPowerChanged(m_maxPower);
 }
