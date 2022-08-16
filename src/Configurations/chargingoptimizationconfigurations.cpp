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
    case RoleP_Value:
        return m_list.at(index.row())->p_value();
    case RoleI_Value:
        return m_list.at(index.row())->i_value();
    case RoleD_Value:
        return m_list.at(index.row())->d_value();
    case RoleSetpoint:
        return m_list.at(index.row())->setpoint();
    }
    return QVariant();
}

QHash<int, QByteArray> ChargingOptimizationConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleEvChargerThingId, "evChargerThingId");
    roles.insert(RoleReenableChargepoint, "reenableChargepoint");
    roles.insert(RoleP_Value, "p_value");
    roles.insert(RoleI_Value, "i_value");
    roles.insert(RoleD_Value, "d_value");
    roles.insert(RoleSetpoint, "setpoint");
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
    connect(chargingOptimizationConfiguration, &ChargingOptimizationConfiguration::p_valueChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingOptimizationConfiguration));
        emit dataChanged(idx, idx, {RoleP_Value});
    });
    connect(chargingOptimizationConfiguration, &ChargingOptimizationConfiguration::i_valueChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingOptimizationConfiguration));
        emit dataChanged(idx, idx, {RoleI_Value});
    });
    connect(chargingOptimizationConfiguration, &ChargingOptimizationConfiguration::d_valueChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingOptimizationConfiguration));
        emit dataChanged(idx, idx, {RoleD_Value});
    });
    connect(chargingOptimizationConfiguration, &ChargingOptimizationConfiguration::setpointChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingOptimizationConfiguration));
        emit dataChanged(idx, idx, {RoleSetpoint});
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


