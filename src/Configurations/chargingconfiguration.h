#ifndef CHARGINGCONFIGURATION_H
#define CHARGINGCONFIGURATION_H

#include <QUuid>
#include <QTime>
#include <QObject>

#include "controlconfigurationenums.h"

class ChargingConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid evChargerThingId READ evChargerThingId CONSTANT)
    Q_PROPERTY(ControlConfig::OperatingMode operatingMode READ operatingMode WRITE setOperatingMode NOTIFY operatingModeChanged)
    Q_PROPERTY(int optimizationStrategies READ optimizationStrategies WRITE setOptimizationStrategies NOTIFY optimizationStrategiesChanged)
    Q_PROPERTY(InsufficientPowerBehavior insufficientPowerBehavior READ insufficientPowerBehavior WRITE setInsufficientPowerBehavior NOTIFY insufficientPowerBehaviorChanged)
    Q_PROPERTY(QUuid carThingId READ carThingId WRITE setCarThingId NOTIFY carThingIdChanged)
    Q_PROPERTY(QString endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)
    Q_PROPERTY(uint targetPercentage READ targetPercentage WRITE setTargetPercentage NOTIFY targetPercentageChanged)
    Q_PROPERTY(QUuid uniqueIdentifier READ uniqueIdentifier WRITE setUniqueIdentifier NOTIFY uniqueIdentifierChanged)
    Q_PROPERTY(bool controllableLocalSystem READ controllableLocalSystem WRITE setControllableLocalSystem NOTIFY controllableLocalSystemChanged)
    Q_PROPERTY(double priceThreshold READ priceThreshold WRITE setPriceThreshold NOTIFY priceThresholdChanged)
    Q_PROPERTY(bool relativePriceEnabled READ relativePriceEnabled WRITE setRelativePriceEnabled NOTIFY relativePriceEnabledChanged)
    /*!
     * \brief JSON-serialisierter Wochenzeitplan für den zeitgesteuerten Lademodus (TIME_CONTROLLED).
     *
     * Der String enthält ein JSON-Array mit genau 7 Einträgen – einen pro Wochentag.
     * Die Einträge sind immer für alle Wochentage vorhanden; ein Eintrag mit
     * \c startTime == "00:00" und \c endTime == "00:00" bedeutet, dass für diesen Tag
     * kein Ladezeitfenster gesetzt ist.
     *
     * Jedes Objekt im Array hat folgende Felder:
     * \li \c day       – Wochentag als englischer Kleinbuchstaben-String
     *                    ("monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday")
     * \li \c startTime – Beginn des Ladezeitfensters im Format "HH:MM"
     * \li \c endTime   – Ende des Ladezeitfensters im Format "HH:MM"
     *
     * Beispiel:
     * \code{.json}
     * [
     *   {"day": "monday",    "startTime": "08:00", "endTime": "18:00"},
     *   {"day": "tuesday",   "startTime": "00:00", "endTime": "00:00"},
     *   {"day": "wednesday", "startTime": "08:00", "endTime": "18:00"},
     *   {"day": "thursday",  "startTime": "00:00", "endTime": "00:00"},
     *   {"day": "friday",    "startTime": "08:00", "endTime": "18:00"},
     *   {"day": "saturday",  "startTime": "00:00", "endTime": "00:00"},
     *   {"day": "sunday",    "startTime": "00:00", "endTime": "00:00"}
     * ]
     * \endcode
     *
     * Ein leerer String ("") bedeutet, dass noch kein Zeitplan konfiguriert wurde.
     * Wird nur ausgewertet, wenn \c optimizationStrategies das Bit \c TimeControlled gesetzt hat.
     */
    Q_PROPERTY(QString chargingSchedule READ chargingSchedule WRITE setChargingSchedule NOTIFY chargingScheduleChanged)
    Q_PROPERTY(uint desiredPhaseCount READ desiredPhaseCount WRITE setDesiredPhaseCount NOTIFY desiredPhaseCountChanged)
    Q_PROPERTY(uint durationMinAfterTurnOn READ durationMinAfterTurnOn WRITE setDurationMinAfterTurnOn NOTIFY durationMinAfterTurnOnChanged)
    Q_PROPERTY(uint switchDelayPhase READ switchDelayPhase WRITE setSwitchDelayPhase NOTIFY switchDelayPhaseChanged)

