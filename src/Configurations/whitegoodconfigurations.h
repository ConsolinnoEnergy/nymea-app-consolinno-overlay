#ifndef WHITEGOODCONFIGURATIONS_H
#define WHITEGOODCONFIGURATIONS_H

#include <QObject>
#include <QAbstractListModel>

#include "whitegoodconfiguration.h"

class WhiteGoodConfigurations : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Role {
        RoleWhiteGoodThingId
    };
    Q_ENUM(Role);

    explicit WhiteGoodConfigurations(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE WhiteGoodConfiguration *getWhiteGoodConfiguration(const QUuid &whiteGoodThingId) const;
    Q_INVOKABLE WhiteGoodConfiguration *get(int index) const;

    void addConfiguration(WhiteGoodConfiguration *whiteGoodConfiguration);
    void removeConfiguration(const QUuid &whiteGoodThingId);

signals:
    void countChanged();

private:
    QList<WhiteGoodConfiguration*> m_list ;

};


#endif // WHITEGOODCONFIGURATIONS_H
