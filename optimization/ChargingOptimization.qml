import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material 2.12

import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"
Page {
    id: root
    header: NymeaHeader {
        text: qsTr("Charging optimization")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ThingsProxy {
        id: ev_chargerProxy
        engine: _engine
        shownInterfaces: ["evcharger"]
    }

    property HemsManager hemsManager
    //TODO: built a page where every possible option is displayed (Similar to AddGenericCar I think)
    // Note there could be multiple Wallboxes, so we need to make it for every Wallbox

    Flickable{
        id: wallboxflickable
        clip: true
        anchors.fill: parent
        contentHeight: wallboxRepeaterColumLayout.height + header.height
        contentWidth: app.width



        flickableDirection: Flickable.VerticalFlick

        ColumnLayout{
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: app.margins
            anchors.margins: app.margins




            ColumnLayout{
                id: wallboxRepeaterColumLayout
                Layout.fillWidth: true

                Repeater{
                    id: wallboxRepeater
                    model: ev_chargerProxy
                    delegate: ColumnLayout{
                        Layout.fillWidth: true

                        property ChargingOptimizationConfiguration chargingOptimizationconfig: hemsManager.chargingOptimizationConfigurations.getChargingOptimizationConfiguration(ev_chargerProxy.get(index).id)

                        Label{
                            Layout.fillWidth: true
                            text: model.name + ":"
                            color: Material.accent

                        }


                        RowLayout{
                            Layout.fillWidth: true
                            Label{
                                Layout.fillWidth: true
                                text: qsTr("Reenable chargepoint:")
                            }

                            Switch{
                                id: reenableChargePointSwitch
                                checked: chargingOptimizationconfig.reenableChargepoint
                            }

                        }


                        RowLayout{
                            Label{
                                Layout.fillWidth: true
                                text: qsTr("P value:")
                            }


                            TextField {
                                id: pvalue
                                Layout.minimumWidth: 55
                                Layout.maximumWidth: 55
                                text: (+chargingOptimizationconfig.p_value).toLocaleString()
                                validator: DoubleValidator{
                                    bottom: -180
                                    top: 180
                                    decimals: 4
                                }
                            }
                        }

                        RowLayout{
                            Label{
                                Layout.fillWidth: true
                                text: qsTr("I value:")

                            }


                            TextField {
                                id: ivalue
                                Layout.minimumWidth: 55
                                Layout.maximumWidth: 55
                                text: (+chargingOptimizationconfig.i_value).toLocaleString()
                                validator: DoubleValidator{
                                    bottom: -180
                                    top: 180
                                    decimals: 4
                                }

                            }
                        }

                        RowLayout{
                            Label{
                                Layout.fillWidth: true
                                text: qsTr("D value:")
                            }


                            TextField {
                                id: dvalue
                                Layout.minimumWidth: 55
                                Layout.maximumWidth: 55
                                text: (+chargingOptimizationconfig.d_value).toLocaleString()
                                validator: DoubleValidator{
                                    bottom: -180
                                    top: 180
                                    decimals: 4
                                }
                            }
                        }

                        RowLayout{
                            Label{
                                Layout.fillWidth: true
                                text: qsTr("Setpoint:")
                            }


                            TextField {
                                id: setpoint
                                Layout.margins: app.margins
                                Layout.minimumWidth: 55
                                Layout.maximumWidth: 55
                                text: chargingOptimizationconfig.setpoint
                                validator: DoubleValidator{
                                    bottom: -180
                                    top: 180
                                    decimals: 4
                                }
                            }
                        }

                        Button{
                            id: testingButton
                            Layout.fillWidth: true
                            text: qsTr("Configure: " + model.name )
                            onClicked: {

                                hemsManager.setChargingOptimizationConfiguration(ev_chargerProxy.get(index).id, {reenableChargepoint: reenableChargePointSwitch.checked, p_value: pvalue.text, i_value: ivalue.text, d_value: dvalue.text, setpoint: setpoint.text })
                            }
                        }

                    }

                }

            }

        }

    }

}
