#ifndef SELFCONSUMPTIONCONFIGURATION_H
#define SELFCONSUMPTIONCONFIGURATION_H

#include <QObject>

class SelfConsumptionConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool selfConsumptionEnabled READ selfConsumptionEnabled WRITE setSelfConsumptionEnabled NOTIFY selfConsumptionEnabledChanged)
    Q_PROPERTY(int selfConsumptionTargetPower READ selfConsumptionTargetPower WRITE setSelfConsumptionTargetPower NOTIFY selfConsumptionTargetPowerChanged)
    Q_PROPERTY(double selfConsumptionKp READ selfConsumptionKp WRITE setSelfConsumptionKp NOTIFY selfConsumptionKpChanged)
    Q_PROPERTY(double selfConsumptionKi READ selfConsumptionKi WRITE setSelfConsumptionKi NOTIFY selfConsumptionKiChanged)
    Q_PROPERTY(double selfConsumptionKd READ selfConsumptionKd WRITE setSelfConsumptionKd NOTIFY selfConsumptionKdChanged)

public:
    explicit SelfConsumptionConfiguration(QObject *parent = nullptr);

    bool selfConsumptionEnabled() const;
    void setSelfConsumptionEnabled(bool selfConsumptionEnabled);

    int selfConsumptionTargetPower() const;
    void setSelfConsumptionTargetPower(int selfConsumptionTargetPower);

    double selfConsumptionKp() const;
    void setSelfConsumptionKp(double selfConsumptionKp);

    double selfConsumptionKi() const;
    void setSelfConsumptionKi(double selfConsumptionKi);

    double selfConsumptionKd() const;
    void setSelfConsumptionKd(double selfConsumptionKd);

signals:
    void selfConsumptionEnabledChanged(bool selfConsumptionEnabled);
    void selfConsumptionTargetPowerChanged(int selfConsumptionTargetPower);
    void selfConsumptionKpChanged(double selfConsumptionKp);
    void selfConsumptionKiChanged(double selfConsumptionKi);
    void selfConsumptionKdChanged(double selfConsumptionKd);

private:
    bool m_selfConsumptionEnabled = false;
    int m_selfConsumptionTargetPower = 0;
    double m_selfConsumptionKp = 0.10;
    double m_selfConsumptionKi = 0.10;
    double m_selfConsumptionKd = 0.00;
};

#endif // SELFCONSUMPTIONCONFIGURATION_H