import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2
import "../components"
import "../delegates"

Page {
    property var stack
    header: ConsolinnoHeader {
        id: header
        show_Image: true
        text: qsTr("Charging mode")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }
    InfoTextInterface{
        anchors.fill: parent
//        summaryText: qsTr("In the charging mode you set how the energy manager should charge the vehicle.")
        body: ColumnLayout{
            Layout.fillWidth: true
            id: bodyItem
            Label{
                Layout.fillWidth: true
                text: qsTr("Charging Mode")
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
                text: qsTr("In charging mode, you set how the energy manager should charge the vehicle.")
            }

            Label{
                Layout.topMargin: 15
                Layout.fillWidth: true
                text: qsTr("Next Trip")
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
                text: qsTr("The charging mode is used to ensure a certain charge level until a departure time, while scheduling the charging to use as much of your own electricity as possible. If the own solar power is not sufficient to reach the charging target, the grid supply (or grid supply times) is scheduled accordingly. The charging plan depends on a forecast of the solar production, which, like every forecast, is always affected by inaccuracies. Therefore, please note that deviations from the forecast may occur, i.e. it may happen that less is charged than solar power is currently available, since less solar power was predicted, or conversely, grid draw may occur if less solar power is available than the forecast assumed.")
            }

            Label{
                Layout.topMargin: 15
                Layout.fillWidth: true
                text: qsTr("Solar Power Only")
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
                text: qsTr("The vehicle will be charged with solar power only. You can specify what should happen if there is not enough solar power available for charging. Charging can be paused or continued with minimal power from the grid. The default setting is pausing. If your car does not automatically continue charging after pausing when its solar power is available again, then the option <font color=\"#87BD26\">Charge with minimum power</font> is useful. Note that the charging current will not regulate down until there is 60 seconds too less solar power available and vice versa will not regulate up until there is 60 seconds more solar power available.")
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
                text: qsTr("Dynamic Tariff")
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
                text: qsTr("In dynamic tariff charging mode, charging takes place at maximum charging current as soon as the price falls below the set price limit. At times when charging does not take place because the price limit is exceeded, charging takes place if there is a PV surplus. If the price limit is changed, this limit is preselected the next time it is plugged in.")
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
                text: qsTr("The charging modes <font color=\"%1\">Solar power only</font>, <font color=\"%1\">Always charging</font> and <font color=\"%1\">Dynamic tariff</font> remain selected after unplugging. This means that when you plug in again, the last selected mode is active. If you have charged with <font color=\"%1\">Next trip</font>, you must select a charging mode again when you plug in.").arg(Style.consolinnoMedium)
            }

        }

    }

}

