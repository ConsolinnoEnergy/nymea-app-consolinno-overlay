#ifndef CHARGINGSESSIONCONFIGURATION_H
#define CHARGINGSESSIONCONFIGURATION_H


#include <QUuid>
#include <QTime>
#include <QObject>
#include <QDebug>


class ChargingSessionConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid chargingSessionThingId READ chargingSessionThingId CONSTANT)
    Q_PROPERTY(QUuid carThingId READ carThingId WRITE setCarThingId NOTIFY carThingIdChanged)
    Q_PROPERTY(QUuid evChargerThingId READ evChargerThingId WRITE setEvChargerThingId NOTIFY evChargerThingIdChanged)
    Q_PROPERTY(QTime startedAt READ startedAt WRITE setStartedAt NOTIFY startedAtChanged)
    Q_PROPERTY(QTime finishedAt READ finishedAt WRITE setFinishedAt NOTIFY finishedAtChanged)
    Q_PROPERTY(float initialBatteryEnergy READ initialBatteryEnergy WRITE setInitialBatteryEnergy NOTIFY initialBatteryEnergyChanged)
    Q_PROPERTY(int duration READ duration WRITE setDuration NOTIFY durationChanged)
    Q_PROPERTY(float energyCharged READ energyCharged WRITE setEnergyCharged NOTIFY energyChargedChanged)
    Q_PROPERTY(float energyBattery READ energyBattery WRITE setEnergyBattery NOTIFY energyBatteryChanged)
    Q_PROPERTY(int batteryLevel READ batteryLevel WRITE setBatteryLevel NOTIFY batteryLevelChanged )




public:
    explicit ChargingSessionConfiguration( QObject *parent = nullptr);

    QUuid chargingSessionThingId() const;
    void setChargingSessionThingId(const QUuid &chargingSessionThingId);

    QUuid carThingId() const;
    void setCarThingId(const QUuid &carThingId);

    QUuid evChargerThingId() const;
    void setEvChargerThingId(const QUuid &evChargerThingId);

    QTime startedAt() const;
    void setStartedAt(const QTime started_at);

    QTime finishedAt() const;
    void setFinishedAt(const QTime finished_at);

    float initialBatteryEnergy() const;
    void setInitialBatteryEnergy( const float initial_battery_energy);

    int duration()const;
    void setDuration(const int duration);

    float energyCharged() const;
    void setEnergyCharged(const float energy_charged);

    float energyBattery() const;
    void setEnergyBattery(const float energy_battery);

    int batteryLevel() const;
    void setBatteryLevel(const int battery_level);

    bool operator == (const ChargingSessionConfiguration &other) const;
    bool operator != (const ChargingSessionConfiguration &other) const;

signals:
    void carThingIdChanged(const QUuid &carThingId);
    void evChargerThingIdChanged(const QUuid &evChargerThingId);
    void startedAtChanged(const QTime started_at);
    void finishedAtChanged(const QTime finished_at);
    void initialBatteryEnergyChanged(const float initial_battery_energy);
    void durationChanged(const int duration);
    void energyChargedChanged(const float energy_charged);
    void energyBatteryChanged(const float energy_battery);
    void batteryLevelChanged(const int battery_level);

private:
    QUuid m_chargingSessionthingId;
    QUuid m_carThingId;
    QUuid m_evChargerThingId;
    QTime m_started_at;
    QTime m_finished_at;
    float m_initial_battery_energy;
    int m_duration;
    float m_energy_charged;
    float m_energy_battery;
    int m_battery_level;









};

QDebug operator<<(QDebug debug, const ChargingSessionConfiguration &chargingSessionConfig);


#endif // CHARGINGSESSIONCONFIGURATION_H
