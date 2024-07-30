import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.15

import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

Page {
    id: root

    property HemsManager hemsManager
    property string name

    readonly property Thing thing: currentThing !== null ? currentThing.get(0) : null

    property int directionID: 0

    signal done(bool skip, bool abort, bool back);

    header: NymeaHeader {
        text: qsTr("Dynamic Electricity Rate")
        backButtonVisible: true
        onBackPressed: {
            if(directionID == 0) {
                pageStack.pop()
            }

        }

    }

    QtObject {
        id: d
        property int pendingCallId: -1
    }

    Connections {
        target: hemsManager
    }

    ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right }
        width: app.width


        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 5
            Layout.rightMargin: 5

            Label {
            Layout.fillWidth: true
            text: qsTr("Submitted Rate:")
            wrapMode: Text.WordWrap
            Layout.alignment: Qt.AlignLeft
            horizontalAlignment: Text.AlignLeft
        }


        VerticalDivider
        {
            Layout.preferredWidth: app.width
            dividerColor: Material.accent
        }

        Flickable{
            id: energyRateFlickable
            clip: true
            width: parent.width
            height: parent.height
            contentHeight: energyRateFlickable.height
            contentWidth: app.width
            visible: erProxy.count !== 0

            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: app.height/3
            Layout.preferredWidth: app.width
            flickableDirection: Flickable.VerticalFlick

            ColumnLayout{
                id: energyRateFlickableList
                Layout.preferredWidth: app.width
                Layout.fillHeight: true
                Repeater{
                    id: energyRateRepeater
                    Layout.preferredWidth: app.width
                    model: ThingsProxy {
                        id: erProxy
                        engine: _engine
                        shownInterfaces: ["dynamicelectricitypricing"]
                    }
                    delegate: ItemDelegate{
                        Layout.preferredWidth: app.width
                        contentItem: ConsolinnoItemDelegate{
                            Layout.fillWidth: true
                            iconName: "../images/energy.svg"
                            progressive: false
                            text: erProxy.get(index) ? erProxy.get(index).name : ""
                            onClicked: {
                            }
                        }
                    }
                }
            }

        }

        Rectangle{
        Layout.preferredHeight: app.height/3
        Layout.fillWidth: true
        visible: erProxy.count === 0
        color: Material.background
            Text {
                text: qsTr("There is no rate set up yet")
                color: Material.foreground
                anchors.fill: parent
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignLeft
            }
        }

        VerticalDivider
        {
            Layout.preferredWidth: app.width
            dividerColor: Material.accent
        }

        }

        ColumnLayout {
            Layout.topMargin: Style.margins
            visible: erProxy.count === 0
            Label {
                Layout.fillWidth: true
                Layout.leftMargin: 5
                text: qsTr("Add Rate: ")
                wrapMode: Text.WordWrap
            }

            ComboBox {
                id: energyRateComboBox
                Layout.fillWidth: true
                Layout.leftMargin: 5
                Layout.rightMargin: 15
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
            visible: erProxy.count !== 0

            Layout.preferredWidth: app.width

            RowLayout {
                Layout.topMargin: 10
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                Label {
                    text: qsTr("Settings:")
                }
            }

            VerticalDivider
            {
                Layout.preferredWidth: app.width
                dividerColor: Material.accent
            }

            RowLayout {
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Label {
                    text: qsTr("Taxes and charges")
                    Layout.fillWidth: true
                }

                TextField {
                    text: "12"
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    Layout.preferredWidth: 60
                    maximumLength: 100

                    onTextChanged: {
                        saveSettings.enabled = true
                    }
                }

                Label {
                    Layout.rightMargin: 10
                    text: qsTr("ct/kWh")
                }

            }

            ColumnLayout {
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                Label {
                    text: qsTr("The electricity price is made up of the current stock market price as well as grid fees, taxes and charges.")
                    Layout.fillWidth: true
                    leftPadding: 5
                    rightPadding: 5
                    wrapMode: Text.WordWrap
                    Layout.preferredWidth: app.width

                }
            }

        }


        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        VerticalDivider
        {
            Layout.preferredWidth: app.width
            dividerColor: Material.accent
        }

        ColumnLayout {
            spacing: 0
            Layout.alignment: Qt.AlignHCenter
            visible: true

            Button {
                id: saveSettings
                text: qsTr("save")
                enabled: false
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignLeft
                visible: erProxy.count != 0
                onClicked: {
                    console.error("new record saved")
                    saveSettings.enabled = false
                }
            }

            Button {
                text: qsTr("cancel")
                Layout.preferredWidth: 200
                onClicked:
                    if(directionID == 0) {
                        pageStack.pop()
                    }
            }

            Button {
                id: addButton
                text: qsTr("add")
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignLeft
                visible: erProxy.count === 0
                onClicked: {
                    pageStack.push(settingsComponent, {thing: currentThing, thingValue: energyRateComboBox.currentValue, thingName: energyRateComboBox.currentText, })
                }
            }
        }

        VerticalDivider
        {
            Layout.preferredWidth: app.width
            dividerColor: Material.accent
        }

    }

    Component {
        id: settingsComponent

        Page {
            id: settingsView
            property HemsManager hemsManager
            property Thing thing: null
            property string thingName: ""
            property string thingValue: ""


            ThingClassesProxy {
                id: thing
                engine: _engine
                filterInterface: "dynamicelectricitypricing"
                includeProvidedInterfaces: true
            }

            header: NymeaHeader {
                visible: true
                text: qsTr("Tariff Settings")
                backButtonVisible: true
                onBackPressed: {
                    pageStack.pop()
                }

            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: app.margins

                RowLayout{
                    Layout.fillWidth: true
                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Taxes and charges")

                    }

                    TextField {
                        text: "12"
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        Layout.preferredWidth: 60
                        maximumLength: 100
                    }

                    Label {
                        text: qsTr("ct/kWh")
                    }
                }

                ColumnLayout {
                    Label {
                        text: qsTr("The electricity price is made up of the current stock market price as well as grid fees, taxes and charges.")
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        Layout.preferredWidth: app.width

                    }
                }

                Item {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                Button {
                    id: savebutton

                    Layout.fillWidth: true
                    text: qsTr("Save")
                    onClicked: {

                        thing.engine.thingManager.addThing(thingValue, thingName, 0)
                        pageStack.push(finishScreenComponent, {thingName: thingName } )
                    }
                }

            }
        }

    }

    Component {
        id: finishScreenComponent

        Page {
            id: finishScreen

            property HemsManager hemsManager
            property int directionID: 0
            property string thingName: ""

            header: NymeaHeader {
                text: qsTr("Dynamic Electricity Rate")
                Layout.preferredWidth: app.width - 2*Style.margins
                backButtonVisible: true
                onBackPressed: {
                    pageStack.pop()
                }
            }

            ColumnLayout {
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right;  margins: Style.margins }
                width: Math.min(parent.width - Style.margins * 2, 300)

                ColumnLayout {
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        Layout.preferredWidth: app.width - 2*Style.margins
                        Layout.preferredHeight: 50
                        color: Material.foreground
                        text: qsTr("The following Electric Rate is submitted")
                        wrapMode: Text.WordWrap
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.Center
                    }

                    Text {
                        id: electricityRate
                        Layout.preferredWidth: app.width - 2*Style.margins
                        color: Material.foreground
                        text: qsTr(thingName)
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
                        text: qsTr("next")
                        Layout.preferredWidth: 200
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: {
                            pageStack.pop()
                            pageStack.pop()
                            pageStack.pop()
                            pageStack.pop()
                        }

                    }

                }

            }

        }
    }

}
