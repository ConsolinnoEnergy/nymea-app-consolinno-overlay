import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import "../components"

SettingsPageBase {
    id: root
    busy: networkManager.loading || d.pendingCallCount > 0

    headerText: qsTr("Network settings")

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
        Layout.topMargin: Style.margins * 6
        Layout.leftMargin: Style.margins
        Layout.rightMargin: Style.margins
        visible: !networkManager.available && !networkManager.loading
        spacing: Style.margins

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
        Layout.topMargin: Style.margins
        Layout.leftMargin: Style.smallMargins
        Layout.rightMargin: Style.smallMargins
        visible: networkManager.available
        contentTopMargin: Style.smallMargins
        headerText: qsTr("General")

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            CoCard {
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

                labelText: qsTr("State")
                interactive: false
                status: {
                    switch (networkManager.state) {
                    case NetworkManager.NetworkManagerStateUnknown:
                    case NetworkManager.NetworkManagerStateAsleep:
                        return CoCard.StatusType.Neutral;
                    case NetworkManager.NetworkManagerStateDisconnected:
                    case NetworkManager.NetworkManagerStateDisconnecting:
                        return CoCard.StatusType.Danger;
                    case NetworkManager.NetworkManagerStateConnecting:
                    case NetworkManager.NetworkManagerStateConnectedLocal:
                    case NetworkManager.NetworkManagerStateConnectedSite:
                        return CoCard.StatusType.Warning;
                    case NetworkManager.NetworkManagerStateConnectedGlobal:
                        return CoCard.StatusType.Success;
                    }
                }
            }
        }
    }

    CoFrostyCard {
        Layout.fillWidth: true
        Layout.leftMargin: Style.smallMargins
        Layout.rightMargin: Style.smallMargins
        Layout.topMargin: Style.margins
        visible: networkManager.available && networkManager.networkingEnabled
        contentTopMargin: Style.smallMargins
        headerText: qsTr("Wired network")

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            CoCard {
                Layout.fillWidth: true
                text: qsTr("No wired network interfaces available")
                visible: networkManager.wiredNetworkDevices.count === 0
            }

            Repeater {
                model: networkManager.wiredNetworkDevices

                CoCard {
                    Layout.fillWidth: true
                    iconLeft: model.pluggedIn ?
                                  "/icons/connections/network-wired.svg" :
                                  "/icons/connections/network-wired-offline.svg"
                    text: interfaceDisplayName(model.interface)  + " (" + model.macAddress + ")"
                    labelText: {
                        var ret = model.pluggedIn ? qsTr("Plugged in") : qsTr("Unplugged");
                        ret += " - ";
                        ret += networkStateToString(model.state);
                        return ret;
                    }
                    interactive: engine.jsonRpcClient.ensureServerVersion("6.2")
                    showChildrenIndicator: interactive
                    onClicked: {
                        if (!engine.jsonRpcClient.ensureServerVersion("6.2")) {
                            return;
                        }
                        var wiredNetworkDevice = networkManager.wiredNetworkDevices.getWiredNetworkDevice(model.interface);
                        console.debug("Clicked wired network device", wiredNetworkDevice.interface, wiredNetworkDevice.state);
                        d.navigatedToSubPage = true;
                        pageStack.push(currentEthernetConnectionPageComponent,
                                       {
                                           wiredNetworkDevice: wiredNetworkDevice,
                                           displayName: interfaceDisplayName(model.interface)
                                       });
                    }
                }
            }
        }
    }

    Component {
        id: currentEthernetConnectionPageComponent
        SettingsPageBase {
            id: currentEthernetConnectionPage

            property Component navbarControls: currentEthernetConnectionPage.wiredNetworkDevice.interface === "eth1" ? writeSettingsNavbar : null

            headerText: currentEthernetConnectionPage.displayName

            property WiredNetworkDevice wiredNetworkDevice: null
            property string displayName: ""

            Component {
                id: writeSettingsNavbar
                CoNavbarButton {
                    text: qsTr("Write settings")
                    enabled: {
                        if (dhcpServerRadioButton.checked) {
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
                Layout.leftMargin: Style.smallMargins
                Layout.rightMargin: Style.smallMargins
                Layout.topMargin: Style.margins
                contentTopMargin: Style.smallMargins
                headerText: qsTr("Details")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoCard {
                        Layout.fillWidth: true
                        text: currentEthernetConnectionPage.wiredNetworkDevice.macAddress
                        labelText: qsTr("MAC Address")
                        interactive: false
                    }
                    CoCard {
                        Layout.fillWidth: true
                        text: {
                            let ipAddresses = currentEthernetConnectionPage.wiredNetworkDevice.ipv4Addresses.join(", ");
                            return ipAddresses === "" ? "-" : ipAddresses;
                        }
                        labelText: qsTr("IPv4 Address")
                        interactive: false
                    }
                    CoCard {
                        Layout.fillWidth: true
                        text: currentEthernetConnectionPage.wiredNetworkDevice.ipv6Addresses.join(", ")
                        labelText: qsTr("IPv6 Address")
                        visible: text.length > 0
                        interactive: false
                    }
                }
            }

            CoFrostyCard {
                Layout.fillWidth: true
                Layout.leftMargin: Style.smallMargins
                Layout.rightMargin: Style.smallMargins
                Layout.topMargin: Style.margins
                contentTopMargin: Style.smallMargins
                headerText: qsTr("IP configuration")
                visible: currentEthernetConnectionPage.wiredNetworkDevice.interface === "eth1"

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoRadioButton {
                        id: dhcpServerRadioButton
                        Layout.fillWidth: true
                        text: qsTr("DHCP server")
                        helpText: qsTr("Default")
                    }

                    CoRadioButton {
                        id: manualClientRadioButton
                        Layout.fillWidth: true
                        text: qsTr("Static")
                    }

                    ButtonGroup {
                        buttons: [
                            dhcpServerRadioButton.radioButton,
                            manualClientRadioButton.radioButton
                        ]
                    }
                }
            }

            CoFrostyCard {
                Layout.fillWidth: true
                Layout.leftMargin: Style.smallMargins
                Layout.rightMargin: Style.smallMargins
                Layout.topMargin: Style.margins
                contentTopMargin: Style.smallMargins
                headerText: qsTr("\"Static\"")
                visible: currentEthernetConnectionPage.wiredNetworkDevice.interface === "eth1"
                         && manualClientRadioButton.checked

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoInputField {
                        id: ipTextField
                        Layout.fillWidth: true
                        labelText: qsTr("IP Address")
                        textField.validator: RegularExpressionValidator {
                            regularExpression: /^(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9][0-9]|[0-9])$/
                        }
                    }

                    CoInputField {
                        id: prefixTextField
                        Layout.fillWidth: true
                        labelText: qsTr("Prefix length")
                        compact: true
                        text: "24"
                        textField.validator: IntValidator {
                            bottom: 8
                            top: 32
                        }
                    }
                }
            }
        }
    }
}
