import QtQuick 2.5
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"

GenericConfigPage {
    id: root

    readonly property State currentTemperature: root.thing.stateByName("temperatureSensor0")
    readonly property State currentConsumption: root.thing.stateByName("currentPower")
    readonly property State totalConsumption: root.thing.stateByName("totalEnergyConsumed")

    readonly property real operatingModeStatus: 1;

    property Thing thing: null

    title: root.thing.name
    headerOptionsVisible: false

    content: [
        ColumnLayout {
            width: parent.width - Style.margins

            anchors {
                top: parent.top
                topMargin: Style.margins
                horizontalCenter: parent.horizontalCenter
            }

            spacing: Style.margins
            //Disabled for now
            /*
            ColumnLayout {
                visible: true
                Layout.fillWidth: true
                Layout.fillHeight: false
                Layout.preferredHeight: operatingModeValueText.height + toolTipText.height
                spacing: Style.smallMargins

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    spacing: Style.smallMargins
                    visible: false

                    Label {
                        Layout.fillWidth: false
                        Layout.preferredWidth: parent.width * 0.65
                        text: qsTr("Operating Mode (Solar Only)")
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Rectangle {
                            width: 100
                            height: operatingModeValueText.height + 10
                            anchors.right: parent.right
                            radius: 13
                            color: {
                                if(root.operatingModeStatus === 1) {
                                    return "#008000"
                                } else if(root.operatingModeStatus === 2) {
                                    return "#F37B8E"
                                } else {
                                    return "#9B9B9B"
                                }
                            }

                            Label {
                                id: operatingModeValueText
                                Layout.leftMargin: 10
                                anchors.centerIn: parent
                                color: Style.white
                                text: {
                                    if(root.operatingModeStatus === 1) {
                                        return qsTr("Active")
                                    } else if(root.operatingModeStatus === 2) {
                                        return qsTr("Off")
                                    } else {
                                        return qsTr("Not available")
                                    }
                                }
                            }
                        }
                    }
                }

                Label {
                    id: toolTipText
                    Layout.topMargin: 13
                    Layout.fillWidth: true
                    visible: false
                    text: {
                        if(root.operatingModeStatus === 1) {
                            return qsTr("The heating is operated only with solar power.")
                        } else if(root.operatingModeStatus === 2) {
                            return qsTr("The operating mode (Solar Only) is turned off. The settings can be changed in the optimization settings.")
                        } else {
                            return qsTr("The operating mode (Solar Only) is not available because a charging process is currently being prioritized.")
                        }
                    }
                    font: Style.smallFont
                    wrapMode: Text.WordWrap
                    color: Configuration.iconColor
                }
            }*/

            ConsolinnoRowLabelValue {
                Layout.fillWidth: true
                Layout.topMargin: 25
                label: qsTr("Current Temperature")
                value: (root.currentTemperature === null) ? 0 : (+root.currentTemperature.value).toLocaleString() + qsTr(" °C")
                visible: root.currentTemperature
            }

            ConsolinnoRowLabelValue {
                Layout.fillWidth: true
                Layout.topMargin: 25
                label: qsTr("Current Consumption")
                value: (+root.currentConsumption.value).toLocaleString() + qsTr(" W")
            }

            ConsolinnoRowLabelValue {
                Layout.fillWidth: true

                label: qsTr("Total Consumption")
                value: (+root.totalConsumption.value.toFixed(2)).toLocaleString() + qsTr(" kWh")
            }
        }
    ]
}
