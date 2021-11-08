#include "chargingconfigurations.h"

ChargingConfigurations::ChargingConfigurations(QObject *parent) :
    QAbstractListModel(parent)
{

}

int ChargingConfigurations::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant ChargingConfigurations::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleEvChargerThingId:
        return m_list.at(index.row())->evChargerThingId();
    case RoleOptimizationEnabled:
        return m_list.at(index.row())->optimizationEnabled();
    case RoleCarThingId:
        return m_list.at(index.row())->carThingId();
    case RoleEndTime:
        return m_list.at(index.row())->endTime();
    case RoleTargetPercentage:
        return m_list.at(index.row())->targetPercentage();
    case RoleZeroReturnPolicy:
        return m_list.at(index.row())->zeroReturnPolicyEnabled();
    }
    return QVariant();
}

QHash<int, QByteArray> ChargingConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleEvChargerThingId, "evChargerThingId");
    roles.insert(RoleOptimizationEnabled, "optimizationEnabled");
    roles.insert(RoleCarThingId, "carThingId");
    roles.insert(RoleEndTime, "endTime");
    roles.insert(RoleTargetPercentage, "targetPercentage");
    roles.insert(RoleZeroReturnPolicy, "zeroReturnPolicyEnabled");
    return roles;
}

ChargingConfiguration *ChargingConfigurations::getChargingConfiguration(const QUuid &evChargerThingId) const
{
    foreach (ChargingConfiguration *chargingConfig, m_list) {
        if (chargingConfig->evChargerThingId() == evChargerThingId) {
            return chargingConfig;
        }
    }

    return nullptr;
}

void ChargingConfigurations::addConfiguration(ChargingConfiguration *chargingConfiguration)
{
    chargingConfiguration->setParent(this);

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(chargingConfiguration);

    connect(chargingConfiguration, &ChargingConfiguration::optimizationEnabledChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingConfiguration));
        emit dataChanged(idx, idx, {RoleOptimizationEnabled});
    });

    connect(chargingConfiguration, &ChargingConfiguration::carThingIdChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingConfiguration));
        emit dataChanged(idx, idx, {RoleCarThingId});
    });

    connect(chargingConfiguration, &ChargingConfiguration::endTimeChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingConfiguration));
        emit dataChanged(idx, idx, {RoleEndTime});
    });

    connect(chargingConfiguration, &ChargingConfiguration::targetPercentageChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingConfiguration));
        emit dataChanged(idx, idx, {RoleTargetPercentage});
    });

    connect(chargingConfiguration, &ChargingConfiguration::zeroReturnPolicyEnabledChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingConfiguration));
        emit dataChanged(idx, idx, {RoleZeroReturnPolicy});
    });

    endInsertRows();

    emit countChanged();
}

void ChargingConfigurations::removeConfiguration(const QUuid &evChargerThingId)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->evChargerThingId() == evChargerThingId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            return;
        }
    }
}
