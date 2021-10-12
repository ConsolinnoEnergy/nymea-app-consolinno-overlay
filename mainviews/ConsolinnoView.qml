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
    ThingsProxy {
        id: batteries
        engine: _engine
        shownInterfaces: ["energystorage"]
    }

    Item {
        id: lsdChart
        anchors.fill: parent
        anchors.topMargin: root.topMargin

        property int hours: 24

        readonly property color rootMeterColor: "#5e9ede"
        readonly property color producersColor: "#f8eb45"
        readonly property color batteriesColor: "#b6c741"
        readonly property var consumersColors: [ "#b15c95", "#c1362f", "#731DD8", "#C4FFF9", "#C16200" ]



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
                running: linesCanvas.visible && Qt.application.state === Qt.ApplicationActive
            }
            onLineAnimationProgressChanged: requestPaint()

            onPaint: {
//                print("repainting lines canvas")
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
                for (var i = 0; i < producers.count; i++) {
                    maxCurrentPower = Math.max(maxCurrentPower, Math.abs(producers.get(i).stateByName("currentPower").value))
                }
                for (var i = 0; i < batteries.count; i++) {
                    maxCurrentPower = Math.max(maxCurrentPower, Math.abs(batteries.get(i).stateByName("currentPower").value))
                }

                // dashed lines from rootMeter
                if (rootMeter) {
                    drawAnimatedLine(ctx, rootMeter, rootMeterTile, false, 0, maxCurrentPower, true, xTranslate, yTranslate)
                }

                for (var i = 0; i < producers.count; i++) {
                    var producer = producers.get(i)
                    var tile = legendProducersRepeater.itemAt(i)
                    drawAnimatedLine(ctx, producer, tile, false, i + 1, maxCurrentPower, false, xTranslate, yTranslate)
                }


                for (var i = 0; i < consumers.count; i++) {
                    var consumer = consumers.get(i)
                    var tile = legendConsumersRepeater.itemAt(i)
                    drawAnimatedLine(ctx, consumer, tile, true, i, maxCurrentPower, false, xTranslate, yTranslate)
                }

                for (var i = 0; i < batteries.count; i++) {
                    var battery = batteries.get(i)
                    var tile = legendBatteriesRepeater.itemAt(i)
                    drawAnimatedLine(ctx, battery, tile, true, consumers.count + i, maxCurrentPower, false, xTranslate, yTranslate)
                }


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

            function drawAnimatedLine(ctx, thing, tile, bottom, index, relativeTo, inverted, xTranslate, yTranslate) {
                ctx.beginPath();
                // rM : max = x : 5
                var currentPower = thing.stateByName("currentPower").value
                ctx.lineWidth = Math.abs(currentPower) / Math.abs(relativeTo) * 5 + 1
                ctx.setLineDash([5, 2])
                var tilePosition = tile.mapToItem(linesCanvas, tile.width / 2, 0)
                if (!bottom) {
                    tilePosition.y = tile.height
                }

                var startX = tilePosition.x - xTranslate
                var startY = tilePosition.y - yTranslate
                var endX = 10 * index
                var endY = -chartView.plotArea.height / 2
                if (bottom) {
                    endY = chartView.plotArea.height / 2
                }

                var height = startY - endY


                var extensionLength = ctx.lineWidth * 7 // 5 + 2 dash segments from setLineDash
                var progress = currentPower === 0 ? 0 : currentPower > 0 ? lineAnimationProgress : 1 - lineAnimationProgress
                if (inverted) {
                    progress = 1 - progress
                }
                var extensionStartY = startY - extensionLength * progress
                if (bottom) {
                    extensionStartY = startY + extensionLength * progress
                }

                ctx.moveTo(startX, extensionStartY);
                ctx.lineTo(startX, startY);
                ctx.bezierCurveTo(startX, endY + height / 2, endX, startY - height / 2, endX, endY)
                ctx.stroke();
                ctx.closePath();
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
                    color: lsdChart.rootMeterColor
                    onClicked: {
                        pageStack.push("/ui/devicepages/SmartMeterDevicePage.qml", {thing: thing})
                    }
                }

                Repeater {
                    id: legendProducersRepeater
                    model: producers

                    delegate: LegendTile {
                        color: lsdChart.producersColor
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
                // Note: Crashes on some devices
//                animationOptions: ChartView.SeriesAnimations
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
                        date.setTime(date.getTime() - (1000 * 60 * 60 * lsdChart.hours) + 2000);
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
                    readonly property XYSeriesAdapter highestRootMeterSeriesAdapter: rootMeterRepeater.count > 0 ? rootMeterRepeater.itemAt(rootMeterRepeater.count - 1).adapter : null
                    readonly property XYSeriesAdapter highestProducersSeriesAdapter: producersRepeater.count > 0 ? producersRepeater.itemAt(producersRepeater.count - 1).adapter : null
                    readonly property XYSeriesAdapter highestConsumersSeriesAdapter: consumersRepeater.count > 0 ? consumersRepeater.itemAt(consumersRepeater.count - 1).adapter : null

                    property double rawMax: Math.max(Math.max(highestRootMeterSeriesAdapter ? highestRootMeterSeriesAdapter.maxValue : 1, highestProducersSeriesAdapter ? highestProducersSeriesAdapter.maxValue : 1), highestConsumersSeriesAdapter ? highestConsumersSeriesAdapter.maxValue : 1)
//                    property double rawMin: Math.min(rootMeter ? rootMeterSeriesAdapter.minValue : 0, highestSeriesAdapter ? highestSeriesAdapter.minValue : 0)

                    property double roundedMax: Math.ceil(rawMax)// Math.ceil(Math.max(rawMax * 0.9, rawMax * 1.1))
//                    property double roundedMin: Math.floor(Math.min(rawMin * 0.9, rawMin * 1.1))
                    max: roundedMax
                    min: -roundedMax//roundedMin - (roundedMax - roundedMin)
                }


                Repeater {
                    id: producersRepeater
                    model: !engine.thingManager.fetchingData ? producers : null

                    delegate: ConsolinnoChartDelegate {
                        thing: producers.get(index)
                        viewStartTime: axisAngular.min
                        viewEndTime: axisAngular.max
                        sampleRate: chartView.sampleRate
                        color: lsdChart.producersColor
                        inverted: true
                        onClicked: pageStack.push("/ui/devicepages/SmartMeterDevicePage.qml", {thing: thing})
                    }
                }

                Repeater {
                    id: rootMeterRepeater
                    model: producersRepeater.model !== null && rootMeter != null ? 1 : null

                    delegate: ConsolinnoChartDelegate {
                        thing: rootMeter
                        viewStartTime: axisAngular.min
                        viewEndTime: axisAngular.max
                        sampleRate: chartView.sampleRate
                        color: lsdChart.rootMeterColor
                        onClicked: pageStack.push("/ui/devicepages/SmartMeterDevicePage.qml", {thing: thing})
                    }
                }


                Repeater {
                    id: consumersRepeater
                    model: rootMeterRepeater.model !== null ? consumers : null

                    delegate: ConsolinnoChartDelegate {
                        thing: consumers.get(index)
                        viewStartTime: axisAngular.min
                        viewEndTime: axisAngular.max
                        sampleRate: chartView.sampleRate
                        color: lsdChart.consumersColors[index]
                        baseSeries: index > 0 ? consumersRepeater.itemAt(index - 1).lineSeries : null
                        onClicked: pageStack.push("/ui/devicepages/SmartMeterDevicePage.qml", {thing: thing})
                    }
                }

                Repeater {
                    id: batteriesRepeater
                    model: producersRepeater.model !== null ? batteries : null

                    delegate: ConsolinnoChartDelegate {
                        thing: batteries.get(index)
                        viewStartTime: axisAngular.min
                        viewEndTime: axisAngular.max
                        sampleRate: chartView.sampleRate
                        color: lsdChart.batteriesColor
                        inverted: true
                        onClicked: pageStack.push("/ui/devicepages/SmartMeterDevicePage.qml", {thing: thing})
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


                    ColumnLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: Style.margins
                        Behavior on opacity { NumberAnimation { duration: 150 } }

                        Label {
                            Layout.fillWidth: true
                            textFormat: Text.RichText
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                            text: '<span style="font-size:' + Style.bigFont.pixelSize + 'px">' +
                                  (currentPowerUsage < 1000 ? currentPowerUsage : currentPowerUsage / 1000).toFixed(1)
                            + '</span> <span style="font-size:' + Style.smallFont.pixelSize + 'px">'
                                  + (currentPowerUsage < 1000 ? "W" : "kW")
                            + '</span>'


                            property double totalCurrentProduction: {
                                var ret = 0;
                                for (var i = 0; i < producers.count; i++) {
                                    var producer = producers.get(i)
                                    var currentPowerState = producer.stateByName("currentPower")
                                    ret += currentPowerState.value
                                }

                                // Add batteries to producers if discharging
                                for (var j = 0; i < batteries.count; j++) {
                                    var battery = batteries.get(j)
                                    var batteryPowerState = battery.stateByName("currentPower")
                                    if (batteryPowerState.value < 0) {
                                        ret += batteryPowerState.value
                                    }
                                }

                                return ret;
                            }

                            property State currentRootMeterPowerState: rootMeter ? rootMeter.stateByName("currentPower") : null
                            property double currentPowerUsage: -totalCurrentProduction + (currentRootMeterPowerState ?  currentRootMeterPowerState.value : 0)
                        }

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Total current power usage")
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            elide: Text.ElideMiddle
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
                            color: lsdChart.consumersColors[index]
                            thing: consumers.get(index)
                            onClicked: {
                                pageStack.push("/ui/devicepages/SmartMeterDevicePage.qml", {thing: thing})
                            }
                        }
                    }

                    Repeater {
                        id: legendBatteriesRepeater
                        model: batteries
                        delegate: LegendTile {
                            color: lsdChart.batteriesColor
                            thing: batteries.get(index)
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
                print("repainting clircles canvas")
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
                    if (lsdChart.width > 500) {
                        ctx.fillText(tmpDate.toLocaleTimeString(Qt.SystemLocaleShortDate), 0, textY)
                    } else {
                        ctx.fillText(tmpDate.getHours(), 0, textY)
                    }

                    ctx.restore()
                }

                ctx.restore();

            }
        }

    }
}
