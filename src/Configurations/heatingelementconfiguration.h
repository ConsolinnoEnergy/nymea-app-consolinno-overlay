#ifndef HEATINGELEMENTCONFIGURATION_H
#define HEATINGELEMENTCONFIGURATION_H

#include <QUuid>
#include <QObject>

class HeatingElementConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid heatingRodThingId READ heatingRodThingId CONSTANT)
    Q_PROPERTY(double maxElectricalPower READ maxElectricalPower WRITE setMaxElectricalPower NOTIFY maxElectricalPowerChanged)

public:
    explicit HeatingElementConfiguration(QObject *parent = nullptr);

    QUuid heatingRodThingId() const;
    void setHeatingRodThingId(const QUuid &heatingRodThingId);

    double maxElectricalPower() const;
    void setMaxElectricalPower(const double &maxElectricalPower);


private:
    QUuid m_heatingRodThingId;
    double m_maxElectricalPower = 0;

signals:
    void maxElectricalPowerChanged(const double maxElectricalPower);

};

#endif // HeatingElementConfiguration_H
