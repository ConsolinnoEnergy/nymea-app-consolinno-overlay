#ifndef CONEMSSTATE_H
#define CONEMSSTATE_H


#include <QList>
#include <QUuid>
#include <QTime>
#include <QObject>
#include <QJsonObject>

class ConEMSState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QJsonObject currentState READ currentState WRITE setCurrentState NOTIFY currentStateChanged)
    Q_PROPERTY(long timestamp READ timestamp WRITE setTimestamp NOTIFY timestampChanged)
    Q_PROPERTY(QList<QUuid> runtimeExceededThings READ runtimeExceededThings NOTIFY runtimeExceededThingsChanged)
    Q_PROPERTY(QList<QUuid> switchDownBlockedThings READ switchDownBlockedThings NOTIFY switchDownBlockedThingsChanged)

public:

    explicit ConEMSState(QObject *parent = nullptr);

    QJsonObject currentState() const;
    void setCurrentState(QJsonObject currentState);

    long timestamp() const;
    void setTimestamp(const long timestamp);

    QList<QUuid> runtimeExceededThings() const;
    QList<QUuid> switchDownBlockedThings() const;

    Q_INVOKABLE bool isRuntimeExceeded(const QUuid &thingId) const;
    Q_INVOKABLE bool isSwitchDownBlocked(const QUuid &thingId) const;

signals:

    void currentStateChanged(QJsonObject currentState);
    void timestampChanged(long timestamp);
    void runtimeExceededThingsChanged(QList<QUuid> runtimeExceededThings);
    void switchDownBlockedThingsChanged(QList<QUuid> switchDownBlockedThings);

private:

    QJsonObject m_currentState = QJsonObject();
    long m_timestamp = 0;
    QList<QUuid> m_runtimeExceededThings;
    QList<QUuid> m_switchDownBlockedThings;

};
#endif // CONEMSSTATE_H
