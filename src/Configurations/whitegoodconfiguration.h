#ifndef WHITEGOODCONFIGURATION_H
#define WHITEGOODCONFIGURATION_H

#include <QUuid>
#include <QObject>

class WhiteGoodConfiguration : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid whiteGoodThingId READ whiteGoodThingId CONSTANT)

public:
    explicit WhiteGoodConfiguration(QObject *parent = nullptr);

    QUuid whiteGoodThingId() const;
    void setWhiteGoodThingId(const QUuid &whiteGoodThingId);

private:
    QUuid m_whiteGoodThingId;
};
#endif // WHITEGOODCONFIGURATION_H
