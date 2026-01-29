import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import NymeaApp.Utils 1.0
import Nymea 1.0
import "components"

Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Settings")
        backButtonVisible: true  // #TODO Back Button im Moment nicht im neuen Design. Wird der hier gebraucht?
        onBackPressed: pageStack.pop()
    }

    HemsManager{
        id: hemsManager
        engine: _engine
    }

    Flickable {
        anchors.fill: parent
        contentHeight: layout.implicitHeight + app.margins
        clip: true

        ColumnLayout {
            id: layout
            anchors {
                left: parent.left;
                top: parent.top;
                right: parent.right;
                margins: Style.smallMargins
            }
            spacing: 0

            // Configuration

            SettingsTile {
                Layout.fillWidth: true
                text: qsTr("Optimization configuration")
                subText: qsTr("Optimize devices and system behavior")
                iconSource: "/icons/preferences-look-and-feel.svg" // #TODO
                onClicked: pageStack.push(Qt.resolvedUrl("mainviews/OptimizationConfiguration.qml"),
                                          {
                                              "hemsManager": hemsManager
                                          })
                // #TODO visibility (cf. HemsOptimizationPage.qml)
            }

            SettingsTile {
                Layout.fillWidth: true
                text: qsTr("Comissioning")
                subText: qsTr("Install devices and set up the system. For installers only.")
                iconSource: "/icons/preferences-look-and-feel.svg" // #TODO
                onClicked: pageStack.push(Qt.resolvedUrl("thingconfiguration/DeviceOverview.qml"),
                                          {
                                              "hemsManager": hemsManager
                                          })
                // #TODO visibility (cf. HemsOptimizationPage.qml)
            }

            SettingsTile {
                Layout.fillWidth: true
                text: qsTr("Development")
                subText: ""
                iconSource: "/icons/preferences-look-and-feel.svg" // #TODO
                onClicked: pageStack.push(Qt.resolvedUrl("optimization/DeveloperConfig.qml"),
                                          {
                                              "hemsManager": hemsManager
                                          })
                // #TODO visibility (cf. HemsOptimizationPage.qml)
            }

            SettingsTile {
                Layout.fillWidth: true
                text: qsTr("Dynamic electricity tariff")
                subText: qsTr("Set up a dynamic electicity tariff for the system to operate with.")
                iconSource: "/icons/preferences-look-and-feel.svg" // #TODO
                onClicked: pageStack.push(Qt.resolvedUrl("optimization/DynamicElectricityRate.qml"),
                                          {
                                              "hemsManager": hemsManager
                                          })
                // #TODO visibility (cf. HemsOptimizationPage.qml)
            }

            SettingsTile {
                Layout.fillWidth: true
                text: qsTr("Grid-supportive control")
                subText: qsTr("Configure grid support capabilities through relays or EEBUS. For installers only.")
                iconSource: "/icons/preferences-look-and-feel.svg" // #TODO
                onClicked: pageStack.push(Qt.resolvedUrl("optimization/GridSupportiveControl.qml"),
                                          {
                                              "hemsManager": hemsManager
                                          })
                // #TODO visibility (cf. HemsOptimizationPage.qml)
            }



            // App Settings

            SettingsTile {
                Layout.fillWidth: true
                text: qsTr("Look & feel")
                subText: qsTr("Customize the app's look and behavior")
                iconSource: "/icons/preferences-look-and-feel.svg"
                onClicked: pageStack.push(Qt.resolvedUrl("appsettings/ConsolinnoLookAndFeelSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                text: qsTr("Developer options")
                subText: qsTr("Access tools for debugging and error reporting")
                iconSource: "/icons/sdk.svg"
                onClicked: pageStack.push(Qt.resolvedUrl("appsettings/DeveloperOptionsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                text: qsTr("About %1").arg(Configuration.appName)
                subText: qsTr("Find app versions and licence information")
                iconSource: "/icons/info.svg"
                onClicked: pageStack.push(Qt.resolvedUrl("appsettings/AboutPage.qml"))
            }


            // System Settings

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "/icons/configure.svg"
                text: qsTr("General")
                subText: qsTr("Change system name and time zone")
                visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                onClicked: pageStack.push(Qt.resolvedUrl("system/GeneralSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "/icons/account.svg"
                text: qsTr("User settings")
                subText: qsTr("Configure who can log in")
                visible: engine.jsonRpcClient.ensureServerVersion("4.2")
                         && engine.jsonRpcClient.authenticated
                onClicked: pageStack.push(Qt.resolvedUrl("system/ConsolinnoUsersSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "/icons/connections/network-wifi.svg"
                text: qsTr("Networking")
                subText: qsTr("Configure the system's network connection")
                visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                         && Configuration.networkSettingsEnabled
                onClicked: pageStack.push(Qt.resolvedUrl("system/ConsolinnoNetworkSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "/icons/connections/network-vpn.svg"
                text: qsTr("Connection settings")
                subText: qsTr("Configure how applications can connect to this system")
                visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                         && Configuration.apiSettingsEnabled
                onClicked: pageStack.push(Qt.resolvedUrl("system/ConsolinnoConnectionInterfacesPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "/icons/mqtt.svg"
                text: qsTr("MQTT broker")
                subText: qsTr("Configure the MQTT broker")
                visible: engine.jsonRpcClient.ensureServerVersion("1.11") &&
                         NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) &&
                         settings.showHiddenOptions
                onClicked: pageStack.push(Qt.resolvedUrl("system/MqttBrokerSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "/icons/stock_website.svg"
                text: qsTr("Web server")
                subText: qsTr("Configure the web server")
                visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) &&
                         Configuration.webServerSettingsEnabled && settings.showHiddenOptions
                onClicked: pageStack.push(Qt.resolvedUrl("system/WebServerSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "/icons/zigbee.svg"
                text: qsTr("ZigBee")
                subText: qsTr("Configure ZigBee networks")
                visible: engine.jsonRpcClient.ensureServerVersion("5.3") &&
                         NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) &&
                         settings.showHiddenOptions
                onClicked: pageStack.push(Qt.resolvedUrl("system/zigbee/ZigbeeSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "/icons/z-wave.svg"
                text: qsTr("Z-Wave")
                subText: qsTr("Configure Z-Wave networks")
                visible: engine.jsonRpcClient.ensureServerVersion("6.1") &&
                         NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) &&
                         settings.showHiddenOptions
                onClicked: pageStack.push(Qt.resolvedUrl("system/zwave/ZWaveSettingsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "/icons/modbus.svg"
                text: qsTr("Modbus RTU")
                subText: qsTr("Configure Modbus RTU master interfaces")
                visible: engine.jsonRpcClient.ensureServerVersion("5.6") &&
                         NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                onClicked: pageStack.push(Qt.resolvedUrl("system/ConsolinnoModbusRtuSettingsPage.qml"),{settingsWizard: false})
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "/icons/plugin.svg"
                text: qsTr("Plugins")
                subText: qsTr("List and cofigure installed plugins")
                visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) &&
                         Configuration.pluginSettingsEnabled
                onClicked:pageStack.push(Qt.resolvedUrl("system/PluginsPage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "/icons/sdk.svg"
                text: qsTr("Developer tools")
                subText: qsTr("Access tools for debugging and error reporting")
                visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) &&
                         Configuration.developerSettingsEnabled
                onClicked: pageStack.push(Qt.resolvedUrl("system/DeveloperTools.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "/icons/system-update.svg"
                text: qsTr("System update")
                subText: qsTr("Update your %1 system").arg(Configuration.systemName)
                visible: engine.systemController.updateManagementAvailable &&
                         NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                onClicked: pageStack.push(Qt.resolvedUrl("system/SystemUpdatePage.qml"))
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "/icons/logs.svg"
                text: qsTr("Log viewer")
                subText: qsTr("View system log")
                visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                onClicked: {
                    if (engine.jsonRpcClient.ensureServerVersion("8.0")) {
                        pageStack.push(Qt.resolvedUrl("system/LogViewerPage.qml"))
                    } else {
                        pageStack.push(Qt.resolvedUrl("system/LogViewerPagePre18.qml"))
                    }
                }
            }

            SettingsTile {
                Layout.fillWidth: true
                iconSource: "/icons/info.svg"
                text: qsTr("About %1").arg(Configuration.systemName)
                subText: qsTr("Find server UUID and versions")
                onClicked: pageStack.push(Qt.resolvedUrl("system/AboutNymeaPage.qml"))
            }


            // #TODO Developer settings (move stuff here which is only visible when settings.showHiddenOptions is true
            // ATTENTION: There is also Configuration.developerSettingsEnabled. What's the difference?

        }
    }
}
