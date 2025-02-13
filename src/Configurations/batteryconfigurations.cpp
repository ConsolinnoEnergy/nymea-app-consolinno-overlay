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
    case RoleRelativePriceEnabled:
        return m_list.at(index.row())->relativePriceEnabled();
    case RoleChargeOnce:
        return m_list.at(index.row())->chargeOnce();
    case RoleControllableLocalSystemEnabled:
        return m_list.at(index.row())->controllableLocalSystem();
    }
    return QVariant();
}

QHash<int, QByteArray> BatteryConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleBatteryThingId, "batteryThingId");
    roles.insert(RoleOptimizationEnabled, "optimizationEnabled");
    roles.insert(RolePriceThreshold, "priceThreshold");
    roles.insert(RoleRelativePriceEnabled, "relativePriceEnabled");
    roles.insert(RoleChargeOnce, "chargeOnce");
    roles.insert(RoleControllableLocalSystemEnabled, "controllableLocalSystem");
    return roles;
}

BatteryConfiguration *BatteryConfigurations::getBatteryConfiguration(const QUuid &batteryThingId) const
{
    foreach (BatteryConfiguration *batteryConfig, m_list) {
        if (batteryConfig->batteryThingId() == batteryThingId) {
            qWarning() << "BatteryConfiguration:" << batteryConfig;
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

