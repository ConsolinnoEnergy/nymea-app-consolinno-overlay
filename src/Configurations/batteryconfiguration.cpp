#include "batteryconfiguration.h"

BatteryConfiguration::BatteryConfiguration(QObject *parent) : QObject(parent)
{

}

QUuid BatteryConfiguration::batteryThingId() const
{
    return m_batteryThingId;
}

void BatteryConfiguration::setBatteryThingId(const QUuid &batteryThingId)
{
    m_batteryThingId = batteryThingId;
}

bool BatteryConfiguration::optimizationEnabled() const
{
    return m_optimizationEnabled;
}

void BatteryConfiguration::setOptimizationEnabled(bool optimizationEnabled)
{
    if (m_optimizationEnabled == optimizationEnabled)
        return;

    m_optimizationEnabled = optimizationEnabled;
    emit optimizationEnabledChanged(m_optimizationEnabled);
}

float BatteryConfiguration::priceThreshold() const {
    return m_priceThreshold;
}

void BatteryConfiguration::setPriceThreshold(float priceThreshold) {
    if (m_priceThreshold == priceThreshold)
        return;

    m_priceThreshold = priceThreshold;
    emit priceThresholdChanged(m_priceThreshold);
}

bool BatteryConfiguration::relativePriceEnabled() const {
    return m_relativePriceEnabled;
}

void BatteryConfiguration::setRelativePriceEnabled(bool relativePriceEnabled) {
    if (m_relativePriceEnabled == relativePriceEnabled)
        return;

    m_relativePriceEnabled = relativePriceEnabled;
    emit relativePriceEnabledChanged(m_relativePriceEnabled);
}

bool BatteryConfiguration::chargeOnce() const {
    return m_chargeOnce;
}

void BatteryConfiguration::setChargeOnce(bool chargeOnce) {
    if (m_chargeOnce == chargeOnce)
        return;

    m_chargeOnce = chargeOnce;
    emit chargeOnceChanged(m_chargeOnce);
}

bool BatteryConfiguration::controllableLocalSystem() const
{
    return m_controllableLocalSystem;
}

void BatteryConfiguration::setControllableLocalSystem(bool controllableLocalSystem)
{
    if (m_controllableLocalSystem == controllableLocalSystem)
        return;

    m_controllableLocalSystem = controllableLocalSystem;
    emit controllableLocalSystemChanged(m_controllableLocalSystem);
}
