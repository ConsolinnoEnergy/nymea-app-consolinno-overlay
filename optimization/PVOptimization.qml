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
    property PvConfiguration pvConfiguration
    property Thing thing
    property int directionID: 0

    signal done()

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
        spacing: 5


        Label {
            Layout.fillWidth: true
            text: thing.name
            wrapMode: Text.WordWrap

        }

        RowLayout {
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: qsTr("Latitude")
            }

            TextField {
                id: latitude
                property bool latitude_validated
                maximumLength: 7
                Layout.minimumWidth: 55
                Layout.maximumWidth: 55
                Layout.rightMargin: 48
                //text: pvConfiguration.latitude !== 0? pvConfiguration.latitude : src.position.coordinate.latitude.toFixed(0)
                text: pvConfiguration.latitude.toFixed(2).toString().replace('.', ',')
                validator: DoubleValidator{
                    bottom: -90
                    top: 90
                    decimals: 4
                }
                onTextChanged: acceptableInput ?latitude_validated = true : latitude_validated = false



            }
            Label {
                id: latitudeunit
                text: qsTr("°")
            }

        }

        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Longitude")
            }

            TextField {
                id: longitudefield
                property bool longitude_validated
                maximumLength: 7
                Layout.minimumWidth: 55
                Layout.maximumWidth: 55
                Layout.rightMargin: 48
                //text: pvConfiguration.longitude !== 0 ? pvConfiguration.longitude : src.position.coordinate.longitude.toFixed(0)
                text: pvConfiguration.longitude.toFixed(2).toString().replace('.', ',')

                validator: DoubleValidator{
                    bottom: -180
                    top: 180
                    decimals: 4
                }

                onTextChanged: acceptableInput ? longitude_validated = true : longitude_validated = false

            }

            Label {
                id: longitudeunit
                text: qsTr("°")
            }
        }



        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Roof pitch")
            }

            TextField {
                id: roofpitch

                property bool roofpitch_validated
                maximumLength: 2
                Layout.minimumWidth: 55
                Layout.maximumWidth: 55
                Layout.rightMargin: 48

                text: pvConfiguration.roofPitch
                validator: IntValidator{
                    bottom: 0;
                    top: 90
                }
                onTextChanged: acceptableInput ?roofpitch_validated = true : roofpitch_validated = false
            }


            Label {
                id: roofpitchunit
                text: qsTr("°")
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Alignment")
            }

            TextField {
                id: alignment
                property bool alignment_validated
                maximumLength: 3
                Layout.minimumWidth: 55
                Layout.maximumWidth: 55
                Layout.rightMargin: 48
                text: pvConfiguration.alignment
                validator: IntValidator{
                    bottom: 0;
                    top: 360
                }
                onTextChanged: acceptableInput ?alignment_validated = true : alignment_validated = false

            }

            Label {
                id: alignmentunit
                Layout.alignment: Qt.AlignLeft
                text: qsTr("°")
            }

        }

        RowLayout {
            Layout.fillWidth: true


            Label {
                id: peakId
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft
                text: qsTr("Peak power")
            }

            TextField {
                id: kwPeak
                Layout.alignment: Qt.AlignRight
                property bool kwPeak_validated
                Layout.rightMargin: 15
                Layout.minimumWidth: 50
                Layout.maximumWidth: 70
                text: pvConfiguration.kwPeak
                maximumLength: 7
                validator: DoubleValidator{
                    bottom: 1;
                }
                onTextChanged: acceptableInput ?kwPeak_validated = true : kwPeak_validated = false


            }

            Label {
                id: kwPeakunit
                text: qsTr("kW")
                Layout.alignment: Qt.AlignRight
            }

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
            property bool validated: longitudefield.longitude_validated && latitude.latitude_validated && roofpitch.roofpitch_validated && alignment.alignment_validated && kwPeak.kwPeak_validated
            text: qsTr("Save")
            //enabled: configurationSettingsChanged
            onClicked: {



                // check if a . was set
                if ( latitude.text.search(/(\.){1}/) >= 0 ){
                    footer.text = qsTr("Please, when putting in the latitude use comma (,) not a dot (.)")
                    return

                }

                // check if a . was set
                if ( longitudefield.text.search(/(\.){1}/) >= 0 ){
                    footer.text = qsTr("Please, when putting in the longitude use comma (,) not a dot (.)")
                    return

                }


                // the input is in the range that is defined in the individual Validator
                if (validated == false)
                {
                    footer.text = qsTr("Some values are out of range. Please check your input.")
                    return
                }


                if (directionID === 1){



                    if (longitudefield.text !== "0" || latitude.text !== "0"){

                        header.text = longitudefield.text
                        hemsManager.setPvConfiguration(thing.id, {longitude: longitudefield.text, latitude: latitude.text, roofPitch: roofpitch.text, alignment: alignment.text, kwPeak: kwPeak.text})
                        footer.text = ""
                        root.done()

                    }else{
                        footer.text = qsTr("Please enter the longitude and latitude of your device (This can be determined i.e via Google maps)")
                    }





                }else if(directionID === 0){



                    if (longitudefield.text !== "0" || latitude.text !== "0"){



                        d.pendingCallId = hemsManager.setPvConfiguration(thing.id, {longitude: longitudefield.text, latitude: latitude.text, roofPitch: roofpitch.text, alignment: alignment.text, kwPeak: kwPeak.text})
                    }else{
                        footer.text = qsTr("Please enter the longitude and latitude of your device (This can be determined i.e via Google maps)")
                    }


                }

            }


        }



    }
}
