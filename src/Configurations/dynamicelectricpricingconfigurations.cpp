#include "dynamicelectricpricingconfigurations.h"
#include <QDebug>
#include "logging.h"

NYMEA_LOGGING_CATEGORY(electricPriceConfiguration, "electricPriceConfig")

DynamicElectricPricingConfigurations::DynamicElectricPricingConfigurations(QObject *parent) :
    QAbstractListModel(parent)
{

}

int DynamicElectricPricingConfigurations::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return m_list.count();
}

QVariant DynamicElectricPricingConfigurations::data(const QModelIndex &index, int role) const
{
    switch (role) {
    case RoleElectricThingId:
        return m_list.at(index.row())->dynamicElectricPricingThingID();
    case RoleOptimizationEnabled:
        return m_list.at(index.row())->optimizationEnabled();
    }
    return QVariant();
}

QHash<int, QByteArray> DynamicElectricPricingConfigurations::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles.insert(RoleElectricThingId, "electricThingId");
    roles.insert(RoleOptimizationEnabled, "optimizationEnabled");
    return roles;
}

DynamicElectricPricingConfiguration *DynamicElectricPricingConfigurations::getElectricConfiguration(const QUuid &electricThingId) const
{

    foreach (DynamicElectricPricingConfiguration *electricConfig, m_list) {
        if (electricConfig->dynamicElectricPricingThingID() == electricThingId) {
            return electricConfig;
        }
    }

    return nullptr;
}

DynamicElectricPricingConfiguration *DynamicElectricPricingConfigurations::get(int index) const
{
    if (index < 0 || index >= m_list.count())
        return nullptr;

    return m_list.at(index);
}

void DynamicElectricPricingConfigurations::addConfiguration(DynamicElectricPricingConfiguration *electricgConfiguration)
{
    electricgConfiguration->setParent(this);

    beginInsertRows(QModelIndex(), m_list.count(), m_list.count());
    m_list.append(electricgConfiguration);

    connect(electricgConfiguration, &DynamicElectricPricingConfiguration::optimizationEnabledChanged, this, [=](){
        QModelIndex idx = index(m_list.indexOf(electricgConfiguration));
        emit dataChanged(idx, idx, {RoleOptimizationEnabled});
    });

    endInsertRows();

    emit countChanged();
}

void DynamicElectricPricingConfigurations::removeConfiguration(const QUuid &electricThingId)
{
    for (int i = 0; i < m_list.count(); i++) {
        if (m_list.at(i)->dynamicElectricPricingThingID() == electricThingId) {
            beginRemoveRows(QModelIndex(), i, i);
            m_list.takeAt(i)->deleteLater();
            endRemoveRows();
            return;
        }
    }
}

