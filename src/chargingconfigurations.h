#ifndef CHARGINGCONFIGURATIONS_H
#define CHARGINGCONFIGURATIONS_H

#include <QObject>
#include <QAbstractListModel>

#include "chargingconfiguration.h"

class ChargingConfigurations : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Role {
        RoleEvChargerThingId,
        RoleOptimizationEnabled,
        RoleCarThingId,
        RoleEndTime,
        RoleTargetPercentage,
        RoleZeroReturnPolicy
    };
    Q_ENUM(Role);

    explicit ChargingConfigurations(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE ChargingConfiguration *getChargingConfiguration(const QUuid &evChargerThingId) const;

    void addConfiguration(ChargingConfiguration *chargingConfiguration);
    void removeConfiguration(const QUuid &evChargerThingId);

signals:
    void countChanged();

private:
    QList<ChargingConfiguration *> m_list;

};

#endif // CHARGINGCONFIGURATIONS_H
