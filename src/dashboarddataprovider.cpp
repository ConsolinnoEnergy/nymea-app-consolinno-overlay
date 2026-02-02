#include "dashboarddataprovider.h"

#include "logging.h"

NYMEA_LOGGING_CATEGORY(dcDashboardDataProvider, "DashboardDataProvider");

DashboardDataProvider::DashboardDataProvider(QObject *parent)
    : QObject{parent}
{
    qCInfo(dcDashboardDataProvider()) << "DashboardDataProvider::ctor";
}
