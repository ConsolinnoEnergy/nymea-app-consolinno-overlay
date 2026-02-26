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
        backButtonVisible: true
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
                margins: 8 // #TODO use values from new style
            }
            spacing: 16 // #TODO use values from new style

            CoFrostyCard {
                Layout.fillWidth: true
                headerText: qsTr("Configuration")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 8 // #TODO use values from new style
                    anchors.bottomMargin: 8 // #TODO use values from new style
                    spacing: 0

                    CoCard {
                        Layout.fillWidth: true
                        text: qsTr("Optimization configuration")
                        helpText: qsTr("Optimize devices and system behavior")
                        iconLeft: "/icons/tune.svg"
                        showChildrenIndicator: true
                        onClicked: pageStack.push(Qt.resolvedUrl("mainviews/OptimizationConfiguration.qml"),
                                                  {
                                                      "hemsManager": hemsManager
                                                  })
                    }

                    CoCard {
                        Layout.fillWidth: true
                        text: qsTr("Comissioning")
                        helpText: qsTr("Install devices and set up the system. For installers only.")
                        iconLeft: "/icons/build.svg"
                        showChildrenIndicator: true
                        onClicked: pageStack.push(Qt.resolvedUrl("thingconfiguration/DeviceOverview.qml"),
                                                  {
                                                      "hemsManager": hemsManager
                                                  })
                    }

                    CoCard {
                        Layout.fillWidth: true
                        text: qsTr("Development")
                        helpText: ""
                        iconLeft: "/icons/configure.svg"
                        showChildrenIndicator: true
                        visible: settings.showHiddenOptions
                        onClicked: pageStack.push(Qt.resolvedUrl("optimization/DeveloperConfig.qml"),
                                                  {
                                                      "hemsManager": hemsManager
                                                  })
                    }

                    CoCard {
                        Layout.fillWidth: true
                        text: qsTr("Dynamic electricity tariff")
                        helpText: qsTr("Set up a dynamic electicity tariff for the system to operate with.")
                        iconLeft: "/icons/euro.svg"
                        showChildrenIndicator: true
                        onClicked: pageStack.push(Qt.resolvedUrl("optimization/DynamicElectricityRate.qml"),
                                                  {
                                                      "hemsManager": hemsManager
                                                  })
                    }

                    CoCard {
                        Layout.fillWidth: true
                        text: qsTr("Grid-supportive control")
                        helpText: qsTr("Configure grid support capabilities through relays or EEBUS. For installers only.")
                        iconLeft: "/icons/electric_meter.svg"
                        showChildrenIndicator: true
                        onClicked: pageStack.push(Qt.resolvedUrl("optimization/GridSupportiveControl.qml"),
                                                  {
                                                      "hemsManager": hemsManager
                                                  })
                    }
                }
            }

            CoFrostyCard {
                Layout.fillWidth: true
                headerText: qsTr("App settings")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0 // #TODO use value from new style

                    CoCard {
                        Layout.fillWidth: true
                        text: qsTr("Look & feel")
                        helpText: qsTr("Customize the app's look and behavior")
                        iconLeft: "/icons/style.svg"
                        showChildrenIndicator: true
                        onClicked: pageStack.push(Qt.resolvedUrl("appsettings/ConsolinnoLookAndFeelSettingsPage.qml"))
                    }

                    CoCard {
                        Layout.fillWidth: true
                        text: qsTr("Developer options")
                        helpText: qsTr("Access tools for debugging and error reporting")
                        iconLeft: "/icons/logo_dev.svg"
                        showChildrenIndicator: true
                        onClicked: pageStack.push(Qt.resolvedUrl("appsettings/DeveloperOptionsPage.qml"))
                    }

                    CoCard {
                        Layout.fillWidth: true
                        text: qsTr("About %1").arg(Configuration.appName)
                        helpText: qsTr("Find app versions and licence information")
                        iconLeft: "/icons/info.svg"
                        showChildrenIndicator: true
                        onClicked: pageStack.push(Qt.resolvedUrl("appsettings/AboutPage.qml"))
                    }
                }
            }

            CoFrostyCard {
                Layout.fillWidth: true
                headerText: qsTr("System settings")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0 // #TODO use value from new style

                    CoCard {
                        Layout.fillWidth: true
                        iconLeft: "/icons/build.svg"
                        text: qsTr("General")
                        helpText: qsTr("Change system name and time zone")
                        showChildrenIndicator: true
                        visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                        onClicked: pageStack.push(Qt.resolvedUrl("system/GeneralSettingsPage.qml"))
                    }

                    CoCard {
                        Layout.fillWidth: true
                        iconLeft: "/icons/account_circle.svg"
                        text: qsTr("User settings")
                        helpText: qsTr("Configure who can log in")
                        showChildrenIndicator: true
                        visible: engine.jsonRpcClient.ensureServerVersion("4.2")
                                 && engine.jsonRpcClient.authenticated
                        onClicked: pageStack.push(Qt.resolvedUrl("system/ConsolinnoUsersSettingsPage.qml"))
                    }

                    CoCard {
                        Layout.fillWidth: true
                        iconLeft: "/icons/android_wifi_3_bar.svg"
                        text: qsTr("Networking")
                        helpText: qsTr("Configure the system's network connection")
                        showChildrenIndicator: true
                        visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                                 && Configuration.networkSettingsEnabled
                        onClicked: pageStack.push(Qt.resolvedUrl("system/ConsolinnoNetworkSettingsPage.qml"))
                    }

                    CoCard {
                        Layout.fillWidth: true
                        iconLeft: "/icons/network_manage.svg"
                        text: qsTr("Connection settings")
                        helpText: qsTr("Configure how applications can connect to this system")
                        showChildrenIndicator: true
                        visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                                 && Configuration.apiSettingsEnabled
                        onClicked: pageStack.push(Qt.resolvedUrl("system/ConsolinnoConnectionInterfacesPage.qml"))
                    }

                    CoCard {
                        Layout.fillWidth: true
                        iconLeft: "/icons/flowchart.svg"
                        text: qsTr("Modbus RTU")
                        helpText: qsTr("Configure Modbus RTU master interfaces")
                        showChildrenIndicator: true
                        visible: engine.jsonRpcClient.ensureServerVersion("5.6") &&
                                 NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                        onClicked: pageStack.push(Qt.resolvedUrl("system/ConsolinnoModbusRtuSettingsPage.qml"),{settingsWizard: false})
                    }

                    CoCard {
                        Layout.fillWidth: true
                        iconLeft: "/icons/extension.svg"
                        text: qsTr("Plugins")
                        helpText: qsTr("List and cofigure installed plugins")
                        showChildrenIndicator: true
                        visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) &&
                                 Configuration.pluginSettingsEnabled
                        onClicked:pageStack.push(Qt.resolvedUrl("system/PluginsPage.qml"))
                    }

                    CoCard {
                        Layout.fillWidth: true
                        iconLeft: "/icons/receipt_long.svg"
                        text: qsTr("Log viewer")
                        helpText: qsTr("View system log")
                        showChildrenIndicator: true
                        visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin)
                        onClicked: {
                            if (engine.jsonRpcClient.ensureServerVersion("8.0")) {
                                pageStack.push(Qt.resolvedUrl("system/LogViewerPage.qml"))
                            } else {
                                pageStack.push(Qt.resolvedUrl("system/LogViewerPagePre18.qml"))
                            }
                        }
                    }

                    CoCard {
                        Layout.fillWidth: true
                        iconLeft: "/icons/info.svg"
                        text: qsTr("About %1").arg(Configuration.systemName)
                        helpText: qsTr("Find server UUID and versions")
                        showChildrenIndicator: true
                        onClicked: pageStack.push(Qt.resolvedUrl("system/AboutNymeaPage.qml"))
                    }
                }
            }

            CoFrostyCard {
                Layout.fillWidth: true
                headerText: qsTr("Developer settings")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0 // #TODO use value from new style

                    CoCard {
                        Layout.fillWidth: true
                        iconLeft: "/icons/language.svg"
                        text: qsTr("Web server")
                        helpText: qsTr("Configure the web server")
                        showChildrenIndicator: true
                        visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) &&
                                 Configuration.webServerSettingsEnabled &&
                                 settings.showHiddenOptions
                        onClicked: pageStack.push(Qt.resolvedUrl("system/WebServerSettingsPage.qml"))
                    }

                    CoCard {
                        Layout.fillWidth: true
                        iconLeft: "/icons/zigbee.svg"
                        text: qsTr("ZigBee")
                        helpText: qsTr("Configure ZigBee networks")
                        showChildrenIndicator: true
                        visible: engine.jsonRpcClient.ensureServerVersion("5.3") &&
                                 NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) &&
                                 settings.showHiddenOptions
                        onClicked: pageStack.push(Qt.resolvedUrl("system/zigbee/ZigbeeSettingsPage.qml"))
                    }

                    CoCard {
                        Layout.fillWidth: true
                        iconLeft: "/icons/z-wave.svg"
                        text: qsTr("Z-Wave")
                        helpText: qsTr("Configure Z-Wave networks")
                        showChildrenIndicator: true
                        visible: engine.jsonRpcClient.ensureServerVersion("6.1") &&
                                 NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) &&
                                 settings.showHiddenOptions
                        onClicked: pageStack.push(Qt.resolvedUrl("system/zwave/ZWaveSettingsPage.qml"))
                    }

                    CoCard {
                        Layout.fillWidth: true
                        iconLeft: "/icons/Mqtt.svg"
                        text: qsTr("MQTT broker")
                        helpText: qsTr("Configure the MQTT broker")
                        showChildrenIndicator: true
                        visible: engine.jsonRpcClient.ensureServerVersion("1.11") &&
                                 NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) &&
                                 settings.showHiddenOptions
                        onClicked: pageStack.push(Qt.resolvedUrl("system/MqttBrokerSettingsPage.qml"))
                    }

                    CoCard {
                        Layout.fillWidth: true
                        iconLeft: "/icons/build.svg"
                        text: qsTr("Developer tools")
                        helpText: qsTr("Access tools for debugging and error reporting")
                        showChildrenIndicator: true
                        visible: NymeaUtils.hasPermissionScope(engine.jsonRpcClient.permissions, UserInfo.PermissionScopeAdmin) &&
                                 Configuration.developerSettingsEnabled
                        onClicked: pageStack.push(Qt.resolvedUrl("system/DeveloperTools.qml"))
                    }
                }
            }
        }
    }
}
