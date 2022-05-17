import QtQuick 2.9
import QtCharts 2.3
import Nymea 1.0

Item {
    id: root
    property Thing thing: null
    property alias viewStartTime: logsModel.viewStartTime
    property date viewEndTime: new Date()
    property alias sampleRate: seriesAdapter.sampleRate
    property color color: "black"
    property XYSeries baseSeries: null
    property alias inverted: seriesAdapter.inverted

    signal clicked();

    onViewEndTimeChanged: seriesAdapter.ensureSamples(viewStartTime, viewEndTime)

    QtObject {
        id: d
        property AreaSeries areaSeries: null
    }

    Connections {
        target: d.areaSeries
        onClicked: root.clicked()
    }

    readonly property var model: LogsModel {
        id: logsModel
        objectName: root.thing.name
        engine: _engine
        thingId: root.thing.id
        typeIds: [root.thing.thingClass.stateTypes.findByName("currentPower").id]
        viewStartTime: axisAngular.min
        live: true
        onBusyChanged: {
            if (busy) {
                chartView.busyModels++
            } else {
                chartView.busyModels--
            }
        }
    }
    readonly property XYSeriesAdapter adapter: XYSeriesAdapter {
        id: seriesAdapter
        objectName: root.thing.name +  " adapter"
        logsModel: logsModel
        sampleRate: chartView.sampleRate
        xySeries: upperSeries
        baseSeries: root.baseSeries
    }
    readonly property XYSeries lineSeries: LineSeries {
        id: upperSeries
        onPointAdded: {
            var newPoint = upperSeries.at(index)

            if (newPoint.x > d.areaSeries.lowerSeries.at(0).x) {
                d.areaSeries.lowerSeries.replace(0, newPoint.x, 0)
            }
            if (newPoint.x < d.areaSeries.lowerSeries.at(1).x) {
                d.areaSeries.lowerSeries.replace(1, newPoint.x, 0)
            }
        }
    }

    Component {
        id: zeroSeriesComponent
        LineSeries {
            id: zeroSeries
            XYPoint { x: root.viewStartTime.getTime(); y: 0 }
            XYPoint { x: root.viewEndTime.getTime(); y: 0 }
        }
    }

    Component.onCompleted: {
        print("onCompleted", root.thing.name)
        d.areaSeries = chartView.createSeries(ChartView.SeriesTypeArea, root.thing.name, axisAngular, axisRadial)
        d.areaSeries.useOpenGL = true
        d.areaSeries.upperSeries = upperSeries;
        if (root.baseSeries) {
            d.areaSeries.lowerSeries = root.baseSeries;
        } else {
            d.areaSeries.lowerSeries = zeroSeriesComponent.createObject(root)
        }

        seriesAdapter.ensureSamples(root.viewStartTime, root.viewEndTime)

        d.areaSeries.color = root.color
        d.areaSeries.borderColor = root.color;
        d.areaSeries.borderWidth = 0;
    }

    Component.onDestruction: {
        chartView.removeSeries(d.areaSeries)
    }
}
