#ifndef CHARGINGSESSIONCONFIGURATIONS_H
#define CHARGINGSESSIONCONFIGURATIONS_H


#include <QObject>
#include <QAbstractListModel>

#include "chargingsessionconfiguration.h"

class ChargingSessionConfigurations : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Role {
        RoleChargingSessionThingId,
        RoleEvChargerThingId,
        RoleStarted_at,
        RoleFinished_at,
        RoleInitial_Battery_Energy,
        RoleDuration,
        RoleEnergy_Charged,
        RoleEnergy_Battery,
        RoleBattery_Level,
        RoleCarThingId
    };
    Q_ENUM(Role);

    explicit ChargingSessionConfigurations(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE ChargingSessionConfiguration *getChargingSessionConfiguration(const QUuid &chargingSessionThingId) const;

    void addConfiguration(ChargingSessionConfiguration *chargingSessionConfiguration);
    void removeConfiguration(const QUuid &chargingSessionThingId);

signals:
    void countChanged();

private:
    QList<ChargingSessionConfiguration *> m_list;

};

#endif // CHARGINGSESSIONCONFIGURATIONS_H
