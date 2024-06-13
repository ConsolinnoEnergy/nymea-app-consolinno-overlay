#ifndef DYNAMICELECTRICPRICINGCONFIGURATION_H
#define DYNAMICELECTRICPRICINGCONFIGURATION_H

#include <QUuid>
#include <QObject>

class DynamicElectricPricingConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid dynamicElectricPricingThingID READ dynamicElectricPricingThingID CONSTANT)
    Q_PROPERTY(bool optimizationEnabled READ optimizationEnabled WRITE setOptimizationEnabled NOTIFY optimizationEnabledChanged)
    Q_PROPERTY(double maxElectricalPower READ maxElectricalPower WRITE setMaxElectricalPower NOTIFY maxElectricalPowerChanged)

public:
    explicit DynamicElectricPricingConfiguration();

    QUuid dynamicElectricPricingThingID() const;
    void setDynamicElectricPricingThingID(const QUuid &dynamicElectricPricingThingID);

    bool optimizationEnabled() const;
    void setOptimizationEnabled(bool optimizationEnabled);

    double maxElectricalPower() const;
    void setMaxElectricalPower(double maxElectricalPower);

signals:
    void optimizationEnabledChanged(bool optimizationEnabled);
    void maxElectricalPowerChanged(const double maxElectricalPower);

private:
    QUuid m_dynamicElectricPricingThingID;
    bool m_optimizationEnabled = false;
    double m_maxElectricalPower = 0;
};
#endif // DYNAMICELECTRICPRICINGCONFIGURATION_H
