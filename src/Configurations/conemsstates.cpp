#include "conemsstates.h"

ConEMSState::ConEMSState(QObject *parent):
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
    }
    return QVariant();
}

QHash<int, QByteArray> ConEMSStates::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleCurrentState, "currentState");

    return roles;
}

ConEMSState *ConEMSStates::getConEMSState() const
{

    foreach (ConEMSState *conEMSState, m_list) {

        if (conEMSState->ConEMSStateID() == conEMSStateID) {
            return conEMSState;
        }
    }

    return nullptr;
}







