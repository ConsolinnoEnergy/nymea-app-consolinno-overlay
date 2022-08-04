#ifndef CHARGINGOPTIMIZATIONCONFIGURATION_H
#define CHARGINGOPTIMIZATIONCONFIGURATION_H

#include <QObject>
#include <QUuid>

class ChargingOptimizationConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid evChargerThingId READ evChargerThingId CONSTANT)
    Q_PROPERTY(bool reenableChargepoint READ reenableChargepoint WRITE setReenableChargepoint NOTIFY reenableChargepointChanged)

public:
    explicit ChargingOptimizationConfiguration(QObject *parent = nullptr);

    QUuid evChargerThingId() const;
    void setEvChargerThingId(const QUuid &evChargerThingId);

    bool reenableChargepoint() const;
    void setReenableChargepoint(const bool reenableChargepoint);


signals:
    void reenableChargepointChanged(bool reenableChargepoint);


private:
    QUuid m_evChargerThingId;
    bool m_reenableChargepoint = false;


};

#endif // CHARGINGOPTIMIZATIONCONFIGURATION_H
