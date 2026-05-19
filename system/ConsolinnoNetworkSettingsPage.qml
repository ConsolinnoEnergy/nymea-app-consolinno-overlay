import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import "../components"

SettingsPageBase {
    id: root
    title: qsTr("Network settings")
    busy: networkManager.loading || d.pendingCallCount > 0

    StackView.onStatusChanged: {
        if (StackView.status === StackView.Active) {
            if (d.navigatedToSubPage) {
                d.navigatedToSubPage = false
            } else {
                d.add(networkManager.getConnectionSettings("eth1"));
            }
        }
    }

    NetworkManager {
        id: networkManager
        engine: _engine
        onEnableNetworkingReply: handleReply(id, status)
        onEnableWirelessNetworkingReply: handleReply(id, status)
        onConnectToWiFiReply: handleReply(id, status)
        onStartAccessPointReply: handleReply(id, status)
        onDisconnectReply: handleReply(id, status)
        onCreateWiredAutoConnectionReply: handleReply(id, status)
        onCreateWiredManualConnectionReply: handleReply(id, status)
        onCreateWiredSharedConnectionReply: handleReply(id, status)
        onEnableEth1StaticIpReply: function(id, status) {
            handleReply(id, status)
            if (status === "NetworkManagerErrorNoError") refreshTimer.start()
        }
        onDisableEth1StaticIpReply: function(id, status) {
            handleReply(id, status)
            if (status === "NetworkManagerErrorNoError") refreshTimer.start()
        }
        onGetConnectionSettingsReply: function(id, status, settings) {
            d.remove(id)
            console.log("Get connection settings reply:", status, JSON.stringify(settings, null, 2))
            if (status === "NetworkManagerErrorNoError") {
                d.eth1IpMethod = settings["ipv4.method"] || ""
                d.eth1Address = settings["ip4.address"] || ""
            }
        }


        function handleReply(id, status) {
            if (!d.has(id)) {
                console.warn("Received reply for unknown call id", id, "with status", status)
                return;
            }

            d.remove(id)

            var errorMessage;
            switch (status) {
            case "NetworkManagerErrorNoError":
                return;
            case "NetworkManagerErrorWirelessNotAvailable":
                errorMessage = qsTr("No wireless hardware available.")
                break;
            case "NetworkManagerErrorAccessPointNotFound":
                errorMessage = qsTr("The access point cannot be found.")
                break;
            case "NetworkManagerErrorNetworkInterfaceNotFound":
                errorMessage = qsTr("The network interface cannot be found.")
                break;
            case "NetworkManagerErrorInvalidNetworkDeviceType":
                errorMessage = qsTr("Invalid network device type.")
                break;
            case "NetworkManagerErrorWirelessNetworkingDisabled":
                errorMessage = qsTr("Wireless networking is disabled.")
                break;
            case "NetworkManagerErrorWirelessConnectionFailed":
                errorMessage = qsTr("The wireless connection failed.")
                break;
            case "NetworkManagerErrorNetworkingDisabled":
                errorMessage = qsTr("Networking is disabled.")
                break;
            case "NetworkManagerErrorNetworkManagerNotAvailable":
                errorMessage = qsTr("The network manager is not available.")
                break;
            case "NetworkManagerErrorUnknownError":
                errorMessage = qsTr("An unexpected error happened.")
                break;

            }
            print("network config reply:", status, errorMessage)

            var component = Qt.createComponent(Qt.resolvedUrl("../components/ErrorDialog.qml"))
            var popup = component.createObject(root, {text: errorMessage, errorCode: status})
            popup.open();
        }
    }

    QtObject {
        id: d
        property var _ids: new Set()
        property int pendingCallCount: 0

        function add(id) { _ids.add(id); pendingCallCount++ }
        function remove(id) { if (_ids.has(id)) { _ids.delete(id); pendingCallCount-- } }
        function has(id) { return _ids.has(id) }

        property bool navigatedToSubPage: false
        property string eth1IpMethod: ""
        property string eth1Address: ""
    }

    Timer {
        id: refreshTimer
        interval: 5000
        repeat: false
        onTriggered: d.add(networkManager.getConnectionSettings("eth1"))
    }

    function interfaceDisplayName(iface) {
        var name = iface.includes("eth") ? "LAN " + (parseInt(iface[3]) + 1) : iface
        return name
    }

    function networkStateToString(networkState, mode) {
        switch (networkState) {
        case NetworkDevice.NetworkDeviceStateUnknown:
            return qsTr("Unknown")
        case NetworkDevice.NetworkDeviceStateUnmanaged:
            return qsTr("Unmanaged")
        case NetworkDevice.NetworkDeviceStateUnavailable:
            return qsTr("Unavailable")
        case NetworkDevice.NetworkDeviceStateDisconnected:
            return qsTr("Disconnected")
        case NetworkDevice.NetworkDeviceStateDeactivating:
            return qsTr("Deactivating")
        case NetworkDevice.NetworkDeviceStateFailed:
            return qsTr("Failed")
        case NetworkDevice.NetworkDeviceStatePrepare:
            return qsTr("Preparing")
        case NetworkDevice.NetworkDeviceStateConfig:
            return qsTr("Configuring")
        case NetworkDevice.NetworkDeviceStateNeedAuth:
            return qsTr("Waiting for password")
        case NetworkDevice.NetworkDeviceStateIpConfig:
            return qsTr("Setting IP configuration")
        case NetworkDevice.NetworkDeviceStateIpCheck:
            return qsTr("Checking IP configuration")
        case NetworkDevice.NetworkDeviceStateSecondaries:
            return qsTr("Secondaries")
        case NetworkDevice.NetworkDeviceStateActivated:
            if (mode === WirelessNetworkDevice.WirelessModeAccessPoint) {
                return qsTr("Hosting access point");
            } else {
                return qsTr("Connected");
            }
        }
    }


    RowLayout {
        Layout.topMargin: app.margins * 6
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        visible: !networkManager.available && !networkManager.loading
        spacing: app.margins
        ColorIcon {
            Layout.preferredHeight: Style.iconSize
            Layout.preferredWidth: Style.iconSize
            name: "/icons/connections/network-wired-disabled.svg"
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: qsTr("Network management is unavailable on this system.")
        }
    }

    CoFrostyCard {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        Layout.topMargin: app.margins
        visible: networkManager.available
        contentTopMargin: Style.smallMargins
        headerText: qsTr("General")

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            NymeaItemDelegate {
                Layout.fillWidth: true
                text: {
                    switch (networkManager.state) {
                    case NetworkManager.NetworkManagerStateUnknown:
                        return qsTr("Unknown");
                    case NetworkManager.NetworkManagerStateAsleep:
                        return qsTr("Asleep");
                    case NetworkManager.NetworkManagerStateDisconnected:
                        return qsTr("Disconnected")
                    case NetworkManager.NetworkManagerStateDisconnecting:
                        return qsTr("Disconnecting")
                    case NetworkManager.NetworkManagerStateConnecting:
                        return qsTr("Connecting")
                    case NetworkManager.NetworkManagerStateConnectedLocal:
                        return qsTr("Locally connected")
                    case NetworkManager.NetworkManagerStateConnectedSite:
                        return qsTr("Site connected")
                    case NetworkManager.NetworkManagerStateConnectedGlobal:
                        return qsTr("Globally connected")
                    }
                }

                prominentSubText: false
                subText: qsTr("State")
                progressive: false
                additionalItem: Led {
                    anchors.verticalCenter: parent.verticalCenter
                    state: {
                        switch (networkManager.state) {
                        case NetworkManager.NetworkManagerStateUnknown:
                        case NetworkManager.NetworkManagerStateAsleep:
                            return "off";
                        case NetworkManager.NetworkManagerStateDisconnected:
                        case NetworkManager.NetworkManagerStateDisconnecting:
                            return "red"
                        case NetworkManager.NetworkManagerStateConnecting:
                        case NetworkManager.NetworkManagerStateConnectedLocal:
                        case NetworkManager.NetworkManagerStateConnectedSite:
                            return "orange"
                        case NetworkManager.NetworkManagerStateConnectedGlobal:
                            return "green";
                        }
                    }
                }
            }

            NymeaItemDelegate {
                Layout.fillWidth: true
                text: qsTr("Networking enabled")
                subText: qsTr("Enable or disable networking altogether")
                prominentSubText: false
                progressive: false
                visible: false
                additionalItem: ConsolinnoSwitch {
                    anchors.verticalCenter: parent.verticalCenter
                    checked: networkManager.networkingEnabled
                    onClicked: {
                        if (!checked) {
                            var dialog = Qt.createComponent(Qt.resolvedUrl("../components/NymeaDialog.qml"));
                            var text = qsTr("Disabling networking will disconnect all connected clients. Be aware that you will not be able to interact remotely with this %1 system any more. Do not proceed unless you know what your are doing.").arg(Configuration.systemName)
                                    + "\n\n"
                                    + qsTr("Do you want to proceed?")
                            var popup = dialog.createObject(app,
                                                            {
                                                                headerIcon: "/icons/dialog-warning-symbolic.svg",
                                                                title: qsTr("Disable networking?"),
                                                                text: text,
                                                                standardButtons: Dialog.Ok | Dialog.Cancel
                                                            });
                            popup.open();
                            popup.accepted.connect(function() {
                                d.add(networkManager.enableNetworking(false));
                            })
                            popup.rejected.connect(function() {
                                checked = true;
                            })
                        } else {
                            d.add(networkManager.enableNetworking(true));
                        }
                    }
                }
            }
        }
    }

    CoFrostyCard {
        Layout.fillWidth: true
        Layout.leftMargin: app.margins
        Layout.rightMargin: app.margins
        Layout.topMargin: app.margins
        visible: networkManager.available && networkManager.networkingEnabled
        contentTopMargin: Style.smallMargins
        headerText: qsTr("Wired network")

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: Style.smallMargins
                Layout.bottomMargin: Style.smallMargins
                text: qsTr("No wired network interfaces available")
                wrapMode: Text.WordWrap
                visible: networkManager.wiredNetworkDevices.count === 0
            }

            Repeater {
                model: networkManager.wiredNetworkDevices

                NymeaItemDelegate {
                    Layout.fillWidth: true
                    iconName: model.pluggedIn ? "/icons/connections/network-wired.svg" : "/icons/connections/network-wired-offline.svg"
                    text: interfaceDisplayName(model.interface)  + " (" + model.macAddress + ")"
                    subText: {
                        var ret = model.pluggedIn ? qsTr("Plugged in") : qsTr("Unplugged")
                        ret += " - "
                        ret += networkStateToString(model.state)
                        return ret;
                    }
                    progressive: engine.jsonRpcClient.ensureServerVersion("6.2")
                    onClicked: {
                        if (!engine.jsonRpcClient.ensureServerVersion("6.2")) {
                            return;
                        }
                        var wiredNetworkDevice = networkManager.wiredNetworkDevices.getWiredNetworkDevice(model.interface);
                        console.debug("Clicked wired network device", wiredNetworkDevice.interface, wiredNetworkDevice.state)
                        d.navigatedToSubPage = true
                        pageStack.push(currentEthernetConnectionPageComponent, {wiredNetworkDevice: wiredNetworkDevice, displayName: interfaceDisplayName(model.interface)})
                    }
                }
            }
        }
    }

    Component {
        id: currentEthernetConnectionPageComponent
        SettingsPageBase {
            id: currentEthernetConnectionPage
            title: currentEthernetConnectionPage.displayName

            property WiredNetworkDevice wiredNetworkDevice: null
            property string displayName: ""

            Component.onCompleted: {
                if (wiredNetworkDevice.interface === "eth1") {
                    manualClientRadioButton.checked = (d.eth1IpMethod === "manual")
                    dhcpServerRadioButton.checked = (d.eth1IpMethod === "shared")
                    var parts = d.eth1Address.split("/")
                    ipTextField.text = parts[0] || ""
                    prefixTextField.text = parts[1] || "24"
                }
            }

            CoFrostyCard {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: app.margins
                contentTopMargin: Style.smallMargins
                headerText: qsTr("Details")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    NymeaItemDelegate {
                        Layout.fillWidth: true
                        text: currentEthernetConnectionPage.wiredNetworkDevice.macAddress
                        subText: qsTr("MAC Address")
                        progressive: false
                    }
                    NymeaItemDelegate {
                        Layout.fillWidth: true
                        text: currentEthernetConnectionPage.wiredNetworkDevice.ipv4Addresses.join(", ")
                        subText: qsTr("IPv4 Address")
                        progressive: false
                    }
                    NymeaItemDelegate {
                        Layout.fillWidth: true
                        text: currentEthernetConnectionPage.wiredNetworkDevice.ipv6Addresses.join(", ")
                        subText: qsTr("IPv6 Address")
                        visible: text.length > 0
                        progressive: false
                    }
                }
            }

            CoFrostyCard {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: app.margins
                contentTopMargin: Style.smallMargins
                headerText: qsTr("IP configuration")
                visible: currentEthernetConnectionPage.wiredNetworkDevice.interface === "eth1"

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    ConsolinnoRadioDelegate {
                        id: dhcpServerRadioButton
                        text: qsTr("DHCP server")
                        description: qsTr("Default")
                    }
                    ConsolinnoRadioDelegate {
                        id: manualClientRadioButton
                        text: qsTr("Static")
                    }
                }
            }

            CoFrostyCard {
                Layout.fillWidth: true
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                Layout.topMargin: app.margins
                contentTopMargin: Style.smallMargins
                headerText: qsTr("\"Static\"")
                visible: currentEthernetConnectionPage.wiredNetworkDevice.interface === "eth1"
                         && manualClientRadioButton.checked

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        Layout.topMargin: Style.smallMargins
                        Layout.bottomMargin: Style.smallMargins

                        Label {
                            text: qsTr("IP Address")
                        }

                        TextField {
                            id: ipTextField
                            maximumLength: 15
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                            validator: RegularExpressionValidator {
                                regularExpression: /^((?:[0-1]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.){0,3}(?:[0-1]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$/
                            }
                        }

                        Label {
                            text: qsTr("Prefix length")
                        }

                        TextField {
                            id: prefixTextField

                            property int maxChars: 2
                            maximumLength: maxChars

                            FontMetrics {
                                id: fontMetrics
                                font: prefixTextField.font
                            }

                            Layout.preferredWidth: fontMetrics.advanceWidth("W".repeat(maxChars)) + leftPadding + rightPadding
                            text: "24"
                            Layout.fillWidth: false
                            validator: IntValidator {
                                bottom: 8
                                top: 32
                            }
                        }
                    }
                }
            }

            Button {
                Layout.fillWidth: true
                Layout.margins: app.margins
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                visible: currentEthernetConnectionPage.wiredNetworkDevice.interface === "eth1"
                text: qsTr("Write settings")
                enabled: {
                    if (dhcpClientRadioButton.checked || dhcpServerRadioButton.checked) {
                        return true;
                    }
                    return ipTextField.acceptableInput && prefixTextField.acceptableInput
                }

                onClicked: {
                    if (manualClientRadioButton.checked) {
                        d.add(networkManager.enableEth1StaticIp(ipTextField.text, prefixTextField.text));
                    } else if (dhcpServerRadioButton.checked) {
                        d.add(networkManager.disableEth1StaticIp());
                    }

                    pageStack.pop(root);
                }
            }
        }
    }
}
