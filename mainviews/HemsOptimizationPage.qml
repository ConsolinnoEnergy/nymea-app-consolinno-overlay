import QtQuick 2.8
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

Page {
    id: root
    signal startWizard()
    header: NymeaHeader {
        text: qsTr("Configurations")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    property HemsManager hemsManager
    ListModel {
        id: useCasesModel
        ListElement { text: qsTr("Optimization configuration"); value: 0; visible: true}
        ListElement { text: qsTr("Comissioning"); value: 1; visible: true}
        ListElement { text: qsTr("Development"); value: 2; visible: false}
        ListElement { text: qsTr("Dynamic electricity tariff"); value: 3; visible: true}
        ListElement { text: qsTr("Grid-supportive control"); value: 4; visible: true}
        // value is set to an integer for pieces which are either going to be migrated to a different location or deleted
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
                id: iconModel
                Layout.fillWidth: true
                iconName: {
                    if (model.value === 0)
                        return "/icons/settings.svg"
                    if (model.value === 1)
                        return "/icons/configure.svg"
                    if (model.value === 2)
                        return "/icons/configure.svg"
                    if (model.value === 3 && Configuration.energyIcon !== ""){
                        return "/ui/images/"+Configuration.energyIcon;
                    }else if (model.value === 3 && Configuration.energyIcon === ""){
                        return "/icons/energy.svg";
                    }else if (model.value === 4 && Configuration.gridIcon !== ""){
                        return "/ui/images/"+Configuration.gridIcon;
                    }else if(model.value === 4 && Configuration.gridIcon === ""){
                        return "/icons/grid.svg";
                    }
                }
                text: model.text
                visible: (hemsManager.availableUseCases) != 0 && (model.visible || settings.showHiddenOptions)
                progressive: true
                onClicked: {
                    switch (model.value) {
                    case 0:
                        pageStack.push(Qt.resolvedUrl("OptimizationConfiguration.qml"), { hemsManager: hemsManager })
                        break;
                    case 1:
                        var page = pageStack.push(Qt.resolvedUrl("../thingconfiguration/DeviceOverview.qml"), { hemsManager: hemsManager })
                        page.startWizard.connect(function(){
                            root.startWizard()
                        })
                        break;
                    case 2:
                        pageStack.push(Qt.resolvedUrl("../optimization/DeveloperConfig.qml"), { hemsManager: hemsManager})
                        break;
                    case 3:
                        pageStack.push(Qt.resolvedUrl("../optimization/DynamicElectricityRate.qml"), { hemsManager: hemsManager})
                        break;
                    case 4:
                        pageStack.push(Qt.resolvedUrl("../optimization/GridSupportiveControl.qml"), { hemsManager: hemsManager})
                        break;
                    }
                }

                Image {
                    id: icons
                    height: 24
                    width: 24
                    source: iconModel.iconName
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
