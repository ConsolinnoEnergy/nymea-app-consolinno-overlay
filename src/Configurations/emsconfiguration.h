#ifndef EMSCONFIGURATION_H
#define EMSCONFIGURATION_H

#include <QDebug>
#include <QList>
#include <QObject>
#include <QUuid>

class EmsConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<QUuid> pvSurplusPriolist READ pvSurplusPriolist WRITE setPvSurplusPriolist NOTIFY pvSurplusPriolistChanged)
    Q_PROPERTY(QList<QUuid> defaultPvSurplusPriolist READ defaultPvSurplusPriolist WRITE setDefaultPvSurplusPriolist NOTIFY defaultPvSurplusPriolistChanged)
    Q_PROPERTY(QList<QUuid> limitPriolist READ limitPriolist WRITE setLimitPriolist NOTIFY limitPriolistChanged)
    Q_PROPERTY(QList<QUuid> defaultLimitPriolist READ defaultLimitPriolist WRITE setDefaultLimitPriolist NOTIFY defaultLimitPriolistChanged)

public:
    explicit EmsConfiguration(QObject *parent = nullptr);

    // Priority list for PV surplus distribution
    // Suggested default order: HeatPump, SwitchableConsumer, Battery, WallBox, HeatingRod
    QList<QUuid> pvSurplusPriolist() const;
    void setPvSurplusPriolist(const QList<QUuid> &pvSurplusPriolist);

    // Default priority list for PV surplus distribution
    QList<QUuid> defaultPvSurplusPriolist() const;
    void setDefaultPvSurplusPriolist(const QList<QUuid> &defaultPvSurplusPriolist);

    // Priority list for load limiting / curtailment
    // Suggested default order: Battery, HeatingRod, HeatPump, ChargePoint
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
    QList<QUuid> m_pvSurplusPriolist;
    QList<QUuid> m_defaultPvSurplusPriolist;
    QList<QUuid> m_limitPriolist;
    QList<QUuid> m_defaultLimitPriolist;
};

#endif  // EMSCONFIGURATION_H
