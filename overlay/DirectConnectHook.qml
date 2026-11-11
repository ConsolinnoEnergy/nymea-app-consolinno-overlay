// SPDX-License-Identifier: GPL-3.0-or-later
//
// Overlay hook for the direct connect deep link handoff
// (consolinno-energy://connect?env=<test|qa|prod>&code=<handoff-code>).
//
// The actual redeem request is done in C++ (DirectConnect). This hook creates a
// hidden, ephemeral session slot, applies the redeemed token, connects and only
// switches to it once the connection is established. On any failure the
// previous device stays active.

import QtQuick

import Nymea
import NymeaApp.Utils

Item {
    id: hook

    property var engine: null
    property var nymeaDiscovery: null
    property var configuredHostsModel: null
    property var rootItem: null

    // Index of the ephemeral slot while a handoff session is active.
    property int shadowIndex: -1
    property var shadowClient: null

    visible: false
    width: 0
    height: 0

    Component.onCompleted: {
        if (DirectConnect.requestPending) {
            DirectConnect.start()
        }
    }

    Connections {
        target: DirectConnect

        function onRequestPendingChanged() {
            if (DirectConnect.requestPending) {
                DirectConnect.start()
            }
        }

        function onReadyChanged() {
            if (DirectConnect.ready) {
                hook.openSession()
            }
        }

        function onErrorStringChanged() {
            if (DirectConnect.errorString.length > 0) {
                hook.abortSession(true)
            }
        }
    }

    Timer {
        id: connectTimeout
        interval: 12000
        repeat: false
        onTriggered: {
            console.warn("DirectConnect: connection timeout")
            hook.abortSession(true)
        }
    }

    Timer {
        id: viewTimer
        property int attempts: 0
        interval: 100
        repeat: true
        onTriggered: {
            attempts++
            var mainPage = hook.rootItem ? hook.rootItem.mainPage : null
            if (mainPage && mainPage.tabsModel && mainPage.tabsModel.count > 0) {
                stop()
                mainPage.goToView(DirectConnect.view, undefined, true)
                // The request is fully handled; allow a future deep link.
                DirectConnect.reset()
            } else if (attempts > 30) {
                stop()
                DirectConnect.reset()
            }
        }
    }

    function openSession() {
        if (!configuredHostsModel || !nymeaDiscovery) {
            console.warn("DirectConnect: missing context, aborting")
            abortSession(true)
            return
        }

        // A new request while a session is active: drop the old one first.
        if (shadowIndex >= 0) {
            abortSession(false)
        }

        var shadow = configuredHostsModel.createEphemeralHost()
        shadowIndex = configuredHostsModel.indexOf(shadow)
        DirectConnect.shadowIndex = shadowIndex

        var client = shadow.engine.jsonRpcClient
        shadowClient = client

        if (!DirectConnect.applyToken(client)) {
            console.warn("DirectConnect: could not apply the session token")
            abortSession(true)
            return
        }

        var host = nymeaDiscovery.nymeaHosts.createCloudHost("HEMS", DirectConnect.tunnelUrl())
        client.connectToHost(host)
        connectTimeout.start()

        client.connectedChanged.connect(function() { hook.onClientConnectedChanged() })
        client.authenticationRequiredChanged.connect(function() { hook.onAuthenticationRequiredChanged() })
    }

    function onClientConnectedChanged() {
        if (!shadowClient || !shadowClient.connected) {
            return
        }
        connectTimeout.stop()
        // Switch only after the connection is up: on failure the previous
        // device stays untouched.
        configuredHostsModel.currentIndex = shadowIndex
        viewTimer.attempts = 0
        viewTimer.start()
    }

    function onAuthenticationRequiredChanged() {
        if (shadowClient && shadowClient.authenticationRequired) {
            console.warn("DirectConnect: session token rejected, aborting")
            abortSession(true)
        }
    }

    function abortSession(clearRequest) {
        connectTimeout.stop()
        viewTimer.stop()

        if (shadowClient) {
            shadowClient.disconnectFromHost()
            shadowClient = null
        }

        if (shadowIndex >= 0) {
            var index = shadowIndex
            shadowIndex = -1
            DirectConnect.shadowIndex = -1
            if (configuredHostsModel && index < configuredHostsModel.count
                    && configuredHostsModel.currentIndex !== index) {
                configuredHostsModel.removeHost(index)
            }
        }

        if (clearRequest) {
            DirectConnect.reset()
        }
    }
}
