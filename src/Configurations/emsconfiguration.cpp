#include "emsconfiguration.h"

EmsConfiguration::EmsConfiguration(QObject *parent): QObject(parent)
{

}

QList<QUuid> EmsConfiguration::pvSurplusPriolist() const
{
    return m_pvSurplusPriolist;
}

void EmsConfiguration::setPvSurplusPriolist(const QList<QUuid> &pvSurplusPriolist)
{
    if (m_pvSurplusPriolist == pvSurplusPriolist) { return; }
    m_pvSurplusPriolist = pvSurplusPriolist;
    emit pvSurplusPriolistChanged();
}

QList<QUuid> EmsConfiguration::defaultPvSurplusPriolist() const
{
    return m_defaultPvSurplusPriolist;
}

void EmsConfiguration::setDefaultPvSurplusPriolist(const QList<QUuid> &defaultPvSurplusPriolist)
{
    if (m_defaultPvSurplusPriolist == defaultPvSurplusPriolist) { return; }
    m_defaultPvSurplusPriolist = defaultPvSurplusPriolist;
    emit defaultPvSurplusPriolistChanged();
}

QList<QUuid> EmsConfiguration::limitPriolist() const
{
    return m_limitPriolist;
}

void EmsConfiguration::setLimitPriolist(const QList<QUuid> &limitPriolist)
{
    if (m_limitPriolist == limitPriolist) { return; }
    m_limitPriolist = limitPriolist;
    emit limitPriolistChanged();
}

QList<QUuid> EmsConfiguration::defaultLimitPriolist() const
{
    return m_defaultLimitPriolist;
}

void EmsConfiguration::setDefaultLimitPriolist(const QList<QUuid> &defaultLimitPriolist)
{
    if (m_defaultLimitPriolist == defaultLimitPriolist) { return; }
    m_defaultLimitPriolist = defaultLimitPriolist;
    emit defaultLimitPriolistChanged();
}

