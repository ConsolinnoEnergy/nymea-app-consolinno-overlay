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

    Q_PROPERTY(QString installerName READ installerName WRITE setInstallerName NOTIFY installerNameChanged)
    Q_PROPERTY(QString installerEmail READ installerEmail WRITE setInstallerEmail NOTIFY installerEmailChanged)
    Q_PROPERTY(QString installerPhoneNr READ installerPhoneNr WRITE setInstallerPhoneNr NOTIFY installerPhoneNrChanged)
    Q_PROPERTY(QString installerWorkplace READ installerWorkplace WRITE setInstallerWorkplace NOTIFY installerWorkplaceChanged)




public:

    explicit UserConfiguration(QObject *parent = nullptr);

    QUuid userConfigID() const;

    QUuid lastSelectedCar() const;
    void setLastSelectedCar(const QUuid &lastSelectedCar);

    int defaultChargingMode() const;
    void setDefaultChargingMode(const int &defaultChargingMode ) ;

    QString installerName() const;
    void setInstallerName(const QString &installerName);

    QString installerEmail() const;
    void setInstallerEmail(const QString &installerEmail) ;

    QString installerPhoneNr() const;
    void setInstallerPhoneNr(const QString &installerPhoneNr);

    QString installerWorkplace() const;
    void setInstallerWorkplace(const QString &installerWorkplace);




signals:
    void lastSelectedCarChanged(QUuid lastSelectedCar);
    void defaultChargingModeChanged(int defaultChagingMode);

    void installerNameChanged(QString installerName);
    void installerEmailChanged(QString installerEmail);
    void installerPhoneNrChanged(QString installerPhoneNr);
    void installerWorkplaceChanged(QString installerWorkplace);



private:
    QUuid m_userConfigID = "528b3820-1b6d-4f37-aea7-a99d21d42e72";
    QUuid m_lastSelectedCar = "282d39a8-3537-4c22-a386-b31faeebbb55";
    int m_defaultChargingMode = 0;
    QString m_installerName = "";
    QString m_installerEmail = "";
    QString m_installerPhoneNr = "";
    QString m_installerWorkplace = "";

};

#endif // USERCONFIGURATION_H
