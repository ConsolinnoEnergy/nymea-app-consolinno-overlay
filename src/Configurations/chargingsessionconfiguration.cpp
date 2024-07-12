#include "chargingsessionconfiguration.h"

ChargingSessionConfiguration::ChargingSessionConfiguration(QObject *parent): QObject(parent)
{

}

QUuid ChargingSessionConfiguration::carThingId() const
{
    return m_carThingId;
}

void ChargingSessionConfiguration::setCarThingId(const QUuid &carThingId)
{
    m_carThingId = carThingId;
}

QUuid ChargingSessionConfiguration::evChargerThingId() const
{
    return m_evChargerThingId;
}

void ChargingSessionConfiguration::setEvChargerThingId(const QUuid &evChargerThingId)
{
    m_evChargerThingId = evChargerThingId;
}

QTime ChargingSessionConfiguration::startedAt() const
{
    return m_started_at;
}

void ChargingSessionConfiguration::setStartedAt(const QTime started_at)
{
    m_started_at = started_at;
}

QString ChargingSessionConfiguration::finishedAt() const
{
    return m_finished_at;
}

void ChargingSessionConfiguration::setFinishedAt(const QString finished_at)
{
    m_finished_at = finished_at;
}

float ChargingSessionConfiguration::initialBatteryEnergy() const
{
    return m_initial_battery_energy;
}

void ChargingSessionConfiguration::setInitialBatteryEnergy(const float initial_battery_energy)
{
    m_initial_battery_energy = initial_battery_energy;
}

int ChargingSessionConfiguration::duration() const
{
    return m_duration;
}

void ChargingSessionConfiguration::setDuration(const int duration)
{
    m_duration = duration;
}

float ChargingSessionConfiguration::energyCharged() const
{
    return m_energy_charged;
}

void ChargingSessionConfiguration::setEnergyCharged(const float energy_charged)
{
    m_energy_charged = energy_charged;
}

float ChargingSessionConfiguration::energyBattery() const
{
    return m_energy_battery;
}

void ChargingSessionConfiguration::setEnergyBattery(const float energy_battery)
{
    m_energy_battery = energy_battery;
}

int ChargingSessionConfiguration::batteryLevel() const
{
    return m_battery_level;
}

void ChargingSessionConfiguration::setBatteryLevel(const int battery_level)
{
    if (m_battery_level == battery_level)
        return;
    m_battery_level = battery_level;
    emit batteryLevelChanged(m_battery_level);
}

QUuid ChargingSessionConfiguration::sessionId() const
{
    return m_sessionId;
}

void ChargingSessionConfiguration::setSessionId(QUuid sessionId)
{
    if (m_sessionId == sessionId)
        return;

    m_sessionId = sessionId;
    emit sessionIdChanged(m_sessionId);
}

int ChargingSessionConfiguration::state() const
{
    return m_state;
}

void ChargingSessionConfiguration::setState(int state)
{
    if (m_state == state)
        return;

    m_state = state;
    emit stateChanged(m_state);
}

int ChargingSessionConfiguration::timestamp() const
{
    return m_timestamp;
}

void ChargingSessionConfiguration::setTimestamp(int timstamp)
{
    if (m_timestamp == timstamp)
        return;

    m_timestamp = timstamp;
    emit timestampChanged(m_timestamp);
}

bool ChargingSessionConfiguration::controllableLocalSystem() const
{
    return m_controllableLocalSystem;
}

void ChargingSessionConfiguration::setControllableLocalSystem(bool controllableLocalSystem)
{
    m_controllableLocalSystem = controllableLocalSystem;
}
