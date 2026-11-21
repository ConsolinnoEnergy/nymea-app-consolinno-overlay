// SPDX-License-Identifier: GPL-3.0-or-later

#include "directconnect.h"

#include <QCoreApplication>
#include <QFileOpenEvent>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QLocalServer>
#include <QLocalSocket>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QRegularExpression>
#include <QSet>
#include <QSettings>
#include <QSslError>
#include <QStandardPaths>
#include <QTimer>
#include <QUrlQuery>
#include <QUuid>

#include <cstdlib>

#include "jsonrpc/jsonrpcclient.h"
#include "logging.h"

#ifdef Q_OS_UNIX
#include <sys/socket.h>
#include <unistd.h>
#endif

NYMEA_LOGGING_CATEGORY(dcDirectConnect, "DirectConnect")

namespace {

// The device management endpoints are compiled in on purpose: the deep link
// only carries an environment key, never a URL.
const QList<DirectConnectEndpoint> &compiledEndpoints()
{
    static const QList<DirectConnectEndpoint> endpoints = {
        { QStringLiteral("test"),
          QStringLiteral("https://service-ui-api.services-test.consolinno-it.de"),
          QStringLiteral("hems-remoteproxy.services-test.consolinno-it.de"),
          QStringLiteral("2213") },
        { QStringLiteral("qa"),
          QStringLiteral("https://service-ui-api.services-qa.consolinno.de"),
          QStringLiteral("hems-remoteproxy.services-qa.consolinno.de"),
          QStringLiteral("2213") },
        { QStringLiteral("prod"),
          QStringLiteral("https://service-ui-api.services.consolinno.de"),
          QStringLiteral("hems-remoteproxy.services.consolinno.de"),
          QStringLiteral("2213") },
    };
    return endpoints;
}

// Tunnel proxies are shared between environments: a device registered in the
// test inventory may be attached to the production proxy and vice versa. All
// three endpoints are publicly CA-signed and are the only hosts the app will
// connect to for a direct connect session.
bool isKnownTunnelEndpoint(const QString &host, int port)
{
    static const QSet<QString> hosts = {
        QStringLiteral("hems-remoteproxy.services.consolinno.de"),
        QStringLiteral("hems-remoteproxy.services-qa.consolinno.de"),
        QStringLiteral("hems-remoteproxy.services-test.consolinno-it.de"),
    };
    return port == 2213 && hosts.contains(host.toLower());
}

constexpr int kRedeemTimeoutMs = 8000;
constexpr auto kLastSessionUuidKey = "DirectConnect/lastSessionUuid";
constexpr qint64 kMaxResponseBytes = 4096;

} // namespace

DirectConnect::DirectConnect(QObject *parent)
    : QObject(parent)
{
    m_network = new QNetworkAccessManager(this);

    QCoreApplication::instance()->installEventFilter(this);
    connect(QCoreApplication::instance(), &QCoreApplication::aboutToQuit, this, &DirectConnect::cleanupSessionSettings);
    acceptArguments(QCoreApplication::arguments());
    startSingleInstance();
    // Remove leftovers of a previous handoff session (e.g. after a crash).
    cleanupSessionSettings();
}

DirectConnect::~DirectConnect() = default;

DirectConnect *DirectConnect::instance()
{
    static DirectConnect *instance = nullptr;
    if (!instance) {
        instance = new DirectConnect();
    }
    return instance;
}

QObject *DirectConnect::qmlSingleton(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return instance();
}

bool DirectConnect::requestPending() const
{
    return m_requestPending;
}

bool DirectConnect::busy() const
{
    return m_busy;
}

bool DirectConnect::ready() const
{
    return m_ready;
}

QString DirectConnect::errorString() const
{
    return m_errorString;
}

QString DirectConnect::view() const
{
    return m_view.isEmpty() ? QStringLiteral("consolinnoDashboard") : m_view;
}

int DirectConnect::shadowIndex() const
{
    return m_shadowIndex;
}

void DirectConnect::setShadowIndex(int index)
{
    if (m_shadowIndex == index) {
        return;
    }
    m_shadowIndex = index;
    emit shadowIndexChanged();
}

QString DirectConnect::environment() const
{
    return m_environment;
}

void DirectConnect::start()
{
    if (!m_requestPending || m_busy || m_ready) {
        return;
    }

    redeem();
}

QUrl DirectConnect::tunnelUrl() const
{
    return m_tunnelUrl;
}

