import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.2
import QtCharts 2.3
import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"
import "../"


Page {
    id: root

    property HemsManager hemsManager
    property ConEMSState conState: hemsManager.conEMSState


    Connections{
        target: hemsManager
        onConEMSStateChanged:
        {
            console.log(conState)
            formattedJSON.text = JSON.stringify(conState, undefined, 4)
        }

    }





    header: ConsolinnoHeader{
        id: header
        text: qsTr("ConEMS Observer")
        onBackPressed: pageStack.pop()
    }





    ColumnLayout{
        anchors.fill: parent
        /**
       ChartView {
        anchors.fill: parent
        antialiasing: true

        ValueAxis {
            id: valueAxisY
            titleText: "Values"
        }

        DateTimeAxis {
            id: valueAxisX
            titleText: "Timestamp"
            format: "HH:mm:ss" // You can adjust the format as needed
        }

        LineSeries {
            name: "Forecast Data"
            axisX: valueAxisX
            axisY: valueAxisY

            // Loop through the subarrays in "forecast" to add data points
            Repeater {
                model: conState.currentState.forecast
                delegate: XYPoint {
                    x: new Date(modelData[0] * 1000) // Convert Unix timestamp to milliseconds
                    y: modelData[1]
                }
            }

            // Ensure the series is cleared and updated when it becomes visible
            onVisibleChanged: {
                if (visible) {
                    clear();
                    for (var i = 0; i < conState.currentState.forecast.length; i++) {
                        append(new Date(conState.currentState.forecast[i][0] * 1000), conState.currentState.forecast[i][1]);
                    }
                }
            }
        }
        }
        **/


        // Create a property to hold the data
        property var jsonData: {
            "objectName": "",
            "currentState": {
                "forecast": [
                    [
                        0.5,
                        0.5
                    ],
                    [
                        2,
                        2
                    ],
                    [
                        3,
                        3
                    ],
                ]
            },
        }

        function updateChartWithData() {
            // Clear the existing data
            //forecastSeries.clear();

            // Iterate through the new data and add it to the LineSeries

            var xMax = 0
            var xMin = conState.currentState.forecast[0][0]
            var yMax = 0
            var yMin = conState.currentState.forecast[0][1]

            for (var i = 0; i < conState.currentState.forecast.length; i++) {
                var dataPoint = conState.currentState.forecast[i];
                xMax = Math.max(xMax, dataPoint[0])
                xMin = Math.min(xMin, dataPoint[0])
                yMax = Math.max(yMax, dataPoint[1])
                yMin = Math.min(yMin, dataPoint[1])
                forecastSeries.append(new Date(dataPoint[0] * 1000), dataPoint[1]);
            }
            valueAxisX.max = new Date(xMax * 1000)
            valueAxisX.min = new Date(xMin * 1000)
            valueAxisY.min = yMin
            valueAxisY.max = yMax
        }
        ChartView {
            anchors.fill: parent
            antialiasing: true

            ValueAxis {
                id: valueAxisY
                titleText: "Solar forecast in kW"
                max:  10
                min: 0
            }

        DateTimeAxis {
            id: valueAxisX
            titleText: "Time"
            format: "HH:mm:ss"
        }

            LineSeries {
                name: "Forecast Data"
                id: forecastSeries
                axisX: valueAxisX
                axisY: valueAxisY
            }
        }

        Component.onCompleted: {
            updateChartWithData()
        }
        /*
        ScrollView {
            anchors.fill: parent
            TextEdit {
                id: formattedJSON
                readOnly: true
                anchors.fill: parent
                wrapMode: Text.Wrap
                text: JSON.stringify(conState, undefined, 4)
                selectByMouse: true
            }
        }
        */


    }
}
