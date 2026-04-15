import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Nymea 1.0
import NymeaApp.Utils 1.0
import "../components"

GenericConfigPage {
    id: root

    property Thing thing: null
    readonly property State currentConsumption: root.thing.stateByName("currentPower")
    readonly property State totalConsumption: root.thing.stateByName("totalEnergyConsumed")

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

                CoEnergyCircle {
                    id: energyCircle
                    Layout.fillWidth: true
                    power: root.currentConsumption ? root.currentConsumption.value : 0
                    icon: app.interfacesToIcon(root.thing.thingClass.interfaces)
                    label: Math.round(power) > 0 ? qsTr("Consuming") : qsTr("Idle")
                }

                RowLayout {
                    id: kpiCardsLayout
                    Layout.fillWidth: true
                    spacing: Style.margins

                    CoKPICard {
                        id: totalConsumptionCard
                        Layout.fillWidth: true
                        icon: Qt.resolvedUrl("qrc:/icons/functions.svg")
                        labelText: qsTr("Total consumption") // #TODO wording
                        // #TODO use decimal places when value is small?
                        valueText: (root.totalConsumption ? NymeaUtils.floatToLocaleString((+root.totalConsumption.value), 0) : "-") + qsTr(" kWh")
                    }
                }
            }
        }
    ]
}
