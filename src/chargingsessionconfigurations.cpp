#include "chargingsessionconfigurations.h"

ChargingSessionConfigurations::ChargingSessionConfigurations(QObject *parent) :
    QAbstractListModel(parent)
{

}

int ChargingSessionConfigurations::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant ChargingSessionConfigurations::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleChargingSessionThingId:
        return m_list.at(index.row())->chargingSessionThingId();
    case RoleEvChargerThingId:
        return m_list.at(index.row())->evChargerThingId();
    case RoleCarThingId:
        return m_list.at(index.row())->carThingId();
    case RoleStarted_at:
        return m_list.at(index.row())->startedAt();
    case RoleFinished_at:
        return m_list.at(index.row())->finishedAt();
    case RoleInitial_Battery_Energy:
        return m_list.at(index.row())->initialBatteryEnergy();
    case RoleEnergy_Charged:
        return m_list.at(index.row())->energyCharged();
    case RoleDuration:
        return m_list.at(index.row())->duration();
    case RoleEnergy_Battery:
        return m_list.at(index.row())->energyBattery();
    case RoleBattery_Level:
        return m_list.at(index.row())->batteryLevel();



    }
    return QVariant();
}

QHash<int, QByteArray> ChargingSessionConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleChargingSessionThingId, "chargingSessionThingId");
    roles.insert(RoleEvChargerThingId, "evChargerThingId");
    roles.insert(RoleCarThingId, "carThingId");
    roles.insert(RoleStarted_at, "started_at");
    roles.insert(RoleFinished_at, "finished_at");
    roles.insert(RoleInitial_Battery_Energy, "initial_Battery_Energy");
    roles.insert(RoleEnergy_Charged, "energy_Charged");
    roles.insert(RoleDuration, "duration");
    roles.insert(RoleEnergy_Battery, "energy_Battery");
    roles.insert(RoleBattery_Level, "battery_Level");


    return roles;
}

ChargingSessionConfiguration *ChargingSessionConfigurations::getChargingSessionConfiguration(const QUuid &chargingSessionThingId) const
{
    foreach (ChargingSessionConfiguration *chargingSessionConfig, m_list) {
        if (chargingSessionConfig->chargingSessionThingId() == chargingSessionThingId) {
            return chargingSessionConfig;
        }
    }

    return nullptr;
}

void ChargingSessionConfigurations::addConfiguration(ChargingSessionConfiguration *chargingSessionConfiguration)
{
    chargingSessionConfiguration->setParent(this);

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(chargingSessionConfiguration);

    connect(chargingSessionConfiguration, &ChargingSessionConfiguration::evChargerThingIdChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingSessionConfiguration));
        emit dataChanged(idx, idx, {RoleEvChargerThingId});
    });

    connect(chargingSessionConfiguration, &ChargingSessionConfiguration::carThingIdChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingSessionConfiguration));
        emit dataChanged(idx, idx, {RoleCarThingId});
    });

    connect(chargingSessionConfiguration, &ChargingSessionConfiguration::startedAtChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingSessionConfiguration));
        emit dataChanged(idx, idx, {RoleStarted_at});
    });

    connect(chargingSessionConfiguration, &ChargingSessionConfiguration::finishedAtChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingSessionConfiguration));
        emit dataChanged(idx, idx, {RoleFinished_at});
    });

    connect(chargingSessionConfiguration, &ChargingSessionConfiguration::initialBatteryEnergyChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingSessionConfiguration));
        emit dataChanged(idx, idx, {RoleInitial_Battery_Energy});
    });

    connect(chargingSessionConfiguration, &ChargingSessionConfiguration::durationChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingSessionConfiguration));
        emit dataChanged(idx, idx, {RoleDuration});
    });

    connect(chargingSessionConfiguration, &ChargingSessionConfiguration::energyChargedChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingSessionConfiguration));
        emit dataChanged(idx, idx, {RoleEnergy_Charged});
    });

    connect(chargingSessionConfiguration, &ChargingSessionConfiguration::energyBatteryChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingSessionConfiguration));
        emit dataChanged(idx, idx, {RoleEnergy_Battery});
    });

    connect(chargingSessionConfiguration, &ChargingSessionConfiguration::batteryLevelChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingSessionConfiguration));
        emit dataChanged(idx, idx, {RoleBattery_Level});
    });

    endInsertRows();

    emit countChanged();
}

void ChargingSessionConfigurations::removeConfiguration(const QUuid &chargingSessionThingId)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->chargingSessionThingId() == chargingSessionThingId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            return;
        }
    }
}

