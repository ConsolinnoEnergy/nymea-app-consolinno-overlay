#ifndef CONEMSSTATE_H
#define CONEMSSTATE_H


#include <QUuid>
#include <QTime>
#include <QObject>
#include <QJsonObject>

class ConEMSState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QJsonObject currentState READ currentState WRITE setCurrentState NOTIFY currentStateChanged)
    Q_PROPERTY(long timestamp READ timestamp WRITE setTimestamp NOTIFY timestampChanged)

public:

    explicit ConEMSState(QObject *parent = nullptr);

    // Controller Flags


    QJsonObject currentState() const;

    void setCurrentState(QJsonObject currentState);

    long timestamp() const;
    void setTimestamp(const long timestamp);


signals:

    void currentStateChanged(QJsonObject currentState);
    void timestampChanged(long timestamp);

private:

    QJsonObject m_currentState = QJsonObject();
    long m_timestamp = 0;


};
#endif // CONEMSSTATE_H
