import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import "qrc:/ui/components"
import Nymea 1.0

ConsolinnoWizardPageBase {
    id: root

    showBackButton: false

    nextButtonText: qsTr("Start EMS setup")
    onNext: pageStack.push(privacyPolicyComponent)

    function exitWizard() {
        pageStack.pop(root, StackView.Immediate)
        pageStack.pop()
    }

    content: ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        Image {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 3
            source: "/ui/images/intro-bg-graphic.svg"
            fillMode: Image.PreserveAspectCrop
        }

        Image {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height / 2
            source: "/ui/images/intro-bg-graphic-2.svg"
            fillMode: Image.PreserveAspectFit
        }

    }

    Component {
        id: privacyPolicyComponent
        ConsolinnoWizardPageBase {

            showNextButton: policyCheckbox.checked
            onNext: pageStack.push(connectLeafletComponent)
            onBack: pageStack.pop()

            content: ColumnLayout {
                anchors.fill: parent
                Flickable {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    contentHeight: textArea.height
                    clip: true

                    TextArea {
                        id: textArea
                        width: parent.width
                        text: "<h3>Legal mumbojumo</h3>Bavaria ipsum dolor sit amet Biaschlegl Sepp is Gamsbart no gelbe Rüam dringma aweng ja, wo samma denn kimmt. Edlweiss mi da, hog di hi Biawambn hob, sowos gwiss Zwedschgndadschi: Mehra Greichats hod, Maßkruag Schbozal! I sog ja nix, i red ja bloß pfundig so griaß God beinand af Woibbadinga gor Klampfn i i daad abfieseln. Sepp zua Biazelt Maibam, do: Barfuaßat kummd hi helfgod, gor Ledahosn a fescha Bua pfenningguat Blosmusi. Oachkatzlschwoaf soi nomoi noch da Giasinga Heiwog Buam des Gschicht Ledahosn wea nia ausgähd, kummt nia hoam soi, Marterl. Sei Maibam Biakriagal Maßkruag Schneid Goaßmaß und sei hod mechad Goaßmaß! D’ Schmankal Biaschlegl sodala hod, .

    Mechad woaß da auf’d Schellnsau gar nia need, Freibia. Weißwiaschd Kuaschwanz a Hoiwe trihöleridi dijidiholleri heitzdog no ham, sog i ma kumm geh? Blärrd etza gfreit mi Wiesn am acht’n Tag schuf Gott des Bia, Deandlgwand. I moan scho aa auszutzeln ghupft wia gsprunga i mechad is Zwedschgndadschi Radler Biawambn. Soi Auffisteign back mas, Schdeckalfisch. Woaß pfundig imma, vui huift vui koa weida Fünferl so schee gscheid Servas: Jo mei nimmds Oachkatzlschwoaf is Guglhupf liberalitas Bavariae! Ledahosn Hemad di, is des liab. Ozapfa vo de i sog ja nix, i red ja bloß glei Resi sammawiedaguad, des basd scho Greichats. Resi hawadere midananda des is a gmahde Wiesn nia need schnacksln nix Jodler.

    Hinter’m Berg san a no Leit Haferl Spuiratz, schüds nei hoam Vergeltsgott Milli! Ebba da, hog di hi Mongdratzal, Bussal a Prosit der Gmiadlichkeit wia da Buachbinda Wanninger Spuiratz Kaiwe a ganze: Helfgod auf’d Schellnsau a liabs Deandl Hetschapfah heid sog i, vui huift vui sowos Gams anbandeln. Bittschön sog i Fünferl, sowos jo mei fias: Fensdaln jedza de Sonn, greaßt eich nachad sei hod vui aasgem Griasnoggalsubbm. Hob wolln noch da Giasinga Heiwog wia da Buachbinda Wanninger des muas ma hoid kenna Sauwedda geh! Zünftig hinter’m Berg san a no Leit Enzian Gschicht boarischer Freibia wia iabaroi des is schee. A Prosit der Gmiadlichkeit i daad hod do! Brodzeid Radler Marterl Ewig und drei Dog, Weißwiaschd oans Heimatland Radler Hemad?

    Biagadn Buam pfundig von gscheckate, Xaver Sauwedda Heimatland Kirwa ebba. Maibam san i mechad dee Schwoanshaxn hob i an Suri! Gams guad mim des is schee ozapfa oans vasteh Gschicht Sauwedda? Koa g’hupft wia gsprunga spernzaln, do. Hod nia need auffi und glei wirds no fui lustiga des wiad a Mordsgaudi baddscher ned, g’hupft wia gsprunga. Kuaschwanz i mog di fei wolpern, da. Sog i Obazda Haberertanz Engelgwand oans wea nia ausgähd, kummt nia hoam is ma Wuascht, Weibaleid Freibia imma. Auf der Oim, da gibt’s koa Sünd a Hoiwe hob i an Suri sauba jo mei i moan oiwei nix Gwiass woass ma ned Marterl? Und glei wirds no fui lustiga und glei wirds no fui lustiga an Schneid, a ganze Radler Leonhardifahrt i bin a woschechta Bayer Marterl Gschicht oa. Zwoa mogsd a Bussal.

    Wann griagd ma nacha wos z’dringa Watschnbaam amoi i hab an Radler! Jodler ham muass in da, Schbozal hi Sauakraud umananda glei. Gschicht aasgem wia da Buachbinda Wanninger, allerweil ned Schmankal. Gfreit mi Haferl spernzaln Leonhardifahrt Sauakraud, Brotzeit owe. A ganze Hoiwe i hob di liab imma Heimatland weida i waar soweid koa Fingahaggln sammawiedaguad nia need. Hea nomoi hallelujah sog i, luja Obazda von nimmds eam griasd eich midnand muass, soi! Watschnbaam schoo pfenningguat, hinter’m Berg san a no Leit di i sog ja nix, i red ja bloß Schbozal des is schee. Hallelujah sog i, luja Prosd nimmds jedza Spuiratz i hob di liab Edlweiss Schaung kost nix a so a Schmarn Jodler, vo de. A Hoiwe Mamalad und sei Bladl. ."
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        textFormat: Text.RichText
                        readOnly: true
                    }
                }


                CheckDelegate {
                    id: policyCheckbox
                    Layout.fillWidth: true
                    text: qsTr("I accept the privacy policy")
                }
            }
        }
    }

    Component {
        id: connectLeafletComponent
        ConsolinnoWizardPageBase {

            onNext: pageStack.push(findLeafletComponent)
            onBack: pageStacl.pop()

            content: ColumnLayout {
                anchors.fill: parent

                Label {
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("Please make sure that your Leaflet is connected to the power source and the network.")
                    wrapMode: Text.WordWrap
                }

                Image {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    source: "/ui/images/leaflet-connect.png"
                    fillMode: Image.PreserveAspectFit
                    verticalAlignment: Image.AlignVCenter
                    horizontalAlignment: Image.AlignHCenter
                }

            }
        }
    }

    Component {
        id: findLeafletComponent

        ConsolinnoWizardPageBase {
            id: findLeafletPage

            content: ColumnLayout {
                anchors.fill: parent

                Label {
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    wrapMode: Text.WordWrap
                    text: hostsProxy.count === 0
                          ? qsTr("Searching for your leaflet...")
                          : qsTr("We've detected multiple Leaflets in your network. Please select the one you'd like to set up.")
                }

                BusyIndicator {
                    Layout.alignment: Qt.AlignHCenter
                    visible: hostsProxy.count === 0
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: NymeaHostsFilterModel {
                        id: hostsProxy
                        discovery: nymeaDiscovery
                        showUnreachableBearers: false
                        jsonRpcClient: engine.jsonRpcClient
                        showUnreachableHosts: false

                        onCountChanged: {
                            if (count === 1) {
                                engine.jsonRpcClient.connectToHost(hostsProxy.get(0))
                            }
                        }
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
                            text: qsTr("Please wait while your nymea system is being discovered.")
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
            }
        }
    }
}
