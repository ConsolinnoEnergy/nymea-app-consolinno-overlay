#include "conemsstate.h"

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
}


long ConEMSState::timestamp() const
{
    return m_timestamp;
}

void ConEMSState::setTimestamp(long timestamp)
{
    m_timestamp = timestamp;
}
