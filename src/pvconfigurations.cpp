#include "pvconfigurations.h"
#include <QDebug>

#include "logging.h"
NYMEA_LOGGING_CATEGORY(dcPvConfiguration, "PvConfig")

PvConfigurations::PvConfigurations(QObject *parent) :
    QAbstractListModel(parent)
{


}

int PvConfigurations::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant PvConfigurations::data(const QModelIndex &index, int role) const
{
    switch(role){
    case RolePvthingId:
        return m_list.at(index.row())->PvThingId();
    // when adding a new role that is suppose to be in the m_list add here
    }

    return QVariant();

}

QHash<int, QByteArray> PvConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RolePvthingId, "PvThingId");
    return roles;
}

PvConfiguration *PvConfigurations::getPvConfiguration(const QUuid &pvThingId) const
{

    foreach(PvConfiguration *pvconfig, m_list){
        if (pvconfig->PvThingId() == pvThingId){
            return pvconfig;
        }

    }

    return nullptr;



}

PvConfiguration *PvConfigurations::get(int index) const
{
    if (index < 0 || index >= m_list.count())
        return nullptr;

    return m_list.at(index);
}

void PvConfigurations::addConfiguration(PvConfiguration *pvConfiguration)
{
    pvConfiguration->setParent(this);

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(pvConfiguration);

    endInsertRows();

    emit countChanged();

}

void PvConfigurations::removeConfiguration(const QUuid &pvThingId)
{
    for(int i = 0; i <m_list.count(); i++){
        if(m_list.at(i)->PvThingId() == pvThingId){
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            return;
        }
    }
}





