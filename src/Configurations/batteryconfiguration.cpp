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

float BatteryConfiguration::maxElectricalPower() const
{
    return m_maxElectricalPower;
}

void BatteryConfiguration::setMaxElectricalPower(float maxElectricalPower)
{
    if (qFuzzyCompare(m_maxElectricalPower, maxElectricalPower))
        return;
    m_maxElectricalPower = maxElectricalPower;
    emit maxElectricalPowerChanged(m_maxElectricalPower);
}

QVariantList BatteryConfiguration::targetSocPvSurplus() const
{
    return m_targetSocPvSurplus;
}

void BatteryConfiguration::setTargetSocPvSurplus(const QVariantList &targetSocPvSurplus)
{
    if (m_targetSocPvSurplus == targetSocPvSurplus)
        return;
    m_targetSocPvSurplus = targetSocPvSurplus;
    emit targetSocPvSurplusChanged(m_targetSocPvSurplus);
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

int BatteryConfiguration::selfConsumptionSocFull() const
{
    return m_selfConsumptionSocFull;
}

void BatteryConfiguration::setSelfConsumptionSocFull(int selfConsumptionSocFull)
{
    if (m_selfConsumptionSocFull == selfConsumptionSocFull)
        return;
    m_selfConsumptionSocFull = selfConsumptionSocFull;
    emit selfConsumptionSocFullChanged(m_selfConsumptionSocFull);
}

int BatteryConfiguration::selfConsumptionSocEmpty() const
{
    return m_selfConsumptionSocEmpty;
}

void BatteryConfiguration::setSelfConsumptionSocEmpty(int selfConsumptionSocEmpty)
{
    if (m_selfConsumptionSocEmpty == selfConsumptionSocEmpty)
        return;
    m_selfConsumptionSocEmpty = selfConsumptionSocEmpty;
    emit selfConsumptionSocEmptyChanged(m_selfConsumptionSocEmpty);
}

int BatteryConfiguration::selfConsumptionSocTaper() const
{
    return m_selfConsumptionSocTaper;
}

void BatteryConfiguration::setSelfConsumptionSocTaper(int selfConsumptionSocTaper)
{
    if (m_selfConsumptionSocTaper == selfConsumptionSocTaper)
        return;
    m_selfConsumptionSocTaper = selfConsumptionSocTaper;
    emit selfConsumptionSocTaperChanged(m_selfConsumptionSocTaper);
}

int BatteryConfiguration::selfConsumptionMaxPower() const
{
    return m_selfConsumptionMaxPower;
}

void BatteryConfiguration::setSelfConsumptionMaxPower(int selfConsumptionMaxPower)
{
    if (m_selfConsumptionMaxPower == selfConsumptionMaxPower)
        return;
    m_selfConsumptionMaxPower = selfConsumptionMaxPower;
    emit selfConsumptionMaxPowerChanged(m_selfConsumptionMaxPower);
}

float BatteryConfiguration::selfConsumptionPriority() const
{
    return m_selfConsumptionPriority;
}

void BatteryConfiguration::setSelfConsumptionPriority(float selfConsumptionPriority)
{
    if (qFuzzyCompare(m_selfConsumptionPriority, selfConsumptionPriority))
        return;
    m_selfConsumptionPriority = selfConsumptionPriority;
    emit selfConsumptionPriorityChanged(m_selfConsumptionPriority);
}

int BatteryConfiguration::selfConsumptionRateLimit() const
{
    return m_selfConsumptionRateLimit;
}

void BatteryConfiguration::setSelfConsumptionRateLimit(int selfConsumptionRateLimit)
{
    if (m_selfConsumptionRateLimit == selfConsumptionRateLimit)
        return;
    m_selfConsumptionRateLimit = selfConsumptionRateLimit;
    emit selfConsumptionRateLimitChanged(m_selfConsumptionRateLimit);
}