#include "conemsstate.h"

ConEMSState::ConEMSState(QObject *parent): QObject(parent)
{

}

QUuid ConEMSState::ConEMSStateID() const
{
    return m_conEMSStateID;
}

void ConEMSState::setConEMSStateID(QUuid conEMSStateID)
{
    m_conEMSStateID = conEMSStateID;
}

ConEMSState::State ConEMSState::currentState() const
{
    return m_currentState;
}

void ConEMSState::setCurrentState(State currentState)
{
    m_currentState = currentState;
}

int ConEMSState::operationMode() const
{
    return m_operationMode;
}

void ConEMSState::setOperationMode(int operationMode)
{
    m_operationMode = operationMode;
}

int ConEMSState::timestamp() const
{
    return m_timestamp;
}

void ConEMSState::setTimestamp(int timestamp)
{
    m_timestamp = timestamp;
}
