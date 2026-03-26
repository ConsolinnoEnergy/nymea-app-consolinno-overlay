#ifndef BATTERYCONFIGURATION_H
#define BATTERYCONFIGURATION_H

#include <QUuid>
#include <QObject>
#include <QVariant>
#include <QList>

class BatteryConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid batteryThingId READ batteryThingId CONSTANT)
    Q_PROPERTY(bool optimizationEnabled READ optimizationEnabled WRITE setOptimizationEnabled NOTIFY optimizationEnabledChanged)
    Q_PROPERTY(float priceThreshold READ priceThreshold WRITE setPriceThreshold NOTIFY priceThresholdChanged)
    Q_PROPERTY(float dischargePriceThreshold READ dischargePriceThreshold WRITE setDischargePriceThreshold NOTIFY dischargePriceThresholdChanged)
    Q_PROPERTY(bool relativePriceEnabled READ relativePriceEnabled WRITE setRelativePriceEnabled NOTIFY relativePriceEnabledChanged)
    Q_PROPERTY(bool chargeOnce READ chargeOnce WRITE setChargeOnce NOTIFY chargeOnceChanged)
    Q_PROPERTY(bool avoidZeroFeedInActive READ avoidZeroFeedInActive WRITE setAvoidZeroFeedInActive NOTIFY avoidZeroFeedInActiveChanged)
    Q_PROPERTY(bool avoidZeroFeedInEnabled READ avoidZeroFeedInEnabled WRITE setAvoidZeroFeedInEnabled NOTIFY avoidZeroFeedInEnabledChanged)
    Q_PROPERTY(bool controllableLocalSystem READ controllableLocalSystem WRITE setControllableLocalSystem NOTIFY controllableLocalSystemChanged)
    Q_PROPERTY(int blockBatteryOnGridConsumption READ blockBatteryOnGridConsumption WRITE setBlockBatteryOnGridConsumption NOTIFY blockBatteryOnGridConsumptionChanged)
    Q_PROPERTY(float maxElectricalPower READ maxElectricalPower WRITE setMaxElectricalPower NOTIFY maxElectricalPowerChanged)
    Q_PROPERTY(QVariantList targetSocPvSurplus READ targetSocPvSurplus WRITE setTargetSocPvSurplus NOTIFY targetSocPvSurplusChanged)

    // Self-consumption configuration parameters (matching backend API)
    Q_PROPERTY(float selfConsumptionCapacity READ selfConsumptionCapacity WRITE setSelfConsumptionCapacity NOTIFY selfConsumptionCapacityChanged)
    Q_PROPERTY(int selfConsumptionSocFull READ selfConsumptionSocFull WRITE setSelfConsumptionSocFull NOTIFY selfConsumptionSocFullChanged)
    Q_PROPERTY(int selfConsumptionSocEmpty READ selfConsumptionSocEmpty WRITE setSelfConsumptionSocEmpty NOTIFY selfConsumptionSocEmptyChanged)
    Q_PROPERTY(int selfConsumptionSocTaper READ selfConsumptionSocTaper WRITE setSelfConsumptionSocTaper NOTIFY selfConsumptionSocTaperChanged)
    Q_PROPERTY(int selfConsumptionMaxPower READ selfConsumptionMaxPower WRITE setSelfConsumptionMaxPower NOTIFY selfConsumptionMaxPowerChanged)
    Q_PROPERTY(float selfConsumptionPriority READ selfConsumptionPriority WRITE setSelfConsumptionPriority NOTIFY selfConsumptionPriorityChanged)
    Q_PROPERTY(int selfConsumptionRateLimit READ selfConsumptionRateLimit WRITE setSelfConsumptionRateLimit NOTIFY selfConsumptionRateLimitChanged)

