import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.15

import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

StackView {
    id: root

    property string startView

    initialItem: startView === "taxesAndFeesSetUp" ? taxesAndFeesSetUp : setUpComponent //taxesAndFeesSetUp


    property HemsManager hemsManager
    property string name
    property bool newTariff: false
    property Thing dynElectricThing
    property int directionID: 0

    signal done(bool skip, bool abort, bool back);

    QtObject {
        id: d
        property int pendingCallId: -1
        property var params: []
        property Thing thingToRemove

    }


    Connections {
        id: connection
        target: engine.thingManager

        onAddThingReply: {
            if(!thingError)
            {
                dynElectricThing = engine.thingManager.things.getThing(thingId);
            }else{
                let props = qsTr("Failed to add thing: ThingErrorHardwareFailure");
                var comp = Qt.createComponent("../components/ErrorDialog.qml")
                var popup = comp.createObject(app, {props} )
                popup.open();
            }
        }
    }

    Component {
        id: setUpComponent

        Page {

            header: NymeaHeader {
                text: qsTr("Dynamic electricity tariff")
                backButtonVisible: true
                onBackPressed: {
                    if(directionID == 0) {
                        pageStack.pop()
                    }
                }
            }

            ColumnLayout {
                anchors {top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right;}
                spacing: 0

                ColumnLayout {
                    spacing: 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 0

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Submitted Rate")
                        wrapMode: Text.WordWrap
                        Layout.alignment: Qt.AlignRight
                        Layout.rightMargin: app.margins
                        horizontalAlignment: Text.AlignRight
                    }
                }

                VerticalDivider
                {
                    Layout.preferredWidth: app.width
                    dividerColor: Material.accent
                }

                Flickable {
                    id: flickableContainer
                    clip: true


                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        id: column
                        Layout.topMargin: 0
                        width: parent.width
                        //Layout.minimumHeight: 230
                        spacing: 0

                        Repeater {
                            id: dynamicRateRepeater
                            model: ThingsProxy {
                                id: erProxy
                                engine: _engine
                                shownInterfaces: ["dynamicelectricitypricing"]
                            }
                            delegate: ConsolinnoThingDelegate {
                                implicitHeight: 50
                                Layout.fillWidth: true
                                iconName: Configuration.energyIcon !== "" ? "/ui/images/"+Configuration.energyIcon : "../images/energy.svg"
                                text: model.name
                                progressive: true
                                canDelete: true
                                onClicked: {
                                    pageStack.push(taxesAndFeesSetUp)
                                }
                                onDeleteClicked: {
                                    engine.thingManager.removeThing(model.id)
                                }
                            }
                        }
                    }
                }

                Rectangle{
                    Layout.preferredHeight: parent.height / 3
                    Layout.fillWidth: true
                    visible: erProxy.count === 0
                    color: Material.background
                    Text {
                        text: qsTr("There is no rate set up yet")
                        color: Material.foreground
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignHCenter
                    }
                }

                VerticalDivider
                {
                    Layout.preferredWidth: app.width
                    dividerColor: Material.accent
                }

                ColumnLayout {
                    Layout.topMargin: Style.margins
                    visible: root.newTariff
                    Label {
                        Layout.fillWidth: true
                        Layout.leftMargin: Style.margins
                        text: qsTr("Add Rate: ")
                        wrapMode: Text.WordWrap
                    }

                    ComboBox {
                        id: energyRateComboBox
                        Layout.leftMargin: Style.margins
                        Layout.preferredWidth: app.width - 2*Style.margins
                        textRole: "displayName"
                        valueRole: "id"
                        model: ThingClassesProxy {
                            id: currentThing
                            engine: _engine
                            filterInterface: "dynamicelectricitypricing"
                            includeProvidedInterfaces: true
                        }
                    }
                }

                ColumnLayout {
                    spacing: 0
                    Layout.alignment: Qt.AlignHCenter
                    visible: true

                    Button {
                        id: addButton
                        text: qsTr("Add Rate")
                        Layout.preferredWidth: app.width - 2*Style.margins
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: {
                            if(!root.newTariff) {
                              root.newTariff = true;
                              addButton.text = qsTr("Next");
                              return;
                            }
                            pageStack.push(dynamicSetUpFeedBack,{comboBoxValue: energyRateComboBox.currentValue, comboBoxCurrentText: energyRateComboBox.currentText});
                            if(!dynElectricThing){
                                engine.thingManager.addThing(energyRateComboBox.currentValue, energyRateComboBox.currentText, d.params);
                            }
                        }
                    }

                    ConsolinnoSetUpButton {
                        text: qsTr("Cancel")
                        backgroundColor: "transparent"
                        onClicked: {
                            pageStack.pop()
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }
            }

        }
    }

    Component {
        id: dynamicSetUpFeedBack

        Page {
            id: root

            property string comboBoxValue: ""
            property string comboBoxCurrentText: ""


            header: NymeaHeader {
                text: qsTr("Dynamic electricity tariff")
                Layout.preferredWidth: app.width - 2*Style.margins
                backButtonVisible: true
                onBackPressed: {
                    if(directionID == 0) {
                        dynElectricThing = null
                        pageStack.pop()
                    }
                }
            }

            ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right; }
                spacing: 0

                ColumnLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        Layout.preferredWidth: app.width - 2*Style.margins
                        Layout.preferredHeight: 50
                        color: Material.foreground
                        text: qsTr("The following tariff is submitted:")
                        wrapMode: Text.WordWrap
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.Center
                    }

                    Text {
                        id: electricityRate
                        Layout.preferredWidth: app.width - 2*Style.margins
                        color: Material.foreground
                        text: qsTr(comboBoxCurrentText)
                        Layout.alignment: Qt.AlignCenter
                        horizontalAlignment: Text.Center
                    }

                    Image {
                        id: succesAddElectricRate
                        Layout.preferredWidth: 150
                        Layout.preferredHeight: 150
                        fillMode: Image.PreserveAspectFit
                        Layout.alignment: Qt.AlignCenter
                        source: "../images/tick.svg"
                    }

                    ColorOverlay {
                        anchors.fill: succesAddElectricRate
                        source: succesAddElectricRate
                        color: Material.accent
                    }

                }

                ColumnLayout {
                    spacing: 0
                    Layout.alignment: Qt.AlignHCenter

                    Button {
                        id: nextButton
                        text: qsTr("Next")
                        Layout.preferredWidth: 250
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: {
                            pageStack.push(taxesAndFeesSetUp)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: taxesAndFeesSetUp

        Page {

            header: NymeaHeader {
                text: qsTr("Dynamic electricity tariff")
                backButtonVisible: true
                onBackPressed: {
                    if(directionID >= 0) {
                        pageStack.pop()
                    }
                }
            }

            ColumnLayout {
                anchors {top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right;}
                Layout.fillWidth: true
                spacing: 0

                RowLayout {
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    spacing: 0
                    Text {
                        Layout.topMargin: 16
                        text: qsTr("Taxes and charges")
                        font.bold: true
                        font.pointSize: 14
                        color: Configuration.iconColor
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    RowLayout {
                        spacing: 0
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        Layout.fillWidth: true

                        Label {
                            Layout.fillWidth: true
                            rightPadding: 16
                            font.pointSize: 12
                            text: qsTr("Network charges")
                        }

                        TextField {
                            id: networkChargesField
                            Layout.rightMargin: 12
                            validator: RegExpValidator { regExp: /^[0-9.,]*$/ }
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }

                        Label {
                            text: "ct/kWh"
                        }
                    }

                    RowLayout {
                        spacing: 0
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        Layout.fillWidth: true

                        Label {
                            rightPadding: 16
                            Layout.fillWidth: true
                            font.pointSize: 12
                            text: qsTr("Taxes & fees")
                        }

                        TextField {
                            id: taxesAndFeesField
                            Layout.rightMargin: 12
                            validator: RegExpValidator { regExp: /^[0-9.,]*$/ }
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }

                        Label {
                            text: "ct/kWh"
                        }
                    }

                    Label {
                        id: footer
                        Layout.fillWidth: true
                        Layout.leftMargin: app.margins
                        Layout.rightMargin: app.margins
                        color: "red"
                        wrapMode: Text.WordWrap
                        font.pixelSize: app.smallFont
                    }

                    ColumnLayout {
                        spacing: 0
                        Layout.alignment: Qt.AlignHCenter
                        visible: true

                        Button {
                            id: saveButton
                            text: qsTr("Save")
                            Layout.preferredWidth: app.width - 2*Style.margins
                            Layout.alignment: Qt.AlignHCenter
                            onClicked: {
                                if((taxesAndFeesField.text > 0 && networkChargesField.text > 0)){
                                    //ToDo: Add Save Logic for Taxes And Fees and Network Charges

                                }else{
                                    footer.text = qsTr("Some attributes are outside of the allowed range: Configurations were not saved.")
                                }
                            }
                        }

                        ConsolinnoSetUpButton {
                            text: qsTr("Cancel")
                            backgroundColor: "transparent"
                            onClicked: {
                                if(directionID === 0){
                                    pageStack.pop()
                                    pageStack.pop()
                                }else{
                                    pageStack.pop()
                                }
                                dynElectricThing = null
                            }
                        }
                    }

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }

                }
            }
        }
    }

}
