import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2

import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

// This is the Development Page
// This is only visible if the Hidden Options are activated, so if you push something be sure it is disabled.
// In order to add something to the development page do the following step:
Page {
    id: root

    header: NymeaHeader {
        text: qsTr("Development")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    property HemsManager hemsManager

    // Add your page here:
    // Name, where it is and which attributes it needs
    // Note you may have to instantiate the attributes that you want to add
    Component.onCompleted: {
        useCasesModel.append({ text: "CarSimulation", link: "../thingconfiguration/carSimulation.qml", attributes: {hemsManager: hemsManager}  })
        useCasesModel.append({ text: "ConEMS Observer", link: "../thingconfiguration/ConEMSObserver.qml", attributes: {hemsManager: hemsManager} })
        useCasesModel.append({ text: "User config Test", link: "../optimization/UserConfig.qml", attributes: {hemsManager: hemsManager} })
        useCasesModel.append({ text: "Installer Data Test", link: "../wizards/InstallerDataView.qml", attributes: {hemsManager: hemsManager} })
        useCasesModel.append({ text: "ChargingOptimization ConfigTest", link: "../optimization/ChargingOptimization.qml", attributes: {hemsManager: hemsManager} })


    }


    ListModel {
        id: useCasesModel

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
                        return"../images/edit.svg"
                }
                text: model.text
                //visible: (hemsManager.availableUseCases) != 0
                progressive: true
                onClicked: {
                        pageStack.push(Qt.resolvedUrl(model.link), model.attributes)



                }
            }
        }
    }




}
