import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0

import "../components"

Page {
    id: root

    property HemsManager hemsManager
    property CloudConfiguration cloudConfiguration: hemsManager.cloudConfiguration

    header: NymeaHeader {
        text: qsTr("Cloud services")
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

            // REQ1: Cloud connection status
            CoFrostyCard {
                Layout.fillWidth: true
                headerText: qsTr("Cloud connection")

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

                        ColorIcon {
                            name: "/icons/cloud.svg"
                            size: 24
                            color: {
                                if (!cloudConfiguration.cloudEnabled)
                                    return Style.colors.typography_Basic_Secondary
                                return Style.colors.brand_Basic_Icon_accent
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: qsTr("Status")
                                font: Style.newParagraphFont
                                color: Style.colors.typography_Basic_Default
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                Layout.fillWidth: true
                                text: {
                                    if (!cloudConfiguration.cloudEnabled)
                                        return qsTr("Disabled")
                                    return qsTr("Connected")
                                }
                                font: Style.newSmallFont
                                color: {
                                    if (!cloudConfiguration.cloudEnabled)
                                        return Style.colors.typography_Basic_Secondary
                                    return Style.colors.brand_Basic_Icon_accent
                                }
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }

            // REQ3: Full opt-out toggle
            CoFrostyCard {
                Layout.fillWidth: true
                headerText: qsTr("General")

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

                        ColorIcon {
                            name: "/icons/online.svg"
                            size: 24
                            color: Style.colors.brand_Basic_Icon_accent
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: qsTr("Enable cloud services")
                                font: Style.newParagraphFont
                                color: Style.colors.typography_Basic_Default
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                Layout.fillWidth: true
                                text: qsTr("Allow the system to connect to cloud services.")
                                font: Style.newSmallFont
                                color: Style.colors.typography_Basic_Default
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
                }
            }

            // REQ2: Granular data category toggles (only visible when cloud is enabled)
            CoFrostyCard {
                Layout.fillWidth: true
                headerText: qsTr("Data categories")
                enabled: cloudConfiguration.cloudEnabled
                opacity: cloudConfiguration.cloudEnabled ? 1.0 : 0.5

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

                        ColorIcon {
                            name: "/icons/energy.svg"
                            size: 24
                            color: Style.colors.brand_Basic_Icon_accent
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: qsTr("Energy monitoring")
                                font: Style.newParagraphFont
                                color: Style.colors.typography_Basic_Default
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                Layout.fillWidth: true
                                text: qsTr("Share energy consumption and production data.")
                                font: Style.newSmallFont
                                color: Style.colors.typography_Basic_Default
                                wrapMode: Text.WordWrap
                            }
                        }

                        ConsolinnoSwitch {
                            id: energyMonitoringSwitch
                            checked: cloudConfiguration.energyMonitoringEnabled
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

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        Layout.topMargin: 8
                        Layout.bottomMargin: 8
                        spacing: 16

                        ColorIcon {
                            name: "/icons/science.svg"
                            size: 24
                            color: Style.colors.brand_Basic_Icon_accent
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: qsTr("Research data")
                                font: Style.newParagraphFont
                                color: Style.colors.typography_Basic_Default
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                Layout.fillWidth: true
                                text: qsTr("Share anonymized data to support research and system improvements.")
                                font: Style.newSmallFont
                                color: Style.colors.typography_Basic_Default
                                wrapMode: Text.WordWrap
                            }
                        }

                        ConsolinnoSwitch {
                            id: researchDataSwitch
                            checked: cloudConfiguration.researchDataEnabled
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
