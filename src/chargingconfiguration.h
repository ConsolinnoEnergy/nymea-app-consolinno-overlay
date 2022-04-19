#ifndef CHARGINGCONFIGURATION_H
#define CHARGINGCONFIGURATION_H

#include <QUuid>
#include <QTime>
#include <QObject>

class ChargingConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid evChargerThingId READ evChargerThingId CONSTANT)
    Q_PROPERTY(bool optimizationEnabled READ optimizationEnabled WRITE setOptimizationEnabled NOTIFY optimizationEnabledChanged)
    Q_PROPERTY(QUuid carThingId READ carThingId WRITE setCarThingId NOTIFY carThingIdChanged)
    Q_PROPERTY(QString endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)
    Q_PROPERTY(uint targetPercentage READ targetPercentage WRITE setTargetPercentage NOTIFY targetPercentageChanged)
    Q_PROPERTY(bool zeroReturnPolicyEnabled READ zeroReturnPolicyEnabled WRITE setZeroReturnPolicyEnabled NOTIFY zeroReturnPolicyEnabledChanged)
    Q_PROPERTY(int optimizationMode READ optimizationMode WRITE setOptimizationMode NOTIFY optimizationModeChanged)

public:

    enum OptimizationMode {
        Unoptimized = 0,
        PVOptimized = 1

    };
    Q_ENUM(OptimizationMode);

    explicit ChargingConfiguration(QObject *parent = nullptr);

    QUuid evChargerThingId() const;
    void setEvChargerThingId(const QUuid &evChargerThingId);

    bool optimizationEnabled() const;
    void setOptimizationEnabled(bool optimizationEnabled);

    QUuid carThingId() const;
    void setCarThingId(const QUuid &carThingId);

    QString endTime() const;
    void setEndTime(const QString &endTime);

    uint targetPercentage() const;
    void setTargetPercentage(uint targetPercentage);

    bool zeroReturnPolicyEnabled() const;
    void setZeroReturnPolicyEnabled(bool zeroReturnPolicyEnabled);

    int optimizationMode() const;
    void setOptimizationMode(int optimizationMode);


signals:
    void optimizationEnabledChanged(bool optimizationEnabled);
    void carThingIdChanged(const QUuid &carThingId);
    void endTimeChanged(const QString &endTime);
    void targetPercentageChanged(uint targetPercentage);
    void zeroReturnPolicyEnabledChanged(bool zeroReturnPolicyEnabled);
    void optimizationModeChanged(int optimizationMode);

private:
    QUuid m_evChargerThingId;
    bool m_optimizationEnabled = false;
    QUuid m_carThingId;
    QString m_endTime = "10:30:00";
    uint m_targetPercentage = 100;
    bool m_zeroReturnPolicyEnabled = false;
    int m_optimizationMode;

};

#endif // CHARGINGCONFIGURATION_H
