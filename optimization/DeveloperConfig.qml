import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2

import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

// This is the Development Page
// This is only visible if the Hidden Options are activated, so if you push something be sure it is disabled.
// In order to add something to the development page do the following 3 steps:
Page {
    id: root

    header: NymeaHeader {
        text: qsTr("Development")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    property HemsManager hemsManager
    // 1. add a ListElement with your feature name and a random value that is not taken yet
    ListModel {
        id: useCasesModel
        ListElement { text: qsTr("CarSimulation"); value: 9}
        ListElement { text: qsTr("ConEMS Observer"); value: 10}
        ListElement { text: qsTr("User config Test"); value: 11}
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
                // 2. add an icon for it, if you dont want to search for one just pick a random one
                iconName: {
                    if (model.value === 9)
                        return"../images/car.svg"
                    if (model.value === 10)
                        return"../images/chart.svg"
                    if (model.value === 11)
                        return"../images/edit.svg"

                }
                text: model.text
                visible: (hemsManager.availableUseCases & model.value) != 0
                progressive: true
                // 3a. link to the a new page if you are working on a new page
                // 3b. Make a new page Copy paste the old page and do your stuff, if you want to add something to an existing page.
                // Note: make sure you are the only one working on this page or mark your changes accordingly if you work with a colleague
                onClicked: {
                    switch (model.value) {
                    case 9:
                        pageStack.push(Qt.resolvedUrl("../thingconfiguration/carSimulation.qml"), { hemsManager: hemsManager})
                        break;
                    case 10:
                        pageStack.push(Qt.resolvedUrl("../thingconfiguration/ConEMSObserver.qml"), { hemsManager: hemsManager})
                        break;
                    case 11:
                        pageStack.push(Qt.resolvedUrl("../optimization/UserConfig.qml"), { hemsManager: hemsManager})
                        break;
                    }


                }
            }
        }
    }




}
