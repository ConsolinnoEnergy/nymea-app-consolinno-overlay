#include "conemsstate.h"
#include <QJsonArray>

ConEMSState::ConEMSState(QObject *parent): QObject(parent)
{

}

QJsonObject ConEMSState::currentState() const
{
    return m_currentState;
}

void ConEMSState::setCurrentState(QJsonObject currentState)
{
    m_currentState = currentState;

    QList<QUuid> runtimeExceeded;
    const QJsonArray runtimeArr = currentState.value("runtime_exceeded_things").toArray();
    for (const QJsonValue &v : runtimeArr) {
        runtimeExceeded.append(QUuid(v.toString()));
    }
    if (m_runtimeExceededThings != runtimeExceeded) {
        m_runtimeExceededThings = runtimeExceeded;
        emit runtimeExceededThingsChanged(m_runtimeExceededThings);
    }

    QList<QUuid> switchDownBlocked;
    const QJsonArray switchDownArr = currentState.value("switch_down_blocked_things").toArray();
    for (const QJsonValue &v : switchDownArr) {
        switchDownBlocked.append(QUuid(v.toString()));
    }
    if (m_switchDownBlockedThings != switchDownBlocked) {
        m_switchDownBlockedThings = switchDownBlocked;
        emit switchDownBlockedThingsChanged(m_switchDownBlockedThings);
    }
}

long ConEMSState::timestamp() const
{
    return m_timestamp;
}

void ConEMSState::setTimestamp(long timestamp)
{
    m_timestamp = timestamp;
}

QList<QUuid> ConEMSState::runtimeExceededThings() const
{
    return m_runtimeExceededThings;
}

QList<QUuid> ConEMSState::switchDownBlockedThings() const
{
    return m_switchDownBlockedThings;
}
