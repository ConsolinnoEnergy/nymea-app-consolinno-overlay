import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import "qrc:/ui/components"
import Nymea 1.0

ConsolinnoWizardPageBase {
    id: root

    showBackButton: false
    showNextButton: false

    onNext: pageStack.push(privacyPolicyComponent)

    function exitWizard() {
        pageStack.pop(root, StackView.Immediate)
        pageStack.pop()
    }

    content: ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.topMargin: Style.margins
        spacing: Style.hugeMargins
        Image {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 4
            source: "/ui/images/intro-bg-graphic.svg"
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
                text: qsTr("Leaflet CLS")
            }
            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: qsTr("Make sure that the Leaflet is operational and connected to the network.")
            }
            ConsolinnoButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Start setup")
                onClicked: root.next()
            }
            ConsolinnoButton {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Demo mode")
                onClicked:
                {
                    var host = nymeaDiscovery.nymeaHosts.createWanHost("Demo server", "nymeas://hems-demo.consolinno-it.de:31222")
                    engine.jsonRpcClient.connectToHost(host)
                }
            }
        }
    }

    Component {
        id: privacyPolicyComponent
        ConsolinnoWizardPageBase {
            id: privacyPolicyPage

            showNextButton: false
            showBackButton: false

            onNext: pageStack.push(connectionInfo)
            onBack: pageStack.pop()

            content: ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; topMargin: Style.bigMargins }
                width: Math.min(parent.width, 450)

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Privacy policy and license agreement")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    font: Style.bigFont
                }

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
                        text: "Bavaria ipsum dolor sit amet Biaschlegl Sepp is Gamsbart no gelbe Rüam dringma aweng ja, wo samma denn kimmt. Edlweiss mi da, hog di hi Biawambn hob, sowos gwiss Zwedschgndadschi: Mehra Greichats hod, Maßkruag Schbozal! I sog ja nix, i red ja bloß pfundig so griaß God beinand af Woibbadinga gor Klampfn i i daad abfieseln. Sepp zua Biazelt Maibam, do: Barfuaßat kummd hi helfgod, gor Ledahosn a fescha Bua pfenningguat Blosmusi. Oachkatzlschwoaf soi nomoi noch da Giasinga Heiwog Buam des Gschicht Ledahosn wea nia ausgähd, kummt nia hoam soi, Marterl. Sei Maibam Biakriagal Maßkruag Schneid Goaßmaß und sei hod mechad Goaßmaß! D’ Schmankal Biaschlegl sodala hod, .
<br><br>
    Mechad woaß da auf’d Schellnsau gar nia need, Freibia. Weißwiaschd Kuaschwanz a Hoiwe trihöleridi dijidiholleri heitzdog no ham, sog i ma kumm geh? Blärrd etza gfreit mi Wiesn am acht’n Tag schuf Gott des Bia, Deandlgwand. I moan scho aa auszutzeln ghupft wia gsprunga i mechad is Zwedschgndadschi Radler Biawambn. Soi Auffisteign back mas, Schdeckalfisch. Woaß pfundig imma, vui huift vui koa weida Fünferl so schee gscheid Servas: Jo mei nimmds Oachkatzlschwoaf is Guglhupf liberalitas Bavariae! Ledahosn Hemad di, is des liab. Ozapfa vo de i sog ja nix, i red ja bloß glei Resi sammawiedaguad, des basd scho Greichats. Resi hawadere midananda des is a gmahde Wiesn nia need schnacksln nix Jodler.
<br><br>
    Hinter’m Berg san a no Leit Haferl Spuiratz, schüds nei hoam Vergeltsgott Milli! Ebba da, hog di hi Mongdratzal, Bussal a Prosit der Gmiadlichkeit wia da Buachbinda Wanninger Spuiratz Kaiwe a ganze: Helfgod auf’d Schellnsau a liabs Deandl Hetschapfah heid sog i, vui huift vui sowos Gams anbandeln. Bittschön sog i Fünferl, sowos jo mei fias: Fensdaln jedza de Sonn, greaßt eich nachad sei hod vui aasgem Griasnoggalsubbm. Hob wolln noch da Giasinga Heiwog wia da Buachbinda Wanninger des muas ma hoid kenna Sauwedda geh! Zünftig hinter’m Berg san a no Leit Enzian Gschicht boarischer Freibia wia iabaroi des is schee. A Prosit der Gmiadlichkeit i daad hod do! Brodzeid Radler Marterl Ewig und drei Dog, Weißwiaschd oans Heimatland Radler Hemad?
