#include "heatingconfigurations.h"

HeatingConfigurations::HeatingConfigurations(QObject *parent) :
    QAbstractListModel(parent)
{

}

int HeatingConfigurations::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant HeatingConfigurations::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleHeatPumpThingId:
        return m_list.at(index.row())->heatPumpThingId();
    case RoleOptimizationEnabled:
        return m_list.at(index.row())->optimizationEnabled();
    case RoleHeatMeterThingId:
        return m_list.at(index.row())->heatMeterThingId();
    }
    return QVariant();
}

QHash<int, QByteArray> HeatingConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleHeatPumpThingId, "heatPumpThingId");
    roles.insert(RoleOptimizationEnabled, "optimizationEnabled");
    roles.insert(RoleHeatMeterThingId, "heatMeterThingId");
    return roles;
}

HeatingConfiguration *HeatingConfigurations::getHeatingConfiguration(const QUuid &heatPumpThingId) const
{
    foreach (HeatingConfiguration *heatingConfig, m_list) {
        if (heatingConfig->heatPumpThingId() == heatPumpThingId) {
            return heatingConfig;
        }
    }

    return nullptr;
}

HeatingConfiguration *HeatingConfigurations::get(int index) const
{
    if (index < 0 || index >= m_list.count())
        return nullptr;

    return m_list.at(index);
}

void HeatingConfigurations::addConfiguration(HeatingConfiguration *heatingConfiguration)
{
    heatingConfiguration->setParent(this);

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(heatingConfiguration);

    connect(heatingConfiguration, &HeatingConfiguration::optimizationEnabledChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(heatingConfiguration));
        emit dataChanged(idx, idx, {RoleOptimizationEnabled});
    });

    connect(heatingConfiguration, &HeatingConfiguration::heatMeterThingIdChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(heatingConfiguration));
        emit dataChanged(idx, idx, {RoleHeatMeterThingId});
    });

    endInsertRows();

    emit countChanged();
}

void HeatingConfigurations::removeConfiguration(const QUuid &heatPumpThingId)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->heatPumpThingId() == heatPumpThingId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            return;
        }
    }
}
