#ifndef HEATINGCONFIGURATIONS_H
#define HEATINGCONFIGURATIONS_H

#include <QObject>
#include <QAbstractListModel>

#include "heatingconfiguration.h"

class HeatingConfigurations : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Role {
        RoleHeatPumpThingId,
        RoleOptimizationEnabled,
        RoleHeatMeterThingId
    };
    Q_ENUM(Role);

    explicit HeatingConfigurations(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE HeatingConfiguration *getHeatingConfiguration(const QUuid &heatPumpThingId) const;
    Q_INVOKABLE HeatingConfiguration *get(int index) const;

    void addConfiguration(HeatingConfiguration *heatingConfiguration);
    void removeConfiguration(const QUuid &heatPumpThingId);

signals:
    void countChanged();

private:
    QList<HeatingConfiguration *> m_list ;

};

#endif // HEATINGCONFIGURATIONS_H
