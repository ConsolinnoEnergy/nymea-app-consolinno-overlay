#ifndef SWITCHCONFIGURATION_H
#define SWITCHCONFIGURATION_H

#include <QDebug>
#include <QObject>
#include <QUuid>

class SwitchConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid switchThingId READ switchThingId CONSTANT)
    Q_PROPERTY(SwitchConfiguration::OptimizationMode optimizationMode READ optimizationMode WRITE setOptimizationMode NOTIFY optimizationModeChanged)
    Q_PROPERTY(double maxElectricalPower READ maxElectricalPower WRITE setMaxElectricalPower NOTIFY maxElectricalPowerChanged)
    Q_PROPERTY(double pvSurplusThreshold READ pvSurplusThreshold WRITE setPvSurplusThreshold NOTIFY pvSurplusThresholdChanged)
    Q_PROPERTY(double durationMinAfterTurnOn READ durationMinAfterTurnOn WRITE setDurationMinAfterTurnOn NOTIFY durationMinAfterTurnOnChanged)
    Q_PROPERTY(double durationMaxTotal READ durationMaxTotal WRITE setDurationMaxTotal NOTIFY durationMaxTotalChanged)
    Q_PROPERTY(bool controllableLocalSystem READ controllableLocalSystem WRITE setControllableLocalSystem NOTIFY controllableLocalSystemChanged)

public:
    enum OptimizationMode {
        OptimizationModePvSurplus,
        OptimizationModeManualOn,
        OptimizationModeManualOff,
        OptimizationModeNoControl
    };
    Q_ENUM(OptimizationMode)

    explicit SwitchConfiguration(QObject *parent = nullptr);

    QUuid switchThingId() const;
    void setSwitchThingId(const QUuid &switchThingId);

    OptimizationMode optimizationMode() const;
    void setOptimizationMode(OptimizationMode optimizationMode);

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
    void optimizationModeChanged(OptimizationMode optimizationMode);
    void maxElectricalPowerChanged(double maxElectricalPower);
    void pvSurplusThresholdChanged(double pvSurplusThreshold);
    void durationMinAfterTurnOnChanged(double durationMinAfterTurnOn);
    void durationMaxTotalChanged(double durationMaxTotal);
    void controllableLocalSystemChanged(bool controllableLocalSystem);

private:
    QUuid m_switchThingId;
    OptimizationMode m_optimizationMode = OptimizationModeNoControl;
    double m_maxElectricalPower = 0.0;
    double m_pvSurplusThreshold = 500.0;
    double m_durationMinAfterTurnOn = 15.0;
    double m_durationMaxTotal = 240.0;
    bool m_controllableLocalSystem = false;
};

#endif // SWITCHCONFIGURATION_H