public:

    // Block battery on grid consumption modes:
    // 0 = Keine Sperrung (No blocking)
    // 1 = Nur EvCharger (Wallbox) (Only EvCharger)
    // 2 = Nur HeatPump (Only HeatPump)
    // 3 = EvCharger + HeatPump (1|2)
    // 4 = Nur HeatingRod (Only HeatingRod)
    // 5 = EvCharger + HeatingRod (1|4)
    // 6 = HeatPump + HeatingRod (2|4)
    // 7 = Alle drei (1|2|4) (All three)
    enum BlockBatteryOnGridConsumptionFlag {
        NoBlocking = 0,
        EvCharger = 1,
        HeatPump = 2,
        HeatingRod = 4
    };
    Q_FLAG(BlockBatteryOnGridConsumptionFlag);

    explicit BatteryConfiguration(QObject *parent = nullptr);

    QUuid batteryThingId() const;
    void setBatteryThingId(const QUuid &batteryThingId);

    bool optimizationEnabled() const;
    void setOptimizationEnabled(bool optimizationEnabled);

    float priceThreshold() const;
    void setPriceThreshold(float priceThreshold);

    float dischargePriceThreshold() const;
    void setDischargePriceThreshold(float dischargePriceThreshold);

    bool relativePriceEnabled() const;
    void setRelativePriceEnabled(bool relativePriceEnabled);

    bool avoidZeroFeedInEnabled() const;
    void setAvoidZeroFeedInEnabled(bool avoidZeroFeedInEnabled);

    bool avoidZeroFeedInActive() const;
    void setAvoidZeroFeedInActive(bool avoidZeroFeedInActive);

    bool chargeOnce() const;
    void setChargeOnce(bool chargeOnce);

    bool controllableLocalSystem() const;
    void setControllableLocalSystem(bool controllableLocalSystem);

    int blockBatteryOnGridConsumption() const;
    void setBlockBatteryOnGridConsumption(int blockBatteryOnGridConsumption);

    float maxElectricalPower() const;
    void setMaxElectricalPower(float maxElectricalPower);

    QVariantList targetSocPvSurplus() const;
    void setTargetSocPvSurplus(const QVariantList &targetSocPvSurplus);

    // Self-consumption configuration getters/setters
    float selfConsumptionCapacity() const;
    void setSelfConsumptionCapacity(float selfConsumptionCapacity);

    int selfConsumptionSocFull() const;
    void setSelfConsumptionSocFull(int selfConsumptionSocFull);

    int selfConsumptionSocEmpty() const;
    void setSelfConsumptionSocEmpty(int selfConsumptionSocEmpty);

    int selfConsumptionSocTaper() const;
    void setSelfConsumptionSocTaper(int selfConsumptionSocTaper);

    int selfConsumptionMaxPower() const;
    void setSelfConsumptionMaxPower(int selfConsumptionMaxPower);

    float selfConsumptionPriority() const;
    void setSelfConsumptionPriority(float selfConsumptionPriority);

    int selfConsumptionRateLimit() const;
    void setSelfConsumptionRateLimit(int selfConsumptionRateLimit);

signals:
    void optimizationEnabledChanged(bool optimizationEnabled);
    void priceThresholdChanged(float priceThreshold);
    void dischargePriceThresholdChanged(float dischargePriceThreshold);
    void avoidZeroFeedInActiveChanged(bool avoidZeroFeedInActive);
    void avoidZeroFeedInEnabledChanged(bool avoidZeroFeedInEnabled);
    void relativePriceEnabledChanged(bool relativePriceEnabled);
    void chargeOnceChanged(bool chargeOnce);
    void controllableLocalSystemChanged(bool controllableLocalSystem);
    void blockBatteryOnGridConsumptionChanged(int blockBatteryOnGridConsumption);
    void maxElectricalPowerChanged(float maxElectricalPower);
    void targetSocPvSurplusChanged(const QVariantList &targetSocPvSurplus);
    void selfConsumptionCapacityChanged(float selfConsumptionCapacity);
    void selfConsumptionSocFullChanged(int selfConsumptionSocFull);
    void selfConsumptionSocEmptyChanged(int selfConsumptionSocEmpty);
    void selfConsumptionSocTaperChanged(int selfConsumptionSocTaper);
    void selfConsumptionMaxPowerChanged(int selfConsumptionMaxPower);
    void selfConsumptionPriorityChanged(float selfConsumptionPriority);
    void selfConsumptionRateLimitChanged(int selfConsumptionRateLimit);

private:
    QUuid m_batteryThingId;
    bool m_optimizationEnabled = true;
    float m_priceThreshold = 0;
    float m_dischargePriceThreshold = 0;
    bool m_relativePriceEnabled = false;
    bool m_chargeOnce = false;
    bool m_controllableLocalSystem = false;
    bool m_avoidZeroFeedInEnabled = false;
    bool m_avoidZeroFeedInActive = false;
    int m_blockBatteryOnGridConsumption = EvCharger;
    float m_maxElectricalPower = 0.0;
    QVariantList m_targetSocPvSurplus = {QVariant(80)};

    // Self-consumption configuration member variables
    float m_selfConsumptionCapacity = -1.0;     // kWh, -1 = not configured
    int m_selfConsumptionSocFull = 95;          // %
    int m_selfConsumptionSocEmpty = 5;          // %
    int m_selfConsumptionSocTaper = 5;          // %
    int m_selfConsumptionMaxPower = 100000;     // W
    float m_selfConsumptionPriority = 1.0;      // –
    int m_selfConsumptionRateLimit = 0;         // W/s
};

#endif // BATTERYCONFIGURATION_H