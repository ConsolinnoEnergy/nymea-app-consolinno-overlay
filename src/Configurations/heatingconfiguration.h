#ifndef HEATINGCONFIGURATION_H
#define HEATINGCONFIGURATION_H

#include <QUuid>
#include <QObject>

class HeatingConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid heatPumpThingId READ heatPumpThingId CONSTANT)
    Q_PROPERTY(bool optimizationEnabled READ optimizationEnabled WRITE setOptimizationEnabled NOTIFY optimizationEnabledChanged)
   // Q_PROPERTY(QUuid heatMeterThingId READ heatMeterThingId WRITE setHeatMeterThingId NOTIFY heatMeterThingIdChanged)
    Q_PROPERTY(double floorHeatingArea READ floorHeatingArea WRITE setFloorHeatingArea NOTIFY floorHeatingAreaChanged)
    Q_PROPERTY(double maxThermalEnergy READ maxThermalEnergy WRITE setMaxThermalEnergy NOTIFY maxThermalEnergyChanged)
    Q_PROPERTY(double maxElectricalPower READ maxElectricalPower WRITE setMaxElectricalPower NOTIFY maxElectricalPowerChanged)
    Q_PROPERTY(bool controllableLocalSystem READ controllableLocalSystem WRITE setControllableLocalSystem NOTIFY controllableLocalSystemChanged)

public:
    explicit HeatingConfiguration(QObject *parent = nullptr);



    QUuid heatPumpThingId() const;
    void setHeatPumpThingId(const QUuid &heatPumpThingId);

    bool optimizationEnabled() const;
    void setOptimizationEnabled(bool optimizationEnabled);

    // The maximal electric power in W the heat pump can consume
    double maxElectricalPower() const;
    void setMaxElectricalPower(const double &maxElectricalPower);

    // The maximal thermal energy in kWh the heat pump can produce
    double maxThermalEnergy() const;
    void setMaxThermalEnergy(const double &maxThermalEnergy);

    // Area of the floor heating in m^2
    double floorHeatingArea() const;
    void setFloorHeatingArea(const double &floorHeatingArea);

    QUuid heatMeterThingId() const;
    void setHeatMeterThingId(const QUuid &heatMeterThingId);

    //
    bool controllableLocalSystem() const;
    void setControllableLocalSystem(bool controllableLocalSystem);
signals:

    void maxThermalEnergyChanged(const double maxThermalEnergy);
    void maxElectricalPowerChanged(const double maxElectricalPower);
    void floorHeatingAreaChanged(const double floorHeatingArea);
    void optimizationEnabledChanged(bool optimizationEnabled);
    void heatMeterThingIdChanged(const QUuid &heatMeterThingId);
    void controllableLocalSystemChanged(bool controllableLocalSystem);

private:
    QUuid m_heatPumpThingId;
    bool m_optimizationEnabled = false;
    QUuid m_heatMeterThingId = "{00000000-0000-0000-0000-000000000000}";


    double m_maxElectricalPower = 0;
    double m_maxThermalEnergy = 0;
    double m_floorHeatingArea = 0;
    bool m_controllableLocalSystem = false;

};

#endif // HEATINGCONFIGURATION_H
