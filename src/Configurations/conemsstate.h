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
    Q_PROPERTY(int timestamp READ timestamp WRITE setTimestamp NOTIFY timestampChanged)

public:

    explicit ConEMSState(QObject *parent = nullptr);

    // Controller Flags


    QJsonObject currentState() const;

    void setCurrentState(QJsonObject currentState);

    int timestamp() const;
    void setTimestamp(const int timestamp);


signals:

    void currentStateChanged(QJsonObject currentState);
    void timestampChanged(int timestamp);

private:

    QJsonObject m_currentState = QJsonObject();
    int m_timestamp = 0;


};
#endif // CONEMSSTATE_H
