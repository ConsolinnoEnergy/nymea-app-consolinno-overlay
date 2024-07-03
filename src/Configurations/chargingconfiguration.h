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
    Q_PROPERTY(int optimizationMode READ optimizationMode WRITE setOptimizationMode NOTIFY optimizationModeChanged)
    Q_PROPERTY(QUuid uniqueIdentifier READ uniqueIdentifier WRITE setUniqueIdentifier NOTIFY uniqueIdentifierChanged)
    Q_PROPERTY(bool controllableLocalSystem READ controllableLocalSystem WRITE setControllableLocalSystem NOTIFY controllableLocalSystemChanged)

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


    int optimizationMode() const;
    void setOptimizationMode(int optimizationMode);

    QUuid uniqueIdentifier() const;
    void setUniqueIdentifier(QUuid uniqueIdentifier);

    bool controllableLocalSystem() const;
    void setControllableLocalSystem(const bool controllableLocalSystem);

signals:
    void optimizationEnabledChanged(bool optimizationEnabled);
    void carThingIdChanged(const QUuid &carThingId);
    void endTimeChanged(const QString &endTime);
    void targetPercentageChanged(uint targetPercentage);
    void optimizationModeChanged(int optimizationMode);
    void uniqueIdentifierChanged(QUuid uniqueIdentifier);
    void controllableLocalSystemChanged(bool controllableLocalSystem);

private:
    QUuid m_evChargerThingId;
    bool m_optimizationEnabled = false;
    QUuid m_carThingId = "00000000-0000-0000-0000-000000000000";
    QString m_endTime = "0:00:00";
    uint m_targetPercentage = 100;
    int m_optimizationMode = 0;
    QUuid m_uniqueIdentifier = "2e2d25c5-57c7-419a-b294-881f11ed01c4";
    bool m_controllableLocalSystem = false;
};

#endif // CHARGINGCONFIGURATION_H
