#ifndef DYNAMICELECTRICPRICINGCONFIGURATIONS_H
#define DYNAMICELECTRICPRICINGCONFIGURATIONS_H

#include <QObject>
#include <QAbstractListModel>

#include "dynamicelectricpricingconfiguration.h"

class DynamicElectricPricingConfigurations : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Role {
        RoleElectricThingId,
        RoleOptimizationEnabled
    };
    Q_ENUM(Role);

    explicit DynamicElectricPricingConfigurations(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE DynamicElectricPricingConfiguration *getElectricConfiguration(const QUuid &electricThingId) const;
    Q_INVOKABLE DynamicElectricPricingConfiguration *get(int index) const;

    void addConfiguration(DynamicElectricPricingConfiguration *electricgConfiguration);
    void removeConfiguration(const QUuid &electricThingId);

signals:
    void countChanged();

private:
    QList<DynamicElectricPricingConfiguration*> m_list ;

};


#endif // DYNAMICELECTRICPRICINGCONFIGURATIONS_H
