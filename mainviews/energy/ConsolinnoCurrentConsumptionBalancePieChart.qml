import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.0
import QtCharts 2.2
import Nymea 1.0

ChartView {
    id: consumptionPieChart
    backgroundColor: "transparent"
    animationOptions: animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation
    title: qsTr("My energy consumption")
    titleColor: Style.foregroundColor
    legend.visible: false

    margins.left: 0
    margins.right: 0
    margins.bottom: 0
    margins.top: 0

    property bool animationsEnabled: true
    property EnergyManager energyManager: null
    property var totalColors: null


    ThingsProxy {
        id: batteries
        engine: _engine
        shownInterfaces: ["energystorage"]
    }

    PieSeries {
        id: consumptionBalanceSeries
        size: 0.88
        holeSize: 0.7

        property double fromGrid: Math.max(0, energyManager.currentPowerAcquisition)
        property double fromStorage: -Math.min(0, energyManager.currentPowerStorage)
        property double fromProduction: energyManager.currentPowerConsumption - fromGrid - fromStorage

        PieSlice {
            color: totalColors[2]
            borderColor: color
            borderWidth: 0
            value: consumptionBalanceSeries.fromGrid
        }
        PieSlice {
            color: totalColors[1]
            borderColor: color
            borderWidth: 0
            value: consumptionBalanceSeries.fromProduction
        }
        PieSlice {
            color: totalColors[5]
            borderColor: color
            borderWidth: 0
            value: consumptionBalanceSeries.fromStorage
        }
        PieSlice {
            color: Style.tooltipBackgroundColor
            borderColor: color
            borderWidth: 0
            value: consumptionBalanceSeries.fromGrid == 0 && consumptionBalanceSeries.fromProduction == 0 && consumptionBalanceSeries.fromStorage == 0 ? 1 : 0
        }
    }


    Column {
        id: centerLayout
        x: consumptionPieChart.plotArea.x + (consumptionPieChart.plotArea.width - width) / 2
        y: consumptionPieChart.plotArea.y + (consumptionPieChart.plotArea.height - height) / 2
        width: consumptionPieChart.plotArea.width * 0.65
//                    height: consumptionPieChart.plotArea.height * 0.65
        height: childrenRect.height
        spacing: Style.smallMargins

        ColumnLayout {
            width: parent.width
            spacing: 0
            Label {
                text: qsTr("Total")
                font: Style.smallFont
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                text: "%1 %2"
                .arg((energyManager.currentPowerConsumption / (energyManager.currentPowerConsumption > 1000 ? 1000 : 1)).toFixed(1))
                .arg(energyManager.currentPowerConsumption > 1000 ? "kW" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.bigFont

            }
        }


        ColumnLayout {
            width: parent.width
            spacing: 0
            Label {
                text: qsTr("From grid")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.extraSmallFont
            }
            Label {
                property double absValue: consumptionBalanceSeries.fromGrid
                color: totalColors[2]
                text: "%1 %2"
                .arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
                .arg(absValue > 1000 ? "kW" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.smallFont
            }
        }


        ColumnLayout {
            width: parent.width
            spacing: 0
            Label {
                text: qsTr("From self production")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.extraSmallFont
            }
            Label {
                color: Qt.darker(totalColors[1], 1.1)
                property double absValue: consumptionBalanceSeries.fromProduction
                text: "%1 %2".arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
                .arg(absValue > 1000 ? "kW" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.smallFont
            }
        }
        ColumnLayout {
            width: parent.width
            spacing: 0
            visible: batteries.count > 0
            Label {
                text: qsTr("From battery")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.extraSmallFont
            }
            Label {
                color: Qt.darker(totalColors[5], 1.1)
                property double absValue: consumptionBalanceSeries.fromStorage
                text: "%1 %2".arg((absValue / (absValue > 1000 ? 1000 : 1)).toFixed(1))
                .arg(absValue > 1000 ? "kW" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.smallFont
            }
        }
    }
}
