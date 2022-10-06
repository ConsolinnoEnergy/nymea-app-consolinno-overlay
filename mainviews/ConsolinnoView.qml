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
    property UserConfiguration userconfig
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
            iconSource: "/ui/images/info.svg",
            color: Material.foreground,
            visible:  true,
            trigger: function() {
                pageStack.push("../info/MainviewInfo.qml",  {stack: pageStack})
            }
        },

        {
            iconSource: "/ui/images/configure.svg",
            color: Style.iconColor,
            visible:  hemsManager.available && rootMeter != null,
            trigger: function() {
                var page = pageStack.push("HemsOptimizationPage.qml", { hemsManager: hemsManager })
                page.startWizard.connect(function(){
                    pageStack.pop(pageStack.get(0))
                    d.resetManualWizardSettings()
                    d.setup(true)



                })
            }
        }
    ]


    QtObject {
        id: d
        property var firstWizardPage: null

        property bool energyMeterWiazrdSkipped: false
        property bool manualEnergyWizardBack: false

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
            wizardSettings.authorisation = false
            wizardSettings.installerData = false

        }

        function resetManualWizardSettings() {
            manualWizardSettings.solarPanelDone = false
            manualWizardSettings.evChargerDone = false
            manualWizardSettings.heatPumpDone = false
            manualWizardSettings.authorisation = false
            manualWizardSettings.installerData = false
            manualWizardSettings.energymeter = false
        }

        function initialManualWizardSettings() {
            manualWizardSettings.solarPanelDone = true
            manualWizardSettings.evChargerDone = true
            manualWizardSettings.heatPumpDone = true
            manualWizardSettings.authorisation = true
            manualWizardSettings.installerData = true
            manualWizardSettings.energymeter = true
        }

        function setup(showFinalPage) {

            print("Setup. Installed energy meters:", energyMetersProxy.count, "EV Chargers:", evChargersProxy.count)



            if ((energyMetersProxy.count === 0 && !wizardSettings.authorisation) || !manualWizardSettings.authorisation){
                var page = d.pushPage("/ui/wizards/AuthorisationView.qml")
                page.done.connect(function( abort , accepted) {
                    if (accepted) {
                        manualWizardSettings.authorisation = true
                        wizardSettings.authorisation = true
                    }
                    if (abort){
                        exitWizard()
                        return
                    }
                    setup(true)
                })
                return
            }


            if ((energyMetersProxy.count === 0 && !energyMeterWiazrdSkipped) || (energyMetersProxy.count === 0 && !manualWizardSettings.energymeter)) {
                var page = d.pushPage("/ui/wizards/SetupEnergyMeterWizard.qml")
                page.done.connect(function(skip, abort) {

                    print("energymeters done", skip, abort)
                    if (abort) {
                        exitWizard()
                        return
                    }
                    if (skip) {
                        energyMeterWiazrdSkipped = true;
                        manualWizardSettings.energymeter = true
                        setup(true)
                        return

                    }

                    manualWizardSettings.energymeter = true
                    // since SetupEnergyMeter is not an add loop I need to pop twice
                    pageStack.pop()
                    pageStack.pop()
                    setup(true)
                })
                return
            }

            if ((!wizardSettings.solarPanelDone) || !manualWizardSettings.solarPanelDone) {
                var page = d.pushPage("/ui/wizards/SetupSolarInverterWizard.qml");
                page.done.connect(function(skip, abort, back){

                    if(back){
                        energyMeterWiazrdSkipped = false
                        manualWizardSettings.energymeter = false
                        pageStack.pop()
                        return
                    }

                    if (abort) {
                        manualWizardSettings.solarPanelDone = true
                        exitWizard();
                        return
                    }
                    wizardSettings.solarPanelDone = true
                    manualWizardSettings.solarPanelDone = true
                    setup(true);
                })
                wizardSettings.solarPanelDone = true
                return
            }

            if (( !wizardSettings.evChargerDone)|| !manualWizardSettings.evChargerDone) {
                var page = d.pushPage("/ui/wizards/SetupEVChargerWizard.qml")
                page.done.connect(function(skip, abort, back) {
                    if(back){
                        manualWizardSettings.solarPanelDone = false
                        pageStack.pop()
                        return

                    }

                    if (abort) {
                        manualWizardSettings.evChargerDone = true
                        exitWizard();
                        return
                    }
                    wizardSettings.evChargerDone = true
                    manualWizardSettings.evChargerDone = true
                    setup(true);
                })

                page.countChanged.connect(function(){
                    blackoutProtectionSetting.blackoutProtectionDone = false
                })

                wizardSettings.evChargerDone = true
                return
            }

            if (( !wizardSettings.heatPumpDone) || !manualWizardSettings.heatPumpDone) {
                var page = d.pushPage("/ui/wizards/SetupHeatPumpWizard.qml")
                page.done.connect(function(skip, abort, back) {

                    if(back){
                        manualWizardSettings.evChargerDone = false
                        pageStack.pop()
                        return

                    }

                    if (abort) {
                        manualWizardSettings.heatPumpDone = true
                        exitWizard();
                        return
                    }

                    wizardSettings.heatPumpDone = true
                    manualWizardSettings.heatPumpDone = true
                    setup(true);
                })

                page.countChanged.connect(function(){
                    blackoutProtectionSetting.blackoutProtectionDone = false
                })

                wizardSettings.heatPumpDone = true
                return
            }

            if (!blackoutProtectionSetting.blackoutProtectionDone)  {
                var page = d.pushPage("../optimization/BlackoutProtectionView.qml", {hemsManager: hemsManager, directionID: 1})
                page.done.connect(function(skip, abort, back) {

                    if(back){
                        manualWizardSettings.heatPumpDone = false
                        pageStack.pop()
                        return

                    }

                    if (abort) {

                        blackoutProtectionSetting.blackoutProtectionDone = true
                        exitWizard();
                        return
                    }

                    blackoutProtectionSetting.blackoutBackPage = true
                    blackoutProtectionSetting.blackoutProtectionDone = true
                    setup(true);
                })

                return
            }



            if ((!wizardSettings.installerData) || !manualWizardSettings.installerData){
                var page = d.pushPage("/ui/wizards/InstallerDataView.qml", {hemsManager: hemsManager, directionID: 0})
                page.done.connect(function( saved , skip, back) {

                    if(back){

                        if (blackoutProtectionSetting.blackoutBackPage)
                        {
                            blackoutProtectionSetting.blackoutProtectionDone = false
                            blackoutProtectionSetting.blackoutBackPage = false
                        }
                        else
                        {
                            manualWizardSettings.heatPumpDone = false
                        }

                        pageStack.pop()
                        return

                    }
                    manualWizardSettings.installerData = true
                    wizardSettings.installerData = true
                    setup(true)
                })
                return
            }



            if (showFinalPage) {
                var page = d.pushPage("/ui/wizards/WizardComplete.qml", {hemsManager: hemsManager})
                page.done.connect(function(skip, abort) {




                    exitWizard()
                })
            }


        }





    }

    function checkForRootmeter(){

        var check = false
        for (var i; i < energyMetersProxy.count; i++){

            if (energyManager.rootMeterId === energyMetersProxy.get(i).id){
                check = true
            }
        }
        return check

    }



    Connections {
        target: engine.thingManager

        // if rootmeter gets removed, choose the first energymeter as new root meter
        // the energyMeterProxy seems to be sorted alphabetically
        onThingRemoved:{


            if (!checkForRootmeter()){
                energyManager.setRootMeterId(energyMetersProxy.get(0).id)
            }
        }

        // on ThingAded check if thing is energymeter
        // if yes, check if rootMeter was already assigned.
        onThingAdded: {
            if (thing.thingClass.interfaces.indexOf("energymeter") >= 0) {
                if (checkForRootmeter()){
                    energyManager.setRootMeterId(thing.id);
                }
            }
        }
    }

    Settings {
        id: wizardSettings
        category: "setupWizard"
        property bool solarPanelDone: false
        property bool evChargerDone: false
        property bool heatPumpDone: false
        property bool authorisation: false
        property bool installerData: false
    }

    Settings {
        id: manualWizardSettings
        category: "manualSetupWizard"
        property bool solarPanelDone: true
        property bool evChargerDone: true
        property bool heatPumpDone: true
        property bool authorisation: true
        property bool installerData: true
        property bool energymeter: true

    }

    Settings {
        id: blackoutProtectionSetting
        category: "blackoutProtectionSetting"
        property bool blackoutProtectionDone: true
        property bool blackoutBackPage: false


    }


    onLoadingChanged: {
        userconfig = hemsManager.userConfigurations.getUserConfiguration("528b3820-1b6d-4f37-aea7-a99d21d42e72")

    }

    ThingsProxy {
        id: evProxy
        engine: _engine
        shownInterfaces: ["electricvehicle"]
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

    PowerBalanceLogs {
        id: powerBalanceLogs
        engine: _engine
        startTime: axisAngular.min
    }

    ThingPowerLogs {
        id: thingPowerLogs
        engine: _engine
        startTime: axisAngular.min
    }

    Item {
        id: lsdChart
        anchors.fill: parent
        anchors.topMargin: root.topMargin
//        anchors.bottomMargin: Style.hugeMargins
        visible: rootMeter != null

        property int hours: 24

        readonly property string rootMeterAcquisitionColor: "#E95E52";
        readonly property string rootMeterReturnColor:  "#24A0D6"
        readonly property color producersColor: "#F7EC5A"
        readonly property color batteriesColor: "#84D35E"
        readonly property var consumersColors: [ "#EEAC66", "#CB5C9E", "#9984C4", "#84982E", "#639F86", "#6FD2CD" ]



        Canvas {
            id: linesCanvas
            anchors.fill: parent
            // Breaks on iOS!
            //renderTarget: Canvas.FramebufferObject
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
//              repainting lines canvas
                var ctx = getContext("2d");
                ctx.reset();
                ctx.save();
                var xTranslate = chartView.x + chartView.plotArea.x + chartView.plotArea.width / 2
                var yTranslate = chartView.y + chartView.plotArea.y + chartView.plotArea.height / 2
                ctx.translate(xTranslate, yTranslate)

                ctx.beginPath()
                ctx.fillStyle = Material.background
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

                    // draw every producer, but not the rootMeter as producer, since it is already drawn.
                    var producer = producers.get(i)
                    if(producer.id !== rootMeter.id){
                        var tile = legendProducersRepeater.itemAt(i)
                        drawAnimatedLine(ctx, producer, tile, false, (i + 1) - ((totalTop - 1) / 2), maxCurrentPower, false, xTranslate, yTranslate)
                    }
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
                // end draw Animated Line



//                ctx.strokeStyle = "black"
//                ctx.fillStyle = "black"

//                ctx.beginPath();
//                ctx.setLineDash([1,0])
//                ctx.lineWidth = 5
//                ctx.moveTo(0, -chartView.plotArea.height / 2)
//                ctx.lineTo(0, 0)
//                ctx.stroke();
//                ctx.closePath();

//                ctx.beginPath();
//                ctx.moveTo(-15, -chartView.plotArea.height / 2)
//                ctx.lineTo(15, -chartView.plotArea.height / 2)
//                ctx.lineTo(0, -chartView.plotArea.height / 2 + 20)
//                ctx.lineTo(-15, -chartView.plotArea.height / 2)
//                ctx.fill()
//                ctx.closePath();

//                ctx.restore();
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
                        visible: producers.get(index).id !== rootMeter.id
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
                XYPoint { x: new Date().setTime(new Date().getTime() - 24 * 60 * 60 * 1000); y: 0 }
                XYPoint { x: new Date().getTime(); y: 0 }
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

                function appendPoint(series, timestamp, value) {
                    // always want a point with value 0 at the end.
                    // if we already have points, we'll remove the 0-point at the end, append the new one and a new 0-point after that
//                    if (series.count > 0) {
//                        series.removePoints(series.count - 1, 1)

//                    }

                    // ensure, that the amount of points does not grow infintely
                    if (series.count > 60*24){
                        series.removePoints(0,0)
                    }

                    series.append(timestamp , value)
//                    series.append(new Date().getTime(), 0)

                    // And make sure the zeroSeries is up on par too
                    zeroSeries.removePoints(zeroSeries.count - 1, 1);
                    zeroSeries.append(axisAngular.now.getTime(), 0)

                    // repaint the timepicker so the charts dont overlap
                    timePickerCanvas.requestPaint()

                }

                DateTimeAxis {
                    id: axisAngular
                    gridVisible: false
                    labelsVisible: false
                    lineVisible: false
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
                    color: Material.background
                    max: Math.max(Math.abs(powerBalanceLogs.maxValue), Math.abs(powerBalanceLogs.minValue)) * 1.1
                    min: -Math.max(Math.abs(powerBalanceLogs.maxValue), Math.abs(powerBalanceLogs.minValue)) * 1.1
                }

                AreaSeries {
                    id: productionSeries
                    axisAngular: axisAngular
                    axisRadial: axisRadial
                    color: lsdChart.producersColor
                    borderColor: "transparent"
                    borderWidth: 0
                    lowerSeries: zeroSeries
                    upperSeries: LineSeries {
                        id: productionUpperSeries
                        Component.onCompleted: {
                            for (var i = 0; i < powerBalanceLogs.count; i++) {
                                var entry = powerBalanceLogs.get(i);
                                chartView.appendPoint(productionUpperSeries, entry.timestamp.getTime(), -entry.production)
                            }
                        }

                        Connections {
                            target: powerBalanceLogs
                            onEntryAdded: {
                                chartView.appendPoint(productionUpperSeries, entry.timestamp.getTime(), -entry.production)
                            }
                        }
                    }
                }

                AreaSeries {
                    id: acquisitionSeries
                    axisAngular: axisAngular
                    axisRadial: axisRadial
                    color: lsdChart.rootMeterAcquisitionColor
                    borderColor: "transparent"
                    borderWidth: 0
                    lowerSeries: zeroSeries
//                    visible: false
                    upperSeries: LineSeries {
                        id: acquisitionUpperSeries
                        Component.onCompleted: {
                            for (var i = 0; i < powerBalanceLogs.count; i++) {
                                var entry = powerBalanceLogs.get(i);
                                chartView.appendPoint(acquisitionSeries, entry.timestamp.getTime(), entry.acquisition)
                            }
                        }

                        Connections {
                            target: powerBalanceLogs
                            onEntryAdded: {
                                chartView.appendPoint(acquisitionUpperSeries, entry.timestamp.getTime(), entry.acquisition)
                            }
                        }
                    }
                }

                AreaSeries {
                    id: returnSeries
                    axisAngular: axisAngular
                    axisRadial: axisRadial
                    color: lsdChart.rootMeterReturnColor
                    borderColor: "transparent"
                    borderWidth: 0
//                    visible: false
                    lowerSeries: zeroSeries
                    upperSeries: LineSeries {
                        id: returnUpperSeries
                        Component.onCompleted: {
                            for (var i = 0; i < powerBalanceLogs.count; i++) {
                                var entry = powerBalanceLogs.get(i);
                                chartView.appendPoint(returnUpperSeries, entry.timestamp.getTime(), -entry.acquisition)
                            }
                        }

                        Connections {
                            target: powerBalanceLogs
                            onEntryAdded: {
                                chartView.appendPoint(returnUpperSeries, entry.timestamp.getTime(), -entry.acquisition)
                            }
                        }
                    }
                }

                AreaSeries {
                    id: storageSeries
                    axisAngular: axisAngular
                    axisRadial: axisRadial
                    color: lsdChart.batteriesColor
                    borderColor: "transparent"
                    borderWidth: 0
//                    visible: false
                    lowerSeries: zeroSeries
                    upperSeries: LineSeries {
                        id: storageUpperSeries
                        Component.onCompleted: {
                            for (var i = 0; i < powerBalanceLogs.count; i++) {
                                var entry = powerBalanceLogs.get(i);
                                chartView.appendPoint(storageUpperSeries, entry.timestamp.getTime(), -entry.storage)
                            }
                        }

                        Connections {
                            target: powerBalanceLogs
                            onEntryAdded: {
                                chartView.appendPoint(storageUpperSeries, entry.timestamp.getTime(), -entry.storage)
                            }
                        }
                    }
                }

                Repeater {
                    model: consumers
                    delegate: Item {
                        id: consumerDelegate
                        property Thing thing: consumers.get(index)
                        property AreaSeries consumerSeries: null
                        Component.onCompleted: {
                            consumerSeries = chartView.createSeries(ChartView.SeriesTypeArea, thing.name, axisAngular, axisRadial)
                            consumerSeries.lowerSeries = zeroSeries
                            consumerSeries.upperSeries = lineSeriesComponent.createObject(consumerSeries)
                            consumerSeries.color = lsdChart.consumersColors[index]
                            consumerSeries.borderWidth = 0
                            consumerSeries.borderColor = consumerSeries.color
                        }
                        Component.onDestruction: {
                            chartView.removeSeries(consumerSeries)
                        }

                        Component {
                            id: lineSeriesComponent
                            LineSeries {
                                id: consumerUpperSeries
                                Component.onCompleted: {
                                    for (var i = 0; i < thingPowerLogs.count; i++) {
                                        var entry = thingPowerLogs.get(i)
                                        if (entry.thingId !== consumerDelegate.thing.id) {
                                            continue
                                        }
                                        chartView.appendPoint(consumerUpperSeries, entry.timestamp.getTime(), entry.currentPower)
                                    }
                                }
                                Connections {
                                    target: thingPowerLogs
                                    onEntryAdded: {
                                        chartView.appendPoint(consumerUpperSeries, entry.timestamp.getTime(), entry.currentPower)
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: innerCircle
                    x: chartView.plotArea.x + width / 2
                    y: chartView.plotArea.y + height / 2
                    width: chartView.plotArea.width / 2
                    height: chartView.plotArea.height / 2
                    radius: width / 2
                    color: "#aeaeae"
                    border.width: 0
                    antialiasing: true
                    border.color: "transparent"
                    //visible: false

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
                        onClicked: pageStack.push("DetailedGraphsPage.qml", {energyManager: energyManager, consumersColors: lsdChart.consumersColors})
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
                            id: mainviewTestingLabel
                            Layout.fillWidth: true
                            text: qsTr("Total current power usage")

                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            elide: Text.ElideMiddle
                            color: "white"
                            font: Style.smallFont
                            visible: innerCircle.height > 120
                        }

//                        Label {
//                            id: mainviewTestingLabel2
//                            Layout.fillWidth: true
//                            text: qsTr("test")

//                            horizontalAlignment: Text.AlignHCenter
//                            wrapMode: Text.WordWrap
//                            elide: Text.ElideMiddle
//                            color: "white"
//                            font: Style.smallFont
//                            visible: innerCircle.height > 120
//                        }

                    }
                }
            }

            Canvas {
                id: timePickerCanvas
                anchors.fill: parent
                // Breaks on iOS!
                //renderTarget: Canvas.FramebufferObject
                renderStrategy: Canvas.Cooperative

                onPaint: {
    //              paint timePicker canvas
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.save();
                    var xTranslate = chartView.x + chartView.plotArea.x + chartView.plotArea.width / 2
                    var yTranslate = chartView.y + chartView.plotArea.y + chartView.plotArea.height / 2
                    ctx.translate(xTranslate, yTranslate)

                    ctx.strokeStyle = "black"
                    ctx.fillStyle = "black"

                    ctx.beginPath();
                    ctx.setLineDash([1,0])
                    ctx.lineWidth = 5
                    ctx.moveTo(0, -chartView.plotArea.height / 2 + innerCircle.radius)
                    ctx.lineTo(0, -(chartView.plotArea.width + 20) / 2)
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
                                if (thing.thingClass.interfaces.indexOf("heatpump") >= 0){
                                    pageStack.push("../optimization/HeatingConfigView.qml", {hemsManager: hemsManager, heatpumpThing: thing })
                                }
                                else if (thing.thingClass.interfaces.indexOf("evcharger") >= 0) {
                                    pageStack.push("../optimization/ChargingConfigView.qml", {hemsManager: hemsManager, thing: thing, carThing:  evProxy.getThing(hemsManager.chargingConfigurations.getChargingConfiguration(thing.id).carThingId)  })
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
                        ctx.fillText(tmpDate.toLocaleTimeString(Qt.locale("de_DE"), "HH:mm"), 0, textY)
                    } else {
                        ctx.fillText(tmpDate.getHours(), 0, textY)
                    }

                    ctx.restore()
                }
                ctx.restore();
            }
        }
    }
/*
    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: Style.hugeMargins
        z: -1
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
*/

    EmptyViewPlaceholder {
        anchors { left: parent.left; right: parent.right; margins: app.margins }
        anchors.verticalCenter: parent.verticalCenter
        //visible: !engine.thingManager.fetchingData && root.rootMeter == null
        visible: !engine.thingManager.fetchingData && energyMetersProxy.count === 0
        property bool rootMeter: !engine.thingManager.fetchingData && root.rootMeter == null
        title: qsTr("Your leaflet is not set up yet.")
        text: qsTr("Please complete the setup wizard or manually configure your devices.")
        imageSource: "/ui/images/leaf.svg"
        buttonText: qsTr("Start setup")
        //onImageClicked: buttonClicked()
        onRootMeterChanged: {
            //d.resetWizardSettings()
        }
        onButtonClicked: {
            d.resetWizardSettings()
            d.initialManualWizardSettings()
            d.setup(false)
        }
    }
}
