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


QString UserConfiguration::installerName() const
{
    return m_installerName;
}

void UserConfiguration::setInstallerName(const QString &installerName)
{
    m_installerName = installerName;
}

QString UserConfiguration::installerEmail() const
{
    return m_installerEmail;
}

void UserConfiguration::setInstallerEmail(const QString &installerEmail)
{
    m_installerEmail = installerEmail;
}

QString UserConfiguration::installerPhoneNr() const
{
    return m_installerPhoneNr;
}

void UserConfiguration::setInstallerPhoneNr(const QString &installerPhoneNr)
{
    m_installerPhoneNr = installerPhoneNr;
}

QString UserConfiguration::installerWorkplace() const
{
    return m_installerWorkplace;
}

void UserConfiguration::setInstallerWorkplace(const QString &installerWorkplace)
{
    m_installerWorkplace = installerWorkplace;
}


bool UserConfiguration::averagingPowerEnabled() const
{
    return m_averagingPowerEnabled;
}

void UserConfiguration::setAveragingPowerEnabled(const bool averagingPowerEnabled)
{
    m_averagingPowerEnabled = averagingPowerEnabled;
}