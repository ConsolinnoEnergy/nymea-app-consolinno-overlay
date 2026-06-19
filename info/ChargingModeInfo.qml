import QtQuick
import QtQuick.Controls
import QtQml
import Nymea 1.0
import QtQuick.Layouts
import "../components"
import "../delegates"

Page {
    id: root
    bottomPadding: 0
    property int navigationFooterHeight: 0
    property var stack
    property bool solarOnlyModeAvailable: false
    property bool nextTripModeAvailable: false
    property bool dynamicPricingModeAvailable: false

    header: ConsolinnoHeader {
        id: header
        show_Image: true
        text: qsTr("Charging mode")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }
    InfoTextInterface{
        navigationFooterHeight: root.navigationFooterHeight
        anchors.fill: parent
//        summaryText: qsTr("In the charging mode you set how the energy manager should charge the vehicle.")
        body: ColumnLayout{
            Layout.fillWidth: true
            id: bodyItem
            Label{
                Layout.fillWidth: true
                text: qsTr("Charging mode")
                leftPadding: app.margins +10
                rightPadding: app.margins +10

                font.bold: true
                font.pixelSize: 17

            }
            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("In charging mode, you set how the energy manager should charge the vehicle. PV surplus is allocated to devices according to your selected priority.")
            }

            Label{
                Layout.topMargin: 15
                Layout.fillWidth: true
                text: qsTr("Always charge")
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                font.bold: true
                font.pixelSize: 17
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("The vehicle is charged with maximum charging power until the vehicle is fully charged or until it stops charging.")
            }

            Label{
                Layout.topMargin: 15
                Layout.fillWidth: true
                text: qsTr("Solar power only")
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                font.bold: true
                font.pixelSize: 17
                visible: root.solarOnlyModeAvailable
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("The vehicle will be charged with solar power only. You can specify what should happen if there is not enough solar power available for charging. Charging can be paused or continued with minimum power from the grid. The default setting is pausing. If your car does not automatically continue charging after pausing when solar power is available again, then the option <b>Charge with minimum power</b> is useful. Note that the car/charger does not react immediately; when 60 seconds too little solar power is available than predicted, charging will not regulate down until there is 60 seconds more solar power available.")
                visible: root.solarOnlyModeAvailable
            }

            Label{
                Layout.topMargin: 15
                Layout.fillWidth: true
                text: qsTr("Next trip")
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                visible: root.nextTripModeAvailable

                font.bold: true
                font.pixelSize: 17

            }
            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("The charging mode is used to ensure a certain charge level until a departure time, while scheduling the charging to use as much of your own electricity as possible. If the own solar power is not sufficient to reach the charging target, grid import is scheduled accordingly. The charging plan depends on a forecast of the solar production, which, like every forecast, is always affected by inaccuracies. Therefore, please note that deviations from the forecast may occur; i.e. it may happen that less is charged then solar power was predicted, or conversely, grid import may occur if less solar power is available than the forecast assumed.")
                visible: root.nextTripModeAvailable
            }

            Label{
                Layout.topMargin: 15
                Layout.fillWidth: true
                text: qsTr("Dynamic pricing")
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                font.bold: true
                font.pixelSize: 17
                visible: root.dynamicPricingModeAvailable
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("In dynamic pricing charging mode, charging takes place at maximum charging current as soon as the price falls below the set price limit. At times when charging does not take place because the price limit is exceeded, charging takes place if there is a PV surplus. If the price limit is changed, this limit is preselected the next time it is plugged in.")
                visible: root.dynamicPricingModeAvailable
            }

            Label{
                Layout.topMargin: 15
                Layout.fillWidth: true
                text: qsTr("Time controlled")
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                font.bold: true
                font.pixelSize: 17
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("In this mode, your wallbox only charges within a defined time window. This means that you can define exactly one time slot per weekday. This lets you target charging to off-peak or bonus periods of your electricity tariff (e.g. overnight). Outside the time window, charging is paused. This mode requires that your wallbox supports pausing an ongoing charging session.")
            }

            Label{
                Layout.topMargin: 15
                Layout.fillWidth: true
                text: qsTr("Behavior when unplugged")
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                font.bold: true
                font.pixelSize: 17
            }

            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("The charging modes <b>Solar power only</b>, <b>Always charging</b>, <b>Dynamic pricing</b> and <b>Time controlled</b> remain selected after unplugging. This means that when you plug in again, the last selected mode is active. If you have charged with <b>Next trip</b>, you must select a charging mode again when you plug in.")
            }

        }

    }

}

