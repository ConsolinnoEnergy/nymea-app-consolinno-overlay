#ifndef SELFCONSUMPTIONCONFIGURATION_H
#define SELFCONSUMPTIONCONFIGURATION_H

#include <QObject>

class SelfConsumptionConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool selfConsumptionEnabled READ selfConsumptionEnabled WRITE setSelfConsumptionEnabled NOTIFY selfConsumptionEnabledChanged)
    Q_PROPERTY(int selfConsumptionTargetPower READ selfConsumptionTargetPower WRITE setSelfConsumptionTargetPower NOTIFY selfConsumptionTargetPowerChanged)
    Q_PROPERTY(float selfConsumptionKp READ selfConsumptionKp WRITE setSelfConsumptionKp NOTIFY selfConsumptionKpChanged)
    Q_PROPERTY(float selfConsumptionKi READ selfConsumptionKi WRITE setSelfConsumptionKi NOTIFY selfConsumptionKiChanged)
    Q_PROPERTY(float selfConsumptionKd READ selfConsumptionKd WRITE setSelfConsumptionKd NOTIFY selfConsumptionKdChanged)

public:
    explicit SelfConsumptionConfiguration(QObject *parent = nullptr);

    bool selfConsumptionEnabled() const;
    void setSelfConsumptionEnabled(bool selfConsumptionEnabled);

    int selfConsumptionTargetPower() const;
    void setSelfConsumptionTargetPower(int selfConsumptionTargetPower);

    float selfConsumptionKp() const;
    void setSelfConsumptionKp(float selfConsumptionKp);

    float selfConsumptionKi() const;
    void setSelfConsumptionKi(float selfConsumptionKi);

    float selfConsumptionKd() const;
    void setSelfConsumptionKd(float selfConsumptionKd);

signals:
    void selfConsumptionEnabledChanged(bool selfConsumptionEnabled);
    void selfConsumptionTargetPowerChanged(int selfConsumptionTargetPower);
    void selfConsumptionKpChanged(float selfConsumptionKp);
    void selfConsumptionKiChanged(float selfConsumptionKi);
    void selfConsumptionKdChanged(float selfConsumptionKd);

private:
    bool m_selfConsumptionEnabled = false;
    int m_selfConsumptionTargetPower = 0;
    float m_selfConsumptionKp = 0.10;
    float m_selfConsumptionKi = 0.10;
    float m_selfConsumptionKd = 0.00;
};

#endif // SELFCONSUMPTIONCONFIGURATION_H
