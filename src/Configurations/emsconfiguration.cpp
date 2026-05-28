#include "emsconfiguration.h"

EmsConfiguration::EmsConfiguration(QObject *parent): QObject(parent)
{

}

PvSurplusEntries EmsConfiguration::pvSurplusPriolist() const
{
    return m_pvSurplusPriolist;
}

void EmsConfiguration::setPvSurplusPriolist(const PvSurplusEntries &pvSurplusPriolist)
{
    if (m_pvSurplusPriolist == pvSurplusPriolist) { return; }
    m_pvSurplusPriolist = pvSurplusPriolist;
    emit pvSurplusPriolistChanged();
}

PvSurplusEntries EmsConfiguration::defaultPvSurplusPriolist() const
{
    return m_defaultPvSurplusPriolist;
}

void EmsConfiguration::setDefaultPvSurplusPriolist(const PvSurplusEntries &defaultPvSurplusPriolist)
{
    if (m_defaultPvSurplusPriolist == defaultPvSurplusPriolist) { return; }
    m_defaultPvSurplusPriolist = defaultPvSurplusPriolist;
    emit defaultPvSurplusPriolistChanged();
}

int EmsConfiguration::pvSurplusPriolistIndexOf(const QUuid &thingId) const
{
    for (int i = 0; i < m_pvSurplusPriolist.size(); ++i) {
        if (m_pvSurplusPriolist.at(i).thingId() == thingId)
            return i;
    }
    return -1;
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

