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


int ConEMSState::timestamp() const
{
    return m_timestamp;
}

void ConEMSState::setTimestamp(int timestamp)
{
    m_timestamp = timestamp;
}
