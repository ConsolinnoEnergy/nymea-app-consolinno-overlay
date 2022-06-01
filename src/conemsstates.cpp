#include "conemsstates.h"

ConEMSStates::ConEMSStates(QObject *parent):
    QAbstractListModel(parent)
{

}

int ConEMSStates::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant ConEMSStates::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleConEMSStateID:
        return m_list.at(index.row())->ConEMSStateID();
    case RoleCurrentState:
        return m_list.at(index.row())->currentState();
    case RoleOperationMode:
        return m_list.at(index.row())->operationMode();

    }
    return QVariant();
}

QHash<int, QByteArray> ConEMSStates::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleConEMSStateID, "conEMSStateID");
    roles.insert(RoleCurrentState, "currentState");
    roles.insert(RoleOperationMode, "operationMode");

    return roles;
}

ConEMSState *ConEMSStates::getConEMSState(const QUuid &conEMSStateID) const
{

    foreach (ConEMSState *conEMSState, m_list) {

        if (conEMSState->ConEMSStateID() == conEMSStateID) {
            return conEMSState;
        }
    }

    return nullptr;
}

void ConEMSStates::addConEMSState(ConEMSState *conEMSState)
{
    conEMSState->setParent(this);

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(conEMSState);

    connect(conEMSState, &ConEMSState::currentStateChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(conEMSState));
        emit dataChanged(idx, idx, {RoleCurrentState});
    });

    connect(conEMSState, &ConEMSState::operationModeChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(conEMSState));
        emit dataChanged(idx, idx, {RoleOperationMode});
    });



    endInsertRows();

    emit countChanged();
}

void ConEMSStates::removeConEMSState(const QUuid &conEMSStateID)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->ConEMSStateID() == conEMSStateID) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            return;
        }
    }
}




