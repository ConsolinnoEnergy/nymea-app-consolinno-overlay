#include "switchableconsumerconfigurations.h"

SwitchableConsumerConfigurations::SwitchableConsumerConfigurations(QObject *parent) :
    QAbstractListModel(parent)
{
}

int SwitchableConsumerConfigurations::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant SwitchableConsumerConfigurations::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleSwitchableConsumerThingId:
        return m_list.at(index.row())->switchableConsumerThingId();
    case RoleOptimizationMode:
        return m_list.at(index.row())->optimizationMode();
    case RoleMaxElectricalPower:
        return m_list.at(index.row())->maxElectricalPower();
    case RolePvSurplusThreshold:
        return m_list.at(index.row())->pvSurplusThreshold();
    case RoleDurationMinAfterTurnOn:
        return m_list.at(index.row())->durationMinAfterTurnOn();
    case RoleDurationMaxTotal:
        return m_list.at(index.row())->durationMaxTotal();
    case RoleControllableLocalSystem:
        return m_list.at(index.row())->controllableLocalSystem();
    }

    return QVariant();
}

QHash<int, QByteArray> SwitchableConsumerConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleSwitchableConsumerThingId, "switchableConsumerThingId");
    roles.insert(RoleOptimizationMode, "optimizationMode");
    roles.insert(RoleMaxElectricalPower, "maxElectricalPower");
    roles.insert(RolePvSurplusThreshold, "pvSurplusThreshold");
    roles.insert(RoleDurationMinAfterTurnOn, "durationMinAfterTurnOn");
    roles.insert(RoleDurationMaxTotal, "durationMaxTotal");
    roles.insert(RoleControllableLocalSystem, "controllableLocalSystem");
    return roles;
}

SwitchableConsumerConfiguration *SwitchableConsumerConfigurations::getSwitchableConsumerConfiguration(const QUuid &switchableConsumerThingId) const
{
    foreach (SwitchableConsumerConfiguration *config, m_list) {
        if (config->switchableConsumerThingId() == switchableConsumerThingId) {
            return config;
        }
    }
    return nullptr;
}

SwitchableConsumerConfiguration *SwitchableConsumerConfigurations::get(int index) const
{
    if (index < 0 || index >= m_list.count())
        return nullptr;

    return m_list.at(index);
}

void SwitchableConsumerConfigurations::addConfiguration(SwitchableConsumerConfiguration *configuration)
{
    configuration->setParent(this);

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(configuration);

    connect(configuration, &SwitchableConsumerConfiguration::optimizationModeChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(configuration));
        emit dataChanged(idx, idx, {RoleOptimizationMode});
    });

    connect(configuration, &SwitchableConsumerConfiguration::maxElectricalPowerChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(configuration));
        emit dataChanged(idx, idx, {RoleMaxElectricalPower});
    });

    connect(configuration, &SwitchableConsumerConfiguration::pvSurplusThresholdChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(configuration));
        emit dataChanged(idx, idx, {RolePvSurplusThreshold});
    });

    connect(configuration, &SwitchableConsumerConfiguration::durationMinAfterTurnOnChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(configuration));
        emit dataChanged(idx, idx, {RoleDurationMinAfterTurnOn});
    });

    connect(configuration, &SwitchableConsumerConfiguration::durationMaxTotalChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(configuration));
        emit dataChanged(idx, idx, {RoleDurationMaxTotal});
    });

    connect(configuration, &SwitchableConsumerConfiguration::controllableLocalSystemChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(configuration));
        emit dataChanged(idx, idx, {RoleControllableLocalSystem});
    });

    endInsertRows();

    emit countChanged();
}

void SwitchableConsumerConfigurations::removeConfiguration(const QUuid &switchableConsumerThingId)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->switchableConsumerThingId() == switchableConsumerThingId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
            return;
        }
    }
}
