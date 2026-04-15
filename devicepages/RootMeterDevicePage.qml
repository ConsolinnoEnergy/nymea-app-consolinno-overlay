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

    readonly property State currentConsumption: thing.stateByName("currentPower")
    readonly property State totalConsumption: thing.stateByName("totalEnergyConsumed")
    readonly property State totalFeedIn: thing.stateByName("totalEnergyProduced")
    property bool lpcActive: (gridSupport && gridSupport.stateByName("isLpcActive") !== null) ?
                                 gridSupport.stateByName("isLpcActive").value :
                                 false
    property double lpcPowerLimit: gridSupport ? gridSupport.stateByName("lpcValue").value : 0

    function convertToKw(numberW){
        return (+(Math.round((numberW / 1000) * 100 ) / 100)).toLocaleString()
    }

    title: qsTr("Grid")
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
                    id: lpcWarning
                    Layout.fillWidth: true
                    visible: lpcActive
                    type: CoNotification.Type.Warning
                    title: qsTr("Grid-supportive control")
                    message: qsTr("Due to a control order from the network operator, the total power of controllable devices is <b>temporarily limited</b> to <b>%1 kW.</b> If, for example, you are currently charging your electric car, the charging process may not be carried out at the usual power level.").arg(convertToKw(lpcPowerLimit))
                }

                CoEnergyCircle {
                    id: energyCircle
                    property var rawPowerValue: root.currentConsumption ? root.currentConsumption.value : 0
                    Layout.fillWidth: true
                    power: Math.abs(rawPowerValue)
                    icon: Math.round(rawPowerValue) > 0 ?
                               Qt.resolvedUrl("qrc:/icons/output_circle.svg") :
                               Math.round(rawPowerValue) < 0 ?
                                   Qt.resolvedUrl("qrc:/icons/input_circle.svg") :
                                   app.interfacesToIcon(root.thing.thingClass.interfaces)
                    label: Math.round(rawPowerValue) > 0 ?
                               qsTr("Consuming") :
                               Math.round(rawPowerValue) < 0 ?
                                   qsTr("Producing") :
                                   qsTr("Idle")
                }

                RowLayout {
                    id: kpiCardsLayout
                    Layout.fillWidth: true
                    spacing: Style.margins

                    CoKPICard {
                        id: totalConsumptionCard
                        Layout.fillWidth: true
                        icon: Qt.resolvedUrl("qrc:/icons/output_circle.svg")
                        labelText: qsTr("Total grid consumption") // #TODO wording
                        // #TODO use decimal places when value is small?
                        valueText: (root.totalConsumption ? NymeaUtils.floatToLocaleString((+root.totalConsumption.value), 0) : "-") + qsTr(" kWh")
                    }

                    CoKPICard {
                        id: totalFeedInCard
                        Layout.fillWidth: true
                        icon: Qt.resolvedUrl("qrc:/icons/input_circle.svg")
                        labelText: qsTr("Total grid feed-in") // #TODO wording
                        // #TODO use decimal places when value is small?
                        valueText: (root.totalFeedIn ? NymeaUtils.floatToLocaleString((+root.totalFeedIn.value), 0) : "-") + qsTr(" kWh")
                    }
                }
            }
        }
    ]
}
