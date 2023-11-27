import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.2
import QtCharts 2.3
import Nymea 1.0
import "../components"
import "../optimization"

Page {
    id: root

    property HemsManager hemsManager
    property ConEMSState conState: hemsManager.conEMSState

    PowerBalanceLogs {
        id: powerBalanceLogs
        engine: _engine
        startTime: new Date(valueAxisX.min)
        endTime: new Date(valueAxisX.max)
        sampleRate: EnergyLogs.SampleRate15Mins
    }

    Connections {
        target: powerBalanceLogs
        onEntriesAdded: {
            for (var i = 0; i < entries.length; i++) {
                var entry = entries[i]
                forecastChart.addEntry(entry)
            }
        }
        onEntriesRemoved: {
            productionUpperSeries.removePoints(index, count)
        }
    }

    Connections {
        target: hemsManager
        onConEMSStateChanged: {
            formattedJSON.text = JSON.stringify(conState, undefined, 4)
        }
    }

    header: ConsolinnoHeader {
        id: header
        text: qsTr("Debug Charts")
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors.fill: parent

        function updateChartWithData() {
            forecastSeries.clear()

            var xMax = 0
            var xMin = conState.currentState.forecast.data[0][0]
            var yMax = 0
            var yMin = conState.currentState.forecast.data[0][1]

            for (var i = 0; i < conState.currentState.forecast.data.length; i++) {
                var dataPoint = conState.currentState.forecast.data[i]
                xMax = Math.max(xMax, dataPoint[0])
                xMin = Math.min(xMin, dataPoint[0])
                yMax = Math.max(yMax, dataPoint[1])
                yMin = Math.min(yMin, dataPoint[1])
                forecastSeries.append(new Date(dataPoint[0] * 1000),
                                      dataPoint[1])
            }
            valueAxisX.max = new Date(xMax * 1000)
            valueAxisX.min = new Date(xMin * 1000)
            valueAxisY.min = yMin
            valueAxisY.max = yMax
            powerBalanceLogs.startTime = new Date(xMin * 1000)
            powerBalanceLogs.endTime = new Date(xMax * 1000)
            powerBalanceLogs.fetchLogs()
        }

        ChartView {
            id: forecastChart
            title: "Forecast"
            Layout.fillWidth: true
            Layout.fillHeight: true
            antialiasing: true

            ValueAxis {
                id: valueAxisY
                titleText: "Solar forecast in kW"
                max: 10
                min: 0
            }

            DateTimeAxis {
                id: valueAxisX
                titleText: "Time"
                format: "HH:mm:ss"
            }

            function calculateValue(entry) {
                return Math.abs(entry.production * 0.001)
            }
            function addEntry(entry) {
                productionUpperSeries.append(new Date(entry.timestamp.getTime()),
                                             calculateValue(entry))
                valueAxisY.max = Math.max(calculateValue(entry), valueAxisY.max)
            }

            LineSeries {
                id: productionUpperSeries
                axisX: valueAxisX
                axisY: valueAxisY
                color: "blue"
                name: "Measured production"
            }

            LineSeries {
                name: "Solar forecast (" + conState.currentState.forecast.source + ")"
                id: forecastSeries
                axisX: valueAxisX
                axisY: valueAxisY
            }
        }

        Component.onCompleted: {
            updateChartWithData()
        }
    }
}