bool DirectConnect::applyToken(JsonRpcClient *client)
{
    if (!client || !m_ready || m_token.isEmpty() || m_serverUuid.isEmpty()) {
        return false;
    }

    const bool applied = client->setSessionToken(QUuid(m_serverUuid), m_token);

    // The client owns the token for the lifetime of the session. Drop our copy.
    m_token.fill('\0');
    m_token.clear();

    return applied;
}

void DirectConnect::reset()
{
    m_requestPending = false;
    m_busy = false;
    m_ready = false;
    m_shadowIndex = -1;
    m_errorString.clear();
    m_view.clear();
    m_environment.clear();
    m_code.clear();
    m_serverUuid.clear();
    m_tunnelUrl = QUrl();
    if (!m_token.isEmpty()) {
        m_token.fill('\0');
        m_token.clear();
    }

    emit requestPendingChanged();
    emit busyChanged();
    emit readyChanged();
    emit errorStringChanged();
    emit shadowIndexChanged();
}

bool DirectConnect::eventFilter(QObject *watched, QEvent *event)
{
    Q_UNUSED(watched)

    // macOS delivers URL schemes as file open events instead of arguments.
    if (event->type() == QEvent::FileOpen) {
        auto *fileOpenEvent = static_cast<QFileOpenEvent *>(event);
        if (acceptUrl(fileOpenEvent->url())) {
            emit requestPendingChanged();
        }
    }

    return false;
}

bool DirectConnect::acceptArguments(const QStringList &arguments)
{
    for (const QString &argument : arguments) {
        if (!argument.startsWith(QStringLiteral("consolinno-energy://"))) {
            continue;
        }
        if (acceptUrl(QUrl(argument))) {
            return true;
        }
        qCWarning(dcDirectConnect()) << "Ignoring invalid direct connect deep link";
    }
    return false;
}

bool DirectConnect::acceptUrl(const QUrl &url)
{
    if (!url.isValid() || url.scheme() != QStringLiteral("consolinno-energy")
        || url.host() != QStringLiteral("connect") || !url.path().isEmpty()
        || url.hasFragment()) {
        return false;
    }

    const QUrlQuery query(url);
    const auto envValues = query.allQueryItemValues(QStringLiteral("env"), QUrl::FullyDecoded);
    const auto codeValues = query.allQueryItemValues(QStringLiteral("code"), QUrl::FullyDecoded);
    if (envValues.count() != 1 || codeValues.count() != 1) {
        return false;
    }

    const QString environment = envValues.first();
    const QString code = codeValues.first();

    if (!endpointForKey(environment)) {
        qCWarning(dcDirectConnect()) << "Ignoring deep link with unknown environment";
        return false;
    }

    static const QRegularExpression codePattern(QStringLiteral("^[A-Za-z0-9_-]{16,512}$"));
    if (!codePattern.match(code).hasMatch()) {
        qCWarning(dcDirectConnect()) << "Ignoring deep link with malformed handoff code";
        return false;
    }

    if (m_busy || m_ready) {
        qCWarning(dcDirectConnect()) << "Ignoring deep link, a handoff is already in progress";
        return false;
    }

    m_environment = environment;
    m_code = code;
    m_requestPending = true;
    m_errorString.clear();

    qCInfo(dcDirectConnect()) << "Accepted direct connect request for environment" << environment;
    return true;
}

