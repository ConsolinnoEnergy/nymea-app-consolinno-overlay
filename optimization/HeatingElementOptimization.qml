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
                    footer.text = qsTr("Some attributes are outside of the allowed range: Configurations were not saved.")
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
        anchors.fill: parent
        anchors.margins: app.margins

        RowLayout{
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: qsTr("Maximal electrical power")
            }


            TextField {
                id: maxPowerInput
                property bool maxElectricalPower_validated
                Layout.preferredWidth: 60
                Layout.rightMargin: 8
                text: (+heatingElementConfiguration.maxElectricalPower).toLocaleString()
                maximumLength: 10
                validator: DoubleValidator{bottom: 1 }

                onTextChanged: acceptableInput ?maxElectricalPower_validated = true : maxElectricalPower_validated = false
            }

            Label {
                id: maxElectricalPowerunit
                text: qsTr("kW")
            }

        }

        RowLayout{
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: qsTr("Operating mode (Solar Only)")
            }

            Switch {
                id: operatingModeSwitch
                Component.onCompleted: checked = heatingElementConfiguration.optimizationEnabled
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                font: Style.smallFont
                color: Style.consolinnoMedium
                wrapMode: Text.Wrap
                text: operatingModeSwitch.checked ? qsTr("The heater is operated only with solar power. If a wallbox is connected to the system, and a charging process is started, charging is prioritized.") : qsTr("The heating element is not controlled by the %1.").arg(Configuration.deviceName)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: heatRodThing.thingClass.interfaces.includes("controllableconsumer") || heatRodThing.thingClass.interfaces.includes("smartheatingrod");
            RowLayout {
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Grid-supportive-control")
                }
                Switch {
                    id: controllSwitch
                    Component.onCompleted: checked = heatingElementConfiguration.controllableLocalSystem
                }
            }

            Text {
                Layout.fillWidth: true
                font: Style.smallFont
                color: Style.consolinnoMedium
                wrapMode: Text.Wrap
                text: qsTr("If the device must be controlled in accordance with § 14a, this setting must be enabled and the nominal power must correspond to the registered power.")
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
            Layout.fillWidth: true
            text: qsTr("Ok")
            property bool validated: maxPowerInput.maxElectricalPower_validated

            onClicked: {
                let inputText = maxPowerInput.text
                inputText.includes(",") === true ? inputText = inputText.replace(",",".") : inputText
                d.pendingCallId = hemsManager.setHeatingElementConfiguration(heatRodThing.id, { "maxElectricalPower": parseFloat(inputText), "optimizationEnabled": operatingModeSwitch.checked, controllableLocalSystem: controllSwitch.checked})
                if(directionID !== 1){
                    pageStack.pop()
                }
                root.done()
            }
        }
    }
}
