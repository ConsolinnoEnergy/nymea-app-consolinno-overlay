#include "whitegoodconfiguration.h"

WhiteGoodConfiguration::WhiteGoodConfiguration(QObject *parent) : QObject(parent)
{

}

QUuid WhiteGoodConfiguration::whiteGoodThingId() const
{
    return m_whiteGoodThingId;
}

void WhiteGoodConfiguration::setWhiteGoodThingId(const QUuid &whiteGoodThingId)
{
    m_whiteGoodThingId = whiteGoodThingId;
}
