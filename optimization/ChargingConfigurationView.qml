import QtQuick 2.12
import QtQuick.Controls 2.4
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
                    id: endTimeLabel
                    Layout.fillWidth: true
                    property var today: new Date()
                    property var endTime: new Date(today.getTime() + endTimeSlider.value * 60000)
                    property var feasibility
                    text: "End of the charging time: " + endTime.toLocaleString(Qt.locale("de-DE"), "dd/MM HH:mm") + "  Feasible: " + feasibility

                    function endTimeValidityPrediction(d){
                        // TODO: write validator to determine if something is feasible or not

                        switch (d){
                        case 1:
                            feasibility =  "  <font color=\"red\">not feasible</font>"
                            break
                        case 2:
                            feasibility = "  <font color=\"lightgreen\">probably feasible</font>"
                            break
                        case 3:
                            feasibility = "  <font color=\"darkgreen\">feasible</font>"
                            break
                        }

                        return


                    }


                }


                RowLayout {
                    Layout.fillWidth: true

                    Slider {
                        id: endTimeSlider
                        property int chargingConfigHours: Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime , "HH:mm:ss").getHours()
                        property int chargingConfigMinutes: Date.fromLocaleString(Qt.locale("de-DE"), chargingConfiguration.endTime , "HH:mm:ss").getMinutes()
                        property int nextDay: chargingConfigHours*60 + chargingConfigMinutes - endTimeLabel.today.getHours()*60 - endTimeLabel.today.getMinutes() < 0 ? 1 : 0
                        Layout.fillWidth: true
                        from: 0
                        to: 24*60
                        stepSize: 1
                        //         von config hours      von config minutes         current hours                    current minutes                 add a day if negative (since it means it is the next day)
                        value: chargingConfigHours*60 + chargingConfigMinutes - endTimeLabel.today.getHours()*60 - endTimeLabel.today.getMinutes() + nextDay*24*60

                        onPositionChanged: {
                            if (value < 60){
                                endTimeLabel.endTimeValidityPrediction(1)
                            }
                            else if (value >= 60 & value < 150) {
                                endTimeLabel.endTimeValidityPrediction(2)
                            }
                            else{
                                endTimeLabel.endTimeValidityPrediction(3)
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


                        // Maintool to debug
                        //footer.text = chargingConfiguration.endTime

                        // TODO: wait for response
                        d.pendingCallId = hemsManager.setChargingConfiguration(chargingConfiguration.evChargerThingId  , optimizationEnabledSwitch.checked, comboboxev.model.get(comboboxev.currentIndex).id,  parseInt(endTimeLabel.endTime.getHours()) , parseInt( endTimeLabel.endTime.getMinutes()) , targetPercentageSlider.value, zeroRetrunPolicyEnabledSwitch.checked)





                    }

                }
            }
        }
    }
}
