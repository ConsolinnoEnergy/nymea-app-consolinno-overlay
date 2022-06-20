#include "userconfiguration.h"

UserConfiguration::UserConfiguration(QObject *parent): QObject(parent)
{

}

QUuid UserConfiguration::userConfigID() const
{
    return m_userConfigID;
}

QUuid UserConfiguration::lastSelectedCar() const
{
    return m_lastSelectedCar;
}

void UserConfiguration::setLastSelectedCar(const QUuid &lastSelectedCar)
{
    m_lastSelectedCar = lastSelectedCar;
}

int UserConfiguration::defaultChargingMode() const
{
    return m_defaultChargingMode;
}

void UserConfiguration::setDefaultChargingMode(const int &defaultChargingMode)
{
    m_defaultChargingMode = defaultChargingMode;
}
