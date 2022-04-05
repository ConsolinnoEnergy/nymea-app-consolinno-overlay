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

    header: NymeaHeader {
        text: "PV"
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }




    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins

        Repeater {
            id: testrepeater

            model: hemsManager.pvConfigurations
            delegate: NymeaItemDelegate {

                property PvConfiguration pvConfiguration: hemsManager.pvConfigurations.getPvConfiguration(model.PvThingId)
                property Thing pvThing: engine.thingManager.things.getThing(model.PvThingId)


                Layout.fillWidth: true
                iconName: "../images/thermostat/heating.svg"
                progressive: true
                text: pvThing.name
                onClicked: pageStack.push(pvConfigurationComponent, { hemsManager: hemsManager, pvConfiguration: pvConfiguration, pvThing: pvThing })




            }
        }
     }

    Component.onCompleted: {
        // FIXME: directly open if there is only one heatpump to save a click
        //                if (hemsManager.heatingConfigurations.count === 1) {
        //                    onClicked: pageStack.push(heatingConfigurationComponent, { hemsManager: hemsManager,
        //                                                  heatingConfiguration: hemsManager.heatingConfigurations.get(0),
        //                                                  heatPumpThing: engine.thingManager.things.getThing(hemsManager.heatingConfigurations.get(0).heatPumpThingId) })
        //                }
    }

    Component {
        id: pvConfigurationComponent

        Page {
            id: root
            property HemsManager hemsManager
            property PvConfiguration pvConfiguration
            property Thing pvThing

            // TODO: only if any configuration has changed, warn also on leaving if unsaved settings
            //property bool configurationSettingsChanged

            header: NymeaHeader {
                text: qsTr("Pv configuration")
                backButtonVisible: true
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
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: pvThing.name
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
                        maximumLength: 6
                        Layout.minimumWidth: 50
                        Layout.maximumWidth: 50
                        Layout.rightMargin: 48
                        text: pvConfiguration.latitude
                        validator: DoubleValidator{
                            bottom: -90
                            top: 90
                            decimals: 4
                        }
                        onTextChanged: acceptableInput ?latitude_validated = true : latitude_validated = false



                    }
                    Text {
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
                        Layout.minimumWidth: 50
                        Layout.maximumWidth: 50
                        Layout.rightMargin: 48
                        text: pvConfiguration.longitude
                        validator: DoubleValidator{
                            bottom: -180
                            top: 180
                            decimals: 4
                        }

                        onTextChanged: acceptableInput ? longitude_validated = true : longitude_validated = false

                    }

                    Text {
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
                        Layout.minimumWidth: 50
                        Layout.maximumWidth: 50
                        Layout.rightMargin: 48

                        text: pvConfiguration.roofPitch
                        validator: IntValidator{
                            bottom: 0;
                            top: 90
                        }
                        onTextChanged: acceptableInput ?roofpitch_validated = true : roofpitch_validated = false   
                    }


                    Text {
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
                        Layout.minimumWidth: 50
                        Layout.maximumWidth: 50
                        Layout.rightMargin: 48
                        text: pvConfiguration.alignment
                        validator: IntValidator{
                            bottom: 0;
                            top: 360
                        }
                        onTextChanged: acceptableInput ?alignment_validated = true : alignment_validated = false

                    }

                    Text {
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
                        Layout.rightMargin: 10
                        Layout.minimumWidth: 50
                        Layout.maximumWidth: 70
                        text: pvConfiguration.kwPeak
                        maximumLength: 7
                        validator: DoubleValidator{
                            bottom: 0;
                        }
                        onTextChanged: acceptableInput ?kwPeak_validated = true : kwPeak_validated = false


                    }

                    Text {
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

              //  Button {
              //      id: assignHeatMeter
              //      Layout.fillWidth: true
                    // We only need to assign a hear meter if this heatpump does not provide one
              //      visible: !heatMeterIncluded
              //      text: qsTr("TODO: Assign heat meter")
                    // TODO: Select a heat meter from the things and show it here. Allow to reassign a heat meter and remove the assignment
              //  }

             //   Item {
                    // place holder
              //      Layout.fillHeight: true
              //      Layout.fillWidth: true
              //  }

                Button {
                    id: savebutton
                    Layout.fillWidth: true
                    property bool validated: longitudefield.longitude_validated && latitude.latitude_validated && roofpitch.roofpitch_validated && alignment.alignment_validated && kwPeak.kwPeak_validated
                    text: qsTr("Save")
                    //enabled: configurationSettingsChanged
                    onClicked: {
                        if (validated == true)
                        {
                        longitudefield.placeholderText = "60"

                        footer.text = "saved"
                        d.pendingCallId = hemsManager.setPvConfiguration(pvConfiguration.PvThingId, parseFloat(longitudefield.text), parseFloat(latitude.text), parseInt(roofpitch.text), parseInt(alignment.text), parseFloat(kwPeak.text) )
                        }
                        else
                        {



                        footer.text = "some attributes are outside of the allowed range: Configurations were not saved"
                        }
                    }


                }
            }
        }
    }
}
