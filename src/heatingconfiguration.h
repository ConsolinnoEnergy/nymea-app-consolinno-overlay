#ifndef HEATINGCONFIGURATION_H
#define HEATINGCONFIGURATION_H

#include <QUuid>
#include <QObject>

class HeatingConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid heatPumpThingId READ heatPumpThingId CONSTANT)
    Q_PROPERTY(bool optimizationEnabled READ optimizationEnabled WRITE setOptimizationEnabled NOTIFY optimizationEnabledChanged)
    Q_PROPERTY(QUuid heatMeterThingId READ heatMeterThingId WRITE setHeatMeterThingId NOTIFY heatMeterThingIdChanged)

public:
    explicit HeatingConfiguration(QObject *parent = nullptr);

    QUuid heatPumpThingId() const;
    void setHeatPumpThingId(const QUuid &heatPumpThingId);

    bool optimizationEnabled() const;
    void setOptimizationEnabled(bool optimizationEnabled);

    QUuid heatMeterThingId() const;
    void setHeatMeterThingId(const QUuid &heatMeterThingId);

signals:
    void optimizationEnabledChanged(bool optimizationEnabled);
    void heatMeterThingIdChanged(const QUuid &heatMeterThingId);

private:
    QUuid m_heatPumpThingId;
    bool m_optimizationEnabled = false;
    QUuid m_heatMeterThingId;

};

#endif // HEATINGCONFIGURATION_H
