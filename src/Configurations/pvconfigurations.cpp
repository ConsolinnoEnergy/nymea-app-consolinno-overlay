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
        return m_list.at(index.row())->pvThingId();
    case RoleLatitude:
        return m_list.at(index.row())->latitude();
    case RoleLongitude:
        return m_list.at(index.row())->longitude();
    case RoleRoofPitch:
        return m_list.at(index.row())->roofPitch();
    case RoleAlignment:
        return m_list.at(index.row())->alignment();
    case RoleKwPeak:
        return m_list.at(index.row())->kwPeak();

    }

    return QVariant();

}

QHash<int, QByteArray> PvConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RolePvthingId, "PvThingId");
    roles.insert(RoleLatitude, "latitude");
    roles.insert(RoleLongitude, "longitude");
    roles.insert(RoleRoofPitch, "roofPitch");
    roles.insert(RoleAlignment, "alignment");
    roles.insert(RoleKwPeak, "kwPeak");
    return roles;
}

PvConfiguration *PvConfigurations::getPvConfiguration(const QUuid &pvThingId) const
{

    foreach(PvConfiguration *pvconfig, m_list){
        if (pvconfig->pvThingId() == pvThingId){
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

    connect(pvConfiguration, &PvConfiguration::latitudeChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(pvConfiguration));
        emit dataChanged(idx, idx, {RoleLatitude});
    });


    connect(pvConfiguration, &PvConfiguration::longitudeChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(pvConfiguration));
        emit dataChanged(idx, idx, {RoleLongitude});
    });

    connect(pvConfiguration, &PvConfiguration::roofPitchChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(pvConfiguration));
        emit dataChanged(idx, idx, {RoleRoofPitch});
    });

    connect(pvConfiguration, &PvConfiguration::alignmentChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(pvConfiguration));
        emit dataChanged(idx, idx, {RoleAlignment});
    });

    connect(pvConfiguration, &PvConfiguration::kwPeakChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(pvConfiguration));
        emit dataChanged(idx, idx, {RoleKwPeak});
    });


    endInsertRows();

    emit countChanged();

}

void PvConfigurations::removeConfiguration(const QUuid &pvThingId)
{
    for(int i = 0; i <m_list.count(); i++){
        if(m_list.at(i)->pvThingId() == pvThingId){
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            return;
        }
    }
}





