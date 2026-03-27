#ifndef HEATINGCONFIGURATION_H
#define HEATINGCONFIGURATION_H

#include <QUuid>
#include <QObject>

class HeatingConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid heatPumpThingId READ heatPumpThingId CONSTANT)
    Q_PROPERTY(bool optimizationEnabled READ optimizationEnabled WRITE setOptimizationEnabled NOTIFY optimizationEnabledChanged)
    Q_PROPERTY(QUuid heatMeterThingId READ heatMeterThingId WRITE setHeatMeterThingId NOTIFY heatMeterThingIdChanged)
    Q_PROPERTY(double floorHeatingArea READ floorHeatingArea WRITE setFloorHeatingArea NOTIFY floorHeatingAreaChanged)
    Q_PROPERTY(double maxThermalEnergy READ maxThermalEnergy WRITE setMaxThermalEnergy NOTIFY maxThermalEnergyChanged)
    Q_PROPERTY(double maxElectricalPower READ maxElectricalPower WRITE setMaxElectricalPower NOTIFY maxElectricalPowerChanged)
    Q_PROPERTY(double priceThreshold READ priceThreshold WRITE setPriceThreshold USER true NOTIFY priceThresholdChanged)
    Q_PROPERTY(bool relativePriceEnabled READ relativePriceEnabled WRITE setRelativePriceEnabled USER true NOTIFY relativePriceEnabledChanged)
    Q_PROPERTY(HPOptimizationMode optimizationMode READ optimizationMode WRITE setOptimizationMode USER true NOTIFY optimizationModeChanged)
    Q_PROPERTY(bool controllableLocalSystem READ controllableLocalSystem WRITE setControllableLocalSystem NOTIFY controllableLocalSystemChanged)
    Q_PROPERTY(HeatingConfiguration::HouseType houseType READ houseType WRITE setHouseType NOTIFY houseTypeChanged)
    Q_PROPERTY(double pvSurplusThreshold READ pvSurplusThreshold WRITE setPvSurplusThreshold NOTIFY pvSurplusThresholdChanged)
    Q_PROPERTY(int durationMinAfterTurnOn READ durationMinAfterTurnOn WRITE setDurationMinAfterTurnOn NOTIFY durationMinAfterTurnOnChanged)
    Q_PROPERTY(double durationMaxTotal READ durationMaxTotal WRITE setDurationMaxTotal NOTIFY durationMaxTotalChanged)

public:
    explicit HeatingConfiguration(QObject *parent = nullptr);

    enum HouseType {
        HouseTypePassive,
        HouseTypeLowEnergy,
        HouseTypeEnEV2016,
        HouseTypeBefore1949,
        HouseTypeSince1949,
        HouseTypeSince1969,
        HouseTypeSince1979,
        HouseTypeSince1984
    };
    Q_ENUM(HouseType)

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

    HeatingConfiguration::HouseType houseType() const;
    void setHouseType(HouseType houseType);

    double pvSurplusThreshold() const;
    void setPvSurplusThreshold(double pvSurplusThreshold);

    int durationMinAfterTurnOn() const;
    void setDurationMinAfterTurnOn(int durationMinAfterTurnOn);

    double durationMaxTotal() const;
    void setDurationMaxTotal(double durationMaxTotal);

signals:
    void maxThermalEnergyChanged(const double maxThermalEnergy);
    void maxElectricalPowerChanged(const double maxElectricalPower);
    void floorHeatingAreaChanged(const double floorHeatingArea);
    void optimizationEnabledChanged(bool optimizationEnabled);
    void heatMeterThingIdChanged(const QUuid &heatMeterThingId);
    void controllableLocalSystemChanged(bool controllableLocalSystem);
    void houseTypeChanged(HeatingConfiguration::HouseType houseType);
    void pvSurplusThresholdChanged(double pvSurplusThreshold);
    void durationMinAfterTurnOnChanged(int durationMinAfterTurnOn);
    void durationMaxTotalChanged(double durationMaxTotal);
    void priceThresholdChanged(double priceThreshold);
    void relativePriceEnabledChanged(bool relativePriceEnabled);
    void optimizationModeChanged(HeatingConfiguration::HPOptimizationMode optimizationMode);

private:
    QUuid m_heatPumpThingId;
    bool m_optimizationEnabled = false;
    QUuid m_heatMeterThingId = "{00000000-0000-0000-0000-000000000000}";
    double m_priceThreshold = 0.30;
    bool m_relativePriceEnabled = false;

    HPOptimizationMode m_optimizationMode = OptimizationModePVSurplus;
    double m_maxElectricalPower = 0;
    double m_maxThermalEnergy = 0;
    double m_floorHeatingArea = 0;
    bool m_controllableLocalSystem = false;
    HouseType m_houseType = HouseTypeSince1984;
    double m_pvSurplusThreshold = 500.0;
    int m_durationMinAfterTurnOn = 15;
    double m_durationMaxTotal = 240.0;

};

#endif // HEATINGCONFIGURATION_H
