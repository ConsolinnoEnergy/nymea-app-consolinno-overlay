#ifndef BATTERYCONFIGURATION_H
#define BATTERYCONFIGURATION_H

#include <QUuid>
#include <QObject>

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

    // Self-consumption configuration parameters (new API)
    Q_PROPERTY(bool selfConsumptionEnabled READ selfConsumptionEnabled WRITE setSelfConsumptionEnabled NOTIFY selfConsumptionEnabledChanged)
    Q_PROPERTY(float selfConsumptionCapacity READ selfConsumptionCapacity WRITE setSelfConsumptionCapacity NOTIFY selfConsumptionCapacityChanged)
    Q_PROPERTY(int targetSocPvSurplusMin READ targetSocPvSurplusMin WRITE setTargetSocPvSurplusMin NOTIFY targetSocPvSurplusMinChanged)
    Q_PROPERTY(int targetSocPvSurplusMax READ targetSocPvSurplusMax WRITE setTargetSocPvSurplusMax NOTIFY targetSocPvSurplusMaxChanged)

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

    // Self-consumption configuration getters/setters
    bool selfConsumptionEnabled() const;
    void setSelfConsumptionEnabled(bool selfConsumptionEnabled);

    float selfConsumptionCapacity() const;
    void setSelfConsumptionCapacity(float selfConsumptionCapacity);

    int targetSocPvSurplusMin() const;
    void setTargetSocPvSurplusMin(int targetSocPvSurplusMin);

    int targetSocPvSurplusMax() const;
    void setTargetSocPvSurplusMax(int targetSocPvSurplusMax);

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
    void selfConsumptionEnabledChanged(bool selfConsumptionEnabled);
    void selfConsumptionCapacityChanged(float selfConsumptionCapacity);
    void targetSocPvSurplusMinChanged(int targetSocPvSurplusMin);
    void targetSocPvSurplusMaxChanged(int targetSocPvSurplusMax);

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

    // Self-consumption configuration member variables
    bool m_selfConsumptionEnabled = false;
    float m_selfConsumptionCapacity = -1.0;  // -1.0 = not configured sentinel
    int m_targetSocPvSurplusMin = 20;
    int m_targetSocPvSurplusMax = 80;
};

#endif // BATTERYCONFIGURATION_H