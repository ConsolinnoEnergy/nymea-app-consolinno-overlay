#ifndef PVCONFIGURATION_H
#define PVCONFIGURATION_H

#include <QUuid>
#include <QObject>

class PvConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid PvThingId READ PvThingId CONSTANT)
    Q_PROPERTY(float longitude READ longitude WRITE setLongitude NOTIFY longitudeChanged)
    Q_PROPERTY(float latitude READ latitude WRITE setLatitude NOTIFY latitudeChanged)
    Q_PROPERTY(double roofPitch READ roofPitch WRITE setRoofPitch NOTIFY roofPitchChanged )
    Q_PROPERTY(double alignment READ alignment WRITE setAlignment NOTIFY alignmentChanged)
    Q_PROPERTY(double kwPeak READ kwPeak  WRITE setKwPeak NOTIFY kwPeakChanged)

public:
    explicit PvConfiguration(QObject *parent = nullptr);

    QUuid PvThingId() const;
    void setPvThingId(const QUuid &pvThingId);

    float latitude() const;
    void setLatitude(const float &latitude);

    float longitude() const;
    void setLongitude(const float &longitude);

    int roofPitch() const;
    void setRoofPitch(const int roofPitch);

    int alignment() const;
    void setAlignment(const int alignment);

    float kwPeak() const;
    void setKwPeak(const float kwPeak);

signals:
    void longitudeChanged(const int longitude);
    void latitudeChanged(const int latitude);
    void roofPitchChanged(const int roofPitch);
    void alignmentChanged(const int alignment);
    void kwPeakChanged(const float kwPeak);



private:
    QUuid m_PvThingId;
    float m_longitude = 0;
    float m_latitude = 0;
    int m_roofPitch = 0;
    int m_alignment = 0;
    float m_kwPeak = 0;

};

#endif // PVCONFIGURATION_H
