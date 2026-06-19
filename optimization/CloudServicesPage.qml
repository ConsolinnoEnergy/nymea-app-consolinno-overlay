import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0

import "../components"

Page {
    id: root
    bottomPadding: 0
    property int navigationFooterHeight: 0

    property CloudConfiguration cloudConfiguration: hemsManager.cloudConfiguration

    header: null

    CoHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        blurSource: bodyFlickable
        text: qsTr("Consolinno Cloud Services")
        subText: qsTr("(Beta)")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    Flickable {
        id: bodyFlickable
        anchors.fill: parent
        topMargin: header.height
        contentHeight: layout.implicitHeight + layout.anchors.topMargin + layout.anchors.bottomMargin + root.navigationFooterHeight
        clip: true
        Component.onCompleted: Qt.callLater(() => contentY = -topMargin)

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

            CoFrostyCard {
                Layout.fillWidth: true
                headerText: qsTr("Connection")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoCard {
                        Layout.fillWidth: true
                        text: cloudConfiguration.mqttConnected ? qsTr("Connected") : qsTr("Not connected")
                        labelText: qsTr("Status")
                        status: cloudConfiguration.mqttConnected ?
                                    CoCard.StatusType.Success :
                                    CoCard.StatusType.Neutral
                    }
                }
            }

            CoFrostyCard {
                Layout.fillWidth: true
                headerText: qsTr("Consent")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoSwitch {
                        id: cloudEnabledSwitch
                        Layout.fillWidth: true
                        text: qsTr("Activate Consolinno Cloud Services")
                        helpText: qsTr("Activates the connection to our cloud services. Only the selected release categories will be shared.")
                        infoUrl: "CloudServicesActivateInfo.qml"
                        checked: cloudConfiguration.cloudEnabled

                        onToggled: {
                            hemsManager.setCloudConfiguration({"cloudEnabled": checked});
                        }
                    }

                    CoCard {
                        Layout.fillWidth: true
                        iconLeft: Qt.resolvedUrl("/icons/cookie.svg")
                        text: qsTr("More about data processing and privacy")
                        showChildrenIndicator: true
                        labelText: Configuration.privacyPolicyUrl

                        onClicked: {
                            Qt.openUrlExternally(Configuration.privacyPolicyUrl);
                        }
                    }
                }
            }

            CoFrostyCard {
                Layout.fillWidth: true
                headerText: qsTr("Release categories")
                enabled: cloudConfiguration.cloudEnabled

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoSwitch {
                        id: energyMonitoringSwitch
                        Layout.fillWidth: true
                        text: qsTr("Energy Monitoring")
                        helpText: qsTr("Shares consumption and production data for accurate energy analysis.")
                        infoUrl: "EnergyMonitoringInfo.qml"
                        checked: cloudConfiguration.energyMonitoringEnabled

                        onToggled: {
                            hemsManager.setCloudConfiguration({ "energyMonitoringEnabled": checked });
                        }
                    }

                    CoSwitch {
                        id: researchDataSwitch
                        Layout.fillWidth: true
                        text: qsTr("Anonymized usage data")
                        helpText: qsTr("Shares fully anonymized data for research and product improvement.")
                        infoUrl: "AnonymizedUsageDataInfo.qml"
                        checked: cloudConfiguration.researchDataEnabled

                        onToggled: {
                            hemsManager.setCloudConfiguration({ "researchDataEnabled": checked });
                        }
                    }
                }
            }
        }
    }
}
