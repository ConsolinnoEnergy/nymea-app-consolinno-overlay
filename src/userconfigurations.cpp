#include "userconfigurations.h"

UserConfigurations::UserConfigurations(QObject *parent) :
    QAbstractListModel(parent)
{

}
int UserConfigurations::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant UserConfigurations::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleUserConfigID:
        return m_list.at(index.row())->userConfigID();
    case RoleLastSelectedCar:
        return m_list.at(index.row())->lastSelectedCar();
    case RoleDefaultChargingMode:
        return m_list.at(index.row())->defaultChargingMode();
    }
    return QVariant();
}

QHash<int, QByteArray> UserConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleUserConfigID, "userConfigId");
    roles.insert(RoleDefaultChargingMode, "defaultChargingMode");
    roles.insert(RoleLastSelectedCar, "lastSelectedCar");
    return roles;
}

UserConfiguration *UserConfigurations::getUserConfiguration(const QUuid &userconfigId) const
{
    foreach (UserConfiguration *userconfig, m_list) {
        if (userconfig->userConfigID() == userconfigId) {
            return userconfig;
        }
    }

    return nullptr;
}

void UserConfigurations::addConfiguration(UserConfiguration *userconfiguration)
{
    userconfiguration->setParent(this);

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(userconfiguration);

    connect(userconfiguration, &UserConfiguration::lastSelectedCarChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(userconfiguration));
        emit dataChanged(idx, idx, {RoleLastSelectedCar});
    });

    connect(userconfiguration, &UserConfiguration::defaultChargingModeChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(userconfiguration));
        emit dataChanged(idx, idx, {RoleDefaultChargingMode});
    });

    endInsertRows();
    emit countChanged();
}

void UserConfigurations::removeConfiguration(const QUuid &userconfigID)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->userConfigID() == userconfigID) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            return;
        }
    }
}

