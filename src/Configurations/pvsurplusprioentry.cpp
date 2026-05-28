#include "pvsurplusprioentry.h"

#include <QVariant>

PvSurplusEntry::PvSurplusEntry() {}

PvSurplusEntry::PvSurplusEntry(const QUuid &thingId, bool locked)
    : m_thingId(thingId)
    , m_locked(locked)
{}

QUuid PvSurplusEntry::thingId() const
{
    return m_thingId;
}

void PvSurplusEntry::setThingId(const QUuid &thingId)
{
    m_thingId = thingId;
}

bool PvSurplusEntry::locked() const
{
    return m_locked;
}

void PvSurplusEntry::setLocked(bool locked)
{
    m_locked = locked;
}

bool PvSurplusEntry::operator==(const PvSurplusEntry &other) const
{
    return m_thingId == other.thingId() && m_locked == other.locked();
}

QVariant PvSurplusEntries::get(int index) const
{
    if (index < 0 || index >= size()) {
        return QVariant();
    }

    return QVariant::fromValue(at(index));
}
