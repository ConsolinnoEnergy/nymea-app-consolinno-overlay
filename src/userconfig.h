#ifndef USERCONFIG_H
#define USERCONFIG_H

#include <QUuid>
#include <QObject>

class UserConfig : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid userConfigID READ userConfigID CONSTANT)
    Q_PROPERTY(QUuid lastSelectedCar READ lastSelectedCar WRITE setLastSelectedCar NOTIFY lastSelectedCarChanged)

//    Q_PROPERTY(QUuid carThingId READ carThingId WRITE setCarThingId NOTIFY carThingIdChanged)
//    Q_PROPERTY(QString endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)
//    Q_PROPERTY(uint targetPercentage READ targetPercentage WRITE setTargetPercentage NOTIFY targetPercentageChanged)
//    Q_PROPERTY(int optimizationMode READ optimizationMode WRITE setOptimizationMode NOTIFY optimizationModeChanged)
//    Q_PROPERTY(QUuid uniqueIdentifier READ uniqueIdentifier WRITE setUniqueIdentifier NOTIFY uniqueIdentifierChanged)




public:

    UserConfig();

    QUuid userConfigID() const;

    QUuid lastSelectedCar() const;
    void setLastSelectedCar(const QUuid &lastSelectedCar);

    int defaultChargingMode() const;
    void setDefaultChargingMode(const int &defaultChargingMode ) const;


signals:
    void lastSelectedCarChanged(QUuid lastSelectedCar);

private:
    QUuid m_userConfigID = "528b3820-1b6d-4f37-aea7-a99d21d42e72";
    QUuid m_lastSelectedCar;
    int m_defaultChargingMode;

};

#endif // USERCONFIG_H
