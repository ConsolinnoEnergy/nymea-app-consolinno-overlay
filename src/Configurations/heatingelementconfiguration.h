#ifndef HEATINGELEMENTCONFIGURATION_H
#define HEATINGELEMENTCONFIGURATION_H

#include <QUuid>
#include <QObject>

class HeatingElementConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid heatingRodThingId READ heatingRodThingId CONSTANT)
    Q_PROPERTY(double maxPower READ maxPower WRITE setMaxPower NOTIFY maxPowerChanged)

public:
    explicit HeatingElementConfiguration(QObject *parent = nullptr);

    QUuid heatingRodThingId() const;
    void setHeatingRodThingId(const QUuid &heatingRodThingId);

    double maxPower() const;
    void setMaxPower(const double &maxPower);


private:
    QUuid m_heatingRodThingId;
    double m_maxPower = 0;

signals:
    void maxPowerChanged(const double maxPower);

};

#endif // HeatingElementConfiguration_H
