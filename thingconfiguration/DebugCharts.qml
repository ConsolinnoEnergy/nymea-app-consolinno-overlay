import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCharts
import Nymea
import "../components"
import "../optimization"

Page {
    id: root

    property ConEMSState conState: hemsManager.conEMSState
    // The manager emits the update signal; ConEMSState itself does not.
    property var currentState: conState ? conState.currentState : ({})
    readonly property var forecast: currentState.forecast || ({})
    readonly property var deviceSchedules: currentState.device_schedules || []

    function populateSeries(series, axisX, axisY, data) {
        series.clear()
        var xMin = Infinity
        var xMax = -Infinity
        var yMin = 0
        var yMax = 0
        for (let i = 0; i < data.length; i++) {
            const point = data[i]
            if (!point || point.length < 2 || point[0] === null || point[1] === null)
                continue
            const timestamp = Number(point[0]) * 1000
            const value = Number(point[1])
            if (!isFinite(timestamp) || !isFinite(value))
                continue
            series.append(timestamp, value)
            xMin = Math.min(xMin, timestamp)
            xMax = Math.max(xMax, timestamp)
            yMin = Math.min(yMin, value)
            yMax = Math.max(yMax, value)
        }
        if (!series.count) {
            const now = Date.now()
            axisX.min = new Date(now)
            axisX.max = new Date(now + 900000)
            axisY.min = 0
            axisY.max = 1
            return false
        }
        axisX.min = new Date(xMin)
        axisX.max = new Date(xMax > xMin ? xMax : xMin + 900000)
        axisY.min = yMin
        axisY.max = yMax > yMin ? yMax : yMin + 1
        return true
    }

    function updateForecast() {
        productionUpperSeries.clear()
        if (populateSeries(forecastSeries, valueAxisX, valueAxisY, forecast.data || [])) {
            powerBalanceLogs.startTime = valueAxisX.min
            powerBalanceLogs.endTime = valueAxisX.max
            powerBalanceLogs.fetchLogs()
        }
    }

    onForecastChanged: Qt.callLater(updateForecast)

    PowerBalanceLogs {
        id: powerBalanceLogs
        engine: _engine
        startTime: new Date(valueAxisX.min)
        endTime: new Date(valueAxisX.max)
        sampleRate: EnergyLogs.SampleRate15Mins
    }

    Connections {
        target: powerBalanceLogs
        onEntriesAdded: function(index, entries) {
            for (var i = 0; i < entries.length; i++) {
                var entry = entries[i]
                forecastChart.addEntry(entry)
            }
        }
        onEntriesRemoved: function(index, count) {
            productionUpperSeries.removePoints(index, count)
        }
    }

    Connections {
        target: hemsManager
        onConEMSStateChanged: function(state) {
            root.currentState = state.currentState
        }
    }

    header: CoHeader {
        id: header
        text: qsTr("Debug Charts")
        onBackPressed: pageStack.pop()
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            width: parent.width

            ChartView {
                id: forecastChart
                title: "Forecast"
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(300, root.height * 0.6)
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
                    name: "Solar forecast (" + (root.forecast.source || "") + ")"
                    id: forecastSeries
                    axisX: valueAxisX
                    axisY: valueAxisY
                }
            }

            Repeater {
                model: root.deviceSchedules

                delegate: ChartView {
                    id: scheduleChart
                    required property var modelData
                    readonly property var schedule: modelData
                    title: schedule.label || schedule.source || schedule.thingId || "Device schedule"
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.max(300, root.height * 0.6)
                    antialiasing: true

                    function updateChart() {
                        root.populateSeries(scheduleSeries, scheduleAxisX, scheduleAxisY,
                                            schedule.data || [])
                    }

                    onScheduleChanged: Qt.callLater(updateChart)
                    Component.onCompleted: updateChart()

                    DateTimeAxis {
                        id: scheduleAxisX
                        titleText: "Time"
                        format: "dd.MM HH:mm"
                    }

                    ValueAxis {
                        id: scheduleAxisY
                        titleText: scheduleChart.schedule.deviceType === "heat_pump" ? "SG-Ready state"
                                   : scheduleChart.schedule.deviceType === "switch" ? "On / off (0 / 1)"
                                   : "Power in W"
                        min: 0
                        max: 1
                    }

                    LineSeries {
                        id: scheduleSeries
                        name: scheduleChart.title
                        axisX: scheduleAxisX
                        axisY: scheduleAxisY
                    }
                }
            }
        }
    }

    Component.onCompleted: updateForecast()
}
