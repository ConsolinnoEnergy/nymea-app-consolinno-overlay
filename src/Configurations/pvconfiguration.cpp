#include "pvconfiguration.h"

PvConfiguration::PvConfiguration(QObject *parent) : QObject(parent)
{

}


QUuid PvConfiguration::pvThingId() const
{
    return m_PvThingId;
}

void PvConfiguration::setPvThingId(const QUuid &pvThingId)
{

    m_PvThingId = pvThingId;

}


double PvConfiguration::latitude() const
{
    return m_latitude;
}

void PvConfiguration::setLatitude(const double &latitude)
{
 m_latitude = latitude;
}

double PvConfiguration::longitude() const
{
    return m_longitude;
}

void PvConfiguration::setLongitude(const double &longitude)
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

bool PvConfiguration::controllableLocalSystem() const
{
    return m_controllableLocalSystem;
}

void PvConfiguration::setControllableLocalSystem(bool controllableLocalSystem)
{
    if (m_controllableLocalSystem == controllableLocalSystem) { return; }
    m_controllableLocalSystem = controllableLocalSystem;
    emit controllableLocalSystemChanged(m_controllableLocalSystem);
}
