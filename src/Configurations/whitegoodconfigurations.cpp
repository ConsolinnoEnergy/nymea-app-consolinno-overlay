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
    }
    return QVariant();
}

QHash<int, QByteArray> WhiteGoodConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleWhiteGoodThingId, "whiteGoodThingId");
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

