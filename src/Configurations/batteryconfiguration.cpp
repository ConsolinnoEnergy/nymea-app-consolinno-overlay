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

bool BatteryConfiguration::avoidZeroFeedInActive() const
{
    return m_avoidZeroFeedInActive;
}

void BatteryConfiguration::setAvoidZeroFeedInActive(bool avoidZeroFeedInActive)
{
    /*
    if(m_avoidZeroFeedInActive == avoidZeroFeedInActive)
        return;*/

    m_avoidZeroFeedInActive = avoidZeroFeedInActive;
    emit avoidZeroFeedInActiveChanged(m_avoidZeroFeedInActive);
}

bool BatteryConfiguration::avoidZeroFeedInEnabled() const
{
    return m_avoidZeroFeedInEnabled;
}

void BatteryConfiguration::setAvoidZeroFeedInEnabled(bool avoidZeroFeedInEnabled)
{
    if(m_avoidZeroFeedInEnabled == avoidZeroFeedInEnabled)
        return;

    m_avoidZeroFeedInEnabled = avoidZeroFeedInEnabled;
    emit avoidZeroFeedInEnabledChanged(m_avoidZeroFeedInEnabled);
}


float BatteryConfiguration::priceThreshold() const {
    return m_priceThreshold;
}

void BatteryConfiguration::setPriceThreshold(float priceThreshold) {

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
