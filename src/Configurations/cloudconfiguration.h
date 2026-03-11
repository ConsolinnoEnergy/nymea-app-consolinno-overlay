#ifndef CLOUDCONFIGURATION_H
#define CLOUDCONFIGURATION_H

#include <QObject>

class CloudConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool cloudEnabled READ cloudEnabled WRITE setCloudEnabled NOTIFY cloudEnabledChanged)
    Q_PROPERTY(bool energyMonitoringEnabled READ energyMonitoringEnabled WRITE setEnergyMonitoringEnabled NOTIFY energyMonitoringEnabledChanged)
    Q_PROPERTY(bool researchDataEnabled READ researchDataEnabled WRITE setResearchDataEnabled NOTIFY researchDataEnabledChanged)

public:
    explicit CloudConfiguration(QObject *parent = nullptr);

    bool cloudEnabled() const;
    void setCloudEnabled(bool cloudEnabled);

    bool energyMonitoringEnabled() const;
    void setEnergyMonitoringEnabled(bool energyMonitoringEnabled);

    bool researchDataEnabled() const;
    void setResearchDataEnabled(bool researchDataEnabled);

signals:
    void cloudEnabledChanged(bool cloudEnabled);
    void energyMonitoringEnabledChanged(bool energyMonitoringEnabled);
    void researchDataEnabledChanged(bool researchDataEnabled);

private:
    bool m_cloudEnabled = false;
    bool m_energyMonitoringEnabled = false;
    bool m_researchDataEnabled = false;
};

#endif // CLOUDCONFIGURATION_H
