#ifndef HEMSMANAGER_H
#define HEMSMANAGER_H

#include <QObject>

#include "engine.h"
#include "Configurations/heatingconfigurations.h"
#include "Configurations/chargingconfigurations.h"
#include "Configurations/chargingsessionconfigurations.h"
#include "Configurations/pvconfigurations.h"
#include "Configurations/userconfigurations.h"
#include "Configurations/conemsstate.h"
#include "Configurations/chargingoptimizationconfigurations.h"
#include "Configurations/heatingelementconfigurations.h"

#include "Configurations/conemsstate.h"



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
    Q_PROPERTY(ChargingOptimizationConfigurations *chargingOptimizationConfigurations READ chargingOptimizationConfigurations CONSTANT)
    Q_PROPERTY(PvConfigurations *pvConfigurations READ pvConfigurations CONSTANT)
    Q_PROPERTY(ChargingSessionConfigurations *chargingSessionConfigurations READ chargingSessionConfigurations CONSTANT)
    Q_PROPERTY(ConEMSState *conEMSState READ conEMSState CONSTANT)
    Q_PROPERTY(UserConfigurations *userConfigurations READ userConfigurations CONSTANT)
    Q_PROPERTY(HeatingElementConfigurations *heatingElementConfigurations READ heatingElementConfigurations CONSTANT)

    Q_PROPERTY(bool averagingPowerEnabled READ averagingPowerEnabled WRITE setAveragingPowerEnabled NOTIFY averagingPowerEnabledChanged)


