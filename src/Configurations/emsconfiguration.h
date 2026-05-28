#ifndef EMSCONFIGURATION_H
#define EMSCONFIGURATION_H

#include <QDebug>
#include <QList>
#include <QObject>
#include <QUuid>

#include "pvsurplusprioentry.h"

class EmsConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(PvSurplusEntries pvSurplusPriolist READ pvSurplusPriolist WRITE setPvSurplusPriolist NOTIFY pvSurplusPriolistChanged)
    Q_PROPERTY(PvSurplusEntries defaultPvSurplusPriolist READ defaultPvSurplusPriolist WRITE setDefaultPvSurplusPriolist NOTIFY defaultPvSurplusPriolistChanged)
    Q_PROPERTY(QList<QUuid> limitPriolist READ limitPriolist WRITE setLimitPriolist NOTIFY limitPriolistChanged)
    Q_PROPERTY(QList<QUuid> defaultLimitPriolist READ defaultLimitPriolist WRITE setDefaultLimitPriolist NOTIFY defaultLimitPriolistChanged)

public:
    explicit EmsConfiguration(QObject *parent = nullptr);

    // Priority list for PV surplus distribution
    PvSurplusEntries pvSurplusPriolist() const;
    void setPvSurplusPriolist(const PvSurplusEntries &pvSurplusPriolist);

    // Default priority list for PV surplus distribution
    PvSurplusEntries defaultPvSurplusPriolist() const;
    void setDefaultPvSurplusPriolist(const PvSurplusEntries &defaultPvSurplusPriolist);

    // Priority list for load limiting / curtailment
    Q_INVOKABLE int pvSurplusPriolistIndexOf(const QUuid &thingId) const;

    QList<QUuid> limitPriolist() const;
    void setLimitPriolist(const QList<QUuid> &limitPriolist);

    // Default priority list for load limiting / curtailment
    QList<QUuid> defaultLimitPriolist() const;
    void setDefaultLimitPriolist(const QList<QUuid> &defaultLimitPriolist);

signals:
    void pvSurplusPriolistChanged();
    void defaultPvSurplusPriolistChanged();
    void limitPriolistChanged();
    void defaultLimitPriolistChanged();

private:
    PvSurplusEntries m_pvSurplusPriolist;
    PvSurplusEntries m_defaultPvSurplusPriolist;
    QList<QUuid> m_limitPriolist;
    QList<QUuid> m_defaultLimitPriolist;
};

#endif  // EMSCONFIGURATION_H
