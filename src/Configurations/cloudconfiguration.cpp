#include "cloudconfiguration.h"

CloudConfiguration::CloudConfiguration(QObject *parent) : QObject(parent)
{
}

bool CloudConfiguration::cloudEnabled() const
{
    return m_cloudEnabled;
}

void CloudConfiguration::setCloudEnabled(bool cloudEnabled)
{
    if (m_cloudEnabled == cloudEnabled)
        return;
    m_cloudEnabled = cloudEnabled;
    emit cloudEnabledChanged(m_cloudEnabled);
}

bool CloudConfiguration::energyMonitoringEnabled() const
{
    return m_energyMonitoringEnabled;
}

void CloudConfiguration::setEnergyMonitoringEnabled(bool energyMonitoringEnabled)
{
    if (m_energyMonitoringEnabled == energyMonitoringEnabled)
        return;
    m_energyMonitoringEnabled = energyMonitoringEnabled;
    emit energyMonitoringEnabledChanged(m_energyMonitoringEnabled);
}

bool CloudConfiguration::researchDataEnabled() const
{
    return m_researchDataEnabled;
}

void CloudConfiguration::setResearchDataEnabled(bool researchDataEnabled)
{
    if (m_researchDataEnabled == researchDataEnabled)
        return;
    m_researchDataEnabled = researchDataEnabled;
    emit researchDataEnabledChanged(m_researchDataEnabled);
}

bool CloudConfiguration::mqttConnected() const
{
    return m_mqttConnected;
}

void CloudConfiguration::setMqttConnected(bool mqttConnected)
{
    if (m_mqttConnected == mqttConnected)
        return;
    m_mqttConnected = mqttConnected;
    emit mqttConnectedChanged(m_mqttConnected);
}
