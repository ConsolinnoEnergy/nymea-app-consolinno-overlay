
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
import QtGraphicalEffects 1.15

import "../components"
import "../delegates"

MainViewBase {
    id: root
    property bool fetchPending: true
    //readonly property bool loading: true
    property bool loading: engine.thingManager.fetchingData
                           || logsLoader.fetchingData
    property UserConfiguration userconfig

    function compareSemanticVersions(version1, version2) {
        // Returns 0 if version1 == version2
        // Returns 1 if version1 > version2
        // Returns -1 if version1 < version2

        var v1 = version1.split('.').map(function(part) { return parseInt(part); });
        var v2 = version2.split('.').map(function(part) { return parseInt(part); });

        for (var i = 0; i < Math.max(v1.length, v2.length); i++) {
            var num1 = i < v1.length ? v1[i] : 0;
            var num2 = i < v2.length ? v2[i] : 0;

            if (num1 < num2) {
                return -1; // version1 is lower
            } else if (num1 > num2) {
                return 1; // version1 is higher
            }
        }

        return 0; // versions are equal
    }

    function checkHEMSVersion(){
        var minSysVersion = Configuration.minSysVersion
        // Checks if System version is less or equal to minSysVersion
        if ([-1].includes(compareSemanticVersions(engine.jsonRpcClient.experiences.Hems, minSysVersion)))
        {
            return false
        }
        return true
    }


    EnergyManager {
        id: energyManager
        engine: _engine
    }

    HemsManager {
        id: hemsManager
        engine: _engine
    }

    headerButtons: [{
            "iconSource": Configuration.infoIcon !== "" ? "/ui/images/"+Configuration.infoIcon : "/ui/images/info.svg",
            "color": Material.foreground,
            "visible": true,
            "trigger": function () {
                pageStack.push("../info/MainviewInfo.qml", {
                                   "stack": pageStack
                               })
            }
        }, {
            "iconSource": Configuration.settingsIcon !== "" ? "/ui/images/"+Configuration.settingsIcon : "/ui/images/configure.svg",
            "color": Style.iconColor,
            "visible": hemsManager.available && rootMeter != null,
            "trigger": function () {
                var page = pageStack.push("HemsOptimizationPage.qml", {
                                              "hemsManager": hemsManager
                                          })
                page.startWizard.connect(function () {
                    pageStack.pop(pageStack.get(0))
                    d.resetManualWizardSettings()
                    d.setup(true)
                })
            }
        }]

    QtObject {
        id: d
        property var firstWizardPage: null

        property bool energyMeterWiazrdSkipped: false
        property bool manualEnergyWizardBack: false

        //readonly property bool loading: false
        function pushPage(comp, properties) {
            var page = pageStack.push(comp, properties)
            if (!d.firstWizardPage) {
                d.firstWizardPage = page
            }
            return page
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
            wizardSettings.heatingElementDone = false
            wizardSettings.authorisation = false
            wizardSettings.installerData = false
        }

        function resetManualWizardSettings() {
            manualWizardSettings.solarPanelDone = false
            manualWizardSettings.evChargerDone = false
            manualWizardSettings.heatPumpDone = false
            manualWizardSettings.heatingElementDone = false
            manualWizardSettings.authorisation = false
            manualWizardSettings.installerData = false
            manualWizardSettings.energymeter = false
        }

        function resetBlackoutProtectionSettings() {
            blackoutProtectionSetting.blackoutProtectionDone = false
        }

        function initialManualWizardSettings() {
            manualWizardSettings.solarPanelDone = true
            manualWizardSettings.evChargerDone = true
            manualWizardSettings.heatPumpDone = true
            manualWizardSettings.heatingElementDone = true
            manualWizardSettings.authorisation = true
            manualWizardSettings.installerData = true
            manualWizardSettings.energymeter = true
        }

        function setup(showFinalPage) {

            print("Setup. Installed energy meters:", energyMetersProxy.count,
                  "EV Chargers:", evChargersProxy.count)

            if ((energyMetersProxy.count === 0 && !wizardSettings.authorisation)
                    || !manualWizardSettings.authorisation) {
                var page = d.pushPage("/ui/wizards/AuthorisationView.qml", { "hemsManager": hemsManager })
                page.done.connect(function (abort, accepted) {
                    if (accepted) {
                        manualWizardSettings.authorisation = true
                        wizardSettings.authorisation = true
                    }
                    if (abort) {
                        exitWizard()
                        return
                    }
                    setup(true)
                })
                return
            }

            if ((energyMetersProxy.count === 0 && !energyMeterWiazrdSkipped)
                    || (energyMetersProxy.count === 0
                        && !manualWizardSettings.energymeter)) {
                var page = d.pushPage("/ui/wizards/SetupEnergyMeterWizard.qml")
                page.done.connect(function (skip, abort) {

                    print("energymeters done", skip, abort)
                    if (abort) {
                        exitWizard()
                        return
                    }
                    if (skip) {
                        energyMeterWiazrdSkipped = true
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

            if ((!wizardSettings.solarPanelDone)
                    || !manualWizardSettings.solarPanelDone) {
                var page = d.pushPage(
                            "/ui/wizards/SetupSolarInverterWizard.qml")
                page.done.connect(function (skip, abort, back) {

                    if (back) {
                        energyMeterWiazrdSkipped = false
                        manualWizardSettings.energymeter = false
                        pageStack.pop()
                        return
                    }

                    if (abort) {
                        manualWizardSettings.solarPanelDone = true
                        exitWizard()
                        return
                    }
                    wizardSettings.solarPanelDone = true
                    manualWizardSettings.solarPanelDone = true
                    setup(true)
                })
                wizardSettings.solarPanelDone = true
                return
            }

            if ((!wizardSettings.evChargerDone)
                    || !manualWizardSettings.evChargerDone) {
                var page = d.pushPage("/ui/wizards/SetupEVChargerWizard.qml")
                page.done.connect(function (skip, abort, back) {
                    if (back) {
                        manualWizardSettings.solarPanelDone = false
                        pageStack.pop()
                        return
                    }

                    if (abort) {
                        manualWizardSettings.evChargerDone = true
                        exitWizard()
                        return
                    }
                    wizardSettings.evChargerDone = true
                    manualWizardSettings.evChargerDone = true
                    setup(true)
                })

                page.countChanged.connect(function () {
                    blackoutProtectionSetting.blackoutProtectionDone = false
                })

                wizardSettings.evChargerDone = true
                return
            }

            if ((!wizardSettings.heatPumpDone)
                    || !manualWizardSettings.heatPumpDone) {
                var page = d.pushPage("/ui/wizards/SetupHeatPumpWizard.qml")
                page.done.connect(function (skip, abort, back) {

                    if (back) {
                        manualWizardSettings.evChargerDone = false
                        pageStack.pop()
                        return
                    }

                    if (abort) {
                        manualWizardSettings.heatPumpDone = true
                        exitWizard()
                        return
                    }

                    wizardSettings.heatPumpDone = true
                    manualWizardSettings.heatPumpDone = true
                    setup(true)
                })

                page.countChanged.connect(function () {
                    blackoutProtectionSetting.blackoutProtectionDone = false
                })

                wizardSettings.heatPumpDone = true
                return
            }

            if((!wizardSettings.heatingElementDone) || (!manualWizardSettings.heatingElementDone)) {
                var page = d.pushPage("/ui/wizards/SetupHeatingElementWizard.qml")
                page.done.connect(function (skip, abort, back) {
                    if (back) {
                        manualWizardSettings.heatPumpDone = false
                        pageStack.pop()
                        return
                    }
                    if (abort) {
                        manualWizardSettings.heatingElementDone = true
                        exitWizard()
                        return
                    }
                    wizardSettings.heatingElementDone = true
                    manualWizardSettings.heatingElementDone = true
                    setup(true)
                })
                page.countChanged.connect(function () {
                    blackoutProtectionSetting.blackoutProtectionDone = false
                })

                wizardSettings.heatingElementDone = true
                return;
            }


            if (!blackoutProtectionSetting.blackoutProtectionDone) {
                var page = d.pushPage(
                            "../optimization/BlackoutProtectionView.qml", {
                                "hemsManager": hemsManager,
                                "directionID": 1
                            })
                page.done.connect(function (skip, abort, back) {

                    if (back) {
                        manualWizardSettings.heatPumpDone = false
                        pageStack.pop()
                        return
                    }

                    if (abort) {

                        blackoutProtectionSetting.blackoutProtectionDone = true
                        exitWizard()
                        return
                    }

                    blackoutProtectionSetting.blackoutBackPage = true
                    blackoutProtectionSetting.blackoutProtectionDone = true
                    setup(true)
                })

                return
            }

            if ((!wizardSettings.installerData)
                    || !manualWizardSettings.installerData) {
                var page = d.pushPage("/ui/wizards/InstallerDataView.qml", {
                                          "hemsManager": hemsManager,
                                          "directionID": 0
                                      })
                page.done.connect(function (saved, skip, back) {

                    if (back) {

                        if (blackoutProtectionSetting.blackoutBackPage) {
                            blackoutProtectionSetting.blackoutProtectionDone = false
                            blackoutProtectionSetting.blackoutBackPage = false
                        } else {
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
                var page = d.pushPage("/ui/wizards/WizardComplete.qml", {
                                          "hemsManager": hemsManager
                                      })
                page.done.connect(function (skip, abort) {

                    exitWizard()
                })
            }
        }
    }

    function checkForRootmeter() {

        var check = false
        for (var i; i < energyMetersProxy.count; i++) {

            if (energyManager.rootMeterId === energyMetersProxy.get(i).id) {
                check = true
            }
        }
        return check
    }

    Connections {
        target: engine.thingManager

        // if rootmeter gets removed, choose the first energymeter as new root meter
        // the energyMeterProxy seems to be sorted alphabetically
        onThingRemoved: {

            if (!checkForRootmeter()) {
                energyManager.setRootMeterId(energyMetersProxy.get(0).id)
            }
        }

        // on ThingAded check if thing is energymeter
        // if yes, check if rootMeter was already assigned.
        onThingAdded: {
            if (thing.thingClass.interfaces.indexOf("energymeter") >= 0) {
                if (checkForRootmeter()) {
                    energyManager.setRootMeterId(thing.id)
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
        property bool heatingElementDone: false
        property bool authorisation: false
        property bool installerData: false
    }

    Settings {
        id: manualWizardSettings
        category: "manualSetupWizard"
        property bool solarPanelDone: true
        property bool evChargerDone: true
        property bool heatPumpDone: true
        property bool heatingElementDone: true
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

    Settings {
        id: shownPopupsSetting
        category: "shownPopups"
        property var shown: []
    }

    Component {
        id: incompNotificationComponent
        Popup {
            property string message: ""
            id: incompNotificationPopup
            parent: root
            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 2)
            width: parent.width * 0.9
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            contentItem: Label {
                Layout.fillWidth: true
                Layout.topMargin: app.margins
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                text: message
            }
        }
    }


    Component {
        id: startUpNotificationComponent

        Popup {
            property string message: ""
            id: startUpNotificationPopup
            parent: root
            x: Math.round((parent.width - width) / 2)
            y: Math.round((parent.height - height) / 2)

            width: parent.width * 0.9
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            contentItem: Label {
                Layout.fillWidth: true
                Layout.topMargin: app.margins
                Layout.leftMargin: app.margins
                Layout.rightMargin: app.margins
                wrapMode: Text.WordWrap
                textFormat: Text.RichText
                text: message
            }
            onClosed: {
                console.debug("shonwPopupsSetting.shown: ",
                              shownPopupsSetting.shown)
                var shownPopups = shownPopupsSetting.shown
                shownPopups.push(appVersion)
                shownPopupsSetting.shown = shownPopups
            }
        }
    }

    onLoadingChanged: {
        console.debug("Loading changed")
        userconfig = hemsManager.userConfigurations.getUserConfiguration(
                    "528b3820-1b6d-4f37-aea7-a99d21d42e72")
    }
    
    onVisibleChanged: {
        console.debug("Visibility of " + engine.jsonRpcClient.currentHost.name + " changed to " + visible)
        if (visible) {
            // Show message if app was updated
            var notficationPopup = startUpNotificationComponent.createObject(root) 
            notficationPopup.message= qsTr('CHANGENOTIFICATION_PLACEHOLDER');
            // If Popup not already open, open it
            if (notficationPopup.opened === false
                    && shownPopupsSetting.shown.indexOf(appVersion) === -1) {
                notficationPopup.open()
            }

            // Show message if HEMS version is not compatible
            if (!checkHEMSVersion()) {
                var incompNotificationPopup = incompNotificationComponent.createObject(root)
                //                incompNotificationPopup.message = qsTr("%2 App is not compatible with the HEMS system version running on %1. Please update your HEMS.").arg(engine.jsonRpcClient.currentHost.name).arg(Configuration.appName)
                
                let phone = (Configuration.serviceTel !== "") ? qsTr("Phone: <a href='tel:%1'>%1</a>").arg(Configuration.serviceTel) : ""
                let mail = qsTr("Email: <a href='mailto:%1'>%1</a>").arg(Configuration.serviceEmail)

                incompNotificationPopup.message=qsTr('<h3>Incompatible Software Versions</h3>
                <p>The software versions of your "%3 App" (v%1) and your "%6 End Device" (v%2) are incompatible and currently only partially usable. Your "%6 End Device" will be automatically updated during the day.</p>
                <p>If you still receive this message after several hours, please contact our support:</p>
                <ul>
                    <li>%7</li>
                    <li>%4</li>
                </ul>
                <p>We apologize for the temporary limitations in use.</p>
                <p>Best regards</p>
                <p>Your %5 Team</p>').arg(appVersion).arg(engine.jsonRpcClient.experiences.Hems).arg(Configuration.appName).arg(mail).arg(Configuration.appName).arg(Configuration.deviceName).arg(phone)
                // If Popup not already open, open it
                if (incompNotificationPopup.opened === false) {
                    incompNotificationPopup.open()
                }
            }
        }
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
        shownInterfaces: ["smartmeterconsumer", "heatpump", "evcharger", "smartheatingrod"]
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
    ThingsProxy {
        id: electrics
        engine: _engine
        shownInterfaces: ["dynamicelectricitypricing"]
    }
    ThingsProxy {
        id: gridSupport
        engine: _engine
        shownInterfaces: ["gridsupport"]
    }
    PowerBalanceLogs {
        id: powerBalanceLogs
        engine: _engine
        startTime: axisAngular.min
        endTime: axisAngular.max
        sampleRate: EnergyLogs.SampleRate15Mins
        Component.onCompleted: fetchLogs()
    }

    ThingPowerLogsLoader {
        id: logsLoader
        engine: _engine
        startTime: axisAngular.min
        endTime: axisAngular.max
        sampleRate: EnergyLogs.SampleRate15Mins
    }

    Item {
        id: lsdChart
        anchors.fill: parent
        anchors.topMargin: root.topMargin
        visible: rootMeter != null

        property int hours: 24
        readonly property var consumersColors: Configuration.consumerColors
        readonly property color electricsColor: Configuration.epexColor
        property string currentGridValueState: ""

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
                running: linesCanvas.visible
                         && Qt.application.state === Qt.ApplicationActive
            }
            onLineAnimationProgressChanged: requestPaint()

            onPaint: {
                //              repainting lines canvas
                var ctx = getContext("2d")
                ctx.reset()
                ctx.save()
                var xTranslate = chartView.x + chartView.plotArea.x + chartView.plotArea.width / 2
                var yTranslate = chartView.y + chartView.plotArea.y + chartView.plotArea.height / 2
                ctx.translate(xTranslate, yTranslate)

                ctx.beginPath()
                ctx.fillStyle = Material.background
                ctx.arc(0, 0, chartView.plotArea.width / 2, 0, 2 * Math.PI)
                ctx.fill()
                ctx.closePath()

                ctx.strokeStyle = Style.foregroundColor
                ctx.fillStyle = Style.foregroundColor


                lsdChart.currentGridValueState = gridSupport.get(0) !== null ? gridSupport.get(0).stateByName("plimStatus").value : ""

                var maxCurrentPower = rootMeter ? Math.abs(
                                                      rootMeter.stateByName(
                                                          "currentPower").value) : 0

                var currentPrice = electrics.count > 0 ? Math.abs(electrics.get(0).stateByName(
                                                            "currentMarketPrice").value) : 0

                for (var i = 0; i < producers.count; i++) {
                    maxCurrentPower = Math.max(maxCurrentPower, Math.abs(
                                                   producers.get(i).stateByName(
                                                       "currentPower").value))
                }
                for (var i = 0; i < consumers.count; i++) {
                    if (consumers.get(i).thingClass.interfaces.indexOf(
                                "smartmeterconsumer") >= 0) {
                        maxCurrentPower = Math.max(
                                    maxCurrentPower,
                                    Math.abs(consumers.get(i).stateByName(
                                                 "currentPower").value))
                    }
                }
                for (var i = 0; i < producers.count; i++) {
                    maxCurrentPower = Math.max(maxCurrentPower, Math.abs(
                                                   producers.get(i).stateByName(
                                                       "currentPower").value))
                }
                for (var i = 0; i < batteries.count; i++) {
                    maxCurrentPower = Math.max(maxCurrentPower, Math.abs(
                                                   batteries.get(i).stateByName(
                                                       "currentPower").value))
                }
                for (var i = 0; i < electrics.count; i++) {
                    currentPrice = Math.max(currentPrice, Math.abs(
                                                   electrics.get(i).stateByName(
                                                    "currentMarketPrice").value))
                }


                var totalTop = rootMeter ? 1 : 0
                totalTop += producers.count

                // dashed lines from rootMeter
                if (rootMeter) {
                    drawAnimatedLine(ctx, rootMeter.stateByName(
                                         "currentPower").value, rootMeterTile,
                                     false, -(totalTop - 1) / 2,
                                     maxCurrentPower, true, xTranslate,
                                     yTranslate)
                }

                for (var i = 0; i < producers.count; i++) {

                    // draw every producer, but not the rootMeter as producer, since it is already drawn.
                    var producer = producers.get(i)
                    if (rootMeter && producer.id !== rootMeter.id) {
                        var tile = legendProducersRepeater.itemAt(i)
                        drawAnimatedLine(ctx, producer.stateByName(
                                             "currentPower").value, tile,
                                         false, (i + 1) - ((totalTop - 1) / 2),
                                         maxCurrentPower, false,
                                         xTranslate, yTranslate)
                    }
                }

                var totalBottom = consumers.count + batteries.count

                for (var i = 0; i < consumers.count; i++) {
                    var consumer = consumers.get(i)
                    var tile = legendConsumersRepeater.itemAt(i)
                    if (consumer.thingClass.interfaces.indexOf(
                                "smartmeterconsumer") >= 0) {
                        drawAnimatedLine(
                                    ctx, consumer.stateByName(
                                        "currentPower").value, tile,
                                    true, i - ((totalBottom - 1) / 2), maxCurrentPower,
                                    false, xTranslate, yTranslate)
                    } else {
                        // draws line for consumers without power monitoring
                        drawAnimatedLine(ctx, 0, tile, true,
                                         i - ((totalBottom - 1) / 2),
                                         maxCurrentPower, false, xTranslate,
                                         yTranslate)
                    }
                }

                for (var i = 0; i < batteries.count; i++) {
                    var battery = batteries.get(i)
                    var tile = legendBatteriesRepeater.itemAt(i)
                    drawAnimatedLine(
                                ctx, battery.stateByName(
                                    "currentPower").value, tile,
                                true, consumers.count + i - ((totalBottom - 1) / 2),
                                maxCurrentPower, false, xTranslate, yTranslate)
                }

                // end draw Animated Line
            }

            function drawAnimatedLine(ctx, currentPower, tile, bottom, index, relativeTo, inverted, xTranslate, yTranslate) {
                ctx.beginPath()
                // rM : max = x : 5
                ctx.lineWidth = Math.abs(currentPower) / Math.abs(
                            relativeTo) * 5 + 1
                ctx.setLineDash([5, 2])
                var tilePosition = tile.mapToItem(linesCanvas,
                                                  tile.width / 2, 0)
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
                var progress = currentPower
                        === 0 ? 0 : currentPower > 0 ? lineAnimationProgress : 1
                                                       - lineAnimationProgress
                if (inverted) {
                    progress = 1 - progress
                }
                var extensionStartY = startY - extensionLength * progress
                if (bottom) {
                    extensionStartY = startY + extensionLength * progress
                }

                ctx.moveTo(startX, extensionStartY)
                ctx.lineTo(startX, startY)
                ctx.bezierCurveTo(startX, endY + height / 2, endX,
                                  startY - height / 2, endX, endY)
                ctx.stroke()
                ctx.closePath()
            }
        }
        ColumnLayout {
            id: layout
            anchors.fill: parent

            Flickable {
                Layout.preferredWidth: Math.min(
                                           implicitWidth,
                                           parent.width - Style.margins * 2)
                implicitWidth: topLegend.implicitWidth
                Layout.margins: Style.margins
                Layout.preferredHeight: topLegend.implicitHeight
                contentWidth: topLegend.implicitWidth
                Layout.alignment: Qt.AlignHCenter
                onContentXChanged: {
                    linesCanvas.requestPaint()
                }



                RowLayout {
                    id: topLegend
                    Layout.fillWidth: true
                    Layout.margins: Style.margins
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Style.margins

                    LegendTile {
                        id: rootMeterTile
                        thing: rootMeter
                        isRootmeter: true
                        isElectric: false
                        isNotify: lsdChart.currentGridValueState
                        color: Configuration.rootMeterAcquisitionColor
                        negativeColor: Configuration.rootMeterReturnColor
                        onClicked: {
                            print("Clicked root meter", index, thing.name)
                            pageStack.push(
                                        "/ui/devicepages/GenericSmartDeviceMeterPage.qml",
                                        {
                                            "thing": thing,
                                            "isRootmeter": isRootmeter,
                                            "isNotify": isNotify
                                        })
                        }
                    }

                    Repeater {
                        id: legendProducersRepeater
                        model: producers
                        delegate: LegendTile {
                            visible: rootMeter && producers.get(index).id !== rootMeter.id
                            color: Configuration.inverterColor
                            thing: producers.get(index)
                            isElectric: false
                            onClicked: {
                                print("Clicked producer", index, thing.name)
                                pageStack.push(
                                            "/ui/devicepages/GenericSmartDeviceMeterPage.qml",
                                            {
                                                "thing": thing
                                            })
                            }
                        }
                    }

                    Repeater {
                        id: legendElectricsRepeater
                        model: electrics
                        delegate: LegendTile {
                            visible: rootMeter && electrics.get(index).id !== rootMeter.id
                            color: lsdChart.electricsColor
                            thing: electrics.get(index)
                            isElectric: true
                            onClicked: {
                                print("Clicked producer", index, thing.name)
                                pageStack.push("/ui/devicepages/PageWraper.qml")
                            }
                        }
                    }
                }
            }

            LineSeries {
                id: zeroSeries
                XYPoint {
                    x: new Date().setTime(new Date().getTime(
                                              ) - 24 * 60 * 60 * 1000)
                    y: 0
                }
                XYPoint {
                    x: new Date().getTime()
                    y: 0
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
                    circleCanvas.requestPaint()
                    linesCanvas.requestPaint()
                    timePickerCanvas.requestPaint()
                }

                function appendPoint(series, timestamp, value) {
                    // always want a point with value 0 at the end.
                    // if we already have points, we'll remove the 0-point at the end, append the new one and a new 0-point after that
                    //                    if (series.count > 0) {
                    //                        series.removePoints(series.count - 1, 1)

                    //                    }

                    // ensure, that the amount of points does not grow infintely
                    if (series.count > 60 * 24) {
                        series.removePoints(0, 0)
                    }

                    series.append(timestamp, value)
                    //                    series.append(new Date().getTime(), 0)

                    // And make sure the zeroSeries is up on par too
                    zeroSeries.removePoints(zeroSeries.count - 1, 1)
                    zeroSeries.append(axisAngular.now.getTime(), 0)
                }

                DateTimeAxis {
                    id: axisAngular
                    gridVisible: false
                    labelsVisible: false
                    lineVisible: false
                    property date now: new Date()
                    min: {
                        var date = new Date(now)
                        date.setTime(date.getTime(
                                         ) - (1000 * 60 * 60 * lsdChart.hours) + 2000)
                        return date
                    }
                    max: {
                        var date = new Date(now)
                        date.setTime(date.getTime() + 2000)
                        return date
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
                    max: Math.max(Math.abs(powerBalanceLogs.maxValue),
                                  Math.abs(powerBalanceLogs.minValue)) * 1.1
                    min: -Math.max(Math.abs(powerBalanceLogs.maxValue),
                                   Math.abs(powerBalanceLogs.minValue)) * 1.1
                }

                AreaSeries {
                    id: productionSeries
                    axisAngular: axisAngular
                    axisRadial: axisRadial
                    color: Configuration.inverterColor
                    borderColor: "transparent"
                    borderWidth: 0
                    lowerSeries: zeroSeries
                    upperSeries: LineSeries {
                        id: productionUpperSeries
                        Component.onCompleted: {
                            for (var i = 0; i < powerBalanceLogs.count; i++) {
                                var entry = powerBalanceLogs.get(i)
                                chartView.appendPoint(productionUpperSeries,
                                                      entry.timestamp.getTime(
                                                          ), -entry.production)
                            }
                        }

                        Connections {
                            target: powerBalanceLogs
                            onEntriesAdded: {
                                for (var i = 0; i < entries.length; i++) {
                                    var entry = entries[i]
                                    chartView.appendPoint(
                                                productionUpperSeries,
                                                entry.timestamp.getTime(),
                                                -entry.production)

                                    chartView.appendPoint(
                                                acquisitionUpperSeries,
                                                entry.timestamp.getTime(),
                                                entry.acquisition)
                                    chartView.appendPoint(
                                                returnUpperSeries,
                                                entry.timestamp.getTime(),
                                                -entry.acquisition)
                                    chartView.appendPoint(
                                                storageUpperSeries,
                                                entry.timestamp.getTime(),
                                                -entry.storage)
                                }
                            }
                        }
                    }
                }

                AreaSeries {
                    id: acquisitionSeries
                    axisAngular: axisAngular
                    axisRadial: axisRadial
                    color: Configuration.rootMeterAcquisitionColor
                    borderColor: "transparent"
                    borderWidth: 0
                    lowerSeries: zeroSeries
                    //                    visible: false
                    upperSeries: LineSeries {
                        id: acquisitionUpperSeries
                        Component.onCompleted: {
                            for (var i = 0; i < powerBalanceLogs.count; i++) {
                                var entry = powerBalanceLogs.get(i)
                                chartView.appendPoint(acquisitionSeries,
                                                      entry.timestamp.getTime(
                                                          ), entry.acquisition)
                            }
                        }

                        //                        Connections {
                        //                            target: powerBalanceLogs
                        //                            onEntriesAdded: {
                        //                                for (var i = 0; i < entries.length; i++) {
                        //                                var entry = entries[i]
                        //                                chartView.appendPoint(acquisitionUpperSeries,
                        //                                                      entry.timestamp.getTime(
                        //                                                          ), entry.acquisition)
                        //                                }
                        //                            }
                        //                        }
                    }
                }

                AreaSeries {
                    id: returnSeries
                    axisAngular: axisAngular
                    axisRadial: axisRadial
                    color: Configuration.rootMeterReturnColor
                    borderColor: "transparent"
                    borderWidth: 0
                    //                    visible: false
                    lowerSeries: zeroSeries
                    upperSeries: LineSeries {
                        id: returnUpperSeries
                        Component.onCompleted: {
                            for (var i = 0; i < powerBalanceLogs.count; i++) {
                                var entry = powerBalanceLogs.get(i)
                                chartView.appendPoint(returnUpperSeries,
                                                      entry.timestamp.getTime(
                                                          ), -entry.acquisition)
                            }
                        }

                        //                        Connections {
                        //                            target: powerBalanceLogs
                        //                            onEntriesAdded: {
                        //                                for (var i = 0; i < entries.length; i++) {
                        //                                var entry = entries[i]
                        //                                chartView.appendPoint(returnUpperSeries,
                        //                                                      entry.timestamp.getTime(
                        //                                                          ), -entry.acquisition)
                        //                                }
                        //                            }
                        //                        }
                    }
                }

                AreaSeries {
                    id: storageSeries
                    axisAngular: axisAngular
                    axisRadial: axisRadial
                    color: Configuration.batteriesColor
                    borderColor: "transparent"
                    borderWidth: 0
                    //                    visible: false
                    lowerSeries: zeroSeries
                    upperSeries: LineSeries {
                        id: storageUpperSeries
                        Component.onCompleted: {
                            for (var i = 0; i < powerBalanceLogs.count; i++) {
                                var entry = powerBalanceLogs.get(i)
                                chartView.appendPoint(storageUpperSeries,
                                                      entry.timestamp.getTime(
                                                          ), -entry.storage)
                            }
                        }

                        //                        Connections {
                        //                            target: powerBalanceLogs
                        //                            onEntriesAdded: {
                        //                                for (var i = 0; i < entries.length; i++) {
                        //                                var entry = entries[i]
                        //                                chartView.appendPoint(storageUpperSeries,
                        //                                                      entry.timestamp.getTime(
                        //                                                          ), -entry.storage)
                        //                                }
                        //                            }
                        //                        }
                    }
                }

                Repeater {
                    model: consumers
                    delegate: Item {
                        id: consumerDelegate
                        property Thing thing: consumers.get(index)
                        property AreaSeries consumerSeries: null
                        Component.onCompleted: {
                            consumerSeries = chartView.createSeries(
                                        ChartView.SeriesTypeArea, thing.name,
                                        axisAngular, axisRadial)
                            consumerSeries.lowerSeries = zeroSeries
                            consumerSeries.upperSeries = lineSeriesComponent.createObject(
                                        consumerSeries)

                            if(thing.thingClass.interfaces.indexOf("heatpump") >= 0){
                                consumerSeries.color = Configuration.heatpumpColor
                            }else if(thing.thingClass.interfaces.indexOf("evcharger") >= 0){
                                consumerSeries.color = Configuration.wallboxColor
                            }else if(thing.thingClass.interfaces.indexOf("smartheatingrod") >= 0){
                                consumerSeries.color = Configuration.heatingRodColor
                            }else{
                                consumerSeries.color = lsdChart.consumersColors[index]
                            }
                            consumerSeries.borderWidth = 0
                            consumerSeries.borderColor = consumerSeries.color
                        }
                        Component.onDestruction: {
                            chartView.removeSeries(consumerSeries)
                        }

                        readonly property ThingPowerLogs logs: ThingPowerLogs {
                            id: thingPowerLogs
                            engine: _engine
                            startTime: axisAngular.min
                            endTime: axisAngular.max
                            thingId: consumerDelegate.thing.id
                            loader: logsLoader
                            Component.onCompleted: fetchLogs()
                        }

                        Component {
                            id: lineSeriesComponent
                            LineSeries {
                                id: consumerUpperSeries
                                Component.onCompleted: {
                                    for (var i = 0; i < thingPowerLogs.count; i++) {
                                        var entry = thingPowerLogs.get(i)
                                        chartView.appendPoint(
                                                    consumerUpperSeries,
                                                    entry.timestamp.getTime(),
                                                    entry.currentPower)
                                    }
                                }
                                Connections {
                                    target: thingPowerLogs
                                    onEntriesAdded: {
                                        for (var i = 0; i < entries.length; i++) {
                                            var entry = entries[i]
                                            chartView.appendPoint(
                                                        consumerUpperSeries,
                                                        entry.timestamp.getTime(
                                                            ),
                                                        entry.currentPower)
                                        }
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

                    RadialGradient {
                        id: grad
                        anchors.fill: parent
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                //color: "#949494"
                                color: Configuration.mainInnerCicleFirst //"#b6b6b6" //Configuration.mainInnerCicleFirst
                            }
                            GradientStop {
                                position: 0.8
                                //color: "white"
                                color: Configuration.mainInnerCicleSecond //"#b6b6b6" //Configuration.mainInnerCicleSecond
                            }
                        }
                    }

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        id: mask
                        maskSource: Rectangle {
                            height: grad.height
                            width: grad.width
                            radius: width / 2 - 1
                        }
                    }
                    border.width: 1
                    antialiasing: true
                    border.color: "#ffffff"

                    //visible: false
                    MouseArea {
                        anchors.fill: parent
                        onPressed: {
                            // Only handle presses that are within the circle
                            var mouseXcentered = mouseX - width / 2
                            var mouseYcentered = mouseY - height / 2
                            var distanceFromCenter = Math.sqrt(
                                        Math.pow(mouseXcentered,
                                                 2) + Math.pow(mouseYcentered,
                                                               2))
                            if (distanceFromCenter > width / 2) {
                                mouse.accepted = false
                            }
                        }
                        onClicked: pageStack.push("DetailedGraphsPage.qml", {
                                                      "energyManager": energyManager,
                                                      "totalColors": Configuration.totalColors,
                                                      "consumersColors": lsdChart.consumersColors
                                                  })
                    }

                    ColumnLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: Style.margins
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            textFormat: Text.RichText
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                            text: getText()

                            function getText() {
                                const powerConsumption = energyManager.currentPowerConsumption;
                                const bigFontSize = Style.bigFont.pixelSize;
                                const smallFontSize = Style.smallFont.pixelSize;

                                let displayPower = powerConsumption < 1000 
                                    ? powerConsumption 
                                    : powerConsumption / 1000;

                                displayPower = displayPower.toFixed(1); 
                                let displayPowerStr = (+displayPower).toLocaleString();

                                const unit = powerConsumption < 1000 
                                    ? "W" 
                                    : "kW";

                                const powerSpan = `<span style="font-size:${bigFontSize}px">${displayPowerStr}</span>`;
                                const unitSpan = `<span style="font-size:${smallFontSize}px">${unit}</span>`;

                                return powerSpan + " " + unitSpan;
                            }
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

            Flickable {
                Layout.preferredWidth: Math.min(
                                           implicitWidth,
                                           parent.width - Style.margins * 2)
                implicitWidth: bottomLegend.implicitWidth
                Layout.margins: Style.margins
                Layout.preferredHeight: tabsRepeater.count >= 2 ? bottomLegend.implicitHeight + 50 : bottomLegend.implicitHeight
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
                            color: {
                                if(thing.thingClass.interfaces.indexOf("heatpump") >= 0){
                                    return Configuration.heatpumpColor
                                }else if(thing.thingClass.interfaces.indexOf("evcharger") >= 0){
                                    return Configuration.wallboxColor
                                }else if(thing.thingClass.interfaces.indexOf("smartheatingrod") >= 0){
                                    return Configuration.heatingRodColor
                                }else{
                                    return lsdChart.consumersColors[index]
                                }
                            }
                            thing: consumers.get(index)
                            onClicked: {
                                print("Clicked consumer", index, thing.name)
                                if (thing.thingClass.interfaces.indexOf(
                                            "heatpump") >= 0) {
                                    pageStack.push(
                                                "../optimization/HeatingConfigView.qml",
                                                {
                                                    "hemsManager": hemsManager,
                                                    "thing": thing
                                                })
                                } else if (thing.thingClass.interfaces.indexOf(
                                               "evcharger") >= 0) {

                                    // check if those specific values are provided by the thing
                                    var pluggedIn = thing.stateByName(
                                                "pluggedIn")
                                    var maxChargingCurrent = thing.stateByName(
                                                "maxChargingCurrent")
                                    var phaseCount = thing.stateByName(
                                                "phaseCount")

                                    // if yes you can use the optimization
                                    if (pluggedIn !== null
                                            && maxChargingCurrent !== null
                                            && phaseCount !== null) {
                                        pageStack.push(
                                                    "../optimization/ChargingConfigView.qml",
                                                    {
                                                        "hemsManager": hemsManager,
                                                        "thing": thing,
                                                        "carThing": evProxy.getThing(
                                                                        hemsManager.chargingConfigurations.getChargingConfiguration(
                                                                            thing.id).carThingId)
                                                    })
                                    } // if not you have to resort to the EvChargerThingPage
                                    else {
                                        pageStack.push(
                                                    "/ui/devicepages/EvChargerThingPage.qml",
                                                    {
                                                        "thing": thing
                                                    })
                                    }

                                } else if(thing.thingClass.interfaces.indexOf("smartheatingrod") >= 0) {
                                    pageStack.push(
                                                "/ui/devicepages/HeatingElementDevicePage.qml",
                                                {
                                                    "hemsManager": hemsManager,
                                                    "thing": thing
                                                })
                                } else {
                                    pageStack.push(
                                                "/ui/devicepages/GenericSmartDeviceMeterPage.qml",
                                                {
                                                    "thing": thing
                                                })
                                }
                            }
                        }
                    }

                    Repeater {
                        id: legendBatteriesRepeater
                        model: batteries
                        delegate: LegendTile {
                            color: Configuration.batteriesColor
                            thing: batteries.get(index)
                            onClicked: {
                                print("Clicked battery", index, thing.name)
                                let noDynPrice = electrics.count >= 1 && thing.thingClass.interfaces.indexOf("controllablebattery") >= 0 ? "/ui/optimization/BatteryConfigView.qml" : "/ui/devicepages/GenericSmartDeviceMeterPage.qml"
                                let batteryView = thing.thingClass.interfaces.indexOf("controllablebattery") >= 0 ? "/ui/optimization/BatteryConfigView.qml" : "/ui/devicepages/GenericSmartDeviceMeterPage.qml"
                                pageStack.push((noDynPrice || batteryView),
                                            {
                                                "hemsManager": hemsManager,
                                                "thing": thing
                                            })
                            }
                        }
                    }
                }
            }
        }

        Canvas {
            id: timePickerCanvas
            anchors.fill: layout

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

                ctx.strokeStyle = Configuration.mainTimeNow
                ctx.fillStyle = Configuration.mainTimeNow

                ctx.beginPath()
                ctx.lineWidth = 3
                ctx.moveTo(0,
                           -chartView.plotArea.height / 2 + innerCircle.radius)
                ctx.lineTo(0, -(chartView.plotArea.width + 20) / 2)
                ctx.stroke()
                ctx.closePath()

                ctx.beginPath()
                ctx.moveTo(-15, -chartView.plotArea.height / 2)
                ctx.lineTo(15, -chartView.plotArea.height / 2)
                ctx.lineTo(0, -chartView.plotArea.height / 2 + 20)
                ctx.lineTo(-15, -chartView.plotArea.height / 2)
                ctx.fill()
                ctx.closePath()

                ctx.restore()
            }
        }


        /**
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

**/
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
                var ctx = getContext("2d")
                ctx.reset()
                ctx.save()
                var xTranslate = chartView.x + chartView.plotArea.x + chartView.plotArea.width / 2
                var yTranslate = chartView.y + chartView.plotArea.y + chartView.plotArea.height / 2
                ctx.translate(xTranslate, yTranslate)

                // Outer circle
                ctx.lineWidth = circleWidth
                var sliceAngle = 2 * Math.PI / lsdChart.hours
                var timeSinceFullHour = new Date().getMinutes()
                var timeDiffRotation = timeSinceFullHour * sliceAngle / 60

                // could also be just a circle if only one color is used
                // see strokeStyle
                for (var i = 0; i < lsdChart.hours; i++) {
                    ctx.save()
                    ctx.rotate(i * sliceAngle - timeDiffRotation)
                    ctx.beginPath()
                    //ctx.strokeStyle = i % 2 == 0 ? Style.gray : Style.darkGray; //alternating colors
                    ctx.strokeStyle = Configuration.mainTimeCircle // could also be achieved with only a circle //Color for inner circle
                    ctx.arc(0, 0, (chartView.plotArea.width + circleWidth) / 2,
                            0, sliceAngle)
                    ctx.stroke()
                    ctx.closePath()
                    ctx.restore()
                }
                // Dividers between sections
                for (var i = 0; i < lsdChart.hours; i++) {
                    ctx.save()
                    ctx.rotate(i * sliceAngle - timeDiffRotation)
                    ctx.beginPath()
                    ctx.strokeStyle = Configuration.mainTimeCircleDivider
                    ctx.arc(0, 0, (chartView.plotArea.width + circleWidth) / 2,
                            0, 0.005)
                    ctx.stroke()
                    ctx.closePath()
                    ctx.restore()
                }

                // Hour texts in outer circle
                var startHour = new Date().getHours() - lsdChart.hours + 1
                for (var i = 0; i < lsdChart.hours; i++) {
                    ctx.save()

                    ctx.rotate(i * sliceAngle - timeDiffRotation + sliceAngle * 1.5)

                    var tmpDate = new Date()
                    tmpDate.setHours(startHour + i, 0, 0)
                    ctx.textAlign = 'center'
                    ctx.font = "" + Style.smallFont.pixelSize + "px " + Style.smallFont.family
                    ctx.fillStyle = Configuration.mainCircleTimeColor //gray
                    var textY = -(chartView.plotArea.height + circleWidth) / 2
                            + Style.smallFont.pixelSize / 2
                    // Just can't figure out where I'm missing thosw 2 pixels in the proper calculation (yet)...
                    textY -= 2
                    if (chartView.width > 400 && chartView.height > 400) {
                        ctx.fillText(tmpDate.toLocaleTimeString(
                                         Qt.locale("de_DE"), "HH:mm"), 0, textY)
                    } else {
                        ctx.fillText(tmpDate.getHours(), 0, textY)
                    }

                    ctx.restore()
                }
                ctx.restore()
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
        anchors {
            left: parent.left
            right: parent.right
            margins: app.margins
        }
        anchors.verticalCenter: parent.verticalCenter
        //visible: !engine.thingManager.fetchingData && root.rootMeter == null
        visible: !engine.thingManager.fetchingData
                 && energyMetersProxy.count === 0
        property bool rootMeter: !engine.thingManager.fetchingData
                                 && root.rootMeter == null
        title: qsTr("Your %1 is not set up yet.").arg(Configuration.deviceName)
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
            d.resetBlackoutProtectionSettings()
            d.setup(false)
        }
    }
}
