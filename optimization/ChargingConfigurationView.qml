import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root

    property HemsManager hemsManager

    header: NymeaHeader {
        text: qsTr("Charging")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins

        Repeater {
            model: hemsManager.chargingConfigurations
            delegate: NymeaItemDelegate {

                property ChargingConfiguration chargingConfiguration: hemsManager.chargingConfigurations.getChargingConfiguration(model.evChargerThingId)
                property Thing evChargerThing: engine.thingManager.things.getThing(model.evChargerThingId)

                Layout.fillWidth: true
                iconName:  "../images/ev-charger.svg"
                progressive: true
                text: evChargerThing.name
                onClicked: pageStack.push(chargingConfigurationComponent, { hemsManager: hemsManager, chargingConfiguration: chargingConfiguration, evChargerThing: evChargerThing })
            }
        }
    }


    Component {
        id: chargingConfigurationComponent

        Page {
            id: root
            property HemsManager hemsManager
            property ChargingConfiguration chargingConfiguration
            property Thing evChargerThing

            // TODO: only if any configuration has changed, warn also on leaving if unsaved settings
            //property bool configurationSettingsChanged

            header: NymeaHeader {
                text: qsTr("Charging configuration")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: app.margins

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: evChargerThing.name
                    wrapMode: Text.WordWrap
                    //font.pixelSize: app.smallFont
                }


                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Electic car Id:")
                    }

                    Label {

                        text: chargingConfiguration.carThingId
                        Layout.rightMargin: app.margins
                    }


                }


                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Optimization enabled")
                    }

                    Switch {
                        id: optimizationEnabledSwitch
                        Component.onCompleted: checked = chargingConfiguration.optimizationEnabled
                    }
                }

//                Button {
//                    id: assignCar
//                    Layout.fillWidth: true
//                    // We only need to assign a hear meter if this heatpump does not provide one
//                    visible: chargingConfiguration.carThingId === "{00000000-0000-0000-0000-000000000000}"
//                    text: qsTr("TODO: Assign car")
//                    // TODO: Select or setup car from the things and show it here. Allow to reassign a car, remove assignment, edit car
//                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Target state of charge %1%").arg(targetPercentageSlider.value)
                }

                Slider {
                    id: targetPercentageSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    stepSize: 1
                    Component.onCompleted: {
                        value = chargingConfiguration.targetPercentage
                    }
                }

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Target time to reach target percentage")
                }

                Rectangle {
                    id: timePicker
                    width: frame.implicitWidth + 10
                    height: frame.implicitHeight + 10
                    Layout.alignment: Qt.AlignHCenter

                    function formatText(count, modelData) {
                        var data = count === 12 ? modelData + 1 : modelData;
                        return data.toString().length < 2 ? "0" + data : data;
                    }

                    FontMetrics {
                        id: fontMetrics
                        font.pixelSize: app.mediumFont
                    }

                    Component {
                        id: delegateComponent

                        Label {
                            text: timePicker.formatText(Tumbler.tumbler.count, modelData)
                            opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: fontMetrics.font.pixelSize * 1.25
                        }
                    }

                    Frame {
                        id: frame
                        padding: 0
                        anchors.centerIn: parent

                        Row {
                            Tumbler {
                                id: hoursTumbler
                                model: 24
                                delegate: delegateComponent
                                visibleItemCount: 4
                            }

                            Tumbler {
                                id: minutesTumbler
                                model: 60
                                delegate: delegateComponent
                                visibleItemCount: 4
                            }
                        }
                    }
                }


                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Zero return policy")
                    }

                    Switch {
                        id: zeroRetrunPolicyEnabledSwitch
                        Component.onCompleted: checked = chargingConfiguration.zeroReturnPolicyEnabled
                    }
                }

                Item {
                    // place holder
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Save")
                    //enabled: configurationSettingsChanged
                    onClicked: {
                        // TODO: wait for response
                        hemsManager.setChargingConfiguration(chargingConfiguration.evChargerThingId, optimizationEnabledSwitch.checked, chargingConfiguration.carThingId, hoursTumbler.currentIndex, minutesTumbler.currentIndex , chargingConfiguration.targetPercentage, chargingConfiguration.zeroReturnPolicyEnabled)
                    }
                }
            }
        }
    }
}
