import QtQuick 2.8
import QtQuick.Controls 2.1
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
        ListElement { text: qsTr("Grid Supportive Control"); value: 3; visible: false}
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
                Layout.fillWidth: true
                iconName: {
                    if (model.value === 0)
                        return "../images/settings.svg"
                    if (model.value === 1)
                        return "../images/configure.svg"
                    if (model.value === 2)
                        return "../images/configure.svg"
                    /*
                    if (model.value === 3)
                        return "../images/configure.svg"
                    */


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
                        pageStack.push(Qt.resolvedUrl("../optimization/EvChargerOptimization.qml"), { hemsManager: hemsManager})
                        break;
                    /*
                       pageStack.push(Qt.resolvedUrl("../optimization/GridSupportiveControlConfig.qml"), { hemsManager: hemsManager})
                      */
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
