#ifndef PVCONFIGURATION_H
#define PVCONFIGURATION_H

#include <QUuid>
#include <QObject>

class PvConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid pvThingId READ pvThingId CONSTANT)
    Q_PROPERTY(double longitude READ longitude WRITE setLongitude NOTIFY longitudeChanged)
    Q_PROPERTY(double latitude READ latitude WRITE setLatitude NOTIFY latitudeChanged)
    Q_PROPERTY(double roofPitch READ roofPitch WRITE setRoofPitch NOTIFY roofPitchChanged )
    Q_PROPERTY(double alignment READ alignment WRITE setAlignment NOTIFY alignmentChanged)
    Q_PROPERTY(double wPeak READ wPeak WRITE setWPeak NOTIFY wPeakChanged)
    Q_PROPERTY(bool controllableLocalSystem READ controllableLocalSystem WRITE setControllableLocalSystem NOTIFY controllableLocalSystemChanged)

public:
    explicit PvConfiguration(QObject *parent = nullptr);

    QUuid pvThingId() const;
    void setPvThingId(const QUuid &pvThingId);

    double latitude() const;
    void setLatitude(const double &latitude);

    double longitude() const;
    void setLongitude(const double &longitude);

    int roofPitch() const;
    void setRoofPitch(const int roofPitch);

    int alignment() const;
    void setAlignment(const int alignment);

    double wPeak() const;
    void setWPeak(const double wPeak);

    bool controllableLocalSystem() const;
    void setControllableLocalSystem(bool controllableLocalSystem);

signals:
    void longitudeChanged(const int longitude);
    void latitudeChanged(const int latitude);
    void roofPitchChanged(const int roofPitch);
    void alignmentChanged(const int alignment);
    void wPeakChanged(const double wPeak);
    void controllableLocalSystemChanged(bool controllableLocalSystem);


private:
    QUuid m_PvThingId;
    double m_longitude = 0;
    double m_latitude = 0;
    int m_roofPitch = 0;
    int m_alignment = 0;
    double m_wPeak = 0;
    bool m_controllableLocalSystem = false;

};

#endif // PVCONFIGURATION_H
