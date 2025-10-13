import QtQuick 2.8
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

Page {
    id: root

    header: NymeaHeader {
        text: qsTr("Optimization configuration")
        backButtonVisible: true
        onBackPressed:{
            if ( hemsManager.availableUseCases === 0){
                pageStack.pop(root)
            }
            else{
                pageStack.pop()
            }
        }
    }

    property HemsManager hemsManager

    Component.onCompleted: {
        // Update like this because qml does not allow to set the value directly when using calculations
        useCasesModel.set(1, {value: HemsManager.HemsUseCaseHeating | HemsManager.HemsUseCaseHeatingRod})
    }

    ListModel {
        id: useCasesModel
        ListElement { text: qsTr("Blackout protection"); value: HemsManager.HemsUseCaseBlackoutProtection; visible: true }
        ListElement { text: qsTr("Heating"); value: 0; visible: true } // For setting the value see the Component.onCompleted function above
        //ListElement { text: qsTr("Heating Element"); value: HemsManager.HemsUseCaseHeatingElement; visible: true }
        ListElement { text: qsTr("Charging"); value: HemsManager.HemsUseCaseCharging; visible: true }
        ListElement { text: qsTr("Battery"); value: HemsManager.HemsUseCaseBattery; visible: true }
        ListElement { text: qsTr("Pv"); value: HemsManager.HemsUseCasePv; visible: true}
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
                id: allIcons
                Layout.fillWidth: true
                iconName: {
                    let icon = "";
                    switch (model.value) {
                        case HemsManager.HemsUseCaseBlackoutProtection:
                            icon = "../images/attention.svg";
                            break;
                        case HemsManager.HemsUseCaseHeating | HemsManager.HemsUseCaseHeatingRod:
                            if(Configuration.heatpumpIcon !== ""){
                                icon = "qrc:/ui/images/"+Configuration.heatpumpIcon;
                            }else{
                                icon = "../images/thermostat/heating.svg";
                            }
                            break;
                        case HemsManager.HemsUseCaseCharging:
                            icon = Configuration.evchargerIcon !== "" ? "../images/" + Configuration.evchargerIcon : "../images/ev-charger.svg";
                            break;
                        case HemsManager.HemsUseCaseBattery:
                            icon = Configuration.batteryIcon !== "" ? "../images/" + Configuration.batteryIcon : "../images/battery/battery-080.svg";
                            break;
                        case HemsManager.HemsUseCasePv:
                            icon = Configuration.inverterIcon !== "" ? "../images/" + Configuration.inverterIcon : "../images/weathericons/weather-clear-day.svg";
                            break;
                        case HemsManager.HemsUseCaseHeatingRod:
                            icon = "../images/sensors/water.svg";
                            break;
                    }
                    return icon;
                }

                Image {
                    id: icons
                    height: 24
                    width: 24
                    source: allIcons.iconName
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    z: 2
                }

                ColorOverlay {
                    anchors.fill: icons
                    source: icons
                    color: Style.consolinnoMedium
                    z: 3
                }


                text: model.text
                visible: (hemsManager.availableUseCases & model.value) != 0 && (model.visible || settings.showHiddenOptions)
                progressive: true
                onClicked: {
                    switch (model.value) {
                    case HemsManager.HemsUseCaseBlackoutProtection:
                        pageStack.push(Qt.resolvedUrl("../optimization/BlackoutProtectionView.qml"), { hemsManager: hemsManager })
                        break;
                    case HemsManager.HemsUseCaseHeating | HemsManager.HemsUseCaseHeatingRod:
                        pageStack.push(Qt.resolvedUrl("../optimization/HeatingConfigurationView.qml"), { hemsManager: hemsManager })
                        break;
                    case HemsManager.HemsUseCaseCharging:
                        pageStack.push(Qt.resolvedUrl("../optimization/ChargingConfigurationView.qml"), { hemsManager: hemsManager })
                        break;
                    case HemsManager.HemsUseCaseBattery:
                        pageStack.push(Qt.resolvedUrl("../optimization/BatteryConfigurationView.qml"), { hemsManager: hemsManager })
                        break;
                    case HemsManager.HemsUseCasePv:
                        pageStack.push(Qt.resolvedUrl("../optimization/PVConfigurationView.qml"), { hemsManager: hemsManager })
                        break;
                    case HemsManager.HemsUseCaseHeatingRod:
                        pageStack.push(Qt.resolvedUrl("../optimization/HeatingElementConfigurationView.qml"), { hemsManager: hemsManager })
                        break;
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
