#ifndef DASHBOARDDATAPROVIDER_H
#define DASHBOARDDATAPROVIDER_H

#include <QObject>

class DashboardDataProvider : public QObject
{
    Q_OBJECT
public:
    explicit DashboardDataProvider(QObject *parent = nullptr);

signals:

};

#endif // DASHBOARDDATAPROVIDER_H
