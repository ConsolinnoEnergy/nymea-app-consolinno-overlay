import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

Page {
    id: root


    header: NymeaHeader {
        text: qsTr("Optimizations")
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
    ListModel {
        id: useCasesModel
        ListElement { text: qsTr("Blackout protection"); value: HemsManager.HemsUseCaseBlackoutProtection; visible: true }
        ListElement { text: qsTr("Heating"); value: HemsManager.HemsUseCaseHeating; visible: true }
        //ListElement { text: qsTr("Charging"); value: HemsManager.HemsUseCaseCharging; visible: true }
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
                Layout.fillWidth: true
                iconName: {
                    if (model.value === HemsManager.HemsUseCaseBlackoutProtection)
                        return "../images/attention.svg"
                    if (model.value === HemsManager.HemsUseCaseHeating)
                        return "../images/thermostat/heating.svg"
                    if (model.value === HemsManager.HemsUseCaseCharging)
                        return "../images/ev-charger.svg"
                    if (model.value === HemsManager.HemsUseCasePv)
                        return"../images/weathericons/weather-clear-day.svg"


                }
                text: model.text
                visible: (hemsManager.availableUseCases & model.value) != 0 && (model.visible || settings.showHiddenOptions)
                progressive: true
                onClicked: {
                    switch (model.value) {
                    case HemsManager.HemsUseCaseBlackoutProtection:
                        pageStack.push(Qt.resolvedUrl("../optimization/BlackoutProtectionView.qml"), { hemsManager: hemsManager })
                        break;
                    case HemsManager.HemsUseCaseHeating:
                        pageStack.push(Qt.resolvedUrl("../optimization/HeatingConfigurationView.qml"), { hemsManager: hemsManager })
                        break;
                    case HemsManager.HemsUseCaseCharging:
                        pageStack.push(Qt.resolvedUrl("../optimization/ChargingConfigurationView.qml"), { hemsManager: hemsManager })
                        break;
                    case HemsManager.HemsUseCasePv:
                        pageStack.push(Qt.resolvedUrl("../optimization/PVConfigurationView.qml"), { hemsManager: hemsManager })
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
