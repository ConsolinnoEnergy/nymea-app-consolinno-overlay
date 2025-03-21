import QtQuick 2.15
import Nymea 1.0
import QtCharts 2.3

Item {
    property var xAxis: []
    property var yAxis: []

    AreaSeries {
        axisX: xAxis
        axisY: yAxis
        color: '#ff0000'
        borderWidth: 2
        borderColor: '#ff0000'
        upperSeries: LineSeries {
          id: mainSeries
        }

        Component.onCompleted: {
          console.error(xAxis);
        }
    }

    function appendBar(posX, value) {
      mainSeries.append(posX, value);
    }
}
