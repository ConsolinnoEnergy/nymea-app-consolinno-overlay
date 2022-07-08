#ifndef USERCONFIGURATIONS_H
#define USERCONFIGURATIONS_H

#include <QObject>
#include <QAbstractListModel>

#include "userconfiguration.h"


class UserConfigurations : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Role {
        RoleUserConfigID,
        RoleLastSelectedCar,
        RoleDefaultChargingMode,
        RoleInstallerName,
        RoleInstallerEmail,
        RoleInstallerPhoneNr,
        RoleInstallerWorkplace

    };
    Q_ENUM(Role);

    explicit UserConfigurations(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE UserConfiguration *getUserConfiguration(const QUuid & userConfigID) const;


    void addConfiguration(UserConfiguration *userconfiguration);
    void removeConfiguration(const QUuid &userConfigId);

signals:
    void countChanged();

private:
    QList<UserConfiguration *> m_list;

};

#endif // USERCONFIGURATIONS_H
