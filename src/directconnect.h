// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef DIRECTCONNECT_H
#define DIRECTCONNECT_H

#include <QObject>
#include <QPointer>
#include <QUrl>

class QJSEngine;
class QQmlEngine;
class QLocalServer;
class QNetworkAccessManager;
class QNetworkReply;
class QTimer;
class JsonRpcClient;

struct DirectConnectEndpoint {
    QString key;
    QString managementBaseUrl;
    QString tunnelHost;
    QString tunnelPort;
};

/**
 * Handles the `consolinno-energy://connect?env=<test|qa|prod>&code=<code>`
 * deep link.
 *
 * The deep link only carries an environment key and a single-use handoff code.
 * The code is redeemed at the environment's device management endpoint, which
 * returns the tunnel connection data and a freshly created nymea session token.
 *
 * The session token never leaves this class: it is only handed to the
 * `JsonRpcClient` through `applyToken()`, never exposed as a QML property and
 * never written to disk.
 */
class DirectConnect : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool requestPending READ requestPending NOTIFY requestPendingChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)
    Q_PROPERTY(QString view READ view NOTIFY readyChanged)
    Q_PROPERTY(int shadowIndex READ shadowIndex WRITE setShadowIndex NOTIFY shadowIndexChanged)
    Q_PROPERTY(QString environment READ environment NOTIFY requestPendingChanged)

public:
    explicit DirectConnect(QObject *parent = nullptr);
    ~DirectConnect() override;

    static DirectConnect *instance();
    static QObject *qmlSingleton(QQmlEngine *engine, QJSEngine *scriptEngine);

    bool requestPending() const;
    bool busy() const;
    bool ready() const;
    QString errorString() const;
    QString view() const;
    int shadowIndex() const;
    void setShadowIndex(int index);
    QString environment() const;

    // Starts the redeem request if a deep link was provided at startup or
    // forwarded by a second instance.
    Q_INVOKABLE void start();

    // Applies the redeemed session token to the given client. The token is
    // consumed here and never exposed to QML.
    Q_INVOKABLE bool applyToken(JsonRpcClient *client);

    // tunnel:// url including the server uuid query parameter.
    Q_INVOKABLE QUrl tunnelUrl() const;

    // Clears all state after the request has been handled (success or failure).
    Q_INVOKABLE void reset();

signals:
    void requestPendingChanged();
    void busyChanged();
    void readyChanged();
    void errorStringChanged();
    void shadowIndexChanged();

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

private:
    static const DirectConnectEndpoint *endpointForKey(const QString &key);

    bool acceptUrl(const QUrl &url);
    bool acceptArguments(const QStringList &arguments);
    void startSingleInstance();
    void redeem();
    void onRedeemFinished(QNetworkReply *reply);
    void cleanupSessionSettings();
    void fail(const QString &reason);

    QNetworkAccessManager *m_network = nullptr;
    QLocalServer *m_localServer = nullptr;
    QTimer *m_timeout = nullptr;
    QPointer<QNetworkReply> m_reply;

    bool m_requestPending = false;
    bool m_busy = false;
    bool m_ready = false;
    int m_shadowIndex = -1;
    QString m_errorString;
    QString m_view;

    QString m_environment;
    QString m_code;
    QByteArray m_token;
    QString m_serverUuid;
    // Server uuid whose per-device settings are removed when the process ends.
    QString m_cleanupUuid;
    QUrl m_tunnelUrl;
};

#endif // DIRECTCONNECT_H
