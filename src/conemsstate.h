#ifndef CONEMSSTATE_H
#define CONEMSSTATE_H


#include <QUuid>
#include <QTime>
#include <QObject>

class ConEMSState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUuid ConEMSStateID READ ConEMSStateID CONSTANT)
    Q_PROPERTY(State currentState READ currentState WRITE setCurrentState NOTIFY currentStateChanged)
    Q_PROPERTY(int operationMode READ operationMode WRITE setOperationMode NOTIFY operationModeChanged)
    Q_PROPERTY(int timestamp READ timestamp WRITE setTimestamp NOTIFY timestampChanged)

public:

    explicit ConEMSState(QObject *parent = nullptr);

    enum State {
        Unknown = 0,
        Running = 1,
        Optimizer_Busy = 2,
        Restarting = 3,
        Error = 4,
    };
    Q_ENUM(State);

    enum Controller{
        CHARGING_CONTROLLER = 1,
        HEATPUMP_CONTROLLER = 2




    };
    Q_ENUM(Controller);

    // Controller Flags

    Q_INVOKABLE bool chargingControllerActive();
    Q_INVOKABLE bool heatpumpControllerActive();

    QUuid ConEMSStateID() const;
    void setConEMSStateID(const QUuid conEMSStateID);

    State currentState() const;
    void setCurrentState(State currentState);

    int operationMode() const;
    void setOperationMode(const int operationMode);

    int timestamp() const;
    void setTimestamp(const int timestamp);




signals:

    void currentStateChanged(State currentState);
    void operationModeChanged(const int operationMode);
    void timestampChanged(const int timestamp);



private:


    QUuid m_conEMSStateID = "f002d80e-5f90-445c-8e95-a0256a0b464e";
    State m_currentState = State::Optimizer_Busy;
    int m_operationMode = 0;
    int m_timestamp = 0;



};
#endif // CONEMSSTATE_H
