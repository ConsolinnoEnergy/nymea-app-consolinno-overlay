#include "whitegoodconfigurations.h"
#include <QDebug>
#include "logging.h"

NYMEA_LOGGING_CATEGORY(whiteGoodConfiguration, "whiteGoodConfig")

WhiteGoodConfigurations::WhiteGoodConfigurations(QObject *parent) :
    QAbstractListModel(parent)
{

}

int WhiteGoodConfigurations::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant WhiteGoodConfigurations::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleWhiteGoodThingId:
        return m_list.at(index.row())->whiteGoodThingId();
    case RoleOperatingMode:
        return m_list.at(index.row())->operatingMode();
    case RoleOptimizationStrategies:
        return m_list.at(index.row())->optimizationStrategies();
    case RoleControllableLocalSystem:
        return m_list.at(index.row())->controllableLocalSystem();
    case RolePriceThreshold:
        return m_list.at(index.row())->priceThreshold();
    case RoleDischargePriceThreshold:
        return m_list.at(index.row())->dischargePriceThreshold();
    case RoleTimeSchedule:
        return m_list.at(index.row())->timeSchedule();
    }
    return QVariant();
}

QHash<int, QByteArray> WhiteGoodConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleWhiteGoodThingId, "whiteGoodThingId");
    roles.insert(RoleOperatingMode, "operatingMode");
    roles.insert(RoleOptimizationStrategies, "optimizationStrategies");
    roles.insert(RoleControllableLocalSystem, "controllableLocalSystem");
    roles.insert(RolePriceThreshold, "priceThreshold");
    roles.insert(RoleDischargePriceThreshold, "dischargePriceThreshold");
    roles.insert(RoleTimeSchedule, "timeSchedule");
    return roles;
}

WhiteGoodConfiguration *WhiteGoodConfigurations::getWhiteGoodConfiguration(const QUuid &whiteGoodThingId) const
{

    foreach (WhiteGoodConfiguration *whiteGoodConfig, m_list) {
        if (whiteGoodConfig->whiteGoodThingId() == whiteGoodThingId) {
            return whiteGoodConfig;
        }
    }

    return nullptr;
}

WhiteGoodConfiguration *WhiteGoodConfigurations::get(int index) const
{
    if (index < 0 || index >= m_list.count())
        return nullptr;

    return m_list.at(index);
}

void WhiteGoodConfigurations::addConfiguration(WhiteGoodConfiguration *whiteGoodConfiguration)
{
    whiteGoodConfiguration->setParent(this);

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(whiteGoodConfiguration);

    connect(whiteGoodConfiguration, &WhiteGoodConfiguration::operatingModeChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(whiteGoodConfiguration));
        emit dataChanged(idx, idx, {RoleOperatingMode});
    });

    connect(whiteGoodConfiguration, &WhiteGoodConfiguration::optimizationStrategiesChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(whiteGoodConfiguration));
        emit dataChanged(idx, idx, {RoleOptimizationStrategies});
    });

    connect(whiteGoodConfiguration, &WhiteGoodConfiguration::controllableLocalSystemChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(whiteGoodConfiguration));
        emit dataChanged(idx, idx, {RoleControllableLocalSystem});
    });

    connect(whiteGoodConfiguration, &WhiteGoodConfiguration::priceThresholdChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(whiteGoodConfiguration));
        emit dataChanged(idx, idx, {RolePriceThreshold});
    });

    connect(whiteGoodConfiguration, &WhiteGoodConfiguration::dischargePriceThresholdChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(whiteGoodConfiguration));
        emit dataChanged(idx, idx, {RoleDischargePriceThreshold});
    });

    connect(whiteGoodConfiguration, &WhiteGoodConfiguration::timeScheduleChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(whiteGoodConfiguration));
        emit dataChanged(idx, idx, {RoleTimeSchedule});
    });
    endInsertRows();

    emit countChanged();
}

void WhiteGoodConfigurations::removeConfiguration(const QUuid &whiteGoodThingId)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->whiteGoodThingId() == whiteGoodThingId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            return;
        }
    }
}