void DirectConnect::startSingleInstance()
{
    const QString socketName = QStringLiteral("consolinno-energy-%1")
            .arg(QCoreApplication::applicationName());

    QLocalSocket probe;
    probe.connectToServer(socketName, QIODevice::WriteOnly);
    if (probe.waitForConnected(300)) {
        // Another instance is running: forward our arguments and exit.
        const QString payload = QCoreApplication::arguments().join(QChar(0x1f));
        probe.write(payload.toUtf8());
        probe.flush();
        probe.waitForBytesWritten(300);
        probe.disconnectFromServer();
        std::exit(0);
    }

    QLocalServer::removeServer(socketName);
    m_localServer = new QLocalServer(this);
    m_localServer->setSocketOptions(QLocalServer::UserAccessOption);
    if (!m_localServer->listen(socketName)) {
        qCWarning(dcDirectConnect()) << "Unable to listen for a running instance:" << m_localServer->errorString();
        return;
    }

    connect(m_localServer, &QLocalServer::newConnection, this, [this]() {
        while (QLocalSocket *socket = m_localServer->nextPendingConnection()) {
#ifdef Q_OS_LINUX
            struct ucred credentials{};
            socklen_t length = sizeof(credentials);
            if (::getsockopt(socket->socketDescriptor(), SOL_SOCKET, SO_PEERCRED, &credentials, &length) == 0
                    && credentials.uid != ::geteuid()) {
                qCWarning(dcDirectConnect()) << "Rejecting forwarded deep link from another user";
                socket->abort();
                socket->deleteLater();
                continue;
            }
#elif defined(Q_OS_UNIX)
            uid_t peerUid = 0;
            gid_t peerGid = 0;
            if (::getpeereid(socket->socketDescriptor(), &peerUid, &peerGid) == 0
                    && peerUid != ::geteuid()) {
                qCWarning(dcDirectConnect()) << "Rejecting forwarded deep link from another user";
                socket->abort();
                socket->deleteLater();
                continue;
            }
#endif
            connect(socket, &QLocalSocket::disconnected, socket, &QLocalSocket::deleteLater);
            connect(socket, &QLocalSocket::readyRead, socket, [this, socket]() {
                const QStringList arguments = QString::fromUtf8(socket->readAll())
                        .split(QChar(0x1f), Qt::SkipEmptyParts);
                if (acceptArguments(arguments)) {
                    emit requestPendingChanged();
                }
            });
        }
    });
}

void DirectConnect::redeem()
{
    const DirectConnectEndpoint *endpoint = endpointForKey(m_environment);
    if (!endpoint) {
        fail(QStringLiteral("unknown-environment"));
        return;
    }

    m_busy = true;
    m_errorString.clear();
    emit busyChanged();
    emit errorStringChanged();

    QNetworkRequest request(QUrl(endpoint->managementBaseUrl + QStringLiteral("/session/handoff/redeem")));
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
    request.setRawHeader("Accept", "application/json");
    request.setRawHeader("Authorization", "Bearer " + m_code.toUtf8());
    request.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::ManualRedirectPolicy);
    // HTTP/1.1 only: the HTTP/2 stack is unnecessary for a single request and
    // has shown stalls with the platform TLS backend.
    request.setAttribute(QNetworkRequest::Http2AllowedAttribute, false);
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);

    m_reply = m_network->post(request, QByteArray());

    // Strict TLS: never ignore certificate errors on this path.
    connect(m_reply, &QNetworkReply::sslErrors, this, [this](const QList<QSslError> &errors) {
        qCWarning(dcDirectConnect()) << "TLS error while redeeming handoff code:" << errors;
        if (m_reply) {
            m_reply->abort();
        }
    });

    m_timeout = new QTimer(this);
    m_timeout->setSingleShot(true);
    m_timeout->setInterval(kRedeemTimeoutMs);
    connect(m_timeout, &QTimer::timeout, this, [this]() {
        if (m_reply && m_reply->isRunning()) {
            qCWarning(dcDirectConnect()) << "Handoff redeem timed out";
            m_reply->abort();
        }
    });
    m_timeout->start();

    connect(m_reply, &QNetworkReply::finished, this, [this]() {
        QNetworkReply *reply = m_reply;
        m_reply = nullptr;
        if (m_timeout) {
            m_timeout->stop();
            m_timeout->deleteLater();
            m_timeout = nullptr;
        }
        onRedeemFinished(reply);
        reply->deleteLater();
    });
}

