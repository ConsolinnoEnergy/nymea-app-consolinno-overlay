#include "devconfigpvsurplus.h"

DevConfigPvSurplus::DevConfigPvSurplus(QObject *parent) : QObject(parent)
{
}

int DevConfigPvSurplus::filterTimeConstant() const
{
    return m_filterTimeConstant;
}

void DevConfigPvSurplus::setFilterTimeConstant(int filterTimeConstant)
{
    if (m_filterTimeConstant == filterTimeConstant)
        return;

    m_filterTimeConstant = filterTimeConstant;
    emit filterTimeConstantChanged(m_filterTimeConstant);
}

int DevConfigPvSurplus::postSwitchTimeout() const
{
    return m_postSwitchTimeout;
}

void DevConfigPvSurplus::setPostSwitchTimeout(int postSwitchTimeout)
{
    if (m_postSwitchTimeout == postSwitchTimeout)
        return;

    m_postSwitchTimeout = postSwitchTimeout;
    emit postSwitchTimeoutChanged(m_postSwitchTimeout);
}

double DevConfigPvSurplus::pidKp() const
{
    return m_pidKp;
}

void DevConfigPvSurplus::setPidKp(double pidKp)
{
    if (m_pidKp == pidKp)
        return;

    m_pidKp = pidKp;
    emit pidKpChanged(m_pidKp);
}

double DevConfigPvSurplus::pidKi() const
{
    return m_pidKi;
}

void DevConfigPvSurplus::setPidKi(double pidKi)
{
    if (m_pidKi == pidKi)
        return;

    m_pidKi = pidKi;
    emit pidKiChanged(m_pidKi);
}

double DevConfigPvSurplus::pidKd() const
{
    return m_pidKd;
}

void DevConfigPvSurplus::setPidKd(double pidKd)
{
    if (m_pidKd == pidKd)
        return;

    m_pidKd = pidKd;
    emit pidKdChanged(m_pidKd);
}

double DevConfigPvSurplus::pidSetpoint() const
{
    return m_pidSetpoint;
}

void DevConfigPvSurplus::setPidSetpoint(double pidSetpoint)
{
    if (m_pidSetpoint == pidSetpoint)
        return;

    m_pidSetpoint = pidSetpoint;
    emit pidSetpointChanged(m_pidSetpoint);
}
