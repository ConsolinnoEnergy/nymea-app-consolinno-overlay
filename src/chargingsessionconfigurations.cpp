#include "chargingsessionconfigurations.h"
#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcChargingSessionConfig, "ChargingSessionConfig")


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
    case RoleEvChargerThingId:
        return m_list.at(index.row())->evChargerThingId();   
    case RoleState:
        return m_list.at(index.row())->state();
    case RoleSessionId:
        return m_list.at(index.row())->sessionId();
    case RoleTimestamp:
        return m_list.at(index.row())->timestamp();
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
    roles.insert(RoleEvChargerThingId, "evChargerThingId");
    roles.insert(RoleCarThingId, "carThingId");
    roles.insert(RoleState, "state");
    roles.insert(RoleSessionId, "sessionId");
    roles.insert(RoleTimestamp, "timestamp");
    roles.insert(RoleStarted_at, "startedAt");
    roles.insert(RoleFinished_at, "finishedAt");
    roles.insert(RoleInitial_Battery_Energy, "initialBatteryEnergy");
    roles.insert(RoleEnergy_Charged, "energyCharged");
    roles.insert(RoleDuration, "duration");
    roles.insert(RoleEnergy_Battery, "energyBattery");
    roles.insert(RoleBattery_Level, "batteryLevel");


    return roles;
}

ChargingSessionConfiguration *ChargingSessionConfigurations::getChargingSessionConfiguration(const QUuid &evChargerThingId) const
{

    foreach (ChargingSessionConfiguration *chargingSessionConfig, m_list) {

        if (chargingSessionConfig->evChargerThingId() == evChargerThingId) {
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

    connect(chargingSessionConfiguration, &ChargingSessionConfiguration::stateChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingSessionConfiguration));
        emit dataChanged(idx, idx, {RoleState});
    });

    connect(chargingSessionConfiguration, &ChargingSessionConfiguration::sessionIdChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingSessionConfiguration));
        emit dataChanged(idx, idx, {RoleSessionId});
    });

    connect(chargingSessionConfiguration, &ChargingSessionConfiguration::timestampChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(chargingSessionConfiguration));
        emit dataChanged(idx, idx, {RoleTimestamp});
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

void ChargingSessionConfigurations::removeConfiguration(const QUuid &evChargerThingId)
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

