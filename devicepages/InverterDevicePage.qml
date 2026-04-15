import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import NymeaApp.Utils 1.0
import "../components"

GenericConfigPage {
    id: root

    property Thing thing: null
    property Thing gridSupport: null

    readonly property State currentPower: thing.stateByName("currentPower")
    readonly property State totalProduction: thing.stateByName("totalEnergyProduced")

    property bool showLppWarning: false
    property double lppPowerLimit: gridSupport.stateByName("lppValue") ? gridSupport.stateByName("lppValue").value : 0

    function convertToKw(numberW){
        return (+(Math.round((numberW / 1000) * 100 ) / 100)).toLocaleString()
    }

    title: root.thing.name
    headerOptionsVisible: false

    content: [
        Flickable {
            anchors.fill: parent
            contentHeight: columnLayout.implicitHeight +
                           columnLayout.anchors.topMargin +
                           columnLayout.anchors.bottomMargin
            clip: true

            ColumnLayout {
                id: columnLayout
                anchors.fill: parent
                anchors.margins: Style.margins
                spacing: Style.margins

                CoNotification {
                    id: lppWarning
                    Layout.fillWidth: true
                    visible: showLppWarning
                    type: CoNotification.Type.Warning
                    title: qsTr("Feed-in curtailment")
                    message: qsTr("The feed-in is <b>limited temporarily</b> to <b>%1 kW</b> due to a control command from the grid operator.").arg(convertToKw(lppPowerLimit))
                }

                CoEnergyCircle {
                    id: energyCircle
                    property var rawPowerValue: root.currentPower ? root.currentPower.value : 0
                    Layout.fillWidth: true
                    power: Math.abs(rawPowerValue)
                    icon: app.interfacesToIcon(root.thing.thingClass.interfaces)
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
                        labelText: qsTr("Total production") // #TODO wording
                        // #TODO use decimal places when value is small?
                        valueText: (root.totalProduction ? NymeaUtils.floatToLocaleString((+root.totalProduction.value), 0) : "-") + qsTr(" kWh")
                    }
                }
            }
        }
    ]
}
