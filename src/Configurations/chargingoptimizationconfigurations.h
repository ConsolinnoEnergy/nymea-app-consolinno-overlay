#ifndef CHARGINGOPTIMIZATIONCONFIGURATIONS_H
#define CHARGINGOPTIMIZATIONCONFIGURATIONS_H

#include <QObject>
#include <QAbstractListModel>


#include "chargingoptimizationconfiguration.h"

class ChargingOptimizationConfigurations : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:

    enum Role {
        RoleEvChargerThingId,
        RoleReenableChargepoint,
        RoleP_Value,
        RoleI_Value,
        RoleD_Value,
        RoleSetpoint

    };
    Q_ENUM(Role);

    explicit ChargingOptimizationConfigurations(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE ChargingOptimizationConfiguration *getChargingOptimizationConfiguration(const QUuid &evChargerThingId) const;

    void addConfiguration(ChargingOptimizationConfiguration *chargingOptimizationConfiguration);
    void removeConfiguration(const QUuid &evChargerThingId);

signals:
    void countChanged();

private:
    QList<ChargingOptimizationConfiguration *> m_list;


};

#endif // CHARGINGOPTIMIZATIONCONFIGURATIONS_H
