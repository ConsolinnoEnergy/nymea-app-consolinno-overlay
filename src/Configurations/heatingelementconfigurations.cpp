#include <QDebug>

#include "heatingelementconfigurations.h"
#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcHeatingElementConfiguration, "HeatingElementConfig")

HeatingElementConfigurations::HeatingElementConfigurations(QObject *parent)
    : QAbstractListModel{parent}
{

}

int HeatingElementConfigurations::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant HeatingElementConfigurations::data(const QModelIndex &index, int role) const
{
    switch(role){
    case RoleHeatingRodThingId:
        return m_list.at(index.row())->heatingRodThingId();
    case RoleMaxPower:
        return m_list.at(index.row())->maxPower();
    }

    return QVariant();

}

QHash<int, QByteArray> HeatingElementConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleHeatingRodThingId, "heatingRodThingId");
    roles.insert(RoleMaxPower, "maxPower");
    return roles;
}

HeatingElementConfiguration *HeatingElementConfigurations::getHeatingElementConfiguration(const QUuid &heatingRodThingId) const
{

    foreach(HeatingElementConfiguration *heatingElementConfig, m_list){
        if (heatingElementConfig->heatingRodThingId() == heatingRodThingId){
            return heatingElementConfig;
        }
    }
    return nullptr;
}

HeatingElementConfiguration *HeatingElementConfigurations::get(int index) const
{
    if (index < 0 || index >= m_list.count())
        return nullptr;

    return m_list.at(index);
}

void HeatingElementConfigurations::addConfiguration(HeatingElementConfiguration *heatingElementConfiguration)
{
    heatingElementConfiguration->setParent(this);

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(heatingElementConfiguration);

    connect(heatingElementConfiguration, &HeatingElementConfiguration::maxPowerChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(heatingElementConfiguration));
        emit dataChanged(idx, idx, {RoleMaxPower});
    });

    endInsertRows();
    emit countChanged();
}

void HeatingElementConfigurations::removeConfiguration(const QUuid &heatingRodThingId)
{
    for(int i = 0; i <m_list.count(); i++){
        if(m_list.at(i)->heatingRodThingId() == heatingRodThingId){
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            return;
        }
    }
}
