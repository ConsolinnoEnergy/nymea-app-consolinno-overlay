#ifndef PVCONFIGURATIONS_H
#define PVCONFIGURATIONS_H

#include <QObject>
#include <QAbstractListModel>

#include "pvconfiguration.h"

class PvConfigurations : public QAbstractListModel
{

    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Role{
     RolePvthingId,
     RoleLatitude,
     RoleLongitude,
     RoleRoofPitch,
     RoleAlignment,
     RoleKwPeak
    };
    Q_ENUM(Role);

    explicit PvConfigurations(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE PvConfiguration *getPvConfiguration(const QUuid &pvThingId) const;
    Q_INVOKABLE PvConfiguration *get(int index) const;

    void addConfiguration(PvConfiguration *pvConfiguration);
    void removeConfiguration(const QUuid &pvThingId);



signals:
    void countChanged();

private:
    QList<PvConfiguration*> m_list;



};

#endif // PVCONFIGURATIONS_H
