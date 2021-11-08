#ifndef HEMSMANAGER_H
#define HEMSMANAGER_H

#include <QObject>

#include "engine.h"
#include "heatingconfigurations.h"
#include "chargingconfigurations.h"

class HemsManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(Engine *engine READ engine WRITE setEngine NOTIFY engineChanged)
    Q_PROPERTY(bool fetchingData READ fetchingData NOTIFY fetchingDataChanged)

    Q_PROPERTY(HemsUseCases availableUseCases READ availableUseCases NOTIFY availableUseCasesChanged)
    Q_PROPERTY(HeatingConfigurations *heatingConfigurations READ heatingConfigurations CONSTANT)
    Q_PROPERTY(ChargingConfigurations *chargingConfigurations READ chargingConfigurations CONSTANT)

public:
    enum HemsUseCase {
        HemsUseCaseBlackoutProtection = 0x01,
        HemsUseCaseHeating = 0x02,
        HemsUseCaseCharging = 0x04
    };
    Q_ENUM(HemsUseCase)
    Q_DECLARE_FLAGS(HemsUseCases, HemsUseCase)
    Q_FLAG(HemsUseCases)

    explicit HemsManager(QObject *parent = nullptr);
    ~HemsManager();

    Engine *engine() const;
    void setEngine(Engine *engine);

    bool fetchingData() const;

    HemsUseCases availableUseCases() const;
    HeatingConfigurations *heatingConfigurations() const;
    ChargingConfigurations *chargingConfigurations() const;

signals:
    void engineChanged();
    void fetchingDataChanged();

    void availableUseCasesChanged(HemsUseCases availableUseCases);

private slots:
    void notificationReceived(const QVariantMap &data);

    void getAvailableUseCasesResponse(int commandId, const QVariantMap &data);
    void getHeatingConfigurationsResponse(int commandId, const QVariantMap &data);
    void getChargingConfigurationsResponse(int commandId, const QVariantMap &data);

private:
    QPointer<Engine> m_engine = nullptr;
    bool m_fetchingData = false;

    HemsUseCases m_availableUseCases;
    HeatingConfigurations *m_heatingConfigurations = nullptr;
    ChargingConfigurations *m_chargingConfigurations = nullptr;

    void addOrUpdateHeatingConfiguration(const QVariantMap &configurationMap);
    void addOrUpdateChargingConfiguration(const QVariantMap &configurationMap);
    HemsManager::HemsUseCases unpackUseCases(const QStringList &useCasesList);
};

Q_DECLARE_OPERATORS_FOR_FLAGS(HemsManager::HemsUseCases)

#endif // HEMSMANAGER_H
