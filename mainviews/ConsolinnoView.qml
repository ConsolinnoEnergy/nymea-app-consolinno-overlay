/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import QtCharts 2.3
import Nymea 1.0
import "../components"
import "../delegates"

MainViewBase {
    id: root


    readonly property bool loading: engine.thingManager.fetchingData

    QtObject {
        id: d
        property var currentWizard: null

        function setup(showFinalPage) {

            print("Setup. Installed energy meters:", energyMetersProxy.count, "EV Chargers:", evChargersProxy.count)

            if (energyMetersProxy.count === 0) {
                d.currentWizard = pageStack.push("/ui/wizards/SetupEnergyMeterWizard.qml")
                d.currentWizard.done.connect(function() {setup(true)})
                return
            }

//            if (evChargersProxy.count === 0) {
//                d.currentWizard = pageStack.push("/ui/wizards/SetupEVChargerWizard.qml")
//                d.currentWizard.done.connect(function() {setup(true)})
//                return
//            }

            if (showFinalPage) {
                var page = pageStack.push("/ui/wizards/WizardComplete.qml")
                page.done.connect(function() {exitWizard()})
            }
        }

        function exitWizard() {
            pageStack.pop(d.currentWizard, StackView.Immediate)
            pageStack.pop()
        }
    }

    onLoadingChanged: {
        if (!loading) {
            d.setup(false)
        }
    }

    ThingsProxy {
        id: energyMetersProxy
        engine: _engine
        shownInterfaces: ["energymeter"]
    }
    readonly property Thing rootMeter: energyMetersProxy.count > 0 ? energyMetersProxy.get(0) : null

    ThingsProxy {
        id: evChargersProxy
        engine: _engine
        shownInterfaces: ["evcharger"]
    }

    ThingsProxy {
        id: consumers
        engine: _engine
        shownInterfaces: ["smartmeterconsumer"]
    }
    ThingsProxy {
        id: producers
        engine: _engine
        shownInterfaces: ["smartmeterproducer"]
    }

    Item {
        id: lsdChart
        anchors.fill: parent
        anchors.topMargin: root.topMargin

        property int hours: 12

        readonly property var colors: ["#5e9ede", "#f8eb45", "#b15c95", "#c1362f", "#b6c741"]

        Canvas {
            id: linesCanvas
            anchors.fill: parent
            renderTarget: Canvas.FramebufferObject
            renderStrategy: Canvas.Cooperative

            property real lineAnimationProgress: 0
            NumberAnimation {
                target: linesCanvas
                property: "lineAnimationProgress"
                duration: 1000
                loops: Animation.Infinite
                from: 0
                to: 1
                running: true
            }
            onLineAnimationProgressChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.save();
                var xTranslate = chartView.x + chartView.plotArea.x + chartView.plotArea.width / 2
                var yTranslate = chartView.y + chartView.plotArea.y + chartView.plotArea.height / 2
                ctx.translate(xTranslate, yTranslate)

                var maxCurrentPower = rootMeter ? Math.abs(rootMeter.stateByName("currentPower").value) : 0;
                for (var i = 0; i < producers.count; i++) {
                    maxCurrentPower = Math.max(maxCurrentPower, Math.abs(producers.get(i).stateByName("currentPower").value))
                }
                for (var i = 0; i < consumers.count; i++) {
                    maxCurrentPower = Math.max(maxCurrentPower, Math.abs(consumers.get(i).stateByName("currentPower").value))
                }

                // dashed lines from rootMeter
                if (rootMeter) {
                    ctx.beginPath();
                    // rM : max = x : 5
                    var currentPower = rootMeter.stateByName("currentPower").value
                    ctx.lineWidth = currentPower * 5 / maxCurrentPower + 1
                    ctx.setLineDash([5, 2])
                    var rootmeterPosition = rootMeterTile.mapToItem(linesCanvas, rootMeterTile.width / 2, rootMeterTile.height)
                    var startX = rootmeterPosition.x - xTranslate
                    var startY = rootmeterPosition.y - yTranslate
                    var endX = -((producers.count) * 5)
                    var endY = - chartView.plotArea.height / 2
                    var height = startY - endY

                    var extensionLength = ctx.lineWidth * 7
                    var progress = currentPower > 0 ? 1 - lineAnimationProgress : lineAnimationProgress
                    var extensionStartY = startY - extensionLength * progress

                    ctx.moveTo(startX, extensionStartY);
                    ctx.lineTo(startX, startY);
                    ctx.bezierCurveTo(startX, endY + height / 2, endX, startY - height / 2, endX, endY)
                    ctx.stroke();
                    ctx.closePath();
                }

                for (var i = 0; i < producers.count; i++) {
                    ctx.beginPath();
                    // rM : max = x : 5
                    var producer = producers.get(i)
                    var currentPower = producer.stateByName("currentPower").value
                    ctx.lineWidth = currentPower * 5 / maxCurrentPower + 1
                    ctx.setLineDash([5, 2])
                    var tile = legendProducersRepeater.itemAt(i)
                    var position = tile.mapToItem(linesCanvas, tile.width / 2, tile.height)
//                    print("consumer pos", consumer.name, consumerPosition)
                    var startX = position.x - xTranslate
                    var startY = position.y - yTranslate
                    var endX = 10 * i - ((producers.count - 1) * 5)
                    var endY = -chartView.plotArea.height / 2
                    var height = startY - endY

                    var extensionLength = ctx.lineWidth * 7 // 5 + 2 dash segments from setLineDash
                    var progress = currentPower == 0 ? 0 : currentPower > 0 ? lineAnimationProgress : 1 - lineAnimationProgress
                    var extensionStartY = startY - extensionLength * progress

                    ctx.moveTo(startX, extensionStartY);
                    ctx.lineTo(startX, startY);
                    ctx.bezierCurveTo(startX, endY + height / 2, endX, startY - height / 2, endX, endY)
                    ctx.stroke();
                    ctx.closePath();
                }


                for (var i = 0; i < consumers.count; i++) {
                    ctx.beginPath();
                    // rM : max = x : 5
                    var consumer = consumers.get(i)
                    var currentPower = consumer.stateByName("currentPower").value
                    ctx.lineWidth = currentPower / maxCurrentPower + 1
                    ctx.setLineDash([5, 2])
                    var consumerTile = legendConsumersRepeater.itemAt(i)
                    var consumerPosition = consumerTile.mapToItem(linesCanvas, consumerTile.width / 2, 0)
//                    print("consumer pos", consumer.name, consumerPosition)
                    var startX = consumerPosition.x - xTranslate
                    var startY = consumerPosition.y - yTranslate
                    var endX = 10 * i - ((consumers.count - 1) * 5)
                    var endY = chartView.plotArea.height / 2
                    var height = startY - endY

                    var extensionLength = ctx.lineWidth * 7 // 5 + 2 dash segments from setLineDash
                    var progress = currentPower == 0 ? 0 : currentPower > 0 ? lineAnimationProgress : 1 - lineAnimationProgress
                    var extensionStartY = startY + extensionLength * progress

                    ctx.moveTo(startX, extensionStartY);
                    ctx.lineTo(startX, startY);
                    ctx.bezierCurveTo(startX, endY + height / 2, endX, startY - height / 2, endX, endY)
                    ctx.stroke();
                    ctx.closePath();
                }

//                print("painting circle")

                ctx.beginPath();
                ctx.setLineDash([1,0])
                ctx.lineWidth = 5
                ctx.moveTo(0, -chartView.plotArea.height / 2)
                ctx.lineTo(0, 0)
                ctx.stroke();
                ctx.closePath();

                ctx.beginPath();
                ctx.fillStyle = "black"
                ctx.moveTo(-15, -chartView.plotArea.height / 2)
                ctx.lineTo(15, -chartView.plotArea.height / 2)
                ctx.lineTo(0, -chartView.plotArea.height / 2 + 20)
                ctx.lineTo(-15, -chartView.plotArea.height / 2)
                ctx.fill()
                ctx.closePath();

                ctx.restore();
            }
        }


        ColumnLayout {
            id: layout
            anchors.fill: parent


            RowLayout {
                id: topLegend
                Layout.fillWidth: true
                Layout.margins: Style.margins
                Layout.alignment: Qt.AlignHCenter

                LegendTile {
                    id: rootMeterTile
                    thing: rootMeter
                    color: lsdChart.colors[0]
                    onClicked: {
                        pageStack.push("/ui/devicepages/SmartMeterDevicePage.qml", {thing: thing})
                    }
                }

                Repeater {
                    id: legendProducersRepeater
                    model: producers

                    delegate: LegendTile {
                        color: lsdChart.colors[index + 1]
                        thing: producers.get(index)
                        onClicked: {
                            pageStack.push("/ui/devicepages/SmartMeterDevicePage.qml", {thing: thing})
                        }
                    }
                }
            }

            PolarChartView {
                id: chartView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: Style.bigMargins

                property int sampleRate: XYSeriesAdapter.SampleRate10Minutes
                property int busyModels: 0
                legend.visible: false
                animationOptions: ChartView.SeriesAnimations
                backgroundColor: "transparent"

                onPlotAreaChanged: {
                    linesCanvas.requestPaint()
                    circleCanvas.requestPaint()
                }

                DateTimeAxis {
                    id: axisAngular
                    gridVisible: false
                    labelsVisible: false
                    property date now: new Date()
                    min: {
                        var date = new Date(now);
                        date.setTime(date.getTime() - (1000 * 60 * 60 * 12) + 2000);
                        return date;
                    }
                    max: {
                        var date = new Date(now);
                        date.setTime(date.getTime() + 2000)
                        return date;
                    }
                }

                ValueAxis {
                    id: axisRadial
                    gridVisible: false
                    labelsVisible: false
                    lineVisible: false
                    minorGridVisible: false
                    shadesVisible: false
                    color: "black"
                    readonly property XYSeriesAdapter highestSeriesAdapter: consumersRepeater.count > 0 ? consumersRepeater.itemAt(consumersRepeater.count - 1).adapter : null

                    property double rawMax: Math.max(rootMeter ? rootMeterSeriesAdapter.maxValue : 1, highestSeriesAdapter ? highestSeriesAdapter.maxValue : 1)
                    property double rawMin: Math.min(rootMeter ? rootMeterSeriesAdapter.minValue : 0, highestSeriesAdapter ? highestSeriesAdapter.minValue : 0)

                    property double roundedMax: Math.ceil(rawMax)// Math.ceil(Math.max(rawMax * 0.9, rawMax * 1.1))
                    property double roundedMin: Math.floor(Math.min(rawMin * 0.9, rawMin * 1.1))
                    max: roundedMax
                    min: -roundedMax//roundedMin - (roundedMax - roundedMin)
                }



                LogsModel {
                    id: rootMeterLogsModel
                    objectName: "Root meter model"
                    engine: rootMeter ? _engine : null // Don't start fetching before we know what we want
                    thingId: rootMeter ? rootMeter.id : ""
                    typeIds: rootMeter ? [rootMeter.thingClass.stateTypes.findByName("currentPower").id] : []
                    viewStartTime: axisAngular.min
                    live: true
                }
                XYSeriesAdapter {
                    id: rootMeterSeriesAdapter
                    objectName: "Root meter adapter"
                    logsModel: rootMeterLogsModel
                    sampleRate: chartView.sampleRate
                    xySeries: rootMeterSeries
                    Component.onCompleted: ensureSamples(axisAngular.min, axisAngular.max)
                }
                Connections {
                    target: axisAngular
//                    onMinChanged: rootMeterSeriesAdapter.ensureSamples(axisAngular.min, axisAngular.max)
                    onMaxChanged: rootMeterSeriesAdapter.ensureSamples(axisAngular.min, axisAngular.max)
                }
                AreaSeries {
                    id: rootMeterAreaSeries
                    axisAngular: axisAngular
                    axisRadial: axisRadial
                    // HACK: We want this to be created (added to the chart) *before* the repeater Series below...
                    // That might not be the case for a reason I don't understand. Most likely due to a mix of the declarative
                    // approach here and the imperative approach using chartView.createSeries() below.
                    // So hacking around by blocking the repeater from loading until this one is done
                    property bool ready: false
                    Component.onCompleted: ready = true
                    color: lsdChart.colors[0]
                    borderColor: color

                    upperSeries: LineSeries {
                        id: rootMeterSeries
                        onPointAdded: {
                            var newPoint = rootMeterSeries.at(index)

                            if (newPoint.x > rootMeterLowerSeries.at(0).x) {
                                rootMeterLowerSeries.replace(0, newPoint.x, 0)
                            }
                            if (newPoint.x < rootMeterLowerSeries.at(1).x) {
                                rootMeterLowerSeries.replace(1, newPoint.x, 0)
                            }
                        }
                    }
                    lowerSeries: LineSeries {
                        id: rootMeterLowerSeries
                        XYPoint { x: axisAngular.max.getTime(); y: 0 }
                        XYPoint { x: axisAngular.min.getTime(); y: 0 }
                    }

                }

                Repeater {
                    id: consumersRepeater
                    model: rootMeterAreaSeries.ready && !engine.thingManager.fetchingData ? consumers : null

                    delegate: Item {
                        id: consumer
                        property Thing thing: consumers.get(index)

                        property var model: LogsModel {
                            id: logsModel
                            objectName: consumer.thing.name
                            engine: _engine
                            thingId: consumer.thing.id
                            typeIds: [consumer.thing.thingClass.stateTypes.findByName("currentPower").id]
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
                        property XYSeriesAdapter adapter: XYSeriesAdapter {
                            id: seriesAdapter
                            objectName: consumer.thing.name +  " adapter"
                            logsModel: logsModel
                            sampleRate: chartView.sampleRate
                            xySeries: upperSeries
                        }
                        Connections {
                            target: axisAngular
//                            onMinChanged: seriesAdapter.ensureSamples(axisAngular.min, axisAngular.max)
                            onMaxChanged: seriesAdapter.ensureSamples(axisAngular.min, axisAngular.max)
                        }
                        property XYSeries lineSeries: LineSeries {
                            id: upperSeries
                            onPointAdded: {
                                var newPoint = upperSeries.at(index)

                                if (newPoint.x > lowerSeries.at(0).x) {
                                    lowerSeries.replace(0, newPoint.x, 0)
                                }
                                if (newPoint.x < lowerSeries.at(1).x) {
                                    lowerSeries.replace(1, newPoint.x, 0)
                                }
                            }
                        }
                        LineSeries {
                            id: lowerSeries
                            XYPoint { x: axisAngular.max.getTime(); y: 0 }
                            XYPoint { x: axisAngular.min.getTime(); y: 0 }
                        }

                        Component.onCompleted: {
                            var indexInModel = consumers.indexOf(consumer.thing)
                            print("creating series", consumer.thing.name, index, indexInModel)
                            seriesAdapter.ensureSamples(axisAngular.min, axisAngular.max)
                            var areaSeries = chartView.createSeries(ChartView.SeriesTypeArea, consumer.thing.name, axisAngular, axisRadial)
                            areaSeries.useOpenGL = true
                            areaSeries.upperSeries = upperSeries;
                            if (index > 0) {
                                areaSeries.lowerSeries = consumersRepeater.itemAt(index - 1).lineSeries
                                seriesAdapter.baseSeries = consumersRepeater.itemAt(index - 1).lineSeries
                            } else {
                                areaSeries.lowerSeries = lowerSeries;
                            }

                            areaSeries.color = lsdChart.colors[indexInModel+1] //Qt.color(lsdChart.colors[i+1]);
                            areaSeries.borderColor = areaSeries.color;
                            areaSeries.borderWidth = 0;
                        }
                    }
                }

                Rectangle {
                    x: chartView.plotArea.x + width / 2
                    y: chartView.plotArea.y + height / 2
                    width: chartView.plotArea.width / 2
                    height: chartView.plotArea.height / 2
                    radius: width / 2
                    color: Style.darkGray
                    border.width: 2
                    border.color: "white"

                    BusyIndicator {
                        running: periodConsumptionModel.busy
                        anchors.centerIn: parent
                    }


                    ColumnLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: Style.margins
                        opacity: periodConsumptionModel.busy ? 0 : 1
                        Behavior on opacity { NumberAnimation { duration: 150 } }

                        Label {
                            Layout.fillWidth: true
                            text: '<span style="font-size:' + Style.bigFont.pixelSize + 'px">' +
                                  totalPeriodConsumption.toFixed(1)
                            + '</span> <span style="font-size:' + Style.smallFont.pixelSize + 'px">'
                                  + "kWh"
                            + '</span>'
                            textFormat: Text.RichText
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"

                            LogsModel {
                                id: periodConsumptionModel
                                objectName: "Root meter model"
                                engine: rootMeter ? _engine : null // Don't start fetching before we know what we want
                                thingId: rootMeter ? rootMeter.id : ""
                                typeIds: rootMeter ? [rootMeter.thingClass.stateTypes.findByName("totalEnergyConsumed").id] : []
                                viewStartTime: axisAngular.min
                                live: true
                            }


                            property LogEntry logEntryAtStart: periodConsumptionModel.busy ? periodConsumptionModel.findClosest(axisAngular.min) : periodConsumptionModel.findClosest(axisAngular.min)
                            property State totalEnergyConsumedState: rootMeter ? rootMeter.stateByName("totalEnergyConsumed") : null
                            property double totalPeriodConsumption: logEntryAtStart && totalEnergyConsumedState ? totalEnergyConsumedState.value - logEntryAtStart.value : 0
                        }

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Total")
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideMiddle
                            color: "white"
                            font: Style.smallFont
                        }
                        Label {
                            Layout.fillWidth: true
                            text: qsTr("12h")
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                            font: Style.smallFont
                        }

                    }
                }
            }

            Flickable {
                Layout.preferredWidth: Math.min(implicitWidth, parent.width - Style.margins * 2)
                implicitWidth: bottomLegend.implicitWidth
                Layout.margins: Style.margins
                Layout.preferredHeight: bottomLegend.implicitHeight
                contentWidth: bottomLegend.implicitWidth
                Layout.alignment: Qt.AlignHCenter
                onContentXChanged: {
                    linesCanvas.requestPaint()
                }

                RowLayout {
                    id: bottomLegend

                    Repeater {
                        id: legendConsumersRepeater
                        model: consumers
                        delegate: LegendTile {
                            color: lsdChart.colors[index + 1]
                            thing: consumers.get(index)
                            onClicked: {
                                pageStack.push("/ui/devicepages/SmartMeterDevicePage.qml", {thing: thing})
                            }
                        }
                    }
                }
            }
        }

        Canvas {
            id: circleCanvas
            anchors.fill: parent

            Timer {
                running: true
                repeat: true
                interval: 15000
                onTriggered: {
                    axisAngular.now = new Date()
                    circleCanvas.requestPaint()
                }
            }

            property int circleWidth: 20

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.save();
                var xTranslate = chartView.x + chartView.plotArea.x + chartView.plotArea.width / 2
                var yTranslate = chartView.y + chartView.plotArea.y + chartView.plotArea.height / 2
                ctx.translate(xTranslate, yTranslate)


                // Outer circle
                ctx.lineWidth = circleWidth;
                var sliceAngle = 2 * Math.PI / lsdChart.hours
                var timeSinceFullHour = new Date().getMinutes()
                var timeDiffRotation = timeSinceFullHour * sliceAngle / 60

                for (var i = 0; i < lsdChart.hours; i++) {
                    ctx.save();

                    ctx.rotate(i * sliceAngle - timeDiffRotation)

                    ctx.beginPath();
                    ctx.strokeStyle = i % 2 == 0 ? Style.gray : Style.darkGray;
                    ctx.arc(0, 0, (chartView.plotArea.width + circleWidth) / 2, 0, sliceAngle);
                    ctx.stroke();
                    ctx.closePath();

                    ctx.restore()
                }

                // Hour texts in outer circle
                var startHour = new Date().getHours() - lsdChart.hours + 1
                for (var i = 0; i < lsdChart.hours; i++) {
                    ctx.save();

                    ctx.rotate(i * sliceAngle - timeDiffRotation + sliceAngle * 1.5)

                    var tmpDate = new Date()
                    tmpDate.setHours(startHour + i, 0, 0)
                    ctx.textAlign = 'center';
                    ctx.font = "" + Style.smallFont.pixelSize + "px " + Style.smallFont.family
                    ctx.fillStyle = "white"
                    var textY = -(chartView.plotArea.height + circleWidth) / 2 + Style.smallFont.pixelSize / 2
                    // Just can't figure out where I'm missing thosw 2 pixels in the proper calculation (yet)...
                    textY -= 2
                    ctx.fillText(tmpDate.toLocaleTimeString(Qt.SystemLocaleShortDate), 0, textY)

                    ctx.restore()
                }

                ctx.restore();

            }
        }

    }

//    EmptyViewPlaceholder {
//        anchors { left: parent.left; right: parent.right; margins: app.margins }
//        anchors.verticalCenter: parent.verticalCenter
//        visible: /*engine.thingManager.things.count === 0 &&*/ !engine.thingManager.fetchingData
//        title: qsTr("Welcome to %1!").arg(Configuration.systemName)
//        text: qsTr("Start with adding your appliances.")
//        imageSource: "qrc:/ui/images/leaf.svg"
//        buttonText: qsTr("Configure your leaflet")
//    }
}
