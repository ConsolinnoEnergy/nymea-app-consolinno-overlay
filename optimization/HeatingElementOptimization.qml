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
    property Thing heatRodThing
    property int directionID: 0
    signal done()

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
                let props = "";
                switch (error) {
                case "HemsErrorNoError":
                    pageStack.pop()
                    return
                case "HemsErrorInvalidParameter":
                    props.text = qsTr("Could not save configuration. One of the parameters is invalid.")
                    break
                case "HemsErrorInvalidThing":
                    props.text = qsTr("Could not save configuration. The thing is not valid.")
                    break
                default:
                    props.errorCode = error
                }
                var comp = Qt.createComponent("../components/ErrorDialog.qml")
                var popup = comp.createObject(app, {props})
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
            property bool maxElectricalPower_validated
            Layout.fillWidth: true
            Layout.fillHeight: false
            label: qsTr("Max power")
            text: (+heatingElementConfiguration.maxElectricalPower).toLocaleString()
            unit: qsTr("kW")

            validator: DoubleValidator {
                bottom: 1
            }

            onTextChanged: acceptableInput ? maxElectricalPower_validated = true : maxElectricalPower_validated = false

        }

        ConsolinnoSwitchDelegate {
            id: operatingModeSwitch
            checked: heatingElementConfiguration.optimizationEnabled
            Layout.fillWidth: true
            text: qsTr("Operating mode (Solar Only)")
            warningText: operatingModeSwitch.checked ? qsTr("The heater is operated only with solar power. If a wallbox is connected to the system, and a charging process is started, charging is prioritized.") : qsTr("The heating element is not controlled by the HEMS.")
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
            property bool validated: maxPowerInput.maxElectricalPower_validated

            onClicked: {
                let inputText = maxPowerInput.text
                inputText.includes(",") === true ? inputText = inputText.replace(",",".") : inputText
                if (directionID === 1) {
                    if (validated) {
                        d.pendingCallId = hemsManager.setHeatingElementConfiguration(heatRodThing.id, { "maxElectricalPower": parseFloat(inputText), "optimizationEnabled": operatingModeSwitch.checked, controllableLocalSystem: false})
                        root.done()
                    }else{
                        let props = "";
                        props = qsTr("Could not save configuration. One of the parameters is invalid.")
                        var comp = Qt.createComponent("../components/ErrorDialog.qml")
                        var popup = comp.createObject(app, {props})
                        popup.open()
                    }
                } else if (directionID === 0) {
                    if (validated) {
                        d.pendingCallId = hemsManager.setHeatingElementConfiguration( heatRodThing.id, { "maxElectricalPower": parseFloat(inputText), "optimizationEnabled": operatingModeSwitch.checked, controllableLocalSystem: false})
                    }
                }
            }
        }
    }
}
