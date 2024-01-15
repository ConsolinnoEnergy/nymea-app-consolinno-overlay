#ifndef HEATINGELEMENTCONFIGURATIONS_H
#define HEATINGELEMENTCONFIGURATIONS_H

#include <QObject>
#include <QAbstractListModel>
#include "heatingelementconfiguration.h"

class HeatingElementConfigurations : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Role{
     RoleHeatingRodThingId,
     RoleMaxElectricalPower,
     RoleOptimizationEnabled,
    };
    Q_ENUM(Role);

    explicit HeatingElementConfigurations(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE HeatingElementConfiguration *getHeatingElementConfiguration(const QUuid &heatingRodThingId) const;
    Q_INVOKABLE HeatingElementConfiguration *get(int index) const;

    void addConfiguration(HeatingElementConfiguration *heatingElementConfiguration);
    void removeConfiguration(const QUuid &heatingRodThingId);

signals:
    void countChanged();

private:
    QList<HeatingElementConfiguration*> m_list;
};

#endif // HEATINGELEMENTCONFIGURATIONS_H
