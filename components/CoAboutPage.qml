import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import "../components"

SettingsPageBase {
    id: root
    headerText: qsTr("About %1").arg(Configuration.systemName)

    // #TODO
    // - multi click for dev mode
    // - Hide flickable scrollbar (not only on this screen)

    ColumnLayout {
        id: layout
        Layout.fillWidth: true
        Layout.margins: Style.margins
        spacing: Style.margins

        CoFrostyCard {
            id: systemGroup
            Layout.fillWidth: true
            headerText: qsTr("System")
            contentTopMargin: Style.smallMargins

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                CoCard {
                    Layout.fillWidth: true
                    text: engine.systemController.deviceSerialNumber
                    labelText: qsTr("Serial number")
                    iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                    iconRightColor: Style.colors.brand_Basic_Accent
                    visible: engine.systemController.deviceSerialNumber.length > 0
                    onClicked: {
                        PlatformHelper.toClipBoard(text);
                        ToolTip.show(qsTr("%1 copied to clipboard").arg(labelText), 1000);
                    }
                }

                CoCard {
                    Layout.fillWidth: true
                    text: engine.jsonRpcClient.serverUuid
                    labelText: qsTr("Server UUID")
                    iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                    iconRightColor: Style.colors.brand_Basic_Accent
                    onClicked: {
                        PlatformHelper.toClipBoard(text);
                        ToolTip.show(qsTr("%1 copied to clipboard").arg(labelText), 1000);
                    }
                }

                CoCard {
                    Layout.fillWidth: true
                    text: engine.jsonRpcClient.currentConnection.url
                    labelText: qsTr("Connection")
                    interactive: false
                }
            }
        }

        CoFrostyCard {
            id: softwareVersionsGroup
            Layout.fillWidth: true
            headerText: qsTr("Software versions")
            contentTopMargin: Style.smallMargins

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                CoCard {
                    Layout.fillWidth: true
                    text: engine.jsonRpcClient.experiences.Hems
                    labelText: qsTr("%1 (Device)").arg(Configuration.systemName)
                    iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                    iconRightColor: Style.colors.brand_Basic_Accent
                    onClicked: {
                        PlatformHelper.toClipBoard(text);
                        ToolTip.show(qsTr("%1 copied to clipboard").arg(labelText), 1000);
                    }
                }

                CoCard {
                    Layout.fillWidth: true
                    text: appVersion + " (" + appRevision + ")"
                    labelText: qsTr("%1 (App)").arg(Configuration.systemName)
                    iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                    iconRightColor: Style.colors.brand_Basic_Accent
                    onClicked: {
                        PlatformHelper.toClipBoard(text);
                        ToolTip.show(qsTr("%1 copied to clipboard").arg(labelText), 1000);
                    }
                }

                CoCard {
                    Layout.fillWidth: true
                    text: engine.jsonRpcClient.serverVersion
                    labelText: qsTr("Server")
                    interactive: false
                }

                CoCard {
                    Layout.fillWidth: true
                    text: engine.jsonRpcClient.jsonRpcVersion
                    labelText: qsTr("JSON RPC")
                    interactive: false
                }

                CoCard {
                    Layout.fillWidth: true
                    text: engine.jsonRpcClient.serverQtVersion + (engine.jsonRpcClient.serverQtVersion !== engine.jsonRpcClient.serverQtBuildVersion ? " (" + qsTr("Built with %1").arg(engine.jsonRpcClient.serverQtBuildVersion) + ")" : "")
                    labelText: qsTr("Qt (Device)")
                    interactive: false
                }

                CoCard {
                    Layout.fillWidth: true
                    text: qtVersion
                    labelText: qsTr("Qt (App)")
                    interactive: false
                }
            }
        }

        CoFrostyCard {
            id: privacyPolicyGroup
            Layout.fillWidth: true
            headerText: qsTr("Privacy")
            contentTopMargin: Style.smallMargins

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                CoCard {
                    Layout.fillWidth: true
                    text: qsTr("Show privacy policy")
                    helpText: Configuration.privacyPolicyUrl
                    iconLeft: Qt.resolvedUrl("/icons/language.svg")
                    showChildrenIndicator: true
                    onClicked: {
                        Qt.openUrlExternally(Configuration.privacyPolicyUrl)
                    }
                }
            }
        }

        CoFrostyCard {
            id: deviceLicensesGroup
            Layout.fillWidth: true
            headerText: qsTr("Licenses (Device)")
            contentTopMargin: Style.smallMargins

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                CoCard {
                    Layout.fillWidth: true
                    interactive: false
                    text: "Copyright (C) %1 %2".arg(new Date().getFullYear()).arg("Consolinno Energy GmbH") // #TODO copyright C (cf. design)
                }

                CoCard {
                    Layout.fillWidth: true
                    interactive: false
                    text: qsTr("Licensed under the terms of the GNU General Public License, version 3. Please visit the GitHub page for source code and build instructions.")
                }

                // #TODO Github page?
                CoCard {
                    Layout.fillWidth: true
                    text: qsTr("Visit GitHub page")
                    helpText: "github.com/ConsolinnoEnergy/nymea-app"
                    iconLeft: Qt.resolvedUrl("/icons/language.svg")
                    showChildrenIndicator: true
                    onClicked: {
                        Qt.openUrlExternally("https://www.github.com/ConsolinnoEnergy/nymea-app")
                    }
                }

                CoCard {
                    Layout.fillWidth: true
                    text: qsTr("Software and libraries (Device)")
                    helpText: qsTr("View the software and libraries used in this product.")
                    iconLeft: Qt.resolvedUrl("/icons/deployed_code.svg")
                    showChildrenIndicator: true
                    onClicked: {
                        // #TODO
                    }
                }
            }
        }

        CoFrostyCard {
            id: appLicensesGroup
            Layout.fillWidth: true
            headerText: qsTr("Licenses (App)")
            contentTopMargin: Style.smallMargins

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                CoCard {
                    Layout.fillWidth: true
                    interactive: false
                    text: "Copyright (C) %1 %2".arg(new Date().getFullYear()).arg("Consolinno Energy GmbH") // #TODO copyright C (cf. design)
                }

                CoCard {
                    Layout.fillWidth: true
                    interactive: false
                    text: qsTr("Licensed under the terms of the GNU General Public License, version 3. Please visit the GitHub page for source code and build instructions.")
                }

                CoCard {
                    Layout.fillWidth: true
                    text: qsTr("Visit GitHub page")
                    helpText: "github.com/ConsolinnoEnergy/nymea-app"
                    iconLeft: Qt.resolvedUrl("/icons/language.svg")
                    showChildrenIndicator: true
                    onClicked: {
                        Qt.openUrlExternally("https://www.github.com/ConsolinnoEnergy/nymea-app")
                    }
                }

                CoCard {
                    Layout.fillWidth: true
                    text: qsTr("Visit Consolinno-Overlay on GitHub")
                    helpText: "github.com/ConsolinnoEnergy/nymea-app-consolinno-overlay"
                    iconLeft: Qt.resolvedUrl("/icons/language.svg")
                    showChildrenIndicator: true
                    onClicked: {
                        Qt.openUrlExternally("https://www.github.com/ConsolinnoEnergy/nymea-app-consolinno-overlay")
                    }
                }

                CoCard {
                    Layout.fillWidth: true
                    text: qsTr("Software and libraries (App)")
                    helpText: qsTr("View the software and libraries used in this product.")
                    iconLeft: Qt.resolvedUrl("/icons/deployed_code.svg")
                    showChildrenIndicator: true
                    onClicked: {
                        // #TODO
                    }
                }
            }
        }

        CoFrostyCard {
            id: furtherInfoGroup
            Layout.fillWidth: true
            headerText: qsTr("Further information")
            contentTopMargin: Style.smallMargins

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                CoCard {
                    Layout.fillWidth: true
                    interactive: false
                    text: qsTr("This application uses Qt (https://www.qt.io), Copyright (C) The Qt Company Ltd., licensed under the GNU Lesser General Public License v3.")
                }

                CoCard {
                    Layout.fillWidth: true
                    interactive: false
                    text: qsTr("Qt is a registered trademark of The Qt Company Ltd. and its subsidiaries.")
                }

                CoCard {
                    Layout.fillWidth: true
                    text: qsTr("Visit the Qt homepage")
                    helpText: "www.qt.io"
                    iconLeft: Qt.resolvedUrl("/icons/language.svg")
                    showChildrenIndicator: true
                    onClicked: {
                        Qt.openUrlExternally("https://www.qt.io")
                    }
                }

                CoCard {
                    Layout.fillWidth: true
                    text: qsTr("Visit the nymea homepage")
                    helpText: "www.nymea.io"
                    iconLeft: Qt.resolvedUrl("/icons/language.svg")
                    showChildrenIndicator: true
                    onClicked: {
                        Qt.openUrlExternally("https://www.nymea.io")
                    }
                }
            }
        }

        CoFrostyCard {
            id: sourceCodeGroup
            Layout.fillWidth: true
            headerText: qsTr("Source code availability")
            contentTopMargin: Style.smallMargins

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                CoCard {
                    Layout.fillWidth: true
                    interactive: false
                    text: qsTr("Anyone can obtain the source code of these software components from us on a data carrier (CD-ROM, DVD or USB stick) if a request is made to our customer service department at the following address within three years after delivery of the product to the customer or as long as we offer spare parts or support for the product:")
                }

                CoCard {
                    Layout.fillWidth: true
                    interactive: false
                    text: `${Configuration.companyName}\r\n${Configuration.companyAddress}\r\n${Configuration.companyZip} ${Configuration.companyLocation}\r\nTel: ${Configuration.companyTel}\r\nMail: ${Configuration.serviceEmail}`
                }

                CoCard {
                    Layout.fillWidth: true
                    interactive: false
                    text: qsTr("Please provide the following product data:")
                }

                CoCard {
                    Layout.fillWidth: true
                    interactive: false
                    text: qsTr("- Product name\r\n- Software version\r\n- Serial number - if known")
                }

                CoCard {
                    Layout.fillWidth: true
                    interactive: false
                    text: qsTr("and transfer an amount of money in advance, based on the information provided by the support, to cover the costs of creating and sending the disk. Alternatively, the source code can be downloaded free of charge.")
                }
            }
        }
    }
}