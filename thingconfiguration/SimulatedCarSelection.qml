import QtQuick
import QtQuick.Controls
import QtQml
import QtQuick.Layouts
import Nymea
import Qt5Compat.GraphicalEffects

import "../components"
import "../delegates"

Page {
    id: root
    bottomPadding: 0
    property int navigationFooterHeight: 0

    property string wallboxUuid: ""

    signal done(var selectedCar)
    signal back()

    header: null

    CoHeader {
        id: header
        anchors { left: parent.left; right: parent.right; top: parent.top }
        z: 1
        blurSource: bodyFlickable
        text: qsTr("Select car")
        backButtonVisible: true
        onBackPressed: root.back()
    }

    ThingsProxy {
        id: simulationCarsProxy
        engine: _engine
        shownInterfaces: ["electricvehicle"]
        requiredStateName: "pluggedInToChargePoint"
    }

    Flickable {
        id: bodyFlickable
        clip: true
        anchors.fill: parent
        topMargin: header.height
        contentHeight: layout.implicitHeight +
                       layout.anchors.topMargin +
                       layout.anchors.bottomMargin + root.navigationFooterHeight
        Component.onCompleted: Qt.callLater(() => contentY = -topMargin)

        ColumnLayout {
            id: layout
            anchors { left: parent.left; right: parent.right; top: parent.top }
            anchors.margins: Style.margins
            spacing: Style.margins

            CoFrostyCard {
                id: vehiclesGroup
                Layout.fillWidth: true
                contentTopMargin: Style.smallMargins
                headerText: qsTr("Select simulated car to plug in")

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 0

                    CoCard {
                        Layout.fillWidth: true
                        text: qsTr("No car")
                        showChildrenIndicator: true
                        interactive: true

                        onClicked: {
                            root.done(null)
                        }
                    }

                    Repeater {
                        id: optimizerRepeater
                        Layout.fillWidth: true
                        model: simulationCarsProxy

                        delegate: CoCard {
                            id: carCard
                            readonly property var car: simulationCarsProxy.get(index)
                            readonly property var chargePointState: car ? car.stateByName("pluggedInToChargePoint") : null
                            readonly property string chargePointId: chargePointState ? String(chargePointState.value).replace(/[{}]/g, "") : ""

                            // The backend reports an unplugged car as empty or null UUID
                            readonly property bool unplugged: chargePointId === "" || /^0{8}-(0{4}-){3}0{12}$/.test(chargePointId)

                            Layout.fillWidth: true
                            enabled: unplugged || chargePointId === root.wallboxUuid
                            text: car ? car.name : ""
                            showChildrenIndicator: true
                            interactive: true

                            onClicked: {
                                root.done(simulationCarsProxy.get(index))
                            }
                        }
                    }
                }
            }
        }
    }
}