public:
    enum HemsUseCase {
        HemsUseCaseNone = 0x00,
        HemsUseCaseBlackoutProtection = 0x01,
        HemsUseCaseHeating = 0x02,
        HemsUseCaseCharging = 0x04,
        HemsUseCasePv = 0x08,
        HemsUseCaseBattery = 0x10,
        HemsUseCaseHeatingElement = 0x20,
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
    ChargingOptimizationConfigurations *chargingOptimizationConfigurations() const;
    PvConfigurations *pvConfigurations() const;
    ChargingSessionConfigurations *chargingSessionConfigurations() const;
    ConEMSState *conEMSState() const;
    UserConfigurations *userConfigurations() const;
    HeatingElementConfigurations *heatingElementConfigurations() const;
    bool averagingPowerEnabled() const;

    // write and read
    Q_INVOKABLE int setPvConfiguration(const QUuid &pvThingId, const QVariantMap &data);
    Q_INVOKABLE int setHeatingConfiguration(const QUuid &heatPumpThingId, const QVariantMap &data);
    Q_INVOKABLE int setChargingConfiguration(const QUuid &evChargerThingId, const QVariantMap &data );
    Q_INVOKABLE int setChargingOptimizationConfiguration(const QUuid &evChargerThingId, const QVariantMap &data );
    Q_INVOKABLE int setUserConfiguration(const QVariantMap &data);
    Q_INVOKABLE int setHeatingElementConfiguration(const QUuid &heatingRodThingId, const QVariantMap &data);

    
    Q_INVOKABLE void setAveragingPowerEnabled(const bool averagingPowerEnabled);

    // read only
    Q_INVOKABLE int setChargingSessionConfiguration(const QUuid carThingId, const QUuid evChargerThingid, const QString started_at, const QString finished_at, const float initial_battery_energy, const int duration, const float energy_charged, const float energy_battery, const int battery_level, const QUuid sessionId, const int state, const int timestamp);
    Q_INVOKABLE int setConEMSState(int currentState, int operationMode, int timestamp);


signals:

    void engineChanged();
    void availableChanged();
    void fetchingDataChanged();

    void availableUseCasesChanged(HemsUseCases availableUseCases);
    void housholdPhaseLimitChanged(uint housholdPhaseLimit);

    void chargingSessionConfigurationChanged(ChargingSessionConfiguration *configuration);
    void chargingConfigurationChanged(ChargingConfiguration *configuration);
    void chargingOptimizationConfigurationChanged(ChargingOptimizationConfiguration *configuration);
    void conEMSStateChanged(ConEMSState *state);
    void pvConfigurationChanged(PvConfiguration *configuration);
    void userConfigurationChanged(UserConfiguration *configuration);
    void heatingElementConfigurationChanged(HeatingElementConfiguration *configuration);

    void setHousholdPhaseLimitReply(int commandId, const QString &error);

    void setPvConfigurationReply(int commandId, const QString &error);
    void setHeatingConfigurationReply(int commandId, const QString &error);
    void setChargingConfigurationReply(int commandId, const QString &error);
    void setChargingOptimizationConfigurationReply(int commandId, const QString &error);
    void setChargingSessionConfigurationReply(int commandId, const QString &error);
    void setConEMSStateReply(int commandId, const QString &error);
    void setUserConfigurationReply(int commandId, const QString &error);
    void setHeatingElementConfigurationReply(int commandId, const QString &error);

    void averagingPowerEnabledChanged();



private slots:
    Q_INVOKABLE void notificationReceived(const QVariantMap &data);

    Q_INVOKABLE void getAvailableUseCasesResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void getHousholdPhaseLimitResponse(int commandId, const QVariantMap &data);

    Q_INVOKABLE void getHeatingConfigurationsResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void getChargingConfigurationsResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void getChargingOptimizationConfigurationsResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void getChargingSessionConfigurationsResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void getPvConfigurationsResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void getConEMSStateResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void getUserConfigurationsResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void getHeatingElementConfigurationsResponse(int commandId, const QVariantMap &data);

    Q_INVOKABLE void setHousholdPhaseLimitResponse(int commandId, const QVariantMap &data);

    Q_INVOKABLE void setPvConfigurationResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void setHeatingConfigurationResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void setChargingConfigurationResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void setChargingOptimizationConfigurationResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void setChargingSessionConfigurationResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void setConEMSStateResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void setUserConfigurationResponse(int commandId, const QVariantMap &data);
    Q_INVOKABLE void setHeatingElementConfigurationResponse(int commandId, const QVariantMap &data);

private:
    QPointer<Engine> m_engine = nullptr;
    bool m_fetchingData = false;
    bool m_available = false;

    HemsUseCases m_availableUseCases;
    uint m_housholdPhaseLimit = 25;

    HeatingConfigurations *m_heatingConfigurations = nullptr;
    ChargingConfigurations *m_chargingConfigurations = nullptr;
    ChargingOptimizationConfigurations *m_chargingOptimizationConfigurations = nullptr;
    ChargingSessionConfigurations *m_chargingSessionConfigurations = nullptr;
    PvConfigurations *m_pvConfigurations = nullptr;
    ConEMSState *m_conEMSState = nullptr;
    UserConfigurations *m_userConfigurations = nullptr;
    HeatingElementConfigurations *m_heatingElementConfigurations = nullptr;
    bool m_averagingPowerEnabled = true;

    void addOrUpdateHeatingConfiguration(const QVariantMap &configurationMap);
    void addOrUpdateChargingConfiguration(const QVariantMap &configurationMap);
    void addOrUpdateChargingOptimizationConfiguration(const QVariantMap &configurationMap);
    void addOrUpdateChargingSessionConfiguration(const QVariantMap &configurationMap);
    void addOrUpdatePvConfiguration(const QVariantMap &configurationMap);
    void addOrUpdateConEMSState(const QVariantMap &configurationMap);
    void addOrUpdateUserConfiguration(const QVariantMap &configurationMap);
    void addOrUpdateHeatingElementConfiguration(const QVariantMap &configurationMap);

    void updateAvailableUsecases(const QStringList &useCasesList);
    HemsManager::HemsUseCases unpackUseCases(const QStringList &useCasesList);

};

Q_DECLARE_OPERATORS_FOR_FLAGS(HemsManager::HemsUseCases)

#endif // HEMSMANAGER_H
