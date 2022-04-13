#ifndef HEMSMANAGER_H
#define HEMSMANAGER_H

#include <QObject>

#include "engine.h"
#include "heatingconfigurations.h"
#include "chargingconfigurations.h"
#include "chargingsessionconfigurations.h"
#include "pvconfigurations.h"

class HemsManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(bool fetchingData READ fetchingData NOTIFY fetchingDataChanged)

    Q_PROPERTY(bool available READ available NOTIFY availableChanged)
    Q_PROPERTY(HemsUseCases availableUseCases READ availableUseCases NOTIFY availableUseCasesChanged)
    Q_PROPERTY(uint housholdPhaseLimit READ housholdPhaseLimit NOTIFY housholdPhaseLimitChanged)
    Q_PROPERTY(HeatingConfigurations *heatingConfigurations READ heatingConfigurations CONSTANT)
    Q_PROPERTY(ChargingConfigurations *chargingConfigurations READ chargingConfigurations CONSTANT)
    Q_PROPERTY(PvConfigurations *pvConfigurations READ pvConfigurations CONSTANT)
    Q_PROPERTY(ChargingSessionConfigurations *chargingSessionConfigurations READ chargingSessionConfigurations CONSTANT)

public:
    enum HemsUseCase {
        HemsUseCaseNone = 0x00,
        HemsUseCaseBlackoutProtection = 0x01,
        HemsUseCaseHeating = 0x02,
        HemsUseCaseCharging = 0x04,
        HemsUseCasePv = 0x08,
        HemsUseCaseChargingSession = 0x16,
        HemsUseCaseAll = 0xff,

    };
    Q_ENUM(HemsUseCase)
    Q_DECLARE_FLAGS(HemsUseCases, HemsUseCase)
    Q_FLAG(HemsUseCases)

    explicit HemsManager(QObject *parent = nullptr);
    ~HemsManager();

    Engine *engine() const;
    void setEngine(Engine *engine);

    bool available() const;
    bool fetchingData() const;

    HemsUseCases availableUseCases() const;

    uint housholdPhaseLimit() const;
    Q_INVOKABLE int setHousholdPhaseLimit(uint housholdPhaseLimit);

    HeatingConfigurations *heatingConfigurations() const;
    ChargingConfigurations *chargingConfigurations() const;
    PvConfigurations *pvConfigurations() const;
    ChargingSessionConfigurations *chargingSessionConfigurations() const;


    Q_INVOKABLE int setPvConfiguration(const QUuid &pvPumpThingId, const float &longitude, const float &latitude, const int &roofPitch, const int &alignment, const float &kwPeak);
    Q_INVOKABLE int setHeatingConfiguration(const QUuid &heatPumpThingId, bool optimizationEnabled, const double & floorHeatingArea, const double &maxElectricalPower, const double &maxThermalEnergy, const QUuid &heatMeterThingId = QUuid());
    Q_INVOKABLE int setChargingConfiguration(const QUuid &evChargerThingId, bool optimizationEnabled, const QUuid &carThingId,  int hours,  int minutes, uint targetPercentage, bool zeroReturnPolicyEnabled, float necessaryEnergy);
    Q_INVOKABLE int setChargingSessionConfiguration(const QUuid chargingSession, const QUuid carThingId, const QUuid evChargerThingid, const QTime started_at, const QTime finished_at, const float initial_battery_energy, const int duration, const float energy_charged, const float energy_battery, const int battery_level);

signals:

    void engineChanged();
    void availableChanged();
    void fetchingDataChanged();

    void availableUseCasesChanged(HemsUseCases availableUseCases);
    void housholdPhaseLimitChanged(uint housholdPhaseLimit);

    void setHousholdPhaseLimitReply(int commandId, const QString &error);

    void setPvConfigurationReply(int commandId, const QString &error);
    void setHeatingConfigurationReply(int commandId, const QString &error);
    void setChargingConfigurationReply(int commandId, const QString &error);
    void setChargingSessionConfigurationReply(int commandId, const QString &error);



private slots:
    Q_INVOKABLE void notificationReceived(const QVariantMap &data);

    Q_INVOKABLE void getAvailableUseCasesResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void getHousholdPhaseLimitResponse(int commandId, const QVariantMap &data);

    Q_INVOKABLE void getHeatingConfigurationsResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void getChargingConfigurationsResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void getChargingSessionConfigurationsResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void getPvConfigurationsResponse(int commandId, const QVariantMap &data);


    Q_INVOKABLE void setHousholdPhaseLimitResponse(int commandId, const QVariantMap &data);

    Q_INVOKABLE void setPvConfigurationResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void setHeatingConfigurationResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void setChargingConfigurationResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void setChargingSessionConfigurationResponse(int commandId, const QVariantMap &data);

private:
    QPointer<Engine> m_engine = nullptr;
    bool m_fetchingData = false;
    bool m_available = false;

    HemsUseCases m_availableUseCases;
    uint m_housholdPhaseLimit = 25;

    HeatingConfigurations *m_heatingConfigurations = nullptr;
    ChargingConfigurations *m_chargingConfigurations = nullptr;
    ChargingSessionConfigurations *m_chargingSessionConfigurations = nullptr;
    PvConfigurations *m_pvConfigurations = nullptr;


    void addOrUpdateHeatingConfiguration(const QVariantMap &configurationMap);
    void addOrUpdateChargingConfiguration(const QVariantMap &configurationMap);
    void addOrUpdateChargingSessionConfiguration(const QVariantMap &configurationMap);
    void addOrUpdatePvConfiguration(const QVariantMap &configurationMap);


    void updateAvailableUsecases(const QStringList &useCasesList);
    HemsManager::HemsUseCases unpackUseCases(const QStringList &useCasesList);
};

Q_DECLARE_OPERATORS_FOR_FLAGS(HemsManager::HemsUseCases)

#endif // HEMSMANAGER_H
