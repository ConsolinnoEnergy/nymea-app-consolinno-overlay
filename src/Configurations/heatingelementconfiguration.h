#ifndef HEATINGELEMENTCONFIGURATION_H
#define HEATINGELEMENTCONFIGURATION_H

#include <QUuid>
#include <QObject>

class HeatingElementConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid heatingRodThingId READ heatingRodThingId CONSTANT)
    Q_PROPERTY(double maxElectricalPower READ maxElectricalPower WRITE setMaxElectricalPower NOTIFY maxElectricalPowerChanged)
    Q_PROPERTY(bool optimizationEnabled READ optimizationEnabled WRITE setOptimizationEnabled NOTIFY optimizationEnabledChanged)
    Q_PROPERTY(bool controllableLocalSystem READ controllableLocalSystem WRITE setControllableLocalSystem NOTIFY controllableLocalSystemChanged)

public:
    explicit HeatingElementConfiguration(QObject *parent = nullptr);

    QUuid heatingRodThingId() const;
    void setHeatingRodThingId(const QUuid &heatingRodThingId);

    double maxElectricalPower() const;
    void setMaxElectricalPower(const double &maxElectricalPower);

    bool optimizationEnabled() const;
    void setOptimizationEnabled(const bool &optimizationEnabled);

    bool controllableLocalSystem() const;
    void setControllableLocalSystem(const bool &controllableLocalSystem);

private:
    QUuid m_heatingRodThingId;
    double m_maxElectricalPower = 0;
    bool m_optimizationEnabled = false;
    bool m_controllableLocalSystem = false;

signals:
    void maxElectricalPowerChanged(const double maxElectricalPower);
    void optimizationEnabledChanged(const double optimizationEnabled);
    void controllableLocalSystemChanged(const bool &controllableLocalSystem);

};

#endif // HeatingElementConfiguration_H
