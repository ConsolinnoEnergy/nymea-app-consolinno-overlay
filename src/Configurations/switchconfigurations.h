#ifndef SWITCHCONFIGURATIONS_H
#define SWITCHCONFIGURATIONS_H

#include <QAbstractListModel>
#include <QObject>

#include "switchconfiguration.h"

class SwitchConfigurations : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Role {
        RoleSwitchThingId,
        RoleOptimizationMode,
        RoleMaxElectricalPower,
        RolePvSurplusThreshold,
        RoleDurationMinAfterTurnOn,
        RoleDurationMaxTotal,
        RoleControllableLocalSystem
    };
    Q_ENUM(Role)

    explicit SwitchConfigurations(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE SwitchConfiguration *getSwitchConfiguration(const QUuid &switchThingId) const;
    Q_INVOKABLE SwitchConfiguration *get(int index) const;

    void addConfiguration(SwitchConfiguration *configuration);
    void removeConfiguration(const QUuid &switchThingId);

signals:
    void countChanged();

private:
    QList<SwitchConfiguration *> m_list;
};

#endif // SWITCHCONFIGURATIONS_H
