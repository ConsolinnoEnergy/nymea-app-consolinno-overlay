#ifndef CONEMSSTATES_H
#define CONEMSSTATES_H


#include <QObject>
#include <QAbstractListModel>

#include "conemsstate.h"

class ConEMSStates : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Role {
        RoleConEMSStateID,
        RoleCurrentState,
        RoleOperationMode,
    };
    Q_ENUM(Role);

    explicit ConEMSStates(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE ConEMSState *getConEMSState(const QUuid &conEMSStateId) const;

    void addConEMSState(ConEMSState *conEMSState);
    void removeConEMSState(const QUuid &conEMSState);

signals:
    void countChanged();

private:
    QList<ConEMSState *> m_list;

};

#endif // CONEMSSTATES_H
