import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea
import NymeaApp.Utils
import "../components"

GenericConfigPage {
    id: root

    property Thing thing: null
    property Thing gridSupport: null

    readonly property State currentPower: thing.stateByName("currentPower")
    readonly property State totalProduction: thing.stateByName("totalEnergyProduced")

    property bool showLppWarning: false
    property double lppPowerLimit: gridSupport.stateByName("lppValue") ? gridSupport.stateByName("lppValue").value : 0

    title: root.thing.name

    content: [
        Flickable {
            anchors.fill: parent
            contentHeight: columnLayout.implicitHeight +
                           columnLayout.anchors.topMargin +
                           columnLayout.anchors.bottomMargin + root.navigationFooterHeight
            clip: true

            ColumnLayout {
                id: columnLayout
                anchors { left: parent.left; right: parent.right; top: parent.top }
                anchors.margins: Style.margins
                spacing: Style.margins

                CoNotConnectedNotification {
                    Layout.fillWidth: true
                    thing: root.thing
                }

                CoNotification {
                    id: lppWarning
                    Layout.fillWidth: true
                    visible: showLppWarning
                    type: CoNotification.Type.Warning
                    title: qsTr("Feed-in curtailment")
                    message: qsTr("The feed-in is <b>limited temporarily</b> to <b>%1 kW</b> due to a control command from the grid operator.").arg(UiUtils.convertToKw(lppPowerLimit))
                }

                CoEnergyCircle {
                    id: energyCircle
                    property var rawPowerValue: root.currentPower ? root.currentPower.value : 0
                    Layout.fillWidth: true
                    power: Math.abs(rawPowerValue)
                    icon: UiUtils.interfacesToIcon(root.thing.thingClass.interfaces)
                    label: Math.round(rawPowerValue) < 0 ?
                               qsTr("Producing") :
                               qsTr("Idle")
                }

                RowLayout {
                    id: kpiCardsLayout
                    Layout.fillWidth: true
                    spacing: Style.margins

                    CoKPICard {
                        id: totalProductionCard
                        Layout.fillWidth: true
                        icon: Qt.resolvedUrl("qrc:/icons/functions.svg")
                        labelText: qsTr("Total production")
                        valueText: UiUtils.energyDisplayValue(root.totalProduction) + " kWh"
                    }
                }
            }
        }
    ]
}
