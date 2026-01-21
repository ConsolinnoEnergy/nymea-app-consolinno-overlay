#include "chargingconfiguration.h"

ChargingConfiguration::ChargingConfiguration(QObject *parent) : QObject(parent)
{
    QUuid carThingId;
    m_carThingId = "00000000-0000-0000-0000-000000000000"; //"00000000-0000-0000-0000-000000000000"; //"91849ca3-f49f-49bc-a99c-f01075d050b0"

    QUuid uniqueIdentifier;
    m_uniqueIdentifier = uniqueIdentifier.createUuid();

}

QUuid ChargingConfiguration::evChargerThingId() const
{
    return m_evChargerThingId;
}

void ChargingConfiguration::setEvChargerThingId(const QUuid &evChargerThingId)
{
    m_evChargerThingId = evChargerThingId;
}

bool ChargingConfiguration::optimizationEnabled() const
{
    return m_optimizationEnabled;
}

void ChargingConfiguration::setOptimizationEnabled(bool optimizationEnabled)
{
    if (m_optimizationEnabled == optimizationEnabled)
        return;

    m_optimizationEnabled = optimizationEnabled;
    emit optimizationEnabledChanged(m_optimizationEnabled);
}

QUuid ChargingConfiguration::carThingId() const
{
    return m_carThingId;
}

void ChargingConfiguration::setCarThingId(const QUuid &carThingId)
{
    if (m_carThingId == carThingId)
        return;

    m_carThingId = carThingId;
    emit carThingIdChanged(m_carThingId);
}
// This was QTime before, but QTime showed some weird behaviour, so for now we use QString and transform it if necessary
QString ChargingConfiguration::endTime() const
{
    return m_endTime;
}

void ChargingConfiguration::setEndTime(const QString &endTime)
{
    if (m_endTime == endTime)
        return;

    m_endTime = endTime;
    emit endTimeChanged(m_endTime);
}

uint ChargingConfiguration::targetPercentage() const
{
    return m_targetPercentage;
}

void ChargingConfiguration::setTargetPercentage(uint targetPercentage)
{
    if (m_targetPercentage == targetPercentage)
        return;

    m_targetPercentage = targetPercentage;
    emit targetPercentageChanged(m_targetPercentage);
}

int ChargingConfiguration::optimizationMode() const
{
    return m_optimizationMode;
}

void ChargingConfiguration::setOptimizationMode( int optimizationMode)
{
    if (m_optimizationMode == optimizationMode)
        return;

    m_optimizationMode = optimizationMode;
    emit optimizationModeChanged(m_optimizationMode);
}

QUuid ChargingConfiguration::uniqueIdentifier() const
{
    return m_uniqueIdentifier;
}

void ChargingConfiguration::setUniqueIdentifier(QUuid uniqueIdentifier)
{
    if (m_uniqueIdentifier == uniqueIdentifier)
        return;

    m_uniqueIdentifier = uniqueIdentifier;
    emit uniqueIdentifierChanged(m_uniqueIdentifier);
}

bool ChargingConfiguration::controllableLocalSystem() const
{
    return m_controllableLocalSystem;
}

void ChargingConfiguration::setControllableLocalSystem(bool controllableLocalSystem)
{
    if (m_controllableLocalSystem == controllableLocalSystem)
        return;

    m_controllableLocalSystem = controllableLocalSystem;
    emit controllableLocalSystemChanged(m_controllableLocalSystem);

}

float ChargingConfiguration::priceThreshold() const {
    return m_priceThreshold;
}

void ChargingConfiguration::setPriceThreshold(float priceThreshold) {

    if (m_priceThreshold == priceThreshold)
        return;

    m_priceThreshold = priceThreshold;
    emit priceThresholdChanged(m_priceThreshold);
}

QString ChargingConfiguration::chargingSchedule() const {
    return m_chargingSchedule;
}

void ChargingConfiguration::setChargingSchedule(const QString &chargingSchedule) {
    if (m_chargingSchedule == chargingSchedule)
        return;

    m_chargingSchedule = chargingSchedule;
    emit chargingScheduleChanged(m_chargingSchedule);
}
