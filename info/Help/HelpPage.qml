import QtQuick
import QtQuick.Controls
import QtQml
import Nymea
import QtQuick.Layouts

import "../../components"


Page {
    id: root
    bottomPadding: 0
    property int navigationFooterHeight: 0

    header: null

    CoHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        blurSource: bodyFlickable
        text: qsTr("Help")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    property UserConfiguration userconfig: hemsManager.userConfigurations.getUserConfiguration("528b3820-1b6d-4f37-aea7-a99d21d42e72")

    Flickable {
        id: bodyFlickable
        anchors.fill: parent
        topMargin: header.height
        clip: true
        contentHeight: contentColumn.implicitHeight +
                       contentColumn.anchors.topMargin +
                       contentColumn.anchors.bottomMargin + root.navigationFooterHeight

        Component.onCompleted: Qt.callLater(() => contentY = -topMargin)

        ColumnLayout{
            id: contentColumn
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: Style.margins
            spacing: Style.margins

            CoFrostyCard {
                id: manualGroup
                Layout.fillWidth: true
                contentTopMargin: 8
                headerText: qsTr("Manual")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoCard {
                        Layout.fillWidth: true
                        text: qsTr("Download current manuals for %1 from our website.").arg(Configuration.deviceName)
                        iconLeft: Qt.resolvedUrl("/icons/language.svg")
                        showChildrenIndicator: true
                        onClicked: Qt.openUrlExternally(Configuration.downloadMedia)
                    }
                }
            }

            CoFrostyCard {
                id: installerGroup
                Layout.fillWidth: true
                contentTopMargin: 8
                headerText: qsTr("Installer contact")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoCard {
                        Layout.fillWidth: true
                        visible: !noInstallerCard.visible
                        text: qsTr("If you have any problems with your system, please contact your installer:")
                        showChildrenIndicator: false
                        interactive: false
                    }

                    CoCard {
                        id: noInstallerCard
                        Layout.fillWidth: true
                        visible: userconfig.installerName === "" &&
                                 userconfig.installerWorkplace === "" &&
                                 userconfig.installerEmail === "" &&
                                 userconfig.installerPhoneNr === ""
                        text: qsTr("No installer specified")
                        showChildrenIndicator: false
                        interactive: false
                    }

                    CoCard {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: root.userconfig.installerName
                        showChildrenIndicator: false
                        interactive: false
                    }

                    CoCard {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: userconfig.installerWorkplace
                        showChildrenIndicator: false
                        interactive: false
                    }

                    CoCard {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: userconfig.installerEmail
                        iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                        iconRightColor: Style.colors.brand_Basic_Accent
                        showChildrenIndicator: false
                        interactive: true
                        onClicked: {
                            PlatformHelper.toClipBoard(userconfig.installerEmail);
                            ToolTip.show(qsTr("E-Mail address copied to clipboard"), 1000);
                        }
                    }

                    CoCard {
                        Layout.fillWidth: true
                        visible: text !== ""
                        text: userconfig.installerPhoneNr
                        iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                        iconRightColor: Style.colors.brand_Basic_Accent
                        showChildrenIndicator: false
                        interactive: true
                        onClicked: {
                            PlatformHelper.toClipBoard(userconfig.installerPhoneNr);
                            ToolTip.show(qsTr("Phone number copied to clipboard"), 1000);
                        }
                    }
                }
            }

            CoFrostyCard {
                id: serviceGroup
                Layout.fillWidth: true
                contentTopMargin: 8
                headerText: qsTr("%1 service").arg(Configuration.appBranding)

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoCard {
                        Layout.fillWidth: true
                        text: qsTr("If there is a problem with %1 itself, please refer to our service address:").arg(Configuration.deviceName)
                        showChildrenIndicator: false
                        interactive: false
                    }

                    CoCard {
                        Layout.fillWidth: true
                        text: Configuration.serviceEmail
                        iconRight: Qt.resolvedUrl("/icons/file_copy.svg")
                        iconRightColor: Style.colors.brand_Basic_Accent
                        showChildrenIndicator: false
                        interactive: true
                        onClicked: {
                            PlatformHelper.toClipBoard(Configuration.serviceEmail);
                            ToolTip.show(qsTr("Service address copied to clipboard"), 1000);
                        }
                    }
                }
            }
        }
    }
}
