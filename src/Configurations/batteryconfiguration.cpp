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
    if(m_avoidZeroFeedInActive == avoidZeroFeedInActive)
        return;

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

float BatteryConfiguration::dischargePriceThreshold() const {
    return m_dischargePriceThreshold;
}

void BatteryConfiguration::setDischargePriceThreshold(float dischargePriceThreshold) {
    m_dischargePriceThreshold = dischargePriceThreshold;
    emit dischargePriceThresholdChanged(m_dischargePriceThreshold);
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

int BatteryConfiguration::blockBatteryOnGridConsumption() const
{
    return m_blockBatteryOnGridConsumption;
}

void BatteryConfiguration::setBlockBatteryOnGridConsumption(int blockBatteryOnGridConsumption)
{
    if (m_blockBatteryOnGridConsumption == blockBatteryOnGridConsumption) { return; }
    m_blockBatteryOnGridConsumption = blockBatteryOnGridConsumption;
    emit blockBatteryOnGridConsumptionChanged(m_blockBatteryOnGridConsumption);
}

bool BatteryConfiguration::selfConsumptionEnabled() const
{
    return m_selfConsumptionEnabled;
}

void BatteryConfiguration::setSelfConsumptionEnabled(bool selfConsumptionEnabled)
{
    if (m_selfConsumptionEnabled == selfConsumptionEnabled)
        return;
    m_selfConsumptionEnabled = selfConsumptionEnabled;
    emit selfConsumptionEnabledChanged(m_selfConsumptionEnabled);
}

float BatteryConfiguration::selfConsumptionCapacity() const
{
    return m_selfConsumptionCapacity;
}

void BatteryConfiguration::setSelfConsumptionCapacity(float selfConsumptionCapacity)
{
    if (qFuzzyCompare(m_selfConsumptionCapacity, selfConsumptionCapacity))
        return;
    m_selfConsumptionCapacity = selfConsumptionCapacity;
    emit selfConsumptionCapacityChanged(m_selfConsumptionCapacity);
}

int BatteryConfiguration::targetSocPvSurplusMin() const
{
    return m_targetSocPvSurplusMin;
}

void BatteryConfiguration::setTargetSocPvSurplusMin(int targetSocPvSurplusMin)
{
    if (m_targetSocPvSurplusMin == targetSocPvSurplusMin)
        return;
    m_targetSocPvSurplusMin = targetSocPvSurplusMin;
    emit targetSocPvSurplusMinChanged(m_targetSocPvSurplusMin);
}

int BatteryConfiguration::targetSocPvSurplusMax() const
{
    return m_targetSocPvSurplusMax;
}

void BatteryConfiguration::setTargetSocPvSurplusMax(int targetSocPvSurplusMax)
{
    if (m_targetSocPvSurplusMax == targetSocPvSurplusMax)
        return;
    m_targetSocPvSurplusMax = targetSocPvSurplusMax;
    emit targetSocPvSurplusMaxChanged(m_targetSocPvSurplusMax);
}