#ifndef BATTERYCONFIGURATIONS_H
#define BATTERYCONFIGURATIONS_H

#include <QObject>
#include <QAbstractListModel>
#include "batteryconfiguration.h"

class BatteryConfigurations : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Role{
        RoleBatteryThingId,
        RoleOptimizationEnabled,
        RolePriceThreshold,
        RoleRelativePriceEnabled,
        RoleDischargePriceThreshold,
        RoleChargeOnce,
        RoleControllableLocalSystemEnabled,
        RoleAvoidZeroFeedInEnabled,
        RoleAvoidZeroFeedInActive,
        RoleBlockBatteryOnGridConsumption
    };
    Q_ENUM(Role);
    explicit BatteryConfigurations(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE BatteryConfiguration *getBatteryConfiguration(const QUuid &batteryThingId) const;
    Q_INVOKABLE BatteryConfiguration *get(int index) const;

    void addConfiguration(BatteryConfiguration *batteryConfiguration);
    void removeConfiguration(const QUuid &batteryThingId);

signals:
    void countChanged();

private:
    QList<BatteryConfiguration*> m_list;

};

#endif // BATTERYCONFIGURATIONS_H
