#include "pvconfiguration.h"

PvConfiguration::PvConfiguration(QObject *parent) : QObject(parent)
{

}


QUuid PvConfiguration::PvThingId() const
{
    return m_PvThingId;
}

void PvConfiguration::setPvThingId(const QUuid &pvThingId)
{

    m_PvThingId = pvThingId;

}


int PvConfiguration::latitude() const
{
    return m_latitude;
}

void PvConfiguration::setLatitude(const int &latitude)
{
 m_latitude = latitude;
}

int PvConfiguration::longitude() const
{
    return m_longitude;
}

void PvConfiguration::setLongitude(const int &longitude)
{
m_longitude = longitude;
}

int PvConfiguration::roofPitch() const
{
    return m_roofPitch;
}

void PvConfiguration::setRoofPitch(const int roofPitch)
{
    m_roofPitch = roofPitch;
}


int PvConfiguration::alignment() const
{
    return m_alignment;
}

void PvConfiguration::setAlignment(const int alignment)
{
    m_alignment = alignment;
}

float PvConfiguration::kwPeak() const
{
    return m_kwPeak;
}

void PvConfiguration::setKwPeak(const float kwPeak)
{
    m_kwPeak = kwPeak;
}
