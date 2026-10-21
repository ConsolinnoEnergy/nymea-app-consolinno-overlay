#ifndef SWITCHCONFIGURATION_H
#define SWITCHCONFIGURATION_H

#include <QDebug>
#include <QObject>
#include <QUuid>

#include "controlconfigurationenums.h"

class SwitchConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid switchThingId READ switchThingId CONSTANT)
    Q_PROPERTY(ControlConfig::OperatingMode operatingMode READ operatingMode WRITE setOperatingMode NOTIFY operatingModeChanged)
    Q_PROPERTY(int optimizationStrategies READ optimizationStrategies WRITE setOptimizationStrategies NOTIFY optimizationStrategiesChanged)
    Q_PROPERTY(bool manualEnabled READ manualEnabled WRITE setManualEnabled NOTIFY manualEnabledChanged)
    Q_PROPERTY(double maxElectricalPower READ maxElectricalPower WRITE setMaxElectricalPower NOTIFY maxElectricalPowerChanged)
    Q_PROPERTY(double pvSurplusThreshold READ pvSurplusThreshold WRITE setPvSurplusThreshold NOTIFY pvSurplusThresholdChanged)
    Q_PROPERTY(double durationMinAfterTurnOn READ durationMinAfterTurnOn WRITE setDurationMinAfterTurnOn NOTIFY durationMinAfterTurnOnChanged)
    Q_PROPERTY(double durationMaxTotal READ durationMaxTotal WRITE setDurationMaxTotal NOTIFY durationMaxTotalChanged)
    Q_PROPERTY(bool controllableLocalSystem READ controllableLocalSystem WRITE setControllableLocalSystem NOTIFY controllableLocalSystemChanged)

public:
    explicit SwitchConfiguration(QObject *parent = nullptr);

    QUuid switchThingId() const;
    void setSwitchThingId(const QUuid &switchThingId);

    ControlConfig::OperatingMode operatingMode() const;
    void setOperatingMode(ControlConfig::OperatingMode operatingMode);

    int optimizationStrategies() const;
    void setOptimizationStrategies(int optimizationStrategies);

    bool manualEnabled() const;
    void setManualEnabled(bool manualEnabled);

    double maxElectricalPower() const;
    void setMaxElectricalPower(double maxElectricalPower);

    double pvSurplusThreshold() const;
    void setPvSurplusThreshold(double pvSurplusThreshold);

    double durationMinAfterTurnOn() const;
    void setDurationMinAfterTurnOn(double durationMinAfterTurnOn);

    double durationMaxTotal() const;
    void setDurationMaxTotal(double durationMaxTotal);

    bool controllableLocalSystem() const;
    void setControllableLocalSystem(bool controllableLocalSystem);

signals:
    void operatingModeChanged(ControlConfig::OperatingMode operatingMode);
    void optimizationStrategiesChanged(int optimizationStrategies);
    void manualEnabledChanged(bool manualEnabled);
    void maxElectricalPowerChanged(double maxElectricalPower);
    void pvSurplusThresholdChanged(double pvSurplusThreshold);
    void durationMinAfterTurnOnChanged(double durationMinAfterTurnOn);
    void durationMaxTotalChanged(double durationMaxTotal);
    void controllableLocalSystemChanged(bool controllableLocalSystem);

private:
    QUuid m_switchThingId;
    ControlConfig::OperatingMode m_operatingMode = ControlConfig::NoControl;
    int m_optimizationStrategies = ControlConfig::NoStrategy;
    bool m_manualEnabled = false;
    double m_maxElectricalPower = 0.0;
    double m_pvSurplusThreshold = 500.0;
    double m_durationMinAfterTurnOn = 15.0;
    double m_durationMaxTotal = 240.0;
    bool m_controllableLocalSystem = false;
};

#endif // SWITCHCONFIGURATION_H
