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
import Qt.labs.settings 1.1
import "../components"
import "../delegates"

MainViewBase {
    id: root

    readonly property bool loading: engine.thingManager.fetchingData

    EnergyManager {
        id: energyManager
        engine: _engine
    }

    HemsManager {
        id: hemsManager
        engine: _engine
    }

    headerButtons: [
        {
            iconSource: "/ui/images/configure.svg",
            color: Style.iconColor,
            visible:  hemsManager.available && rootMeter != null,
            trigger: function() {
                pageStack.push("HemsOptimizationPage.qml", { hemsManager: hemsManager })
            }
        }
    ]

    QtObject {
        id: d
        property var firstWizardPage: null

        property bool energyMeterWiazrdSkipped: false

        function pushPage(comp, properties) {
            var page = pageStack.push(comp, properties)
            if (!d.firstWizardPage) {
                d.firstWizardPage = page
            }
            return page;
        }

        function exitWizard() {
            print("exiting wizard")
            pageStack.pop(d.firstWizardPage, StackView.Immediate)
            pageStack.pop()
        }


        function resetWizardSettings() {
            wizardSettings.solarPanelDone = false
            wizardSettings.evChargerDone = false
            wizardSettings.heatPumpDone = false
        }

        function setup(showFinalPage) {

            print("Setup. Installed energy meters:", energyMetersProxy.count, "EV Chargers:", evChargersProxy.count)

            if (energyMetersProxy.count === 0 && !energyMeterWiazrdSkipped) {
                var page = d.pushPage("/ui/wizards/SetupEnergyMeterWizard.qml")
                page.done.connect(function(skip, abort) {
                    print("energymeters done", skip, abort)
                    if (abort) {
                        exitWizard()
                        return
                    }
                    if (skip) {
                        energyMeterWiazrdSkipped = true;
                    }
                    setup(true)
                })
                return
            }

            if (inverters.count === 0 && !wizardSettings.solarPanelDone) {
                var page = d.pushPage("/ui/wizards/SetupSolarInverterWizard.qml");
                page.done.connect(function(skip, abort){
                    print("solar inverters done", skip, abort)
                    if (abort) {
                        exitWizard();
                        return
                    }

                    setup(true);
                })
                wizardSettings.solarPanelDone = true
                return
            }

            if (evChargersProxy.count === 0 && !wizardSettings.evChargerDone) {
                var page = d.pushPage("/ui/wizards/SetupEVChargerWizard.qml")
                page.done.connect(function(skip, abort) {
                    if (abort) {
                        exitWizard();
                        return
                    }

                    setup(true);
                })
                wizardSettings.evChargerDone = true
                return
            }

            if (heatPumps.count === 0 && !wizardSettings.heatPumpDone) {
                var page = d.pushPage("/ui/wizards/SetupHeatPumpWizard.qml")
                page.done.connect(function(skip, abort) {
                    if (abort) {
                        exitWizard();
                        return
                    }

                    setup(true);
                })
                wizardSettings.heatPumpDone = true
                return
            }

            if (showFinalPage) {
                var page = d.pushPage("/ui/wizards/WizardComplete.qml", {hemsManager: hemsManager})
                page.done.connect(function(skip, abort) {exitWizard()})
            }
        }
    }

    Connections {
        target: engine.thingManager
        onThingAdded: {
            if (thing.thingClass.interfaces.indexOf("energymeter") >= 0) {
                energyManager.setRootMeterId(thing.id);
            }
        }
    }

    Settings {
        id: wizardSettings
        category: "setupWizard"
        property bool solarPanelDone: false
        property bool evChargerDone: false
        property bool heatPumpDone: false
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
    readonly property Thing rootMeter: engine.thingManager.fetchingData ? null : engine.thingManager.things.getThing(energyManager.rootMeterId)

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
        id: inverters
        engine: _engine
        shownInterfaces: ["solarinverter"]
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
    ThingsProxy {
        id: heatPumps
        engine: _engine
        shownInterfaces: ["heatpump"]
    }

    EnergyLogs {
        id: energyLogs
        engine: _engine
    }

    Item {
        id: lsdChart
        anchors.fill: parent
        anchors.topMargin: root.topMargin
        anchors.bottomMargin: Style.hugeMargins
        visible: rootMeter != null

        property int hours: 24

        readonly property color rootMeterAcquisitionColor: "#e31e24"
        readonly property color rootMeterReturnColor: Style.blue
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

                ctx.beginPath()
                ctx.fillStyle = "white"
                ctx.arc(0, 0, chartView.plotArea.width / 2, 0, 2 * Math.PI)
                ctx.fill();
                ctx.closePath()

                ctx.strokeStyle = Style.foregroundColor
                ctx.fillStyle = Style.foregroundColor

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

                var totalTop = rootMeter ? 1 : 0
                totalTop += producers.count
                // dashed lines from rootMeter
                if (rootMeter) {
                    drawAnimatedLine(ctx, rootMeter, rootMeterTile, false, -(totalTop - 1) / 2, maxCurrentPower, true, xTranslate, yTranslate)
                }

                for (var i = 0; i < producers.count; i++) {
                    var producer = producers.get(i)
                    var tile = legendProducersRepeater.itemAt(i)
                    drawAnimatedLine(ctx, producer, tile, false, (i + 1) - ((totalTop - 1) / 2), maxCurrentPower, false, xTranslate, yTranslate)
                }

                var totalBottom = consumers.count + batteries.count

                for (var i = 0; i < consumers.count; i++) {
                    var consumer = consumers.get(i)
                    var tile = legendConsumersRepeater.itemAt(i)
                    drawAnimatedLine(ctx, consumer, tile, true, i - ((totalBottom - 1) / 2), maxCurrentPower, false, xTranslate, yTranslate)
                }

                for (var i = 0; i < batteries.count; i++) {
                    var battery = batteries.get(i)
                    var tile = legendBatteriesRepeater.itemAt(i)
                    drawAnimatedLine(ctx, battery, tile, true, consumers.count + i - ((totalBottom - 1) / 2), maxCurrentPower, false, xTranslate, yTranslate)
                }


                ctx.strokeStyle = "black"
                ctx.fillStyle = "black"

                ctx.beginPath();
                ctx.setLineDash([1,0])
                ctx.lineWidth = 5
                ctx.moveTo(0, -chartView.plotArea.height / 2)
                ctx.lineTo(0, 0)
                ctx.stroke();
                ctx.closePath();

                ctx.beginPath();
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
                spacing: Style.margins

                LegendTile {
                    id: rootMeterTile
                    thing: rootMeter
                    color: lsdChart.rootMeterAcquisitionColor
                    negativeColor: lsdChart.rootMeterReturnColor
                    onClicked: {
                        print("Clicked root meter", index, thing.name)
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
                            print("Clicked producer", index, thing.name)
                            pageStack.push("/ui/devicepages/SmartMeterDevicePage.qml", {thing: thing})
                        }
                    }
                }
            }

            LineSeries {
                id: zeroSeries
                XYPoint { x: root.viewStartTime.getTime(); y: 0 }
                XYPoint { x: root.viewEndTime.getTime(); y: 0 }
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
//                    max: roundedMax
//                    min: -roundedMax//roundedMin - (roundedMax - roundedMin)

                    max: Math.max(Math.abs(energyLogs.powerBalanceLogs.maxValue), Math.abs(energyLogs.powerBalanceLogs.minValue)) * 1.1
                    min: -Math.max(Math.abs(energyLogs.powerBalanceLogs.maxValue), Math.abs(energyLogs.powerBalanceLogs.minValue)) * 1.1
                }

                AreaSeries {
                    id: productionSeries
                    axisAngular: axisAngular
                    axisRadial: axisRadial
                    color: "yellow"//lsdChart.producersColor
                    lowerSeries: zeroSeries
                    upperSeries: LineSeries {
                        id: productionUpperSeries
                        Component.onCompleted: {
                            for (var i = 0; i < energyLogs.powerBalanceLogs.count; i++) {
                                var entry = energyLogs.powerBalanceLogs.get(i);
                                append(entry.timestamp.getTime(), -entry.production)
                            }
                        }

                        Connections {
                            target: energyLogs.powerBalanceLogs
                            onEntryAdded: {
                                productionUpperSeries.append(entry.timestamp.getTime(), -entry.production)
                            }
                        }
                    }
                }

                AreaSeries {
                    id: acquisitionSeries
                    axisAngular: axisAngular
                    axisRadial: axisRadial
                    color: lsdChart.rootMeterAcquisitionColor
                    lowerSeries: zeroSeries
//                    visible: false
                    upperSeries: LineSeries {
                        id: acquisitionUpperSeries
                        Component.onCompleted: {
                            for (var i = 0; i < energyLogs.powerBalanceLogs.count; i++) {
                                var entry = energyLogs.powerBalanceLogs.get(i);
                                append(entry.timestamp.getTime(), entry.acquisition)
                            }
                        }

                        Connections {
                            target: energyLogs.powerBalanceLogs
                            onEntryAdded: {
                                acquisitionUpperSeries.append(entry.timestamp.getTime(), entry.acquisition)
                            }
                        }
                    }
                }

                AreaSeries {
                    id: returnSeries
                    axisAngular: axisAngular
                    axisRadial: axisRadial
                    color: lsdChart.rootMeterReturnColor
//                    visible: false
                    lowerSeries: zeroSeries
                    upperSeries: LineSeries {
                        id: returnUpperSeries
                        Component.onCompleted: {
                            for (var i = 0; i < energyLogs.powerBalanceLogs.count; i++) {
                                var entry = energyLogs.powerBalanceLogs.get(i);
                                append(entry.timestamp.getTime(), -entry.acquisition)
                            }
                        }

                        Connections {
                            target: energyLogs.powerBalanceLogs
                            onEntryAdded: {
                                returnUpperSeries.append(entry.timestamp.getTime(), -entry.acquisition)
                            }
                        }
                    }
                }

                AreaSeries {
                    id: storageSeries
                    axisAngular: axisAngular
                    axisRadial: axisRadial
                    color: lsdChart.batteriesColor
//                    visible: false
                    lowerSeries: zeroSeries
                    upperSeries: LineSeries {
                        id: storageUpperSeries
                        Component.onCompleted: {
                            for (var i = 0; i < energyLogs.powerBalanceLogs.count; i++) {
                                var entry = energyLogs.powerBalanceLogs.get(i);
                                append(entry.timestamp.getTime(), -entry.storage)
                            }
                        }

                        Connections {
                            target: energyLogs.powerBalanceLogs
                            onEntryAdded: {
                                storageUpperSeries.append(entry.timestamp.getTime(), -entry.storage)
                            }
                        }
                    }
                }


                Repeater {
                    id: consumersRepeater
//                    model: rootMeterRepeater.model !== null ? consumers : null

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
//                    model: producersRepeater.model !== null ? batteries : null

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
                    id: innerCircle
                    x: chartView.plotArea.x + width / 2
                    y: chartView.plotArea.y + height / 2
                    width: chartView.plotArea.width / 2
                    height: chartView.plotArea.height / 2
                    radius: width / 2
                    color: Style.darkGray
                    border.width: 2
                    border.color: "white"
//                    visible: false

                    MouseArea {
                        anchors.fill: parent
                        onPressed: {
                            // Only handle presses that are within the circle
                            var mouseXcentered = mouseX - width / 2
                            var mouseYcentered = mouseY - height / 2
                            var distanceFromCenter = Math.sqrt(Math.pow(mouseXcentered, 2) + Math.pow(mouseYcentered, 2))
                            if (distanceFromCenter > width / 2) {
                                mouse.accepted = false
                            }
                        }
                        onClicked: pageStack.push("/ui/devicepages/SmartMeterDevicePage.qml", {thing: rootMeter})
                    }

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
                                  (energyManager.currentPowerConsumption < 1000 ? energyManager.currentPowerConsumption : energyManager.currentPowerConsumption / 1000).toFixed(1)
                            + '</span> <span style="font-size:' + Style.smallFont.pixelSize + 'px">'
                                  + (energyManager.currentPowerConsumption < 1000 ? "W" : "kW")
                            + '</span>'
                        }

                        Label {
                            Layout.fillWidth: true
                            text: qsTr("Total current power usage")
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            elide: Text.ElideMiddle
                            color: "white"
                            font: Style.smallFont
                            visible: innerCircle.height > 120
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
                    spacing: Style.margins

                    Repeater {
                        id: legendConsumersRepeater
                        model: consumers
                        delegate: LegendTile {
                            color: lsdChart.consumersColors[index]
                            thing: consumers.get(index)
                            onClicked: {
                                print("Clicked consumer", index, thing.name)
                                if (thing.thingClass.interfaces.indexOf("evcharger") >= 0) {
                                    pageStack.push("/ui/devicepages/EvChargerThingPage.qml", {thing: thing})
                                } else {
                                    pageStack.push("/ui/devicepages/SmartMeterDevicePage.qml", {thing: thing})
                                }
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
                                print("Clicked battery", index, thing.name)
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
                    if (chartView.width > 400 && chartView.height > 400) {
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

    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: Style.hugeMargins
        gradient: Gradient {
            GradientStop { position: 0; color: "transparent" }
            GradientStop { position: 1; color: Style.accentColor }
        }

        Image {
            anchors.centerIn: parent
            width: Math.min(parent.width, 700)
            height: parent.height
            source: "/ui/images/intro-bg-graphic.svg"
            sourceSize.width: width
            fillMode: Image.PreserveAspectCrop
            verticalAlignment: Image.AlignTop
        }
    }


    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        visible: !engine.thingManager.fetchingData && root.rootMeter == null
        title: qsTr("Your leaflet is not set up yet.")
        text: qsTr("Please complete the setup wizard or manually configure your devices.")
        imageSource: "/ui/images/leaf.svg"
        buttonText: qsTr("Start setup")
        onImageClicked: buttonClicked()
        onButtonClicked: {
            d.resetWizardSettings()
            d.setup(false)
        }
    }
}
