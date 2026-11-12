#ifndef WHITEGOODCONFIGURATION_H
#define WHITEGOODCONFIGURATION_H

#include <QUuid>
#include <QObject>
#include <QVariant>

#include "controlconfigurationenums.h"

class WhiteGoodConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid whiteGoodThingId READ whiteGoodThingId CONSTANT)
    Q_PROPERTY(ControlConfig::OperatingMode operatingMode READ operatingMode WRITE setOperatingMode NOTIFY operatingModeChanged)
    Q_PROPERTY(int optimizationStrategies READ optimizationStrategies WRITE setOptimizationStrategies NOTIFY optimizationStrategiesChanged)
    Q_PROPERTY(bool controllableLocalSystem READ controllableLocalSystem WRITE setControllableLocalSystem NOTIFY controllableLocalSystemChanged)
    Q_PROPERTY(double priceThreshold READ priceThreshold WRITE setPriceThreshold NOTIFY priceThresholdChanged)
    Q_PROPERTY(QVariant dischargePriceThreshold READ dischargePriceThreshold WRITE setDischargePriceThreshold NOTIFY dischargePriceThresholdChanged)
    Q_PROPERTY(QString timeSchedule READ timeSchedule WRITE setTimeSchedule NOTIFY timeScheduleChanged)

public:
    explicit WhiteGoodConfiguration(QObject *parent = nullptr);

    QUuid whiteGoodThingId() const;
    void setWhiteGoodThingId(const QUuid &whiteGoodThingId);

    ControlConfig::OperatingMode operatingMode() const;
    void setOperatingMode(ControlConfig::OperatingMode operatingMode);

    int optimizationStrategies() const;
    void setOptimizationStrategies(int optimizationStrategies);

    bool controllableLocalSystem() const;
    void setControllableLocalSystem(bool controllableLocalSystem);

    double priceThreshold() const;
    void setPriceThreshold(double priceThreshold);

    // Null when no discharge threshold is configured
    QVariant dischargePriceThreshold() const;
    void setDischargePriceThreshold(const QVariant &dischargePriceThreshold);

    // JSON encoded schedule
    QString timeSchedule() const;
    void setTimeSchedule(const QString &timeSchedule);

signals:
    void operatingModeChanged(ControlConfig::OperatingMode operatingMode);
    void optimizationStrategiesChanged(int optimizationStrategies);
    void controllableLocalSystemChanged(bool controllableLocalSystem);
    void priceThresholdChanged(double priceThreshold);
    void dischargePriceThresholdChanged(const QVariant &dischargePriceThreshold);
    void timeScheduleChanged(const QString &timeSchedule);

private:
    QUuid m_whiteGoodThingId;
    ControlConfig::OperatingMode m_operatingMode = ControlConfig::StrategyControlled;
    int m_optimizationStrategies = ControlConfig::PvOptimized;
    bool m_controllableLocalSystem = false;
    double m_priceThreshold = 0.0;
    QVariant m_dischargePriceThreshold;
    QString m_timeSchedule;
};
#endif // WHITEGOODCONFIGURATION_H
