import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import 'qrc:/ui/components'
import Nymea 1.0

ConsolinnoWizardPageBase {
    id: root

    headerLabel: qsTr("License Terms HEMS<br/>(as of 11/2024)")
    headerBackButtonVisible: false
    showBackButton: false
    showNextButton: false
    background: Item{}
    onNext: pageStack.push(privacyPolicyComponent)

    function exitWizard() {
        pageStack.pop(root, StackView.Immediate)
        pageStack.pop()
    }

    content: ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; topMargin: Style.bigMargins; right: parent.right; left: parent.left }

        Flickable {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Style.margins
            contentHeight: textAreaTerms.height
            clip: true



            TextArea {
                id: textAreaTerms
                width: parent.width
                font: Style.smallFont
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                textFormat: Text.RichText
                readOnly: true
                text: ""
            }

            Component.onCompleted: {
              loadHtmlFile("../terms_of_use_de_DE.html", textAreaTerms);
            }
        }


        RowLayout{
            Layout.leftMargin: Style.margins
            Layout.rightMargin: Style.margins
            spacing: 0

            ConsolinnoCheckBox{
                id: readCheckbox
                Layout.alignment: Qt.AlignHCenter

            }

            Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignLeft
                text: qsTr("Yes I read the Term of Use and agree")


                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if(readCheckbox.checked == true){
                            readCheckbox.checked = false
                        }else{
                            readCheckbox.checked = true
                        }
                    }
                }
            }
        }


        Button {
            Layout.alignment: Qt.AlignHCenter
            text: readCheckbox.checked ? qsTr('next') : qsTr('cancel')
            Layout.preferredWidth: 200
            background: Rectangle{
                color: readCheckbox.checked ? Style.buttonColor : 'grey'
                radius: 4
            }


            onClicked: {
                if (readCheckbox.checked) {
                    root.next()
                } else {
                    Qt.quit();
                }
            }
        }
    }

    Component{
        id: demoModeComponent

        ConsolinnoWizardPageBase {
            id: demoModePage

            headerVisible: false
            showNextButton: false
            showBackButton: false

            onNext: pageStack.push(connectionInfo)
            onBack: pageStack.pop()

            background: Item {}
            content: Item {
                anchors.fill: parent

                ColumnLayout {
                    id: contentColumn

                    anchors {
                        top: parent.top
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                        topMargin: Style.margins
                        bottomMargin: Style.margins
                        leftMargin: Style.margins
                        rightMargin: Style.margins
                    }
                    spacing: Style.hugeMargins

                    Image {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height / 4
                        source: "qrc:/styles/%1/logo-wide.svg".arg(styleController.currentStyle)
                        fillMode: Image.PreserveAspectFit
                    }

                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: false
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: Math.min(parent.width, 300)

                        Label {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            font: Style.bigFont
                            text: qsTr('Welcome to %1!').arg(Configuration.appName)
                        }

                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr('Start setup')
                            Layout.preferredWidth: 200
                            onClicked: demoModePage.next()
                        }

                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr('Demo mode')
                            Layout.preferredWidth: 200
                            onClicked:
                            {
                                var host = nymeaDiscovery.nymeaHosts.createWanHost('Demo server', 'nymeas://hems-demo.consolinno-it.de:31222')
                                engine.jsonRpcClient.connectToHost(host)
                            }
                        }

                        Button {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 200
                            text: qsTr('Back')
                            background: Rectangle{
                                color: 'grey'
                                radius: 4
                            }
                            onClicked: pageStack.pop()
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

            headerLabel: qsTr("Privacy Policy and License Agreement HEMS<br/>(as of 11/2024)")
            showNextButton: false
            showBackButton: false

            onNext: pageStack.push(demoModeComponent)
            onBack: pageStack.pop()

            background: Item {}
            content: ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; topMargin: Style.bigMargins; right: parent.right; left: parent.left }
                width: Math.min(parent.width, 450)

                Flickable {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.margins: Style.margins
                    contentHeight: textArea.height

                    clip: true

                    TextArea {
                        id: textArea
                        width: parent.width
                        font: Style.smallFont
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        textFormat: Text.RichText
                        readOnly: true
                        text: ""
                    }

                      Component.onCompleted: {
                        loadHtmlFile("../privacy_agreement_de_DE.html", textArea);
                      }
                }


                RowLayout{
                    spacing: 0
                    Layout.leftMargin: Style.margins
                    Layout.rightMargin: Style.margins

                    ConsolinnoCheckBox{
                        id: accountCheckbox
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("Yes I agree to open a user account, according to part 6 ")

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if(accountCheckbox.checked == true){
                                    accountCheckbox.checked = false
                                }else{
                                    accountCheckbox.checked = true
                                }
                            }
                        }

                    }
                }


                RowLayout{
                    spacing: 0
                    Layout.leftMargin: Style.margins
                    ConsolinnoCheckBox {
                        id: policyCheckbox
                        Layout.alignment: Qt.AlignHCenter
                    }


                    Label {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr('I confirm that I have read the the agreement and I am accepting it.')

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if(policyCheckbox.checked == true){
                                    policyCheckbox.checked = false
                                }else{
                                    policyCheckbox.checked = true
                                }
                            }
                        }

                    }
                }

                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: policyCheckbox.checked && accountCheckbox.checked ? qsTr('next') : qsTr('cancel')
                    Layout.preferredWidth: 200
                    background: Rectangle{
                        color: policyCheckbox.checked && accountCheckbox.checked ? Style.buttonColor : 'grey'
                        radius: 4
                    }

                    onClicked: {
                        if (policyCheckbox.checked && accountCheckbox.checked) {
                            privacyPolicyPage.next()
                        } else {
                            pageStack.pop()
                        }
                    }
                }
            }
        }

    }

    Component {
        id: connectionInfo
        ConsolinnoWizardPageBase {
            id: connectionInfoPage

            headerLabel: qsTr("Internet Connection")
            showNextButton: false
            showBackButton: false
            background: Item {}
            onNext: pageStack.push(findLeafletComponent)
            onBack: pageStack.pop()

            content: ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; topMargin: Style.bigMargins }
                width: Math.min(parent.width, 450)

                ColumnLayout{
                    Layout.fillWidth: true
                    Label{
                        id: pos

                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        text: qsTr("Please connect your device (LAN port 1) to your network. Be sure this app is also connected to the same network.")
                    }
                }

                Image {
                    Layout.fillWidth: true
                    Layout.preferredHeight: connectionInfoPage.visibleContentHeight - Style.margins * 2
                    Layout.margins: Style.margins * 3
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: width
                    source: "/ui/images/leaflet-ethernet-connect.png"
                }


                Button {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr('next')
                    Layout.preferredWidth: 200

                    onClicked: {
                        connectionInfoPage.next()
                    }
                }
            }
        }
    }


    Component {
        id: findLeafletComponent

        ConsolinnoWizardPageBase {
            id: findLeafletPage

            headerLabel: qsTr("Discovered Devices")
            showBackButton: false
            nextButtonText: qsTr('Manual connection')


            onNext: pageStack.push(manualConnectionComponent)
            background: Item{}

            Timer {
                id: timeoutTimer
                interval: 15000
                running: hostsProxy.count == 0
                onTriggered: pageStack.pop()
            }

            content: ColumnLayout {
                anchors.fill: parent

                Label {
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    wrapMode: Text.WordWrap
                    text: hostsProxy.count === 0
                          ? qsTr('Searching for your %1...').arg(Configuration.deviceName)
                          : qsTr("Please select the device from the list that you want to set up. If no device is displayed in the list, please check the network connection! (Alternatively, a manual connection can also be established).")
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: app.height/3
                    clip: true
                    model: NymeaHostsFilterModel {
                        id: hostsProxy
                        discovery: nymeaDiscovery
                        showUnreachableBearers: false
                        jsonRpcClient: engine.jsonRpcClient
                        showUnreachableHosts: false
                        /*
                        onCountChanged: {
                            if (count === 1) {
                                engine.jsonRpcClient.connectToHost(hostsProxy.get(0))
                            }
                        }*/
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        width: parent.width
                        visible: hostsProxy.count == 0
                        spacing: Style.margins
                        BusyIndicator {
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Label {
                            Layout.fillWidth: true
                            Layout.margins: Style.margins
                            text: qsTr('Please wait while your %1 is being discovered.').arg(Configuration.deviceName)
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }


                    delegate: NymeaSwipeDelegate {
                        id: nymeaHostDelegate
                        width: parent.width
                        property var nymeaHost: hostsProxy.get(index)
                        property string defaultConnectionIndex: {
                            var bestIndex = -1
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
                        iconName: {
                            switch (nymeaHost.connections.get(defaultConnectionIndex).bearerType) {
                            case Connection.BearerTypeLan:
                            case Connection.BearerTypeWan:
                                if (engine.jsonRpcClient.availableBearerTypes & NymeaConnection.BearerTypeEthernet != NymeaConnection.BearerTypeNone) {
                                    return '/ui/images/connections/network-wired.svg'
                                }
                                return '/ui/images/connections/network-wifi.svg';
                            case Connection.BearerTypeBluetooth:
                                return '/ui/images/connections/bluetooth.svg';
                            case Connection.BearerTypeCloud:
                                return '/ui/images/connections/cloud.svg'
                            case Connection.BearerTypeLoopback:
                                return 'qrc:/styles/%1/logo.svg'.arg(styleController.currentStyle)
                            }
                            return ''
                        }
                        text: model.name
                        subText: nymeaHost.connections.get(defaultConnectionIndex).url
                        wrapTexts: false
                        prominentSubText: false
                        progressive: false
                        property bool isSecure: nymeaHost.connections.get(defaultConnectionIndex).secure
                        property bool isOnline: nymeaHost.connections.get(defaultConnectionIndex).bearerType !== Connection.BearerTypeWan ? nymeaHost.connections.get(defaultConnectionIndex).online : true
                        tertiaryIconName: isSecure ? '/ui/images/connections/network-secure.svg' : ''
                        secondaryIconName: !isOnline ? '/ui/images/connections/cloud-error.svg' : ''
                        secondaryIconColor: 'red'

                        onClicked: {
                            engine.jsonRpcClient.connectToHost(nymeaHostDelegate.nymeaHost)
                        }

                        contextOptions: [
                            {
                                text: qsTr('Info'),
                                icon: Qt.resolvedUrl('/ui/images/info.svg'),
                                callback: function() {
                                    var nymeaHost = hostsProxy.get(index);
                                    var connectionInfoDialog = Qt.createComponent('/ui/components/ConnectionInfoDialog.qml')
                                    var popup = connectionInfoDialog.createObject(app,{nymeaHost: nymeaHost})
                                    console.warn('::', connectionInfoDialog.errorString())
                                    popup.open()
                                }
                            }
                        ]
                    }
                }
            }
        }
    }

    Component {
        id: manualConnectionComponent

        ConsolinnoWizardPageBase {
            headerLabel: qsTr("Manual Connection")
            showBackButton: false
            showNextButton: false
            background: Item {}

            content: Item {
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                    right: parent.right
                    topMargin: Style.margins
                    bottomMargin: Style.margins
                    leftMargin: Style.margins
                    rightMargin: Style.margins
                }

                GridLayout {
                    id: manualConnectionDetailsGridLayout

                    width: parent.width
                    height: parent.height / 2
                    anchors.verticalCenter: parent.verticalCenter
                    columns: 2

                    Label {
                        text: qsTr('Protocol')
                    }

                    ConsolinnoDropdown {
                        id: connectionTypeComboBox
                        Layout.fillWidth: true
                        model: [ qsTr("TCP"), qsTr("Websocket"), qsTr("Remote proxy") ]
                    }

                    Label {
                        text: connectionTypeComboBox.currentIndex < 2 ? qsTr("Address:") : qsTr("Proxy address:")
                    }
                    TextField {
                        id: addressTextInput
                        objectName: "addressTextInput"
                        Layout.fillWidth: true
                        placeholderText: connectionTypeComboBox.currentIndex < 2 ? "127.0.0.1" : "hems-remoteproxy.services.consolinno.de"
                    }

                    Label {
                        text: qsTr("%1 UUID:").arg(Configuration.systemName)
                        visible: connectionTypeComboBox.currentIndex == 2
                    }
                    TextField {
                        id: serverUuidTextInput
                        Layout.fillWidth: true
                        visible: connectionTypeComboBox.currentIndex == 2
                    }
                    Label { text: qsTr("Port:") }
                    TextField {
                        id: portTextInput
                        Layout.fillWidth: true
                        placeholderText: connectionTypeComboBox.currentIndex === 0
                                         ? "2222"
                                         : connectionTypeComboBox.currentIndex == 1
                                           ? "4444"
                                           : "2213"
                        validator: IntValidator{bottom: 1; top: 65535;}
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("SSL:")
                    }
                    ConsolinnoCheckBox {
                        id: secureCheckBox
                        checked: true
                    }
                }

                Button {
                    width: 200
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: manualConnectionDetailsGridLayout.bottom
                    anchors.topMargin: Style.margins
                    text: qsTr('Next')
                    onClicked: {
                        var rpcUrl
                        var hostAddress
                        var port

                        // Set default to placeholder
                        if (addressTextInput.text === '') {
                            hostAddress = addressTextInput.placeholderText
                        } else {
                            hostAddress = addressTextInput.text
                        }

                        if (portTextInput.text === '') {
                            port = portTextInput.placeholderText
                        } else {
                            port = portTextInput.text
                        }

                        if (connectionTypeComboBox.currentIndex == 0) {
                            if (secureCheckBox.checked) {
                                rpcUrl = 'nymeas://' + hostAddress + ':' + port
                            } else {
                                rpcUrl = 'nymea://' + hostAddress + ':' + port
                            }
                        } else if (connectionTypeComboBox.currentIndex == 1) {
                            if (secureCheckBox.checked) {
                                rpcUrl = 'wss://' + hostAddress + ':' + port
                            } else {
                                rpcUrl = 'ws://' + hostAddress + ':' + port
                            }
                        } else if (connectionTypeComboBox.currentIndex == 2) {
                            if (secureCheckBox.checked) {
                                rpcUrl = "tunnels://" + hostAddress + ":" + port + "?uuid=" + serverUuidTextInput.text
                            } else {
                                rpcUrl = "tunnel://" + hostAddress + ":" + port + "?uuid=" + serverUuidTextInput.text
                            }
                        }

                        print('Try to connect ', rpcUrl)
                        var host = nymeaDiscovery.nymeaHosts.createWanHost('Manual connection', rpcUrl);
                        engine.jsonRpcClient.connectToHost(host)
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
