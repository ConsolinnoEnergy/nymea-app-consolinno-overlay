#include "chargingsessionconfiguration.h"

ChargingSessionConfiguration::ChargingSessionConfiguration(QObject *parent): QObject(parent)
{

}

QUuid ChargingSessionConfiguration::chargingSessionThingId() const
{
    return m_chargingSessionthingId;
}

void ChargingSessionConfiguration::setChargingSessionThingId(const QUuid &chargingSessionThingId)
{
    m_chargingSessionthingId = chargingSessionThingId;
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

QTime ChargingSessionConfiguration::finishedAt() const
{
    return m_finished_at;
}

void ChargingSessionConfiguration::setFinishedAt(const QTime finished_at)
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
    m_battery_level = battery_level;
}


