#ifndef CHARGINGCONFIGURATION_H
#define CHARGINGCONFIGURATION_H

#include <QUuid>
#include <QTime>
#include <QObject>

class ChargingConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid evChargerThingId READ evChargerThingId CONSTANT)
    Q_PROPERTY(bool optimizationEnabled READ optimizationEnabled WRITE setOptimizationEnabled NOTIFY optimizationEnabledChanged)
    Q_PROPERTY(QUuid carThingId READ carThingId WRITE setCarThingId NOTIFY carThingIdChanged)
    Q_PROPERTY(QString endTime READ endTime WRITE setEndTime NOTIFY endTimeChanged)
    Q_PROPERTY(uint targetPercentage READ targetPercentage WRITE setTargetPercentage NOTIFY targetPercentageChanged)
    Q_PROPERTY(int optimizationMode READ optimizationMode WRITE setOptimizationMode NOTIFY optimizationModeChanged)
    Q_PROPERTY(QUuid uniqueIdentifier READ uniqueIdentifier WRITE setUniqueIdentifier NOTIFY uniqueIdentifierChanged)
    Q_PROPERTY(bool controllableLocalSystem READ controllableLocalSystem WRITE setControllableLocalSystem NOTIFY controllableLocalSystemChanged)
    Q_PROPERTY(float priceThreshold READ priceThreshold WRITE setPriceThreshold NOTIFY priceThresholdChanged)
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
     * Wird nur im Modus \c OptimizationMode == TIME_CONTROLLED (optimizationMode >= 5000) ausgewertet.
     */
    Q_PROPERTY(QString chargingSchedule READ chargingSchedule WRITE setChargingSchedule NOTIFY chargingScheduleChanged)
    Q_PROPERTY(uint desiredPhaseCount READ desiredPhaseCount WRITE setDesiredPhaseCount NOTIFY desiredPhaseCountChanged)

public:

    enum OptimizationMode {
        Unoptimized = 0,
        PVOptimized = 1

    };
    Q_ENUM(OptimizationMode)

    enum PhaseMode {
        Automatic = 0,
        SinglePhase = 1,
        ThreePhase = 3
    };
    Q_ENUM(PhaseMode)


    explicit ChargingConfiguration(QObject *parent = nullptr);

    QUuid evChargerThingId() const;
    void setEvChargerThingId(const QUuid &evChargerThingId);

    bool optimizationEnabled() const;
    void setOptimizationEnabled(bool optimizationEnabled);

    QUuid carThingId() const;
    void setCarThingId(const QUuid &carThingId);

    QString endTime() const;
    void setEndTime(const QString &endTime);

    uint targetPercentage() const;
    void setTargetPercentage(uint targetPercentage);


    int optimizationMode() const;
    void setOptimizationMode(int optimizationMode);

    QUuid uniqueIdentifier() const;
    void setUniqueIdentifier(QUuid uniqueIdentifier);

    bool controllableLocalSystem() const;
    void setControllableLocalSystem(bool controllableLocalSystem);

    float priceThreshold() const;
    void setPriceThreshold(float priceThreshold);

    QString chargingSchedule() const;
    void setChargingSchedule(const QString &chargingSchedule);

    uint desiredPhaseCount() const;
    void setDesiredPhaseCount(uint desiredPhaseCount);

signals:
    void optimizationEnabledChanged(bool optimizationEnabled);
    void carThingIdChanged(const QUuid &carThingId);
    void endTimeChanged(const QString &endTime);
    void targetPercentageChanged(uint targetPercentage);
    void optimizationModeChanged(int optimizationMode);
    void uniqueIdentifierChanged(QUuid uniqueIdentifier);
    void controllableLocalSystemChanged(bool controllableLocalSystem);
    void priceThresholdChanged(float priceThreshold);
    void chargingScheduleChanged(const QString &chargingSchedule);
    void desiredPhaseCountChanged(uint desiredPhaseCount);

private:
    QUuid m_evChargerThingId;
    bool m_optimizationEnabled = false;
    QUuid m_carThingId = "00000000-0000-0000-0000-000000000000";
    QString m_endTime = "0:00:00";
    uint m_targetPercentage = 100;
    int m_optimizationMode = 0;
    QUuid m_uniqueIdentifier = "2e2d25c5-57c7-419a-b294-881f11ed01c4";
    bool m_controllableLocalSystem = false;
    float m_priceThreshold = 0.0;
    QString m_chargingSchedule = "";
    uint m_desiredPhaseCount = ThreePhase;
};

#endif // CHARGINGCONFIGURATION_H
