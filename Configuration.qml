pragma Singleton

import QtQuick 2.0

ConfigurationBase {
    systemName: "Leaflet"
    appName: "Consolinno energy"
    appId: "com.consolinno.energy"

    connectionWizard: "/ui/wizards/ConnectionWizard.qml"

    // Identifier used for branding (e.g. to register for push notifications)
    property string branding: "consolinno"

    // Branding names visible to the user
    property string appBranding: "Consolinno Energy"
    property string coreBranding: "Leaflet"

    // Additional MainViews
    property var additionalMainViews: ListModel {
        ListElement { name: "consolinno"; source: "ConsolinnoView"; displayName: qsTr("Consolinno"); icon: "leaf" }
    }

    // Main views filter: Only those main views are enabled
    //property var mainViewsFilter: [ "consolinno", "things" ]
    //property var mainViewsFilter: ["consolinno"]

    defaultMainView: "consolinno"

    magicEnabled: true
    networkSettingsEnabled: true
    apiSettingsEnabled: true
    mqttSettingsEnabled: true
    webServerSettingsEnabled: true
    zigbeeSettingsEnabled: true
    modbusSettingsEnabled: true
    pluginSettingsEnabled: true

    mainMenuLinks: ListModel {
        ListElement {
            text: qsTr("Help")
            iconName: "../images/help.svg"
            url: "https://consolinno.de"
        }
    }
}
