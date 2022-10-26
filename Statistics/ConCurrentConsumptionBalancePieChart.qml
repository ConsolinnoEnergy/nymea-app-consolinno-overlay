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
    //animationOptions: animationsEnabled ? NymeaUtils.chartsAnimationOptions : ChartView.NoAnimation
    titleColor: Style.foregroundColor
    legend.visible: false
    antialiasing: true

    margins.left: 0
    margins.right: 0
    margins.bottom: 0
    margins.top: 0

    //property bool animationsEnabled: true
    property EnergyManager energyManager: null

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
            color: "#F37B8E"
            borderColor: Style.backgroundColor

            value: consumptionBalanceSeries.fromGrid
        }
        PieSlice {
            color: "#FCE487"
            borderColor: Style.backgroundColor

            value: consumptionBalanceSeries.fromProduction
        }
        PieSlice {
            color: "#ACE3E2"
            borderColor: Style.backgroundColor
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
        height: childrenRect.height
        spacing: Style.smallMargins

        ColumnLayout {
            width: parent.width
            spacing: 0

            MouseArea{
                anchors.fill: parent
                onClicked:{
                    pageStack.push("../mainviews/DetailedGraphsPage.qml", {energyManager: energyManager, consumersColors: lsdChart.consumersColors})
                }
            }

            Image {
                id: home
                scale: 0.8
                source: "../images/home.svg"
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignCenter
                ColorOverlay{
                    anchors.fill: home
                    source: home
                    color: Material.foreground
                }

            }


            Label{
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font: Style.bigfont
                text: qsTr("Current consumption")

            }


            Label {
                text: "%1 %2"
                .arg((energyManager.currentPowerConsumption / (energyManager.currentPowerConsumption > 1000 ? 1000 : 1)).toFixed(1))
                .arg(energyManager.currentPowerConsumption > 1000 ? "kW" : "W")
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter

            }
        }

    }
}
