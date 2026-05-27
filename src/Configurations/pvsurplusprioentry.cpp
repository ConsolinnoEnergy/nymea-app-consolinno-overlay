/* Copyright (C) Consolinno Energy GmbH - All Rights Reserved
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 */

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

bool PvSurplusEntry::operator!=(const PvSurplusEntry &other) const
{
    return !(*this == other);
}

QDebug operator<<(QDebug debug, const PvSurplusEntry &entry)
{
    debug.nospace() << "PvSurplusEntry(thingId: " << entry.thingId().toString()
                    << ", locked: " << entry.locked() << ")";
    return debug.maybeSpace();
}

QVariant PvSurplusEntries::get(int index) const
{
    return QVariant::fromValue(at(index));
}

void PvSurplusEntries::put(const QVariant &variant)
{
    append(variant.value<PvSurplusEntry>());
}
