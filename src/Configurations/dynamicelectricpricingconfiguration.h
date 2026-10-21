#ifndef DYNAMICELECTRICPRICINGCONFIGURATION_H
#define DYNAMICELECTRICPRICINGCONFIGURATION_H

#include <QUuid>
#include <QObject>

class DynamicElectricPricingConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid dynamicElectricPricingThingID READ dynamicElectricPricingThingID CONSTANT)

public:
    explicit DynamicElectricPricingConfiguration(QObject *parent = nullptr);

    QUuid dynamicElectricPricingThingID() const;
    void setDynamicElectricPricingThingID(const QUuid &dynamicElectricPricingThingID);

private:
    QUuid m_dynamicElectricPricingThingID;
};
#endif // DYNAMICELECTRICPRICINGCONFIGURATION_H