public:

    enum InsufficientPowerBehavior {
        ChargeWithMinimumCurrent = 0,
        PauseCharging = 1
    };
    Q_ENUM(InsufficientPowerBehavior)

    enum PhaseMode {
        Automatic = 0,
        SinglePhase = 1,
        ThreePhase = 3
    };
    Q_ENUM(PhaseMode)


    explicit ChargingConfiguration(QObject *parent = nullptr);

    QUuid evChargerThingId() const;
    void setEvChargerThingId(const QUuid &evChargerThingId);

    ControlConfig::OperatingMode operatingMode() const;
    void setOperatingMode(ControlConfig::OperatingMode operatingMode);

    int optimizationStrategies() const;
    void setOptimizationStrategies(int optimizationStrategies);

    InsufficientPowerBehavior insufficientPowerBehavior() const;
    void setInsufficientPowerBehavior(InsufficientPowerBehavior insufficientPowerBehavior);

    QUuid carThingId() const;
    void setCarThingId(const QUuid &carThingId);

    QString endTime() const;
    void setEndTime(const QString &endTime);

    uint targetPercentage() const;
    void setTargetPercentage(uint targetPercentage);

    QUuid uniqueIdentifier() const;
    void setUniqueIdentifier(QUuid uniqueIdentifier);

    bool controllableLocalSystem() const;
    void setControllableLocalSystem(bool controllableLocalSystem);

    double priceThreshold() const;
    void setPriceThreshold(double priceThreshold);

    bool relativePriceEnabled() const;
    void setRelativePriceEnabled(bool relativePriceEnabled);

    QString chargingSchedule() const;
    void setChargingSchedule(const QString &chargingSchedule);

    uint desiredPhaseCount() const;
    void setDesiredPhaseCount(uint desiredPhaseCount);

    uint durationMinAfterTurnOn() const;
    void setDurationMinAfterTurnOn(uint durationMinAfterTurnOn);

    uint switchDelayPhase() const;
    void setSwitchDelayPhase(uint switchDelayPhase);

signals:
    void operatingModeChanged(ControlConfig::OperatingMode operatingMode);
    void optimizationStrategiesChanged(int optimizationStrategies);
    void insufficientPowerBehaviorChanged(ChargingConfiguration::InsufficientPowerBehavior insufficientPowerBehavior);
    void carThingIdChanged(const QUuid &carThingId);
    void endTimeChanged(const QString &endTime);
    void targetPercentageChanged(uint targetPercentage);
    void uniqueIdentifierChanged(QUuid uniqueIdentifier);
    void controllableLocalSystemChanged(bool controllableLocalSystem);
    void priceThresholdChanged(double priceThreshold);
    void relativePriceEnabledChanged(bool relativePriceEnabled);
    void chargingScheduleChanged(const QString &chargingSchedule);
    void desiredPhaseCountChanged(uint desiredPhaseCount);
    void durationMinAfterTurnOnChanged(uint durationMinAfterTurnOn);
    void switchDelayPhaseChanged(uint switchDelayPhase);

private:
    QUuid m_evChargerThingId;
    ControlConfig::OperatingMode m_operatingMode = ControlConfig::NoControl;
    int m_optimizationStrategies = ControlConfig::NoStrategy;
    InsufficientPowerBehavior m_insufficientPowerBehavior = ChargeWithMinimumCurrent;
    QUuid m_carThingId = QUuid("00000000-0000-0000-0000-000000000000");
    QString m_endTime = "0:00:00";
    uint m_targetPercentage = 100;
    QUuid m_uniqueIdentifier = QUuid("2e2d25c5-57c7-419a-b294-881f11ed01c4");
    bool m_controllableLocalSystem = false;
    double m_priceThreshold = 0.0;
    bool m_relativePriceEnabled = false;
    QString m_chargingSchedule = "";
    uint m_desiredPhaseCount = ThreePhase;
    uint m_durationMinAfterTurnOn = 0;
    uint m_switchDelayPhase = 0;
};

#endif // CHARGINGCONFIGURATION_H
