#include "batteryconfigurations.h"
#include<QDebug>


BatteryConfigurations::BatteryConfigurations(QObject *parent): QAbstractListModel(parent)
{

}

int BatteryConfigurations::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant BatteryConfigurations::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleBatteryThingId:
        return m_list.at(index.row())->batteryThingId();
    case RoleOptimizationEnabled:
        return m_list.at(index.row())->optimizationEnabled();
    case RolePriceThreshold:
        return m_list.at(index.row())->priceThreshold();
    case RoleDischargePriceThreshold:
        return m_list.at(index.row())->dischargePriceThreshold();
    case RoleRelativePriceEnabled:
        return m_list.at(index.row())->relativePriceEnabled();
    case RoleChargeOnce:
        return m_list.at(index.row())->chargeOnce();
    case RoleControllableLocalSystemEnabled:
        return m_list.at(index.row())->controllableLocalSystem();
    case RoleAvoidZeroFeedInEnabled:
        return m_list.at(index.row())->avoidZeroFeedInEnabled();
    case RoleAvoidZeroFeedInActive:
        return m_list.at(index.row())->avoidZeroFeedInActive();
    case RoleBlockBatteryOnGridConsumption:
        return m_list.at(index.row())->blockBatteryOnGridConsumption();
    // Self-consumption configuration roles (matching backend API)
    case RoleMaxElectricalPower:
        return m_list.at(index.row())->maxElectricalPower();
    case RoleTargetSocPvSurplus:
        return m_list.at(index.row())->targetSocPvSurplus();
    case RoleSelfConsumptionCapacity:
        return m_list.at(index.row())->selfConsumptionCapacity();
    case RoleSelfConsumptionSocFull:
        return m_list.at(index.row())->selfConsumptionSocFull();
    case RoleSelfConsumptionSocEmpty:
        return m_list.at(index.row())->selfConsumptionSocEmpty();
    case RoleSelfConsumptionSocTaper:
        return m_list.at(index.row())->selfConsumptionSocTaper();
    case RoleSelfConsumptionMaxPower:
        return m_list.at(index.row())->selfConsumptionMaxPower();
    case RoleSelfConsumptionPriority:
        return m_list.at(index.row())->selfConsumptionPriority();
    case RoleSelfConsumptionRateLimit:
        return m_list.at(index.row())->selfConsumptionRateLimit();
    }
    return QVariant();
}

QHash<int, QByteArray> BatteryConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleBatteryThingId, "batteryThingId");
    roles.insert(RoleOptimizationEnabled, "optimizationEnabled");
    roles.insert(RolePriceThreshold, "priceThreshold");
    roles.insert(RoleDischargePriceThreshold, "dischargePriceThreshold");
    roles.insert(RoleRelativePriceEnabled, "relativePriceEnabled");
    roles.insert(RoleChargeOnce, "chargeOnce");
    roles.insert(RoleControllableLocalSystemEnabled, "controllableLocalSystem");
    roles.insert(RoleAvoidZeroFeedInEnabled, "avoidZeroFeedInEnabled");
    roles.insert(RoleAvoidZeroFeedInActive, "avoidZeroFeedInActive");
    roles.insert(RoleBlockBatteryOnGridConsumption, "blockBatteryOnGridConsumption");
    // Self-consumption configuration roles (matching backend API)
    roles.insert(RoleMaxElectricalPower, "maxElectricalPower");
    roles.insert(RoleTargetSocPvSurplus, "targetSocPvSurplus");
    roles.insert(RoleSelfConsumptionCapacity, "selfConsumptionCapacity");
    roles.insert(RoleSelfConsumptionSocFull, "selfConsumptionSocFull");
    roles.insert(RoleSelfConsumptionSocEmpty, "selfConsumptionSocEmpty");
    roles.insert(RoleSelfConsumptionSocTaper, "selfConsumptionSocTaper");
    roles.insert(RoleSelfConsumptionMaxPower, "selfConsumptionMaxPower");
    roles.insert(RoleSelfConsumptionPriority, "selfConsumptionPriority");
    roles.insert(RoleSelfConsumptionRateLimit, "selfConsumptionRateLimit");
    return roles;
}

BatteryConfiguration *BatteryConfigurations::getBatteryConfiguration(const QUuid &batteryThingId) const
{
    foreach (BatteryConfiguration *batteryConfig, m_list) {
        if (batteryConfig->batteryThingId() == batteryThingId) {
            // print to stdout
            return batteryConfig;
        }
    }

    return nullptr;
}

BatteryConfiguration *BatteryConfigurations::get(int index) const
{
    if (index < 0 || index >= m_list.count())
        return nullptr;

    return m_list.at(index);
}

void BatteryConfigurations::addConfiguration(BatteryConfiguration *batteryConfiguration)
{
    batteryConfiguration->setParent(this);

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(batteryConfiguration);

    connect(batteryConfiguration, &BatteryConfiguration::optimizationEnabledChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleOptimizationEnabled});
    });

    connect(batteryConfiguration, &BatteryConfiguration::priceThresholdChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RolePriceThreshold});
    });

    connect(batteryConfiguration, &BatteryConfiguration::dischargePriceThresholdChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleDischargePriceThreshold});
    });

    connect(batteryConfiguration, &BatteryConfiguration::relativePriceEnabledChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleRelativePriceEnabled});
    });

    connect(batteryConfiguration, &BatteryConfiguration::chargeOnceChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleChargeOnce});
    });

    connect(batteryConfiguration, &BatteryConfiguration::controllableLocalSystemChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleControllableLocalSystemEnabled});
    });

    connect(batteryConfiguration, &BatteryConfiguration::avoidZeroFeedInActiveChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleAvoidZeroFeedInActive});
    });

    connect(batteryConfiguration, &BatteryConfiguration::avoidZeroFeedInEnabledChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleAvoidZeroFeedInEnabled});
    });

    connect(batteryConfiguration, &BatteryConfiguration::blockBatteryOnGridConsumptionChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleBlockBatteryOnGridConsumption});
    });

    // Self-consumption configuration signal connections (matching backend API)
    connect(batteryConfiguration, &BatteryConfiguration::maxElectricalPowerChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleMaxElectricalPower});
    });

    connect(batteryConfiguration, &BatteryConfiguration::targetSocPvSurplusChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleTargetSocPvSurplus});
    });

    connect(batteryConfiguration, &BatteryConfiguration::selfConsumptionCapacityChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleSelfConsumptionCapacity});
    });

    connect(batteryConfiguration, &BatteryConfiguration::selfConsumptionSocFullChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleSelfConsumptionSocFull});
    });

    connect(batteryConfiguration, &BatteryConfiguration::selfConsumptionSocEmptyChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleSelfConsumptionSocEmpty});
    });

    connect(batteryConfiguration, &BatteryConfiguration::selfConsumptionSocTaperChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleSelfConsumptionSocTaper});
    });

    connect(batteryConfiguration, &BatteryConfiguration::selfConsumptionMaxPowerChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleSelfConsumptionMaxPower});
    });

    connect(batteryConfiguration, &BatteryConfiguration::selfConsumptionPriorityChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleSelfConsumptionPriority});
    });

    connect(batteryConfiguration, &BatteryConfiguration::selfConsumptionRateLimitChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(batteryConfiguration));
        emit dataChanged(idx, idx, {RoleSelfConsumptionRateLimit});
    });

    endInsertRows();

    emit countChanged();
}

void BatteryConfigurations::removeConfiguration(const QUuid &batteryThingId)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->batteryThingId() == batteryThingId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            return;
        }
    }
}

