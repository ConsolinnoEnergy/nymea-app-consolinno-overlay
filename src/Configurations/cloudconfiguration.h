#ifndef CLOUDCONFIGURATION_H
#define CLOUDCONFIGURATION_H

#include <QObject>

class CloudConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool cloudEnabled READ cloudEnabled WRITE setCloudEnabled NOTIFY cloudEnabledChanged)
    Q_PROPERTY(bool energyMonitoringEnabled READ energyMonitoringEnabled WRITE setEnergyMonitoringEnabled NOTIFY energyMonitoringEnabledChanged)
    Q_PROPERTY(bool researchDataEnabled READ researchDataEnabled WRITE setResearchDataEnabled NOTIFY researchDataEnabledChanged)
    Q_PROPERTY(bool mqttConnected READ mqttConnected WRITE setMqttConnected NOTIFY mqttConnectedChanged)

public:
    explicit CloudConfiguration(QObject *parent = nullptr);

    bool cloudEnabled() const;
    void setCloudEnabled(bool cloudEnabled);

    bool energyMonitoringEnabled() const;
    void setEnergyMonitoringEnabled(bool energyMonitoringEnabled);

    bool researchDataEnabled() const;
    void setResearchDataEnabled(bool researchDataEnabled);

    bool mqttConnected() const;
    void setMqttConnected(bool mqttConnected);

signals:
    void cloudEnabledChanged(bool cloudEnabled);
    void energyMonitoringEnabledChanged(bool energyMonitoringEnabled);
    void researchDataEnabledChanged(bool researchDataEnabled);
    void mqttConnectedChanged(bool mqttConnected);

private:
    bool m_cloudEnabled = false;
    bool m_energyMonitoringEnabled = false;
    bool m_researchDataEnabled = false;
    bool m_mqttConnected = false;
};

#endif // CLOUDCONFIGURATION_H
