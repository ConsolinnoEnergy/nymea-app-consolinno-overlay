import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"

Page {
    id: root

    header: NymeaHeader {
        text: qsTr("Optimizations")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    property HemsManager hemsManager

    ListModel {
        id: useCasesModel
        ListElement { text: qsTr("Blackout protection"); value: HemsManager.HemsUseCaseBlackoutProtection }
        ListElement { text: qsTr("Heating"); value: HemsManager.HemsUseCaseHeating }
        ListElement { text: qsTr("Charging"); value: HemsManager.HemsUseCaseCharging }
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins

        Repeater {
            model: useCasesModel
            delegate: NymeaItemDelegate {
                Layout.fillWidth: true
                iconName: {
                    if (model.value === HemsManager.HemsUseCaseBlackoutProtection)
                        return "../images/attention.svg"

                    if (model.value === HemsManager.HemsUseCaseHeating)
                        return "../images/thermostat/heating.svg"

                    if (model.value === HemsManager.HemsUseCaseCharging)
                        return "../images/ev-charger.svg"
                }
                text: model.text
                visible: (hemsManager.availableUseCases & model.value) != 0
                progressive: model.value !== HemsManager.HemsUseCaseBlackoutProtection
                onClicked: {
                    switch (model.value) {
//                    case HemsManager.HemsUseCaseBlackoutProtection:
//                        pageStack.push(blackoutProtectionComponent, { hemsManager: hemsManager })
//                        break;
                    case HemsManager.HemsUseCaseHeating:
                        pageStack.push(heatingComponent, { hemsManager: hemsManager })
                        break;
                    case HemsManager.HemsUseCaseCharging:
                        pageStack.push(chargingComponent, { hemsManager: hemsManager })
                        break;
                    }
                }
            }
        }
    }

    Component {
        id: blackoutProtectionComponent

        Page {
            id: root
            property HemsManager hemsManager

            header: NymeaHeader {
                text: qsTr("Blackout protection")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            // TODO: maybe allow to disable, or prioritize which ev charger should be adjusted first or something like that
        }
    }

    Component {
        id: heatingComponent

        Page {
            id: root
            property HemsManager hemsManager

            header: NymeaHeader {
                text: qsTr("Heating")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            // TODO: maybe open directly if there is only one configuration (save one click)

            ColumnLayout {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: app.margins

                Repeater {
                    model: hemsManager.heatingConfigurations
                    delegate: NymeaItemDelegate {
                        property HeatingConfiguration heatingConfiguration: hemsManager.heatingConfigurations.getHeatingConfiguration(model.heatPumpThingId)
                        property Thing heatPumpThing: engine.thingManager.things.getThing(model.heatPumpThingId)
                        Layout.fillWidth: true
                        iconName: "../images/thermostat/heating.svg"
                        progressive: true
                        text: heatPumpThing.name
                        onClicked: pageStack.push(heatingConfigurationComponent, { hemsManager: hemsManager, heatingConfiguration: heatingConfiguration, heatPumpThing: heatPumpThing })
                    }
                }
            }

            Component.onCompleted: {
                if (hemsManager.heatingConfigurations.count === 1) {
                    onClicked: pageStack.push(heatingConfigurationComponent, { hemsManager: hemsManager, heatingConfiguration: heatingConfiguration, heatPumpThing: heatPumpThing })

                }
            }
        }
    }

    Component {
        id: heatingConfigurationComponent

        Page {
            id: root
            property HemsManager hemsManager
            property HeatingConfiguration heatingConfiguration
            property Thing heatPumpThing

            property bool heatMeterIncluded: heatPumpThing.thingClassId.interfaces.includes("heatmeter")
            // only if any configuration has changed, warn also on leaving if unsaved settings
            //property bool configurationSettingsChanged

            header: NymeaHeader {
                text: qsTr("Heating configuration")
                backButtonVisible: true
                onBackPressed: pageStack.pop()
            }

            ColumnLayout {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: app.margins

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: heatPumpThing.name
                    wrapMode: Text.WordWrap
                    //font.pixelSize: app.smallFont
                }

                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        Layout.fillWidth: true
                        text: qsTr("Optimization enabled")
                    }

                    Switch {
                        id: optimizationEnabledSwitch
                        checked: heatingConfiguration.optimizationEnabled
                    }
                }

                Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: app.margins
                    Layout.rightMargin: app.margins
                    text: qsTr("For a better optimization you can assign a heat meter which is measuring the produced heat energy of this heat pump.")
                    wrapMode: Text.WordWrap
                    font.pixelSize: app.smallFont
                    visible: !heatMeterIncluded
                }

                Button {
                    id: assignHeatMeter
                    Layout.fillWidth: true
                    // We only need to assign a hear meter if this heatpump does not provide one
                    visible: !heatMeterIncluded
                    text: qsTr("TODO: Assign heat meter")
                    // TODO: Select a heat meter from the things and show it here. Allow to reassign a heat meter and remove the assignment
                }

                Item {
                    // place holder
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                }

                Button {
                    Layout.fillWidth: true
                    text: qsTr("Save")
                    //enabled: configurationSettingsChanged
                    onClicked: {
                        // Set heating configuration

                    }
                }
            }
        }
    }


    Component {
        id: chargingComponent

        Page {
            id: root
            property HemsManager hemsManager
            property ChargingConfiguration chargingConfiguration
            property Thing evChargerThing

            header: NymeaHeader {
                text: qsTr("Charging")
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
                    model: hemsManager.heatingConfigurations
                    delegate: NymeaItemDelegate {
                        Layout.fillWidth: true
                        progressive: true
                        iconName: "../images/ev-charger.svg"
                        text: evChargerThing.name
                        //onClicked: pageStack.push(heatingConfigurationComponent, { hemsManager: hemsManager, heatingConfiguration: heatingConfiguration, heatPumpThing: heatPumpThing })
                    }
                }
            }
        }
    }

    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: hemsManager.availableUseCases === 0
        title: qsTr("No optimizations available")
        text: qsTr("Optimizations will be available once the required things have been added to the system.")
    }
}
