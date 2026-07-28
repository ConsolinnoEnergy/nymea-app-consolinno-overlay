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

    function isRemote() {
        if (["hems-demo.consolinno-it.de", ].includes(engine.jsonRpcClient.currentConnection.hostAddress.toString())) {
            return true;
        }
        if (engine.jsonRpcClient.currentConnection.hostAddress.toString().includes("hems-remoteproxy")) {
            return true;
        }
        return false;
    }

    function openLocal(port) {
        if (isRemote()) {
            var dialog = Qt.createComponent(Qt.resolvedUrl("NymeaDialog.qml"));
            var text = qsTr("Only available on the local network. Please connect the device running this app to the same network as your %1 system, e.g. your home network.").arg(Configuration.deviceName);
            var popup = dialog.createObject(app,
                                            {
                                                title: qsTr("Not available"),
                                                text: text
                                            });
            popup.open();
        } else {
            Qt.openUrlExternally("http://" + engine.jsonRpcClient.currentConnection.hostAddress.toString() + ":" + port);
        }
    }

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

            property int clickCounter: 0

            onHeaderClicked: {
                clickCounter++;;
                if (clickCounter >= 10) {
                    settings.showHiddenOptions = !settings.showHiddenOptions;
                    var dialog = Qt.createComponent(Qt.resolvedUrl("NymeaDialog.qml"));
                    var text = settings.showHiddenOptions
                            ? qsTr("Developer options are now enabled. If you have found this by accident, it is most likely not of any use for you. It will just enable some nerdy developer gibberish in the app. Tap the icon another 10 times to disable it again.")
                            : qsTr("Developer options are now disabled.");
                    var popup = dialog.createObject(app,
                                                    {
                                                        title: qsTr("Howdy cowboy!"),
                                                        text: text,
                                                        closePolicy: Popup.NoAutoClose
                                                    });
                    popup.open();
                    clickCounter = 0;
                }
            }

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
                        Qt.openUrlExternally(Configuration.privacyPolicyUrl);
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
                    text: "© %1 %2".arg(new Date().getFullYear()).arg("Consolinno Energy GmbH")
                }

                CoCard {
                    Layout.fillWidth: true
                    interactive: false
                    text: qsTr("Licensed under the terms of the GNU General Public License, version 3.")
                }

                CoCard {
                    Layout.fillWidth: true
                    text: qsTr("Common Licenses")
                    helpText: qsTr("Only available on the local network")
                    iconLeft: Qt.resolvedUrl("/icons/deployed_code.svg")
                    showChildrenIndicator: true
                    onClicked: {
                        openLocal(8083);
                    }
                }

                CoCard {
                    Layout.fillWidth: true
                    text: qsTr("Software and Libraries")
                    helpText: qsTr("Only available on the local network")
                    iconLeft: Qt.resolvedUrl("/icons/deployed_code.svg")
                    showChildrenIndicator: true
                    onClicked: {
                        openLocal(8082);
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
                    text: "© %1 %2".arg(new Date().getFullYear()).arg("Consolinno Energy GmbH")
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
                        Qt.openUrlExternally("https://www.github.com/ConsolinnoEnergy/nymea-app");
                    }
                }

                CoCard {
                    Layout.fillWidth: true
                    text: qsTr("Visit Consolinno-Overlay on GitHub")
                    helpText: "github.com/ConsolinnoEnergy/nymea-app-consolinno-overlay"
                    iconLeft: Qt.resolvedUrl("/icons/language.svg")
                    showChildrenIndicator: true
                    onClicked: {
                        Qt.openUrlExternally("https://www.github.com/ConsolinnoEnergy/nymea-app-consolinno-overlay");
                    }
                }

                CoCard {
                    Layout.fillWidth: true
                    text: qsTr("Software and libraries (App)")
                    helpText: qsTr("View the software and libraries used in this product.")
                    iconLeft: Qt.resolvedUrl("/icons/deployed_code.svg")
                    showChildrenIndicator: true
                    onClicked: {
                        pageStack.push("CoThirdPartyLicensesPage.qml");
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
                        Qt.openUrlExternally("https://www.qt.io");
                    }
                }

                CoCard {
                    Layout.fillWidth: true
                    text: qsTr("Visit the nymea homepage")
                    helpText: "www.nymea.io"
                    iconLeft: Qt.resolvedUrl("/icons/language.svg")
                    showChildrenIndicator: true
                    onClicked: {
                        Qt.openUrlExternally("https://www.nymea.io");
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
                    text: qsTr("<b>%1</b><br>%2<br>%3 %4<br>Tel: %5<br>Mail: %6")
                    .arg(Configuration.companyName)
                    .arg(Configuration.companyAddress)
                    .arg(Configuration.companyZip)
                    .arg(Configuration.companyLocation)
                    .arg(Configuration.companyTel)
                    .arg(Configuration.serviceEmail)
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