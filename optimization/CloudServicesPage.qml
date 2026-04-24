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
