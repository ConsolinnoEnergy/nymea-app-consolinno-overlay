import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Controls
import QtQuick.Layouts
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
            pageStack.pop()
        }
    }

    Component.onCompleted: {
        // Update like this because qml does not allow to set the value directly when using calculations
        useCasesModel.set(1, {value: HemsManager.HemsUseCaseHeating | HemsManager.HemsUseCaseHeatingRod})
    }

    ListModel {
        id: useCasesModel
        ListElement { text: qsTr("Blackout protection"); value: HemsManager.HemsUseCaseBlackoutProtection; visible: true }
        ListElement { text: qsTr("Heating"); value: 0; visible: true } // For setting the value see the Component.onCompleted function above
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
                            icon = "/icons/arming_countdown.svg";
                            break;
                        case HemsManager.HemsUseCaseHeating | HemsManager.HemsUseCaseHeatingRod:
                            icon = "/icons/mode_heat.svg";
                            break;
                        case HemsManager.HemsUseCaseCharging:
                            icon = "/icons/ev_station.svg";
                            break;
                        case HemsManager.HemsUseCaseBattery:
                            icon = "/icons/battery/battery-060.svg";
                            break;
                        case HemsManager.HemsUseCasePv:
                            icon = "/icons/solar_power.svg";
                            break;
                    }
                    return Qt.resolvedUrl(icon);
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
                        pageStack.push(Qt.resolvedUrl("../optimization/BlackoutProtectionView.qml"))
                        break;
                    case HemsManager.HemsUseCaseHeating | HemsManager.HemsUseCaseHeatingRod:
                        pageStack.push(Qt.resolvedUrl("../optimization/HeatingConfigurationView.qml"))
                        break;
                    case HemsManager.HemsUseCaseCharging:
                        pageStack.push(Qt.resolvedUrl("../optimization/ChargingConfigurationView.qml"))
                        break;
                    case HemsManager.HemsUseCaseBattery:
                        pageStack.push(Qt.resolvedUrl("../optimization/BatteryConfigurationView.qml"))
                        break;
                    case HemsManager.HemsUseCasePv:
                        pageStack.push(Qt.resolvedUrl("../optimization/PVConfigurationView.qml"))
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
        buttonVisible: false
    }
}
