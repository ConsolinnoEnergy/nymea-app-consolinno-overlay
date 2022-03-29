#ifndef PVCONFIGURATION_H
#define PVCONFIGURATION_H

#include <QUuid>
#include <QObject>

class PvConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid PvThingId READ PvThingId CONSTANT)
    Q_PROPERTY(int longitude READ longitude CONSTANT)
    Q_PROPERTY(int latitude READ latitude CONSTANT)
    Q_PROPERTY(double roofPitch READ roofPitch  CONSTANT)
    Q_PROPERTY(double alignment READ alignment  CONSTANT)
    Q_PROPERTY(double kwPeak READ kwPeak  CONSTANT)

public:
    explicit PvConfiguration(QObject *parent = nullptr);

    QUuid PvThingId() const;
    void setPvThingId(const QUuid &pvThingId);

    int latitude() const;
    void setLatitude(const int &latitude);

    int longitude() const;
    void setLongitude(const int &longitude);

    int roofPitch() const;
    void setRoofPitch(const int roofPitch);

    int alignment() const;
    void setAlignment(const int alignment);

    float kwPeak() const;
    void setKwPeak(const float kwPeak);

signals:




private:
    QUuid m_PvThingId;
    int m_longitude = 0;
    int m_latitude = 0;
    int m_roofPitch = 0;
    int m_alignment = 0;
    float m_kwPeak = 0;

};

#endif // PVCONFIGURATION_H
