#ifndef CHARGINGOPTIMIZATIONCONFIGURATION_H
#define CHARGINGOPTIMIZATIONCONFIGURATION_H

#include <QObject>
#include <QUuid>

class ChargingOptimizationConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid evChargerThingId READ evChargerThingId CONSTANT)
    Q_PROPERTY(bool reenableChargepoint READ reenableChargepoint WRITE setReenableChargepoint NOTIFY reenableChargepointChanged)
    Q_PROPERTY(float p_value READ p_value WRITE setP_value NOTIFY reenableChargepointChanged)
    Q_PROPERTY(float i_value READ i_value WRITE setI_value NOTIFY reenableChargepointChanged)
    Q_PROPERTY(float d_value READ d_value WRITE setD_value NOTIFY reenableChargepointChanged)
    Q_PROPERTY(float setpoint READ setpoint WRITE setSetpoint NOTIFY reenableChargepointChanged)
    Q_PROPERTY(bool controllableLocalSystem READ controllableLocalSystem WRITE setControllableLocalSystem NOTIFY controllableLocalSystemChanged)


public:
    explicit ChargingOptimizationConfiguration(QObject *parent = nullptr);

    QUuid evChargerThingId() const;
    void setEvChargerThingId(const QUuid &evChargerThingId);

    bool reenableChargepoint() const;
    void setReenableChargepoint(const bool reenableChargepoint);

    float p_value() const;
    void setP_value(const float p_value);

    float i_value() const;
    void setI_value(const float i_value);

    float d_value() const;
    void setD_value(const float d_value);

    float setpoint() const;
    void setSetpoint(const float setpoint);

    bool controllableLocalSystem() const;
    void setControllableLocalSystem(bool controllableLocalSystem);


signals:
    void reenableChargepointChanged(bool reenableChargepoint);
    void p_valueChanged(float p_value);
    void i_valueChanged(float i_value);
    void d_valueChanged(float d_value);
    void setpointChanged(float setpoint);
    void controllableLocalSystemChanged(bool controllableLocalSystem);


private:
    QUuid m_evChargerThingId;
    bool m_reenableChargepoint = false;
    float m_p_value = 0.0001;
    float m_i_value = 0.0001;
    float m_d_value = 0;
    float m_setpoint = 0;
    bool m_controllableLocalSystem = false;

};

#endif // CHARGINGOPTIMIZATIONCONFIGURATION_H