<br><br>
    Biagadn Buam pfundig von gscheckate, Xaver Sauwedda Heimatland Kirwa ebba. Maibam san i mechad dee Schwoanshaxn hob i an Suri! Gams guad mim des is schee ozapfa oans vasteh Gschicht Sauwedda? Koa g’hupft wia gsprunga spernzaln, do. Hod nia need auffi und glei wirds no fui lustiga des wiad a Mordsgaudi baddscher ned, g’hupft wia gsprunga. Kuaschwanz i mog di fei wolpern, da. Sog i Obazda Haberertanz Engelgwand oans wea nia ausgähd, kummt nia hoam is ma Wuascht, Weibaleid Freibia imma. Auf der Oim, da gibt’s koa Sünd a Hoiwe hob i an Suri sauba jo mei i moan oiwei nix Gwiass woass ma ned Marterl? Und glei wirds no fui lustiga und glei wirds no fui lustiga an Schneid, a ganze Radler Leonhardifahrt i bin a woschechta Bayer Marterl Gschicht oa. Zwoa mogsd a Bussal.
<br><br>
    Wann griagd ma nacha wos z’dringa Watschnbaam amoi i hab an Radler! Jodler ham muass in da, Schbozal hi Sauakraud umananda glei. Gschicht aasgem wia da Buachbinda Wanninger, allerweil ned Schmankal. Gfreit mi Haferl spernzaln Leonhardifahrt Sauakraud, Brotzeit owe. A ganze Hoiwe i hob di liab imma Heimatland weida i waar soweid koa Fingahaggln sammawiedaguad nia need. Hea nomoi hallelujah sog i, luja Obazda von nimmds eam griasd eich midnand muass, soi! Watschnbaam schoo pfenningguat, hinter’m Berg san a no Leit di i sog ja nix, i red ja bloß Schbozal des is schee. Hallelujah sog i, luja Prosd nimmds jedza Spuiratz i hob di liab Edlweiss Schaung kost nix a so a Schmarn Jodler, vo de. A Hoiwe Mamalad und sei Bladl. ."
                    }
                }

                CheckBox {
                    id: policyCheckbox
                    Layout.alignment: Qt.AlignCenter
                }

                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("I confirm that I have read the the agreement and am accepting it.")
                }
                ConsolinnoButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: policyCheckbox.checked ? qsTr("next") : qsTr("cancel")
                    color: policyCheckbox.checked ? Style.accentColor : Style.yellow

                    onClicked: {
                        if (policyCheckbox.checked) {
                            privacyPolicyPage.next()
                        } else {
                            Qt.quit()
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

            showNextButton: false
            showBackButton: false

            onNext: pageStack.push(findLeafletComponent)
            onBack: pageStack.pop()

            content: ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; topMargin: Style.bigMargins }
                width: Math.min(parent.width, 450)

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Establishing a connection")
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    font: Style.bigFont
                }

                Label{
                    Layout.fillWidth: true
                    text: "In order to connect your device (phone/PC) with the Leaflet you have to be in the same network. \n \n Connect your device with a LAN-cable with the Leaflet (Third ethernet slot). \n\n You can also connect your device to your local Wifi if the Leaflet has a Wifi module."
                    wrapMode: Text.WordWrap
                }





                ConsolinnoButton {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("next")
                    color: Style.accentColor

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
            onBack: pageStack.pop()
            nextButtonText: qsTr("Manual connection")


            onNext: pageStack.push(manualConnectionComponent)


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
                          ? qsTr("Searching for your Leaflet...")
                          : qsTr("We've detected multiple Leaflets in your network. Please select the one you'd like to set up.")
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
                            text: qsTr("Please wait while your Leaflet is being discovered.")
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
                                    return "/ui/images/connections/network-wired.svg"
                                }
                                return "/ui/images/connections/network-wifi.svg";
                            case Connection.BearerTypeBluetooth:
                                return "/ui/images/connections/bluetooth.svg";
                            case Connection.BearerTypeCloud:
                                return "/ui/images/connections/cloud.svg"
                            case Connection.BearerTypeLoopback:
                                return "qrc:/styles/%1/logo.svg".arg(styleController.currentStyle)
                            }
                            return ""
                        }
                        text: model.name
                        subText: nymeaHost.connections.get(defaultConnectionIndex).url
                        wrapTexts: false
                        prominentSubText: false
                        progressive: false
                        property bool isSecure: nymeaHost.connections.get(defaultConnectionIndex).secure
                        property bool isOnline: nymeaHost.connections.get(defaultConnectionIndex).bearerType !== Connection.BearerTypeWan ? nymeaHost.connections.get(defaultConnectionIndex).online : true
                        tertiaryIconName: isSecure ? "/ui/images/connections/network-secure.svg" : ""
                        secondaryIconName: !isOnline ? "/ui/images/connections/cloud-error.svg" : ""
                        secondaryIconColor: "red"

                        onClicked: {


                            engine.jsonRpcClient.connectToHost(nymeaHostDelegate.nymeaHost)
                        }

                        contextOptions: [
                            {
                                text: qsTr("Info"),
                                icon: Qt.resolvedUrl("/ui/images/info.svg"),
                                callback: function() {
                                    var nymeaHost = hostsProxy.get(index);
                                    var connectionInfoDialog = Qt.createComponent("/ui/components/ConnectionInfoDialog.qml")
                                    var popup = connectionInfoDialog.createObject(app,{nymeaHost: nymeaHost})
                                    console.warn("::", connectionInfoDialog.errorString())
                                    popup.open()
                                }
                            }
                        ]
                    }
                }

                Label{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    //horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: "You have to authenticate yourself to the Leaflet. For further information look at the manual for Commissioning"

                }


            }
        }
    }

    Component {
        id: manualConnectionComponent
        ConsolinnoWizardPageBase {
//            title: qsTr("Manual connection")
//            text: qsTr("Please enter the connection information for your nymea system")
            onBack: pageStack.pop()

            onNext: {
                var rpcUrl
                var hostAddress
                var port

                // Set default to placeholder
                if (addressTextInput.text === "") {
                    hostAddress = addressTextInput.placeholderText
                } else {
                    hostAddress = addressTextInput.text
                }

                if (portTextInput.text === "") {
                    port = portTextInput.placeholderText
                } else {
                    port = portTextInput.text
                }

                if (connectionTypeComboBox.currentIndex == 0) {
                    if (secureCheckBox.checked) {
                        rpcUrl = "nymeas://" + hostAddress + ":" + port
                    } else {
                        rpcUrl = "nymea://" + hostAddress + ":" + port
                    }
                } else if (connectionTypeComboBox.currentIndex == 1) {
                    if (secureCheckBox.checked) {
                        rpcUrl = "wss://" + hostAddress + ":" + port
                    } else {
                        rpcUrl = "ws://" + hostAddress + ":" + port
                    }
                }

                print("Try to connect ", rpcUrl)
                var host = nymeaDiscovery.nymeaHosts.createWanHost("Manual connection", rpcUrl);
                engine.jsonRpcClient.connectToHost(host)
            }

            content: ColumnLayout {


                anchors.fill: parent
                anchors.margins: Style.margins
                GridLayout {
                    columns: 2

                    Label {
                        text: qsTr("Protocol")
                    }

                    ComboBox {
                        id: connectionTypeComboBox
                        Layout.fillWidth: true
                        model: [ qsTr("TCP"), qsTr("Websocket") ]
                    }

                    Label { text: qsTr("Address:") }
                    TextField {
                        id: addressTextInput
                        objectName: "addressTextInput"
                        Layout.fillWidth: true
                        placeholderText: "127.0.0.1"
                    }

                    Label { text: qsTr("Port:") }
                    TextField {
                        id: portTextInput
                        Layout.fillWidth: true
                        placeholderText: connectionTypeComboBox.currentIndex === 0 ? "2222" : "4444"
                        validator: IntValidator{bottom: 1; top: 65535;}
                    }

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Encrypted connection:")
                    }
                    CheckBox {
                        id: secureCheckBox
                        checked: true
                    }
                }
            }
        }
    }
}
