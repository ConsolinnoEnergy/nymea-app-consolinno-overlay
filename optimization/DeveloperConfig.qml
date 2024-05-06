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
    property UserConfiguration userconfig

    Component.onCompleted: {
        //menuEntriesModel.append({ text: "ConEMS Observer", link: "../thingconfiguration/ConEMSObserver.qml", attributes: {hemsManager: hemsManager} })
        menuEntriesModel.append({
                                    "text": "Debug Charts",
                                    "link": "../thingconfiguration/DebugCharts.qml",
                                    "attributes": {
                                        "hemsManager": hemsManager
                                    }
                                })
        menuEntriesModel.append({
                                    "text": "ConEMS State",
                                    "link": "../thingconfiguration/ConEMSState.qml",
                                    "attributes": {
                                        "hemsManager": hemsManager
                                    }
                                })
        menuEntriesModel.append({
                                    "text": "Power Averaging",
                                    "link": "../thingconfiguration/PowerAverageSetting.qml",
                                    "attributes": {
                                        "hemsManager": hemsManager,
                                        "userconfig": userconfig
                                    }
                                })
        //menuEntriesModel.append({ text: "ChargingOptimization ConfigTest", link: "../optimization/ChargingOptimization.qml", attributes: {hemsManager: hemsManager} })
    }

    ListModel {
        id: menuEntriesModel
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: app.margins

        Repeater {
            model: menuEntriesModel
            delegate: NymeaItemDelegate {
                Layout.fillWidth: true
                iconName: {
                    return "../images/edit.svg"
                }
                text: model.text
                progressive: true
                onClicked: {
                    pageStack.push(Qt.resolvedUrl(model.link), model.attributes)
                }
            }
        }
    }
}
