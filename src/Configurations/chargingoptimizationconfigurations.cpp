#include "chargingoptimizationconfigurations.h"

ChargingOptimizationConfigurations::ChargingOptimizationConfigurations(QObject *parent) :
    QAbstractListModel(parent)
{

}

int ChargingOptimizationConfigurations::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}


QVariant ChargingOptimizationConfigurations::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleEvChargerThingId:
        return m_list.at(index.row())->evChargerThingId();
    case RoleReenableChargepoint:
        return m_list.at(index.row())->reenableChargepoint();
    }
    return QVariant();
}

QHash<int, QByteArray> ChargingOptimizationConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleEvChargerThingId, "evChargerThingId");
    roles.insert(RoleReenableChargepoint, "reenableChargepoint");
    return roles;
}

ChargingOptimizationConfiguration *ChargingOptimizationConfigurations::getChargingOptimizationConfiguration(const QUuid &evChargerThingId) const
{
    foreach (ChargingOptimizationConfiguration *chargingOptimizationConfig, m_list) {
        if (chargingOptimizationConfig->evChargerThingId() == evChargerThingId) {
            return chargingOptimizationConfig;
        }
    }

    return nullptr;
}


void ChargingOptimizationConfigurations::addConfiguration(ChargingOptimizationConfiguration *chargingOptimizationConfiguration)
{
    chargingOptimizationConfiguration->setParent(this);

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(chargingOptimizationConfiguration);

    connect(chargingOptimizationConfiguration, &ChargingOptimizationConfiguration::reenableChargepointChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingOptimizationConfiguration));
        emit dataChanged(idx, idx, {RoleReenableChargepoint});
    });

    endInsertRows();

    emit countChanged();
}

void ChargingOptimizationConfigurations::removeConfiguration(const QUuid &evChargerThingId)
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


