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
    Q_PROPERTY(double priceThreshold READ priceThreshold WRITE setPriceThreshold USER true NOTIFY priceThresholdChanged)
    Q_PROPERTY(bool relativePriceEnabled READ relativePriceEnabled WRITE setRelativePriceEnabled USER true NOTIFY relativePriceEnabledChanged)
    Q_PROPERTY(HPOptimizationMode optimizationMode READ optimizationMode WRITE setOptimizationMode USER true NOTIFY optimizationModeChanged)
    Q_PROPERTY(bool controllableLocalSystem READ controllableLocalSystem WRITE setControllableLocalSystem NOTIFY controllableLocalSystemChanged)

public:
    explicit HeatingConfiguration(QObject *parent = nullptr);

    enum HPOptimizationMode {
        OptimizationModePVSurplus,
        OptimizationModeDynamicPricing,
        OptimizationModeOff 
    };

    Q_ENUM(HPOptimizationMode)

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

    double priceThreshold() const;
    void setPriceThreshold(double priceThreshold);

    bool relativePriceEnabled() const;
    void setRelativePriceEnabled(bool relativePriceEnabled);

    HeatingConfiguration::HPOptimizationMode optimizationMode() const;
    void setOptimizationMode(HPOptimizationMode optimizationMode);

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
    void priceThresholdChanged(double priceThreshold);
    void relativePriceEnabledChanged(bool relativePriceEnabled);
    void optimizationModeChanged(HeatingConfiguration::HPOptimizationMode optimizationMode);

private:
    QUuid m_heatPumpThingId;
    bool m_optimizationEnabled = false;
    QUuid m_heatMeterThingId = QUuid("{00000000-0000-0000-0000-000000000000}");
    double m_priceThreshold = 0.30;
    bool m_relativePriceEnabled = false;

    HPOptimizationMode m_optimizationMode = OptimizationModePVSurplus;
    double m_maxElectricalPower = 0;
    double m_maxThermalEnergy = 0;
    double m_floorHeatingArea = 0;
    bool m_controllableLocalSystem = false;

};

#endif // HEATINGCONFIGURATION_H
