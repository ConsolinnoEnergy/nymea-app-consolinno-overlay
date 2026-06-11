#ifndef DEVCONFIGPVSURPLUS_H
#define DEVCONFIGPVSURPLUS_H

#include <QObject>

class DevConfigPvSurplus : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int filterTimeConstant READ filterTimeConstant WRITE setFilterTimeConstant NOTIFY filterTimeConstantChanged)
    Q_PROPERTY(int postSwitchTimeout READ postSwitchTimeout WRITE setPostSwitchTimeout NOTIFY postSwitchTimeoutChanged)
    Q_PROPERTY(double pidKp READ pidKp WRITE setPidKp NOTIFY pidKpChanged)
    Q_PROPERTY(double pidKi READ pidKi WRITE setPidKi NOTIFY pidKiChanged)
    Q_PROPERTY(double pidKd READ pidKd WRITE setPidKd NOTIFY pidKdChanged)
    Q_PROPERTY(double pidSetpoint READ pidSetpoint WRITE setPidSetpoint NOTIFY pidSetpointChanged)

public:
    explicit DevConfigPvSurplus(QObject *parent = nullptr);

    int filterTimeConstant() const; // [s]
    void setFilterTimeConstant(int filterTimeConstant);

    int postSwitchTimeout() const; // [s]
    void setPostSwitchTimeout(int postSwitchTimeout);

    double pidKp() const;
    void setPidKp(double pidKp);

    double pidKi() const;
    void setPidKi(double pidKi);

    double pidKd() const;
    void setPidKd(double pidKd);

    double pidSetpoint() const; // [W]
    void setPidSetpoint(double pidSetpoint);

signals:
    void filterTimeConstantChanged(int filterTimeConstant);
    void postSwitchTimeoutChanged(int postSwitchTimeout);
    void pidKpChanged(double pidKp);
    void pidKiChanged(double pidKi);
    void pidKdChanged(double pidKd);
    void pidSetpointChanged(double pidSetpoint);

private:
    int m_filterTimeConstant = 600; // [s]
    int m_postSwitchTimeout = 60;   // [s]
    double m_pidKp = 0.05;
    double m_pidKi = 0.0;
    double m_pidKd = 0.0;
    double m_pidSetpoint = 0.0;     // [W]
};

#endif // DEVCONFIGPVSURPLUS_H
