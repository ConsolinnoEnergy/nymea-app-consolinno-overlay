pragma Singleton

import QtQuick 2.5

ConfigurationBase {
    id: configID
    systemName: "Q.Home HEMS"
    appName: "Q Cells HEMS"
    appId: "hems.consolinno.energy"


    connectionWizard: "/ui/wizards/ConnectionWizard.qml"

    //////////////////////////////////////////////////////////////////////////////////////
    //Main View
    readonly property string mainMenuThingName: "black"

    //change "Ubuntu" string to set a different font or set "Ubuntu" to have standard font
    property string fontFamily: "Ubuntu"

    //Wizard Complete
    property bool isIntroIcon: true
    //////////////////////////////////////////////////////////////////////////////////////
    // Defines the minimal compatible HEMS version
    property string minSysVersion: "1.3.0"

    // Identifier used for branding (e.g. to register for push notifications)
    property string branding: "Q CELLS"

    // Identifier used for legal text (e.g. privacy policy)
    property string companyName: "Hanwha Q CELLS GmbH"

    // Branding names visible to the user
    property string appBranding: "Q CELLS"
    property string coreBranding: "Q.Home"
    property string deviceName: "Q.HOME CONTROL"

    //Branding contact-email
    property string contactEmail: "meinesolaranlage@q-cells.com"
    property string serviceEmail: "support.components@q-cells.com"

    //Branding company
    property string companyAddress: "Sonnenallee 17 - 21"
    property string companyZip: "06766"
    property string companyLocation: "Bitterfeld-Wolfen"
    property string companyTel: "+49 (0)3494 6699-0"

    //////////////////////////////////////////////////////////////////////////////////////
    // Will be shown in About page
    property string githubLink: "https://github.com/ConsolinnoEnergy/nymea-app"
    property string privacyPolicyUrl: "https://consolinno.de/hems-datenschutz/"
    property string termsOfConditionsUrl: "https://consolinno.de/hems-agb/"
    property string downloadMedia: "https://www.q-cells.de/privatkunden/services/downloadbereich#"

    //////////////////////////////////////////////////////////////////////////////////////

    //Styles
    // Button
    readonly property color iconColor: "#639df7"
    readonly property color buttonColor: "#001C77"
    readonly property color buttonTextColor: "#ffffff"

    //static things colors
    //producers
    readonly property color rootMeterAcquisitionColor: "#F37B8E"
    readonly property color rootMeterReturnColor: "#45B4E4"
    readonly property color inverterColor: "#FCE487"

    //other things
    readonly property color epexColor: "#E056F5"
    readonly property color epexMainLineColor: "#6CCB56"
    readonly property color epexAverageColor: "#C65B5A"

    //other consumers
    readonly property color heatpumpColor: "#F7B772"
    readonly property color wallboxColor: "#ACE3E2"
    readonly property color heatingRodColor: "#639F86"
    readonly property color consumedColor: "#ADB9E3"

    //batteries
    readonly property color batteriesColor: "#BDD786"
    readonly property color batteryChargeColor: batteriesColor
    readonly property color batteryDischargeColor: "#F7B772"

    //static array of thing colors
    property var consumerColors: ["#FF8954", "#D9F6C5", "#437BC4", "#AA5DC2", "#C6C73F"]
    readonly property var totalColors: [consumedColor, inverterColor, rootMeterAcquisitionColor, rootMeterReturnColor, batteryChargeColor, batteryDischargeColor]

    //custom Icons
    readonly property string gridIcon: ""
    readonly property string heatpumpIcon: ""
    readonly property string heatingRodIcon: ""
    readonly property string energyIcon: ""
    readonly property string inverterIcon: ""
    readonly property string settingsIcon: ""
    readonly property string evchargerIcon: ""
    readonly property string batteryIcon: ""
    readonly property string infoIcon: ""
    readonly property string menuIcon: ""

    //////////////////////////////////////////////////////////////////////////////////////
    //Help links
    property ListModel softwareLinksApp: ListModel {
        ListElement { component: "Suru icons"; url: "https://github.com/snwh/suru-icon-theme" }
        ListElement { component: "Ubuntu font"; url: "https://design.ubuntu.com/font" }
        ListElement { component: "Oswald font"; url: "https://fonts.google.com/specimen/Oswald" }
        ListElement { component: "QTZeroConf"; url: "https://github.com/jbagg/QtZeroConf" }
        ListElement { component: "Android OpenSSL"; url: "https://github.com/KDAB/android_openssl" }
        ListElement { component: "Firebase"; url: "https://github.com/firebase/firebase-cpp-sdk" }
        ListElement { component: "OpenSSl"; url: "https://www.openssl.org/" }
        ListElement { component: "Nymea App"; url: "https://github.com/ConsolinnoEnergy/nymea-app" }
        ListElement { component: "Nymea Remoteproxy"; url: "https://github.com/ConsolinnoEnergy/nymea-remoteproxy" }
        ListElement { component: "Consolinno Overlay"; url: "https://github.com/ConsolinnoEnergy/nymea-app-consolinno-overlay" }
    }

    property ListModel licensesApp: ListModel {
        ListElement { component: "GNU General Public License, Version 3.0"; license: "GPL3" }
        ListElement { component: "GNU Lesser General Public License, Version 3.0"; license: "LGPL3" }
        ListElement { component: "OpenSSL"; license: "OpenSSL" }
        ListElement { component: "Apache License, Version 2.0"; license: "APACHE2" }
        ListElement { component: "Creative Commons Attribution-ShareAlike 3.0 Unported"; license: "CC-BY-SA-3.0" }
        ListElement { component: "SIL Open Font License, Version 1.1"; license: "OFL" }
        ListElement { component: "Ubuntu font licence, Version 1.0"; license: "UFL" }
    }

    //////////////////////////////////////////////////////////////////////////////////////
    //Connection & Settings
    // Default value when manually adding a tunnel proxy
    property string defaultTunnelProxyUrl: "hems-remoteproxy.services.consolinno.de"

    // Hides shutdown button in general settings menu
    property bool hideShutdownButton: true

    // Hides Restart button in general settings menu
    property bool hideRestartButton: true

    // Shows Reboot button in general settings menu
    property bool hideRebootButton: false

    // Shows Developer button in general settings menu
    property bool developerSettingsEnabled: false

    //////////////////////////////////////////////////////////////////////////////////////
    // Additional MainViews
    property var additionalMainViews: ListModel {
        ListElement { name: "consolinno"; source: "ConsolinnoView"; displayName: qsTr("Q CELLS") ; icon: "leaf" }
    }

    // Main views filter: Only those main views are enabled
    //property var mainViewsFilter: ["consolinno"]

    defaultMainView: "consolinno"

    magicEnabled: true
    networkSettingsEnabled: true
    apiSettingsEnabled: true
    mqttSettingsEnabled: false
    webServerSettingsEnabled: false
    zigbeeSettingsEnabled: false
    modbusSettingsEnabled: true
    pluginSettingsEnabled: true



    mainMenuLinks: [ 
        {
            text: qsTr("Help"),
            iconName: "../images/help.svg",
            page: "info/Help/HelpPage.qml"
        },
    ] 

    }
