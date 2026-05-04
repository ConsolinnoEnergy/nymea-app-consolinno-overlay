#include "switchconfigurations.h"

SwitchConfigurations::SwitchConfigurations(QObject *parent) :
    QAbstractListModel(parent)
{
}

int SwitchConfigurations::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant SwitchConfigurations::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleSwitchThingId:
        return m_list.at(index.row())->switchThingId();
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

QHash<int, QByteArray> SwitchConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleSwitchThingId, "switchThingId");
    roles.insert(RoleOptimizationMode, "optimizationMode");
    roles.insert(RoleMaxElectricalPower, "maxElectricalPower");
    roles.insert(RolePvSurplusThreshold, "pvSurplusThreshold");
    roles.insert(RoleDurationMinAfterTurnOn, "durationMinAfterTurnOn");
    roles.insert(RoleDurationMaxTotal, "durationMaxTotal");
    roles.insert(RoleControllableLocalSystem, "controllableLocalSystem");
    return roles;
}

SwitchConfiguration *SwitchConfigurations::getSwitchConfiguration(const QUuid &switchThingId) const
{
    foreach (SwitchConfiguration *config, m_list) {
        if (config->switchThingId() == switchThingId) {
            return config;
        }
    }
    return nullptr;
}

SwitchConfiguration *SwitchConfigurations::get(int index) const
{
    if (index < 0 || index >= m_list.count())
        return nullptr;

    return m_list.at(index);
}

void SwitchConfigurations::addConfiguration(SwitchConfiguration *configuration)
{
    configuration->setParent(this);

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(configuration);

    connect(configuration, &SwitchConfiguration::optimizationModeChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(configuration));
        emit dataChanged(idx, idx, {RoleOptimizationMode});
    });

    connect(configuration, &SwitchConfiguration::maxElectricalPowerChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(configuration));
        emit dataChanged(idx, idx, {RoleMaxElectricalPower});
    });

    connect(configuration, &SwitchConfiguration::pvSurplusThresholdChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(configuration));
        emit dataChanged(idx, idx, {RolePvSurplusThreshold});
    });

    connect(configuration, &SwitchConfiguration::durationMinAfterTurnOnChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(configuration));
        emit dataChanged(idx, idx, {RoleDurationMinAfterTurnOn});
    });

    connect(configuration, &SwitchConfiguration::durationMaxTotalChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(configuration));
        emit dataChanged(idx, idx, {RoleDurationMaxTotal});
    });

    connect(configuration, &SwitchConfiguration::controllableLocalSystemChanged, this, [=]() {
        QModelIndex idx = index(m_list.indexOf(configuration));
        emit dataChanged(idx, idx, {RoleControllableLocalSystem});
    });

    endInsertRows();

    emit countChanged();
}

void SwitchConfigurations::removeConfiguration(const QUuid &switchThingId)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->switchThingId() == switchThingId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            emit countChanged();
            return;
        }
    }
}
