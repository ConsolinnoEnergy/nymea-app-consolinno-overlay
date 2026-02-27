import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root
    property HemsManager hemsManager
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
        onSetPvConfigurationReply: {

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

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins
        anchors.margins: app.margins
        spacing: 5

        function parseNumber(text) {
            try {
                // Try locale parse
                var v = Number.fromLocaleString(Qt.locale(), text)
                //print("parsed locale")
            } catch (e) {
                try {
                    // Parse EN (decimal point)
                    var v = Number.fromLocaleString(Qt.locale("en_EN"), text)
                    //print("parsed EN")
                } catch (e) {
                    // Last try, parse float. Returns 0 if fail to convert
                    var v = parseFloat(text)
                    //print("parsed float")
                }
            }
            return v
        }

        Label {
            Layout.fillWidth: true
            text: thing.name
            wrapMode: Text.WordWrap
        }

        ConsolinnoPVTextField {
            id: latitudeInput

            Layout.fillWidth: true
            Layout.fillHeight: false
            label: qsTr("Latitude")
            text: pvConfiguration.latitude.toLocaleString(Qt.locale())

            validator: DoubleValidator {
                bottom: 30
                top: 60
                decimals: 4
                notation: "StandardNotation"
            }

        }

        ConsolinnoPVTextField {
            id: longitudeInput

            Layout.fillWidth: true
            Layout.fillHeight: false
            label: qsTr("Longitude")
            text: pvConfiguration.longitude.toLocaleString(Qt.locale())

            validator: DoubleValidator {
                bottom: -10 
                top: 30
                decimals: 4
                notation: "StandardNotation"
            }
        }

        ConsolinnoPVTextField {
            id: roofpitchInput

            Layout.fillWidth: true
            Layout.fillHeight: false
            label: qsTr("Roof pitch")
            text: pvConfiguration.roofPitch
            maximumLength: 2

            validator: IntValidator {
                bottom: 0
                top: 90
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Alignment")
            }

            //            TextField {
            //                id: alignment
            //                property bool alignment_validated
            //                maximumLength: 3
            //                Layout.minimumWidth: 55
            //                Layout.maximumWidth: 55
            //                Layout.rightMargin: 48
            //                text: pvConfiguration.alignment //                validator: IntValidator {
            //                    bottom: 0
            //                    top: 360
            //                }
            //                onTextChanged: acceptableInput ? alignment_validated
            //                                                 = true : alignment_validated = false
            //            }

            ConsolinnoDropdown {
                id: alignment
                textRole: "text"
                valueRole: "value"
                Layout.fillWidth: false
                Layout.preferredWidth: contentColumn.width * 0.35 + Style.smallMargins
                currentIndex: 4
                Component.onCompleted: {
                    var current = indexOfValue(pvConfiguration.alignment)
                    if (current !== -1)
                    {
                        currentIndex =  current
                    }else{
                        currentIndex = 4 // south
                    }
                }
                model: [
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
        }

        ConsolinnoPVTextField {
            id: peakPowerInput

            Layout.fillWidth: true
            Layout.fillHeight: false
            label: qsTr("Peak power")
            text: pvConfiguration.kwPeak.toLocaleString(Qt.locale())
            unit: qsTr("kW")

            validator: DoubleValidator {
                bottom: 1
                top: 30
                decimals: 2
                notation: "StandardNotation"
            }
        }

        RowLayout{
            Layout.fillWidth: true
            visible: thing.thingClass.interfaces.includes("limitgridexport") ||
                     thing.thingClass.interfaces.includes("limitableproducer")

            Label {
                Layout.fillWidth: true
                text: qsTr("Grid-supportive-control")
            }

            Switch {
                id: gridSupportControl
                Component.onCompleted: checked = pvConfiguration.controllableLocalSystem
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: thing.thingClass.interfaces.includes("limitgridexport") ||
                     thing.thingClass.interfaces.includes("limitableproducer")

            Text {
                Layout.fillWidth: true
                font: Style.smallFont
                color: Style.consolinnoMedium
                wrapMode: Text.Wrap
                text: qsTr("If the device must be controlled in accordance with § 9, this setting must be enabled.")
            }
        }

        //margins filler
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: Style.bigMargins
        }

        Button {
            id: savebutton

            Layout.fillWidth: true

            property bool validated: latitudeInput.acceptableInput
                                     && longitudeInput.acceptableInput
                                     && roofpitchInput.acceptableInput
                                     && peakPowerInput.acceptableInput


            text: qsTr("Save")
            //enabled: configurationSettingsChanged

            function validateValues() {
                latitudeInput.validateValue();
                longitudeInput.validateValue();
                roofpitchInput.validateValue();
                peakPowerInput.validateValue();
            }

            onClicked: {
                validateValues();

                // the input is in the range that is defined in the individual Validator
                if (validated == false) {
                    return
                }

                if (directionID === 1) {

                    if (Number.fromLocaleString(Qt.locale(),
                                                longitudeInput.text) !== 0
                            || Number.fromLocaleString(Qt.locale(),
                                                       latitudeInput.text) !== 0) {

                        header.text = longitudeInput.text
                        hemsManager.setPvConfiguration(thing.id, {
                                                           "longitude": Number.fromLocaleString(
                                                                            Qt.locale(),
                                                                            longitudeInput.text),
                                                           "latitude": Number.fromLocaleString(
                                                                           Qt.locale(),
                                                                           latitudeInput.text),
                                                           "roofPitch": roofpitchInput.text,
                                                           "alignment": alignment.currentValue,
                                                           "kwPeak": Number.fromLocaleString(
                                                                           Qt.locale(),
                                                                           peakPowerInput.text),
                                                           "controllableLocalSystem": gridSupportControl.checked
                                                       })
                        root.done()
                    } else {
                    }
                } else if (directionID === 0) {
                    if (Number.fromLocaleString(Qt.locale(),
                                                longitudeInput.text) !== 0
                            || Number.fromLocaleString(Qt.locale(),
                                                       latitudeInput.text) !== 0) {

                        d.pendingCallId = hemsManager.setPvConfiguration(
                                    thing.id, {
                                        "longitude": Number.fromLocaleString(
                                                         Qt.locale(),
                                                         longitudeInput.text),
                                        "latitude": Number.fromLocaleString(
                                                        Qt.locale(),
                                                        latitudeInput.text),
                                        "roofPitch": roofpitchInput.text,
                                        "alignment": alignment.currentValue,
                                        "kwPeak": Number.fromLocaleString(
                                                        Qt.locale(),
                                                        peakPowerInput.text),
                                        "controllableLocalSystem": gridSupportControl.checked
                                    })
                    }
                }
            }
        }
    }
}
