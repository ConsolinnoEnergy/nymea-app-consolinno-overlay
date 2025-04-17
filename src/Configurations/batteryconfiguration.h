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
    Q_PROPERTY(bool relativePriceEnabled READ relativePriceEnabled WRITE setRelativePriceEnabled NOTIFY relativePriceEnabledChanged)
    Q_PROPERTY(bool chargeOnce READ chargeOnce WRITE setChargeOnce NOTIFY chargeOnceChanged)
    Q_PROPERTY(bool avoidZeroFeedInActive READ avoidZeroFeedInActive WRITE setavoidZeroFeedInActive NOTIFY avoidZeroFeedInActiveChanged)
    Q_PROPERTY(bool avoidZeroFeedInEnabled READ avoidZeroFeedInEnabled WRITE setavoidZeroFeedInEnabled NOTIFY avoidZeroFeedInEnabledChanged)
    Q_PROPERTY(bool controllableLocalSystem READ controllableLocalSystem WRITE setControllableLocalSystem NOTIFY controllableLocalSystemChanged)

public:
    explicit BatteryConfiguration(QObject *parent = nullptr);

    QUuid batteryThingId() const;
    void setBatteryThingId(const QUuid &batteryThingId);

    bool optimizationEnabled() const;
    void setOptimizationEnabled(bool optimizationEnabled);

    float priceThreshold() const;
    void setPriceThreshold(float priceThreshold);

    bool relativePriceEnabled() const;
    void setRelativePriceEnabled(bool relativePriceEnabled);

    bool avoidZeroFeedInEnabled() const;
    void setavoidZeroFeedInEnabled(bool avoidZeroFeedInEnabled);

    bool avoidZeroFeedInActive() const;
    void setavoidZeroFeedInActive(bool avoidZeroFeedInActive);

    bool chargeOnce() const;
    void setChargeOnce(bool chargeOnce);

    bool controllableLocalSystem() const;
    void setControllableLocalSystem(bool controllableLocalSystem);

signals:
    void optimizationEnabledChanged(bool optimizationEnabled);
    void priceThresholdChanged(float priceThreshold);
    void avoidZeroFeedInActiveChanged(bool avoidZeroFeedInActive);
    void avoidZeroFeedInEnabledChanged(bool avoidZeroFeedInEnabled);
    void relativePriceEnabledChanged(bool relativePriceEnabled);
    void chargeOnceChanged(bool chargeOnce);
    void controllableLocalSystemChanged(bool controllableLocalSystem);

private:
    QUuid m_batteryThingId;
    bool m_optimizationEnabled = true;
    float m_priceThreshold = 0;
    bool m_relativePriceEnabled = false;
    bool m_chargeOnce = false;
    bool m_controllableLocalSystem = false;
    bool m_avoidZeroFeedInEnabled = false;
    bool m_avoidZeroFeedInActive = false;

};

#endif // BATTERYCONFIGURATION_H
