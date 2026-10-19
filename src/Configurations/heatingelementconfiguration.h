#ifndef HEATINGELEMENTCONFIGURATION_H
#define HEATINGELEMENTCONFIGURATION_H

#include <QUuid>
#include <QObject>

#include "controlconfigurationenums.h"

class HeatingElementConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid heatingRodThingId READ heatingRodThingId CONSTANT)
    Q_PROPERTY(double maxElectricalPower READ maxElectricalPower WRITE setMaxElectricalPower NOTIFY maxElectricalPowerChanged)
    Q_PROPERTY(ControlConfig::OperatingMode operatingMode READ operatingMode WRITE setOperatingMode NOTIFY operatingModeChanged)
    Q_PROPERTY(int optimizationStrategies READ optimizationStrategies WRITE setOptimizationStrategies NOTIFY optimizationStrategiesChanged)
    Q_PROPERTY(bool controllableLocalSystem READ controllableLocalSystem WRITE setControllableLocalSystem NOTIFY controllableLocalSystemChanged)

public:
    explicit HeatingElementConfiguration(QObject *parent = nullptr);

    QUuid heatingRodThingId() const;
    void setHeatingRodThingId(const QUuid &heatingRodThingId);

    double maxElectricalPower() const;
    void setMaxElectricalPower(const double &maxElectricalPower);

    ControlConfig::OperatingMode operatingMode() const;
    void setOperatingMode(ControlConfig::OperatingMode operatingMode);

    int optimizationStrategies() const;
    void setOptimizationStrategies(int optimizationStrategies);

    bool controllableLocalSystem() const;
    void setControllableLocalSystem(const bool &controllableLocalSystem);

private:
    QUuid m_heatingRodThingId;
    double m_maxElectricalPower = 0;
    ControlConfig::OperatingMode m_operatingMode = ControlConfig::NoControl;
    int m_optimizationStrategies = ControlConfig::NoStrategy;
    bool m_controllableLocalSystem = false;

signals:
    void maxElectricalPowerChanged(const double maxElectricalPower);
    void operatingModeChanged(ControlConfig::OperatingMode operatingMode);
    void optimizationStrategiesChanged(int optimizationStrategies);
    void controllableLocalSystemChanged(const bool &controllableLocalSystem);

};

#endif // HeatingElementConfiguration_H
