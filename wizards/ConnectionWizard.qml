import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../components"
import Nymea 1.0

ConsolinnoWizardPageBase {
    id: root

    property Component navbarControls: welcomePageNavbarControls
    property int navigationFooterHeight: 0

    headerLabel: qsTr("Setup %1").arg(Configuration.deviceName)

    // #TODO if there is another connection set up in this app, show a header back button
    // and navbar cancel button here and go to the last active connection if one of these
    // is pressed.
    backButtonVisible: false

    Component {
        id: welcomePageNavbarControls
        ColumnLayout {
            spacing: Style.smallMargins

            CoNavbarButton {
                Layout.fillWidth: true
                text: qsTr("Start setup")
                onClicked: pageStack.push(licenseInfoComponent)
            }

            CoNavbarButton {
                Layout.fillWidth: true
                text: qsTr("Demo mode")
                flat: true
                onClicked: {
                    var host = nymeaDiscovery.nymeaHosts.createWanHost('Demo server', 'nymeas://hems-demo.consolinno-it.de:31222');
                    engine.jsonRpcClient.connectToHost(host);
                }
            }

            // Cf. #TODO comment above
            // CoNavbarButton {
            //     Layout.fillWidth: true
            //     text: qsTr("Cancel")
            //     flat: true
            //     onClicked: pageStack.pop()
            // }
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: Style.margins
        anchors.topMargin: root.headerHeight + Style.margins
        anchors.bottomMargin: root.navigationFooterHeight + Style.margins
        spacing: 0

        Item {
            id: spacerTop
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Image {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 4
            source: "qrc:/styles/%1/logo-wide.svg".arg(styleController.currentStyle)
            fillMode: Image.PreserveAspectFit
        }

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font: Style.newH2Font
            color: Style.colors.typography_Headlines_H2
            text: qsTr("Welcome to %1!").arg(Configuration.appName)
        }

        Item {
            id: spacerBottom
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }


    Component {
        id: licenseInfoComponent

        ConsolinnoWizardPageBase {
            id: licenseInfoPage

            property Component navbarControls: licenseInfoNavbarControls
            property int navigationFooterHeight: 0

            headerLabel: qsTr("Setup %1").arg(Configuration.deviceName)

            Component {
                id: licenseInfoNavbarControls
                ColumnLayout {
                    spacing: Style.smallMargins

                    CoCheckBox {
                        id: termsOfUseCheckbox
                        Layout.fillWidth: true
                        text: qsTr("Yes, I have read the Terms of Use.")
                        checked: false
                        feedbackText: qsTr("You must agree to the Terms of Use to continue.")
                        onCheckedChanged: {
                            if (checked) {
                                showError = false;
                            }
                        }
                    }

                    CoNavbarButton {
                        Layout.fillWidth: true
                        text: qsTr("Next")
                        onClicked: {
                            if (!termsOfUseCheckbox.checked) {
                                termsOfUseCheckbox.showError = true;
                                return;
                            }
                            pageStack.push(privacyPolicyComponent);
                        }
                    }

                    CoNavbarButton {
                        Layout.fillWidth: true
                        text: qsTr("Cancel")
                        flat: true
                        onClicked: pageStack.pop(root)
                    }
                }
            }

            ColumnLayout {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: Style.margins
                anchors.topMargin: licenseInfoPage.headerHeight + Style.margins
                anchors.bottomMargin: licenseInfoPage.navigationFooterHeight + Style.margins
                spacing: 0

                CoFrostyCard {
                    id: licenseTermsCard
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    headerText: qsTr("License Terms HEMS<br/>(as of 11/2024)")
                    contentTopMargin: Style.smallMargins

                    ScrollView {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: Style.margins
                        anchors.rightMargin: Style.margins
                        clip: true
                        height: licenseTermsCard.availableContentHeight
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                        TextArea {
                            id: textAreaTerms
                            width: parent.width
                            font: Style.smallFont
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            textFormat: Text.RichText
                            readOnly: true
                            padding: 0

                            background: Rectangle {
                                color: "transparent"
                            }

                            Component.onCompleted: {
                                loadHtmlFile("../terms_of_use_de_DE.html", textAreaTerms);
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: privacyPolicyComponent

        ConsolinnoWizardPageBase {
            id: privacyPolicyPage

            property Component navbarControls: privacyPolicyNavbarControls
            property int navigationFooterHeight: 0

            headerLabel: qsTr("Setup %1").arg(Configuration.deviceName)

            Component {
                id: privacyPolicyNavbarControls
                ColumnLayout {
                    spacing: Style.smallMargins

                    CoCheckBox {
                        id: accountCheckbox
                        Layout.fillWidth: true
                        text: qsTr("Yes, I agree to open a user account, according to part 6.")
                        checked: false
                        feedbackText: qsTr("You must create a user account to continue.")
                        onCheckedChanged: {
                            if (checked) {
                                showError = false;
                            }
                        }
                    }

                    CoCheckBox {
                        id: policyCheckbox
                        Layout.fillWidth: true
                        text: qsTr("I confirm that I have read the the agreement and I am accepting it.")
                        checked: false
                        feedbackText: qsTr("You must agree to the privacy policy to continue.")
                        onCheckedChanged: {
                            if (checked) {
                                showError = false;
                            }
                        }
                    }

                    CoNavbarButton {
                        Layout.fillWidth: true
                        text: qsTr("Next")
                        onClicked: {
                            let anyError = false;
                            if (!accountCheckbox.checked) {
                                accountCheckbox.showError = true;
                                anyError = true;
                            }
                            if (!policyCheckbox.checked) {
                                policyCheckbox.showError = true;
                                anyError = true;
                            }
                            if (anyError) { return; }
                            pageStack.push(networkConnectionInfoComponent);
                        }
                    }

                    CoNavbarButton {
                        Layout.fillWidth: true
                        text: qsTr("Cancel")
                        flat: true
                        onClicked: pageStack.pop(root)
                    }
                }
            }

            ColumnLayout {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: Style.margins
                anchors.topMargin: privacyPolicyPage.headerHeight + Style.margins
                anchors.bottomMargin: privacyPolicyPage.navigationFooterHeight + Style.margins
                spacing: 0

                CoFrostyCard {
                    id: privacyPolicyCard
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    headerText: qsTr("Privacy Policy HEMS<br/>(as of 11/2024)")
                    contentTopMargin: Style.smallMargins

                    ScrollView {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: Style.margins
                        anchors.rightMargin: Style.margins
                        clip: true
                        height: privacyPolicyCard.availableContentHeight
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                        TextArea {
                            id: textAreaPrivacyPolicy
                            width: parent.width
                            font: Style.smallFont
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            textFormat: Text.RichText
                            readOnly: true
                            padding: 0

                            background: Rectangle {
                                color: "transparent"
                            }

                            Component.onCompleted: {
                                loadHtmlFile("../privacy_agreement_de_DE.html", textAreaPrivacyPolicy);
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: networkConnectionInfoComponent

        ConsolinnoWizardPageBase {
            id: networkConnectionInfoPage

            property Component navbarControls: networkConnectionInfoNavbarControls
            property int navigationFooterHeight: 0

            headerLabel: qsTr("Setup %1").arg(Configuration.deviceName)

            Component {
                id: networkConnectionInfoNavbarControls
                ColumnLayout {
                    spacing: Style.smallMargins

                    CoNavbarButton {
                        Layout.fillWidth: true
                        text: qsTr("Next")
                        onClicked: pageStack.push(discoverLeafletComponent)
                    }

                    CoNavbarButton {
                        Layout.fillWidth: true
                        text: qsTr("Cancel")
                        flat: true
                        onClicked: pageStack.pop(root)
                    }
                }
            }

            ColumnLayout {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: Style.margins
                anchors.topMargin: networkConnectionInfoPage.headerHeight + Style.margins
                anchors.bottomMargin: networkConnectionInfoPage.navigationFooterHeight + Style.margins
                spacing: 0

                CoFrostyCard {
                    Layout.fillWidth: true
                    headerText: qsTr("Network connection")
                    contentTopMargin: Style.smallMargins

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.margins
                        anchors.rightMargin: Style.margins
                        spacing: Style.margins

                        Label{
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            text: qsTr("Please connect your device (LAN port 1) to your network. Be sure this app is also connected to the same network.")
                        }

                        Image {
                            Layout.fillWidth: true
                            fillMode: Image.PreserveAspectFit
                            sourceSize.width: width
                            source: "/ui/images/leaflet-ethernet-connect.png"
                        }
                    }
                }

                Item {
                    id: spacer
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }

    Component {
        id: discoverLeafletComponent

        ConsolinnoWizardPageBase {
            id: discoverLeafletPage

            property Component navbarControls: discoverLeafletNavbarControls
            property int navigationFooterHeight: 0

            headerLabel: qsTr("Setup %1").arg(Configuration.deviceName)

            Component {
                id: discoverLeafletNavbarControls
                ColumnLayout {
                    spacing: Style.smallMargins

                    CoNavbarButton {
                        Layout.fillWidth: true
                        text: qsTr("Manual setup")
                        flat: true
                        onClicked: pageStack.push(manualConnectionComponent)
                    }

                    CoNavbarButton {
                        Layout.fillWidth: true
                        text: qsTr("Cancel")
                        flat: true
                        onClicked: pageStack.pop(root)
                    }
                }
            }

            Timer {
                id: discoveryTimer
                interval: 15000
                running: hostsModel.count === 0
            }

            NymeaHostsFilterModel {
                id: hostsModel
                discovery: nymeaDiscovery
                showUnreachableBearers: false
                jsonRpcClient: engine.jsonRpcClient
                showUnreachableHosts: false
            }

            Flickable {
                id: discoverLeafletFlickable
                anchors.fill: parent
                clip: true

                ColumnLayout {
                    id: contentColumn
                    anchors.fill: parent
                    anchors.margins: Style.margins
                    anchors.topMargin: discoverLeafletPage.headerHeight + Style.margins
                    anchors.bottomMargin: discoverLeafletPage.navigationFooterHeight + Style.margins
                    spacing: 0

                    CoFrostyCard {
                        id: discoverLeafletCard
                        Layout.fillWidth: true
                        headerText: qsTr("Discovered Devices")
                        contentTopMargin: Style.smallMargins

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: Style.margins
                            anchors.rightMargin: Style.margins
                            spacing: 0

                            Label {
                                id: infoLabel
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                visible: hostsModel.count === 0
                                text: discoveryTimer.running ?
                                          qsTr("Searching for your %1...").arg(Configuration.deviceName) :
                                          qsTr("No %1 found. Please check the network connection! Alternatively, a manual connection can be established.").arg(Configuration.deviceName)
                            }

                            Repeater {
                                model: hostsModel

                                delegate: CoCard {
                                    Layout.fillWidth: true

                                    property var nymeaHost: hostsModel.get(index)

                                    property string defaultConnectionIndex: {
                                        var bestIndex = -1;
                                        var bestPriority = 0;
                                        for (var i = 0; i < nymeaHost.connections.count; i++) {
                                            var connection = nymeaHost.connections.get(i);
                                            if (bestIndex === -1 || connection.priority > bestPriority) {
                                                bestIndex = i;
                                                bestPriority = connection.priority;
                                            }
                                        }
                                        return bestIndex;
                                    }
                                    property var defaultConnection: nymeaHost.connections.get(defaultConnectionIndex)
                                    property bool isSecure: defaultConnection.secure
                                    property bool isOnline: defaultConnection.bearerType !== Connection.BearerTypeWan ?
                                                                defaultConnection.online :
                                                                true

                                    text: model.name
                                    helpText: nymeaHost.connections.get(defaultConnectionIndex).url

                                    iconLeftColor: Style.colors.brand_Basic_Icon_accent
                                    iconLeft: {
                                        switch (nymeaHost.connections.get(defaultConnectionIndex).bearerType) {
                                        case Connection.BearerTypeLan:
                                        case Connection.BearerTypeWan:
                                            if (engine.jsonRpcClient.availableBearerTypes & NymeaConnection.BearerTypeEthernet !=
                                                    NymeaConnection.BearerTypeNone) {
                                                return "/icons/connections/network-wired.svg";
                                            }
                                            return "/icons/connections/network-wifi.svg";
                                        case Connection.BearerTypeBluetooth:
                                            return "/icons/connections/bluetooth.svg";
                                        case Connection.BearerTypeCloud:
                                            return "/icons/connections/cloud.svg";
                                        case Connection.BearerTypeLoopback:
                                            return "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle);
                                        }
                                        return "";
                                    }

                                    iconRight: isSecure ? "/icons/connections/network-secure.svg" : ""

                                    onClicked: {
                                        engine.jsonRpcClient.connectToHost(nymeaHostDelegate.nymeaHost)
                                    }
                                }

                                // #TODO
                                // - not connected icon?
                                // - contextOptions?

                                // delegate: NymeaSwipeDelegate {
                                //     id: nymeaHostDelegate

                                //     secondaryIconName: !isOnline ? '/icons/connections/cloud-error.svg' : ''
                                //     secondaryIconColor: 'red'

                                //     contextOptions: [
                                //         {
                                //             text: qsTr('Info'),
                                //             icon: Qt.resolvedUrl('/icons/info.svg'),
                                //             callback: function() {
                                //                 var nymeaHost = hostsProxy.get(index);
                                //                 var connectionInfoDialog = Qt.createComponent('/ui/components/ConnectionInfoDialog.qml')
                                //                 var popup = connectionInfoDialog.createObject(app,{nymeaHost: nymeaHost})
                                //                 console.warn('::', connectionInfoDialog.errorString())
                                //                 popup.open()
                                //             }
                                //         }
                                //     ]
                                // }
                            }
                        }
                    }

                    Item {
                        id: spacer
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }

    Component {
        id: manualConnectionComponent

        ConsolinnoWizardPageBase {
            id: manualConnectionPage

            property Component navbarControls: manualConnectionNavbarControls
            property int navigationFooterHeight: 0

            headerLabel: qsTr("Setup %1").arg(Configuration.deviceName)

            Component {
                id: manualConnectionNavbarControls
                ColumnLayout {
                    spacing: Style.smallMargins

                    CoNavbarButton {
                        Layout.fillWidth: true
                        text: qsTr("Finish setup")
                        onClicked: {
                            var rpcUrl;
                            var hostAddress;
                            var port;

                            // Set default to placeholder
                            if (addressTextInput.text === "") {
                                hostAddress = addressTextInput.placeholderText;
                            } else {
                                hostAddress = addressTextInput.text;
                            }

                            if (portTextInput.text === "") {
                                port = portTextInput.placeholderText;
                            } else {
                                port = portTextInput.text;
                            }

                            if (connectionTypeComboBox.currentIndex === 0) {
                                if (secureCheckBox.checked) {
                                    rpcUrl = 'nymeas://' + hostAddress + ':' + port;
                                } else {
                                    rpcUrl = 'nymea://' + hostAddress + ':' + port;
                                }
                            } else if (connectionTypeComboBox.currentIndex === 1) {
                                if (secureCheckBox.checked) {
                                    rpcUrl = 'wss://' + hostAddress + ':' + port;
                                } else {
                                    rpcUrl = 'ws://' + hostAddress + ':' + port;
                                }
                            } else if (connectionTypeComboBox.currentIndex === 2) {
                                if (secureCheckBox.checked) {
                                    rpcUrl = "tunnels://" + hostAddress + ":" + port + "?uuid=" + serverUuidTextInput.text;
                                } else {
                                    rpcUrl = "tunnel://" + hostAddress + ":" + port + "?uuid=" + serverUuidTextInput.text;
                                }
                            }

                            console.info("Trying to connect to ", rpcUrl);
                            var host = nymeaDiscovery.nymeaHosts.createWanHost("Manual connection", rpcUrl);
                            engine.jsonRpcClient.connectToHost(host);
                        }
                    }

                    CoNavbarButton {
                        Layout.fillWidth: true
                        text: qsTr("Cancel")
                        flat: true
                        onClicked: pageStack.pop(root)
                    }
                }
            }

            Flickable {
                id: manualConnectionFlickable
                anchors.fill: parent
                clip: true

                ColumnLayout {
                    id: contentColumn
                    anchors.fill: parent
                    anchors.margins: Style.margins
                    anchors.topMargin: manualConnectionPage.headerHeight + Style.margins
                    anchors.bottomMargin: manualConnectionPage.navigationFooterHeight + Style.margins
                    spacing: 0

                    CoFrostyCard {
                        id: manualConnectionCard
                        Layout.fillWidth: true
                        headerText: qsTr("Manual setup")
                        contentTopMargin: Style.smallMargins

                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: Style.margins
                            anchors.rightMargin: Style.margins
                            spacing: 0

                            CoComboBox {
                                id: connectionTypeComboBox
                                Layout.fillWidth: true
                                labelText: qsTr("Protocol")
                                model: [ qsTr("TCP"), qsTr("Websocket"), qsTr("Remote proxy") ]
                            }

                            CoInputField {
                                id: addressTextInput
                                Layout.fillWidth: true
                                labelText: connectionTypeComboBox.currentIndex < 2 ?
                                               qsTr("Address:") :
                                               qsTr("Proxy address:")
                                placeholderText: connectionTypeComboBox.currentIndex < 2 ?
                                                               "127.0.0.1" :
                                                               "hems-remoteproxy.services.consolinno.de"
                            }

                            CoInputField {
                                id: serverUuidTextInput
                                Layout.fillWidth: true
                                visible: connectionTypeComboBox.currentIndex === 2
                                labelText: qsTr("%1 UUID:").arg(Configuration.systemName)
                            }

                            CoInputField {
                                id: portTextInput
                                Layout.fillWidth: true
                                labelText: qsTr("Port:")
                                placeholderText: connectionTypeComboBox.currentIndex === 0 ?
                                                               "2222" :
                                                               connectionTypeComboBox.currentIndex === 1 ?
                                                                   "4444" :
                                                                   "2213"
                                textField.validator: IntValidator{bottom: 1; top: 65535;}
                            }

                            CheckBox {
                                id: secureCheckBox
                                Layout.fillWidth: true
                                Layout.leftMargin: Style.margins
                                Layout.rightMargin: Style.margins
                                text: qsTr("Establish a connection via SSL.")
                                checked: true
                            }
                        }
                    }

                    Item {
                        id: spacer
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }


    function loadHtmlFile(fileName, textAreaView) {
        var xhr = new XMLHttpRequest();
        xhr.open("GET", Qt.resolvedUrl(fileName), false); // Synchronous read
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                textAreaView.text = xhr.responseText;
            } else if (xhr.status !== 200) {
                console.error("Failed to load file:", xhr.status, xhr.statusText);
            }
        };
        xhr.send();
    }
}
