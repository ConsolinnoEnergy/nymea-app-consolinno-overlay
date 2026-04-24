import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0

import "../components"

Page {
    id: root

    property CloudConfiguration cloudConfiguration: hemsManager.cloudConfiguration

    header: NymeaHeader {
        text: qsTr("Consolinno Cloud Services")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Flickable {
        anchors.fill: parent
        contentHeight: layout.implicitHeight + app.margins
        clip: true

        ColumnLayout {
            id: layout
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
                topMargin: 8
                bottomMargin: 8
                leftMargin: 16
                rightMargin: 16
            }
            spacing: 16

            // Section 1: Verbindung (Connection)
            CoFrostyCard {
                Layout.fillWidth: true
                headerText: qsTr("Connection")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                        spacing: 16

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                // Reflects the live MQTT connection state from the Leaflet MQTT connector
                                // (routed through nymea-energy-plugin-consolinno). See TODO in
                                // HemsManager::getCloudConfigurationResponse().
                                text: cloudConfiguration.mqttConnected ? qsTr("Connected") : qsTr("Not connected")
                                font: Style.newParagraphFont
                                color: Style.colors.typography_Basic_Default
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                Layout.fillWidth: true
                                text: qsTr("Status")
                                font: Style.newSmallFont
                                color: Style.colors.typography_Basic_Secondary
                                wrapMode: Text.WordWrap
                            }
                        }

                        // Green status indicator dot
                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            color: cloudConfiguration.mqttConnected ? "#4CAF50" : Style.colors.typography_Basic_Secondary
                            border.width: 0
                        }
                    }
                }
            }

            // Section 2: Zustimmung (Consent)
            CoFrostyCard {
                Layout.fillWidth: true
                headerText: qsTr("Consent")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    // Enable cloud services toggle with info
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        Layout.topMargin: 8
                        Layout.bottomMargin: 4
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            RowLayout {
                                spacing: 8

                                Text {
                                    text: qsTr("Activate Consolinno Cloud Services")
                                    font: Style.newParagraphFont
                                    color: Style.colors.typography_Basic_Default
                                    wrapMode: Text.WordWrap
                                }

                                InfoButton {
                                    push: "CloudServicesActivateInfo.qml"
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                Layout.topMargin: 4
                                text: qsTr("Activates the connection to our cloud services. Only the selected release categories will be shared.")
                                font: Style.newSmallFont
                                color: Style.colors.typography_Basic_Secondary
                                wrapMode: Text.WordWrap
                            }
                        }

                        ConsolinnoSwitch {
                            id: cloudEnabledSwitch
                            checked: cloudConfiguration.cloudEnabled
                            onToggled: {
                                hemsManager.setCloudConfiguration({"cloudEnabled": checked})
                            }
                        }
                    }

                    // Privacy link with cookie icon
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        Layout.topMargin: 16
                        Layout.bottomMargin: 8
                        spacing: 12

                        ColorIcon {
                            name: "/icons/cookie.svg"
                            size: 24
                            color: Style.colors.brand_Basic_Icon_accent
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: qsTr("More about data processing and privacy")
                                font: Style.newParagraphFont
                                color: Style.colors.typography_Basic_Default
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "www.consolinno.de/hems-datenschutz"
                                font: Style.newSmallFont
                                color: Style.colors.typography_Basic_Secondary
                                wrapMode: Text.WordWrap
                            }
                        }

                        ColorIcon {
                            name: "/icons/next.svg"
                            size: 20
                            color: Style.colors.typography_Basic_Secondary
                            rotation: 180
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Qt.openUrlExternally("https://www.consolinno.de/hems-datenschutz")
                            }
                        }
                    }
                }
            }

            // Section 3: Freigabekategorien (Release categories)
            CoFrostyCard {
                Layout.fillWidth: true
                headerText: qsTr("Release categories")
                enabled: cloudConfiguration.cloudEnabled
                opacity: cloudConfiguration.cloudEnabled ? 1.0 : 0.5

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    // Energy Monitoring toggle
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            RowLayout {
                                spacing: 8

                                Text {
                                    text: qsTr("Energy Monitoring")
                                    font: Style.newParagraphFont
                                    color: cloudConfiguration.cloudEnabled ? Style.colors.typography_Basic_Default : Style.colors.typography_Basic_Secondary
                                    wrapMode: Text.WordWrap
                                }

                                InfoButton {
                                    push: "EnergyMonitoringInfo.qml"
                                    visible: cloudConfiguration.cloudEnabled
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                Layout.topMargin: 4
                                text: qsTr("Shares consumption and production data for accurate energy analysis.")
                                font: Style.newSmallFont
                                color: cloudConfiguration.cloudEnabled ? Style.colors.typography_Basic_Secondary : Style.colors.typography_States_Disabled
                                wrapMode: Text.WordWrap
                            }
                        }

                        ConsolinnoSwitch {
                            id: energyMonitoringSwitch
                            checked: cloudConfiguration.energyMonitoringEnabled
                            enabled: cloudConfiguration.cloudEnabled
                            onToggled: {
                                hemsManager.setCloudConfiguration({"energyMonitoringEnabled": checked})
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        height: 1
                        color: Style.colors.typography_States_Hover
                    }

                    // Anonymized usage data toggle
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                        spacing: 12

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            RowLayout {
                                spacing: 8

                                Text {
                                    text: qsTr("Anonymized usage data")
                                    font: Style.newParagraphFont
                                    color: cloudConfiguration.cloudEnabled ? Style.colors.typography_Basic_Default : Style.colors.typography_Basic_Secondary
                                    wrapMode: Text.WordWrap
                                }

                                InfoButton {
                                    push: "AnonymizedUsageDataInfo.qml"
                                    visible: cloudConfiguration.cloudEnabled
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                Layout.topMargin: 4
                                text: qsTr("Shares fully anonymized data for research and product improvement.")
                                font: Style.newSmallFont
                                color: cloudConfiguration.cloudEnabled ? Style.colors.typography_Basic_Secondary : Style.colors.typography_States_Disabled
                                wrapMode: Text.WordWrap
                            }
                        }

                        ConsolinnoSwitch {
                            id: researchDataSwitch
                            checked: cloudConfiguration.researchDataEnabled
                            enabled: cloudConfiguration.cloudEnabled
                            onToggled: {
                                hemsManager.setCloudConfiguration({"researchDataEnabled": checked})
                            }
                        }
                    }
                }
            }

        }
    }
}
