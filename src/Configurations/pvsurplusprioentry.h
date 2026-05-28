#ifndef PVSURPLUSPRIOENTRY_H
#define PVSURPLUSPRIOENTRY_H

#include <QList>
#include <QObject>
#include <QUuid>

class PvSurplusEntry
{
    Q_GADGET
    Q_PROPERTY(QUuid thingId READ thingId WRITE setThingId USER true)
    Q_PROPERTY(bool locked READ locked WRITE setLocked USER true)

public:
    PvSurplusEntry();
    PvSurplusEntry(const QUuid &thingId, bool locked);

    QUuid thingId() const;
    void setThingId(const QUuid &thingId);

    bool locked() const;
    void setLocked(bool locked);

    bool operator==(const PvSurplusEntry &other) const;

private:
    QUuid m_thingId;
    bool m_locked = false;
};

class PvSurplusEntries : public QList<PvSurplusEntry>
{
    Q_GADGET
    Q_PROPERTY(int count READ count)
public:
    PvSurplusEntries() {}
    PvSurplusEntries(const QList<PvSurplusEntry> &other)
        : QList<PvSurplusEntry>(other)
    {}
    Q_INVOKABLE QVariant get(int index) const;
};

Q_DECLARE_METATYPE(PvSurplusEntry)
Q_DECLARE_METATYPE(PvSurplusEntries)

#endif // PVSURPLUSPRIOENTRY_H
