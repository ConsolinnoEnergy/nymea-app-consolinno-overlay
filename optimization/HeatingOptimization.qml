import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"
import QtQml 2.15


Page {
    id: root
    property HeatingConfiguration heatingConfiguration
    property Thing heatPumpThing
    property int directionID: 0
    signal done()

    function buildMeterModel() {
        meterModel.clear();
        meterModel.append({ text: qsTr("No meter"), thingId: "" });
        for (let i = 0; i < smartMeterConsumerProxy.count; i++) {
            let t = smartMeterConsumerProxy.get(i);
            if (t.thingClass.interfaces.indexOf("hideable") >= 0) {
                meterModel.append({ text: t.name, thingId: t.id.toString() });
            }
        }
        if (!heatingConfiguration) {
            heatMeterCombo.comboBox.currentIndex = 0;
            return;
        }
        let currentId = heatingConfiguration.heatMeterThingId.toString();
        for (let j = 0; j < meterModel.count; j++) {
            if (meterModel.get(j).thingId === currentId) {
                heatMeterCombo.comboBox.currentIndex = j;
                return;
            }
        }
        heatMeterCombo.comboBox.currentIndex = 0;
    }

    header: NymeaHeader {
        text: qsTr("Heating")
        backButtonVisible: directionID === 1 ? false : true
        onBackPressed: pageStack.pop()
    }

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onSetHeatingConfigurationReply: {
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

    ThingsProxy {
        id: smartMeterConsumerProxy
        engine: _engine
        shownInterfaces: ["smartmeterconsumer"]
        onCountChanged: buildMeterModel()
    }

    Component.onCompleted: {
        buildMeterModel();
    }

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: app.margins

        CoFrostyCard {
            Layout.fillWidth: true
            contentTopMargin: Style.smallMargins
            headerText: heatPumpThing.name

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Style.margins
                anchors.rightMargin: Style.margins
                spacing: 0


                CoInputField {
                    id: maxElectricalPower
                    property bool maxElectricalPowerValid: textField.acceptableInput
                    Layout.fillWidth: true
                    labelText: qsTr("Maximal electrical power")
                    compactTextField: true
                    unit: qsTr("kW")
                    textField.text: (+heatingConfiguration.maxElectricalPower).toLocaleString()
                    textField.maximumLength: 10
                    textField.validator: DoubleValidator{ bottom: 1 }
                }

                CoSwitch {
                    id: gridSupportControl
                    Layout.fillWidth: true
                    text: qsTr("Grid-supportive-control")
                    helpText: qsTr("If the device must be controlled in accordance with § 14a, this setting must be enabled and the nominal power must correspond to the registered power.")
                    visible: heatPumpThing.thingClass.interfaces.includes("smartgridheatpump") ||
                             heatPumpThing.thingClass.interfaces.includes("limitableconsumer") ||
                             heatPumpThing.thingClass.interfaces.includes("heatpump")

                    Component.onCompleted: {
                        checked = heatingConfiguration.controllableLocalSystem;
                    }
                }

                CoComboBox {
                    id: heatMeterCombo
                    Layout.fillWidth: true
                    visible: heatPumpThing.thingClass.interfaces.includes("smartmeterconsumerassignable")
                    labelText: qsTr("Electricity meter")
                    comboBox.textRole: "text"
                    comboBox.model: ListModel { id: meterModel }
                }
            }
        }

        Item {
            id: spacer
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        // potential footer for the config app, as a way to show the user that certain attributes where invalid.
        Label {
            id: footer
            Layout.fillWidth: true
            Layout.leftMargin: app.margins
            Layout.rightMargin: app.margins
            color: Style.dangerAccent
            //text: qsTr("For a better optimization you can please insert the upper data, so our optimizer has the information it needs.")
            wrapMode: Text.WordWrap
            font.pixelSize: app.smallFont
        }

        Button {
            id: savebutton
            property bool inputValid: maxElectricalPower.maxElectricalPowerValid

            Layout.fillWidth: true
            text: qsTr("Save")
            onClicked: {
                let inputText = maxElectricalPower.text
                inputText.includes(",") === true ? inputText = inputText.replace(",",".") : inputText
                if (savebutton.inputValid)
                {
                   
                    const newConfig = JSON.parse(JSON.stringify(heatingConfiguration));
                    newConfig.maxElectricalPower = +inputText;
                    newConfig.controllableLocalSystem = gridSupportControl.checked;
                    newConfig.heatMeterThingId = meterModel.get(heatMeterCombo.comboBox.currentIndex).thingId;

                    // TODO this is terrible fix the enum mapping properly
                    // We just want to keep the current value
                    // Mapping: number -> enum name
                    const optimizationModeMap = {
                      0: "OptimizationModePVSurplus",
                      1: "OptimizationModeDynamicPricing",
                      2: "OptimizationModeOff",
                    };

                    // Read the current numeric value from the original config
                    const currentValue = heatingConfiguration.optimizationMode;

                    // Write the enum name instead of the number
                    newConfig.optimizationMode = optimizationModeMap.hasOwnProperty(currentValue)
                      ? optimizationModeMap[currentValue]
                      : "OptimizationModeOff";
                    // end of terrible hack 

                    d.pendingCallId = hemsManager.setHeatingConfiguration(heatingConfiguration.heatPumpThingId, newConfig)
                    if(directionID !== 1){
                        pageStack.pop()
                    }
                    root.done()
                }
                else
                {
                    // for now this is the way how we show the user that some attributes are invalid
                    // TO DO: Show which ones are invalid
                    footer.text = qsTr("Some attributes are outside of the allowed range: Configurations were not saved.")
                }
            }
        }
    }
}