void DirectConnect::onRedeemFinished(QNetworkReply *reply)
{
    if (!reply) {
        fail(QStringLiteral("no-response"));
        return;
    }

    const QVariant statusAttribute = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
    const int status = statusAttribute.isValid() ? statusAttribute.toInt() : 0;

    if (reply->error() != QNetworkReply::NoError || status != 200) {
        qCWarning(dcDirectConnect()) << "Handoff redeem failed with HTTP status" << status << reply->error();
        fail(status == 401 || status == 410 ? QStringLiteral("invalid-code")
                                            : QStringLiteral("request-failed"));
        return;
    }

    const QByteArray body = reply->read(kMaxResponseBytes + 1);
    if (body.size() > kMaxResponseBytes) {
        fail(QStringLiteral("response-too-large"));
        return;
    }

    const QJsonDocument document = QJsonDocument::fromJson(body);
    if (!document.isObject()) {
        fail(QStringLiteral("invalid-response"));
        return;
    }

    const QJsonObject object = document.object();
    const QString serverUuid = object.value(QStringLiteral("serverUuid")).toString();
    const QString tunnelServer = object.value(QStringLiteral("tunnelServer")).toString();
    const int tunnelPort = object.value(QStringLiteral("tunnelPort")).toInt();
    const QString token = object.value(QStringLiteral("token")).toString();

    const DirectConnectEndpoint *endpoint = endpointForKey(m_environment);
    if (!endpoint) {
        fail(QStringLiteral("unknown-environment"));
        return;
    }

    // The response must point at one of the known tunnel proxies. Anything
    // else is rejected before a connection is attempted.
    if (!isKnownTunnelEndpoint(tunnelServer, tunnelPort)) {
        qCWarning(dcDirectConnect()) << "Redeem response points at an unexpected tunnel endpoint";
        fail(QStringLiteral("unexpected-tunnel"));
        return;
    }

    const QUuid uuid(serverUuid);
    if (uuid.isNull() || token.isEmpty() || token.size() > 512) {
        fail(QStringLiteral("invalid-response"));
        return;
    }

    QUrl tunnelUrl;
    tunnelUrl.setScheme(QStringLiteral("tunnels"));
    tunnelUrl.setHost(tunnelServer);
    tunnelUrl.setPort(tunnelPort);
    QUrlQuery tunnelQuery;
    tunnelQuery.addQueryItem(QStringLiteral("uuid"), uuid.toString().remove(QRegularExpression(QStringLiteral("[{}]"))));
    tunnelUrl.setQuery(tunnelQuery);

    m_serverUuid = uuid.toString();
    m_cleanupUuid = m_serverUuid;
    QSettings().setValue(kLastSessionUuidKey, m_serverUuid);
    m_token = token.toUtf8();
    m_tunnelUrl = tunnelUrl;
    m_busy = false;
    m_ready = true;

    qCInfo(dcDirectConnect()) << "Redeemed handoff code for server" << m_serverUuid
                             << "via" << tunnelUrl.host() << tunnelUrl.port();

    emit busyChanged();
    emit readyChanged();
}

void DirectConnect::cleanupSessionSettings()
{
    // The session itself is never persisted, but the regular UI stores per
    // device view settings (tab selection, filters) keyed by the server uuid.
    // Remove those again so a handoff session leaves no trace. The marker also
    // covers sessions that ended without a regular shutdown.
    QSettings settings;

    QStringList uuids;
    if (!m_cleanupUuid.isEmpty()) {
        uuids.append(m_cleanupUuid);
    }
    const QString storedUuid = settings.value(kLastSessionUuidKey).toString();
    if (!storedUuid.isEmpty() && !uuids.contains(storedUuid)) {
        uuids.append(storedUuid);
    }

    for (const QString &uuid : uuids) {
        const QString bare = QString(uuid).remove(QLatin1Char('{')).remove(QLatin1Char('}'));
        const QString braced = QStringLiteral("{") + bare + QStringLiteral("}");
        // QSettings flattens groups with '/', while the native backend stores
        // them with '.'. Match both so the cleanup works on every platform.
        const QStringList prefixes = {
            braced + QLatin1Char('.'),
            braced + QLatin1Char('/'),
            bare + QLatin1Char('.'),
            bare + QLatin1Char('/'),
        };

        const QStringList keys = settings.allKeys();
        for (const QString &key : keys) {
            for (const QString &prefix : prefixes) {
                if (key.startsWith(prefix)) {
                    settings.remove(key);
                    break;
                }
            }
        }
    }

    settings.remove(kLastSessionUuidKey);
    settings.sync();
    m_cleanupUuid.clear();
}

void DirectConnect::fail(const QString &reason)
{
    m_busy = false;
    m_requestPending = false;
    m_ready = false;
    m_errorString = reason;
    m_code.fill(QChar(0));
    m_code.clear();

    qCWarning(dcDirectConnect()) << "Direct connect failed:" << reason;

    emit busyChanged();
    emit requestPendingChanged();
    emit errorStringChanged();
}

const DirectConnectEndpoint *DirectConnect::endpointForKey(const QString &key)
{
    for (const DirectConnectEndpoint &endpoint : compiledEndpoints()) {
        if (endpoint.key == key) {
            return &endpoint;
        }
    }
    return nullptr;
}
