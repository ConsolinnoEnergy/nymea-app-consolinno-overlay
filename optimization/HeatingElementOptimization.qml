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
    property HeatingElementConfiguration heatingElementConfiguration
    property Thing heatPumpThing
    property int directionID: 0

    header: NymeaHeader {
        text: qsTr("Heating Element Configuration")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onSetHeatingElementConfigurationReply: {

            if (commandId === d.pendingCallId) {
                d.pendingCallId = -1
                switch (error) {
                case "HemsErrorNoError":
                    pageStack.pop()
                    return
                case "HemsErrorInvalidParameter":
                    props.text = qsTr(
                                "Could not save configuration. One of the parameters is invalid.")
                    break
                case "HemsErrorInvalidThing":
                    props.text = qsTr(
                                "Could not save configuration. The thing is not valid.")
                    break
                default:
                    props.errorCode = error
                }
                var comp = Qt.createComponent("../components/ErrorDialog.qml")
                var popup = comp.createObject(app, props)
                popup.open()
            }
        }
    }

    ColumnLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: Style.margins
            leftMargin: Style.margins
            rightMargin: Style.margins
        }

        ConsolinnoPVTextField {
            id: maxPowerInput

            Layout.fillWidth: true
            Layout.fillHeight: false
            label: qsTr("Max power")
            text: typeof heatingElementConfiguration.maxElectricalPower !== "null" ? "3,00" : heatingElementConfiguration.maxElectricalPower.toLocaleString(Qt.locale())
            unit: qsTr("kW")

            validator: DoubleValidator {
                bottom: 1
            }
        }

        ConsolinnoSwitchDelegate {
            id: operatingModeSwitch

            Layout.fillWidth: true
            text: qsTr("Operating mode (Solar Only)")
            warningText: qsTr("The heater is operated only with solar power. If a wallbox is connected to the system, and a charging process is started, charging is prioritized.")
        }

        //margins filler
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: Style.bigMargins
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Ok")

            onClicked: {
                if (directionID === 1) {

                    if (Number.fromLocaleString(Qt.locale(),
                                                maxPowerInput.text) !== 0) {

                        header.text = maxPowerInput.text
                        hemsManager.setHeatingElementConfiguration(heatPumpThing.id, {
                                                                       "maxElectricalPower": Number.fromLocaleString(
                                                                                       Qt.locale(),
                                                                                       maxPowerInput.text),
                                                                       "optimizationEnabled": operatingModeSwitch.checked,
                                                                   })
                        root.done()
                    } else {
                    }
                } else if (directionID === 0) {
                    if (Number.fromLocaleString(Qt.locale(),
                                                maxPowerInput.text) !== 0) {

                        d.pendingCallId = hemsManager.setHeatingElementConfiguration(
                                    heatPumpThing.id, {
                                        "maxElectricalPower": Number.fromLocaleString(
                                                        Qt.locale(),
                                                        maxPowerInput.text),
                                        "optimizationEnabled": operatingModeSwitch.checked,
                                    })
                    }
                }
            }
        }
    }
}
