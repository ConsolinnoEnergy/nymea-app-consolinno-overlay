#ifndef SWITCHABLECONSUMERCONFIGURATIONS_H
#define SWITCHABLECONSUMERCONFIGURATIONS_H

#include <QAbstractListModel>
#include <QObject>

#include "switchableconsumerconfiguration.h"

class SwitchableConsumerConfigurations : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Role {
        RoleSwitchableConsumerThingId,
        RoleOptimizationMode,
        RoleMaxElectricalPower,
        RolePvSurplusThreshold,
        RoleDurationMinAfterTurnOn,
        RoleDurationMaxTotal,
        RoleControllableLocalSystem
    };
    Q_ENUM(Role)

    explicit SwitchableConsumerConfigurations(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE SwitchableConsumerConfiguration *getSwitchableConsumerConfiguration(const QUuid &switchableConsumerThingId) const;
    Q_INVOKABLE SwitchableConsumerConfiguration *get(int index) const;

    void addConfiguration(SwitchableConsumerConfiguration *configuration);
    void removeConfiguration(const QUuid &switchableConsumerThingId);

signals:
    void countChanged();

private:
    QList<SwitchableConsumerConfiguration *> m_list;
};

#endif // SWITCHABLECONSUMERCONFIGURATIONS_H
