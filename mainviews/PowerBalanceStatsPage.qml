import QtQuick 2.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.1
import "qrc:/ui/mainviews/energy/"
import "qrc:/ui/components/"
import Nymea 1.0

Page {
    id: root

    header: NymeaHeader {
        text: qsTr("History")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    property EnergyManager energyManager: null

    Flickable {
        anchors.fill: parent
        contentHeight: contentLayout.implicitHeight
        clip: true

        GridLayout {
            id: contentLayout
            anchors {left: parent.left; top: parent.top; right: parent.right }
            columns: app.landscape ? 2 : 1
            PowerBalanceStats {
                Layout.fillWidth: true
                Layout.preferredHeight: width
                energyManager: root.energyManager
            }

            ConsumerStats {
                Layout.fillWidth: true
                Layout.preferredHeight: width
                energyManager: root.energyManager
                visible: consumers.count > 0

                ThingsProxy {
                    id: consumers
                    engine: _engine
                    shownInterfaces: ["smartmeterconsumer"]
                }
            }
        }
    }

}
