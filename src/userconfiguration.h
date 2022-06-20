#ifndef USERCONFIGURATION_H
#define USERCONFIGURATION_H

#include <QUuid>
#include <QObject>
#include <QDebug>

class UserConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid userConfigID READ userConfigID CONSTANT)
    Q_PROPERTY(QUuid lastSelectedCar READ lastSelectedCar WRITE setLastSelectedCar NOTIFY lastSelectedCarChanged)
    Q_PROPERTY(int defaultChargingMode READ defaultChargingMode WRITE setDefaultChargingMode NOTIFY defaultChargingModeChanged)



public:

    explicit UserConfiguration(QObject *parent = nullptr);

    QUuid userConfigID() const;

    QUuid lastSelectedCar() const;
    void setLastSelectedCar(const QUuid &lastSelectedCar);

    int defaultChargingMode() const;
    void setDefaultChargingMode(const int &defaultChargingMode ) ;


signals:
    void lastSelectedCarChanged(QUuid lastSelectedCar);
    void defaultChargingModeChanged(int defaultChagingMode);


private:
    QUuid m_userConfigID = "528b3820-1b6d-4f37-aea7-a99d21d42e72";
    QUuid m_lastSelectedCar = "282d39a8-3537-4c22-a386-b31faeebbb55";
    int m_defaultChargingMode = 0;

};

#endif // USERCONFIGURATION_H
