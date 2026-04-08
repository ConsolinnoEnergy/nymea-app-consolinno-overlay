import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root
    property PvConfiguration pvConfiguration
    property Thing thing
    property int directionID: 0

    signal done

    //    PositionSource{
    //        id: src
    //        updateInterval: 1000
    //        name: "SerialPortNmea"
    //        preferredPositioningMethods: PositionSource.SatellitePositioningMethods
    //        active: true

    //        onPositionChanged: {
    //        }
    //    }
    header: NymeaHeader {
        text: qsTr("PV configuration")
        backButtonVisible: directionID === 1 ? false : true
        onBackPressed: pageStack.pop()
    }

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
        onSetPvConfigurationReply: function(commandId, error) {

            if (commandId == d.pendingCallId) {
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

    Flickable {
        anchors.fill: parent
        // anchors.topMargin: root.implicitHeaderHeight
        clip: true
        contentHeight: contentColumn.implicitHeight +
                       contentColumn.anchors.topMargin +
                       contentColumn.anchors.bottomMargin

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: app.margins

            CoFrostyCard {
                Layout.fillWidth: true
                contentTopMargin: Style.smallMargins
                headerText: thing.name

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: Style.margins
                    anchors.rightMargin: Style.margins
                    spacing: 0

                    CoInputField {
                        id: latitudeInput
                        Layout.fillWidth: true
                        labelText: qsTr("Latitude")
                        compactTextField: true
                        unit: qsTr("°")
                        helpText: qsTr("The value must be between 30 and 60.") // #TODO wording
                        textField.text: pvConfiguration.latitude.toLocaleString(Qt.locale())
                        textField.validator: DoubleValidator {
                            bottom: 30
                            top: 60
                            decimals: 4
                            notation: "StandardNotation"
                        }
                    }

                    CoInputField {
                        id: longitudeInput
                        Layout.fillWidth: true
                        labelText: qsTr("Longitude")
                        compactTextField: true
                        unit: qsTr("°")
                        textField.text: pvConfiguration.longitude.toLocaleString(Qt.locale())
                        textField.validator: DoubleValidator {
                            bottom: -10
                            top: 30
                            decimals: 4
                            notation: "StandardNotation"
                        }
                    }

                    CoInputField {
                        id: roofpitchInput
                        Layout.fillWidth: true
                        labelText: qsTr("Roof pitch")
                        compactTextField: true
                        unit: qsTr("°")
                        textField.text: pvConfiguration.roofPitch
                        textField.maximumLength: 2
                        textField.validator: IntValidator {
                            bottom: 0
                            top: 90
                        }
                    }

                    CoComboBox {
                        id: alignment
                        Layout.fillWidth: true
                        labelText: qsTr("Alignment")
                        comboBox.textRole: "text"
                        comboBox.valueRole: "value"
                        comboBox.currentIndex: 4
                        Component.onCompleted: {
                            var current = comboBox.indexOfValue(pvConfiguration.alignment)
                            if (current !== -1) {
                                comboBox.currentIndex =  current
                            } else {
                                comboBox.currentIndex = 4 // south
                            }
                        }
                        comboBox.model: [
                            { value: 0, text: qsTr("north") },
                            { value: 45, text: qsTr("northeast") },
                            { value: 90, text: qsTr("east") },
                            { value: 135, text: qsTr("southeast") },
                            { value: 180, text: qsTr("south") },
                            { value: 225, text: qsTr("southwest") },
                            { value: 270, text: qsTr("west") },
                            { value: 315, text: qsTr("northwest") },
                        ]
                    }

                    CoInputField {
                        id: peakPowerInput
                        Layout.fillWidth: true
                        labelText: qsTr("Peak power")
                        compactTextField: true
                        unit: qsTr("kW")
                        textField.text: pvConfiguration.kwPeak.toLocaleString(Qt.locale())
                        textField.validator: DoubleValidator {
                            bottom: 1
                            top: 30
                            decimals: 2
                            notation: "StandardNotation"
                        }
                    }

                    CoSwitch {
                        id: gridSupportControl
                        Layout.fillWidth: true
                        visible: thing.thingClass.interfaces.includes("limitgridexport") ||
                                 thing.thingClass.interfaces.includes("limitableproducer")
                        text: qsTr("Grid-supportive-control")
                        helpText: qsTr("If the device must be controlled in accordance with § 9, this setting must be enabled.")

                        Component.onCompleted: {
                            checked = pvConfiguration.controllableLocalSystem;
                        }
                    }
                }
            }

            Item {
                id: spacer
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Button {
                id: savebutton
                Layout.fillWidth: true
                text: qsTr("Save")
                property bool validated: latitudeInput.acceptableInput
                                         && longitudeInput.acceptableInput
                                         && roofpitchInput.acceptableInput
                                         && peakPowerInput.acceptableInput

                onClicked: {
                    // the input is in the range that is defined in the individual Validator
                    if (!validated) { return; }

                    if (directionID === 1) {
                        if (Number.fromLocaleString(Qt.locale(), longitudeInput.text) !== 0 ||
                                Number.fromLocaleString(Qt.locale(), latitudeInput.text) !== 0) {
                            header.text = longitudeInput.text;
                            hemsManager.setPvConfiguration(thing.id,
                                                           {
                                                               "longitude": Number.fromLocaleString(
                                                                                Qt.locale(),
                                                                                longitudeInput.text),
                                                               "latitude": Number.fromLocaleString(
                                                                               Qt.locale(),
                                                                               latitudeInput.text),
                                                               "roofPitch": roofpitchInput.text,
                                                               "alignment": alignment.comboBox.currentValue,
                                                               "kwPeak": Number.fromLocaleString(
                                                                             Qt.locale(),
                                                                             peakPowerInput.text),
                                                               "controllableLocalSystem": gridSupportControl.checked
                                                           });
                            root.done();
                        }
                    } else if (directionID === 0) {
                        if (Number.fromLocaleString(Qt.locale(), longitudeInput.text) !== 0 ||
                                Number.fromLocaleString(Qt.locale(), latitudeInput.text) !== 0) {
                            d.pendingCallId = hemsManager.setPvConfiguration(thing.id,
                                                                             {
                                                                                 "longitude": Number.fromLocaleString(
                                                                                                  Qt.locale(),
                                                                                                  longitudeInput.text),
                                                                                 "latitude": Number.fromLocaleString(
                                                                                                 Qt.locale(),
                                                                                                 latitudeInput.text),
                                                                                 "roofPitch": roofpitchInput.text,
                                                                                 "alignment": alignment.comboBox.currentValue,
                                                                                 "kwPeak": Number.fromLocaleString(
                                                                                               Qt.locale(),
                                                                                               peakPowerInput.text),
                                                                                 "controllableLocalSystem": gridSupportControl.checked
                                                                             });
                        }
                    }
                }
            }
        }
    }
}
