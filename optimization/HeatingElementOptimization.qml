import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import NymeaApp.Utils 1.0
import "../components"
import "../delegates"

Page {
    id: root
    bottomPadding: 0
    property int navigationFooterHeight: 0

    property HeatingElementConfiguration heatingElementConfiguration
    property Thing heatRodThing
    property bool calledFromAssistant: false
    signal done()

    readonly property bool applyEnabled: {
        if (calledFromAssistant) {
            return true;
        } else {
            return Math.abs(Number.fromLocaleString(Qt.locale(), maxElectricalPower.text) - heatingElementConfiguration.maxElectricalPower) > 0.000001 ||
                    gridSupportControl.checked !== heatingElementConfiguration.controllableLocalSystem;
        }
    }

    function applyChanges() {
        if (!maxElectricalPower.acceptableInput) {
            maxElectricalPower.textField.hasError = !maxElectricalPower.acceptableInput;
            return;
        }

        let inputText = maxElectricalPower.text
        inputText.includes(",") === true ? inputText = inputText.replace(",", ".") : inputText
        d.pendingCallId = hemsManager.setHeatingElementConfiguration(heatRodThing.id, {
            "maxElectricalPower": parseFloat(inputText),
            "optimizationEnabled": heatingElementConfiguration ? heatingElementConfiguration.optimizationEnabled : true,
            "controllableLocalSystem": gridSupportControl.checked
        })
        if (!calledFromAssistant) {
            pageStack.pop()
        }
        root.done()
    }

    header: null

    CoHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        blurSource: bodyFlickable
        text: qsTr("Heating")
        backButtonVisible: !calledFromAssistant
        onBackPressed: pageStack.pop()
    }

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onSetHeatingElementConfigurationReply: function(commandId, error) {

            if (commandId === d.pendingCallId) {
                d.pendingCallId = -1
                let props = "";
                switch (error) {
                case "HemsErrorNoError":
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

    Flickable {
        id: bodyFlickable
        anchors.fill: parent
        topMargin: header.height
        clip: true
        contentHeight: contentColumn.implicitHeight + contentColumn.anchors.topMargin + contentColumn.anchors.bottomMargin + root.navigationFooterHeight
        Component.onCompleted: Qt.callLater(() => contentY = -topMargin)

        ColumnLayout {
            id: contentColumn
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: app.margins

            CoFrostyCard {
                Layout.fillWidth: true
                contentTopMargin: Style.smallMargins
                headerText: heatRodThing.name

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoInputField {
                        id: maxElectricalPower
                        Layout.fillWidth: true
                        labelText: qsTr("Maximal electrical power")
                        compact: true
                        unit: qsTr("kW")
                        helpText:
                            qsTr("The value must not be below %1.")
                        .arg(NymeaUtils.floatToLocaleString(maxElectricalPowerValidator.bottom))
                        feedbackText: qsTr("The value is outside the valid range.")
                        textField.text: (+heatingElementConfiguration.maxElectricalPower).toLocaleString()
                        textField.maximumLength: 10
                        textField.validator: DoubleValidator  {
                            id: maxElectricalPowerValidator
                            bottom: 0.5
                        }
                    }

                    CoSwitch {
                        id: gridSupportControl
                        Layout.fillWidth: true
                        text: qsTr("Grid-supportive-control")
                        helpText: qsTr("If the device must be controlled in accordance with § 14a, this setting must be enabled and the nominal power must correspond to the registered power.")
                        visible: heatRodThing.thingClass.interfaces.includes("controllableconsumer") ||
                                 heatRodThing.thingClass.interfaces.includes("heatingrod")

                        Component.onCompleted: {
                            checked = heatingElementConfiguration.controllableLocalSystem
                        }
                    }
                }
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
        }
    }

    property Component navbarControls: heatingElementNavbarControls

    Component {
        id: heatingElementNavbarControls
        CoNavbarButton {
            text: root.calledFromAssistant ? qsTr("Next") : qsTr("Apply changes")
            enabled: root.applyEnabled
            onClicked: root.applyChanges()
        }
    }
}
