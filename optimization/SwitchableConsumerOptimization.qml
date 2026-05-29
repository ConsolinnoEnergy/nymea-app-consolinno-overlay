import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import NymeaApp.Utils 1.0
import "../components"
import "../delegates"

Page {
    id: root

    property SwitchConfiguration switchConfiguration
    property Thing switchThing
    property int directionID: 0
    signal done()

    header: CoHeader {
        text: qsTr("Switchable consumers")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onSetSwitchConfigurationReply: function(commandId, error) {

            if (commandId === d.pendingCallId) {
                d.pendingCallId = -1
                let props = {}
                switch (error) {
                case "HemsErrorNoError":
                    return
                case "HemsErrorInvalidParameter":
                    footer.text = qsTr("Some attributes are outside of the allowed range: Configurations were not saved.")
                    return
                case "HemsErrorInvalidThing":
                    props.text = qsTr("Could not save configuration. The thing is not valid.")
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
        id: contentColumn
        anchors.fill: parent
        anchors.margins: app.margins

        CoFrostyCard {
            Layout.fillWidth: true
            contentTopMargin: Style.smallMargins
            headerText: switchThing.name

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 0

                CoInputField {
                    id: maxElectricalPower
                    property bool maxElectricalPowerValid: textField.acceptableInput
                    Layout.fillWidth: true
                    labelText: qsTr("Maximal electrical power")
                    compact: true
                    unit: qsTr("kW")
                    helpText:
                        qsTr("The value must not be below %1.")
                    .arg(NymeaUtils.floatToLocaleString(maxElectricalPowerValidator.bottom))
                    feedbackText: qsTr("The value is outside the valid range.")
                    textField.text: (+switchConfiguration.maxElectricalPower).toLocaleString()
                    textField.maximumLength: 10
                    textField.validator: DoubleValidator  {
                        id: maxElectricalPowerValidator
                        bottom: 0.5
                    }
                }

                CoSwitch {
                    id: controllSwitch
                    Layout.fillWidth: true
                    visible: false // #TODO CLS toggle only starting with version 2.2
                    text: qsTr("Grid-supportive-control")
                    helpText: qsTr("If the device must be controlled in accordance with § 14a, this setting must be enabled and the nominal power must correspond to the registered power.")

                    Component.onCompleted: {
                        checked = switchConfiguration.controllableLocalSystem;
                    }
                }
            }
        }

        Item {
            id: spacer
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Label {
            id: footer
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            color: Style.dangerAccent
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont
        }

        Button {
            id: savebutton
            Layout.fillWidth: true
            text: qsTr("Apply changes")

            property bool inputValid: maxElectricalPower.maxElectricalPowerValid

            onClicked: {
                let parsedMaxElectricalPower = Number.fromLocaleString(Qt.locale(), maxElectricalPower.text)
                if (savebutton.inputValid) {
                    // #TODO CLS toggle only starting with version 2.2
                    // d.pendingCallId = hemsManager.setSwitchConfiguration(
                    //     switchConfiguration.switchThingId,
                    //     {
                    //         "maxElectricalPower": parsedMaxElectricalPower,
                    //         "controllableLocalSystem": controllSwitch.checked
                    //     }
                    // )
                    d.pendingCallId = hemsManager.setSwitchConfiguration(
                        switchConfiguration.switchThingId,
                        {
                            "maxElectricalPower": parsedMaxElectricalPower
                        }
                    )
                    if (directionID !== 1) {
                        pageStack.pop()
                    }
                    root.done()
                } else {
                    footer.text = qsTr("Some attributes are outside of the allowed range: Configurations were not saved.")
                }
            }
        }
    }
}
