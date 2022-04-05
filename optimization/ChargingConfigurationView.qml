import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtQml 2.2
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



            QtObject {
                id: d
                property int pendingCallId: -1
            }


            Connections {
                target: hemsManager
                onSetChargingConfigurationReply: {
                    if (commandId == d.pendingCallId) {
                        d.pendingCallId = -1

                        switch (error) {
                        case "HemsErrorNoError":
                            pageStack.pop()
                            return;
                        case "HemsErrorInvalidParameter":
                            props.text = qsTr("Could not save configuration. One of the parameters is invalid.");
                            break;
                        case "HemsErrorInvalidThing":
                            props.text = qsTr("Could not save configuration. The thing is not valid.");
                            break;
                        default:
                            props.errorCode = error;
                        }
                        var comp = Qt.createComponent("../components/ErrorDialog.qml")
                        var popup = comp.createObject(app, props)
                        popup.open();
                    }
                }
             }




            ColumnLayout {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: app.margins
                anchors.margins: app.margins

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: evChargerThing.name
                    wrapMode: Text.WordWrap
                }

                RowLayout {
                    Layout.fillWidth: true


                    Label {
                        id: evLabelid
                        Layout.fillWidth: true
                        text: qsTr("Electric car:")


                    }

                    ComboBox {
                        id: comboboxev
                        Layout.fillWidth: true
                        model: ThingsProxy {
                            id: evProxy
                            engine: _engine
                            shownInterfaces: ["electricvehicle"]
                        }

                        textRole: "name"
                        currentIndex: evProxy.indexOf(evProxy.getThing(chargingConfiguration.carThingId ))



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
                                // ChargingConfiguration.endTime example always looks like this: "05:30" (not necessarly this time)
                                currentIndex: parseInt(chargingConfiguration.endTime[0] + chargingConfiguration.endTime[1])
                                model: 24

                                delegate: delegateComponent
                                visibleItemCount: 4
                            }
                            Tumbler {
                                id: minutesTumbler
                                model: 60
                                currentIndex: parseInt(chargingConfiguration.endTime[3] + chargingConfiguration.endTime[4])
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

                Label {
                    id: footer
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    wrapMode: Text.WordWrap
                    font.pixelSize: app.smallFont

                }

                Button {
                    id: savebutton
                    Layout.fillWidth: true
                    text: qsTr("Save")
                    //enabled: configurationSettingsChanged
                    onClicked: {


                        //footer.text = comboboxev.currentIndex
                        // TODO: wait for response
                        d.pendingCallId = hemsManager.setChargingConfiguration(chargingConfiguration.evChargerThingId  , optimizationEnabledSwitch.checked, comboboxev.model.get(comboboxev.currentIndex).id, hoursTumbler.currentIndex, minutesTumbler.currentIndex , targetPercentageSlider.value, zeroRetrunPolicyEnabledSwitch.checked)
                    }
                }
            }
        }
    }
}
