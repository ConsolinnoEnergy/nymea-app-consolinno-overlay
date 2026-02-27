import QtQuick
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
import QtQuick.Controls
import QtCharts
import Nymea 1.0
import "qrc:/ui/components/"

StatsBase {
    id: root

    property EnergyManager energyManager: null

    property bool titleVisible: true
    property var totalColors: null

    property ThingsProxy producers: ThingsProxy {
        engine: _engine
        shownInterfaces: ["smartmeterproducer"]
    }

    readonly property bool hasProducers: producers.count > 0

    QtObject {
        id: d
        property var config: root.configs[selectionTabs.currentValue.config]
        property int startOffset: 0

        property var selectedSet: null

        property date startTime: root.calculateTimestamp(config.startTime(), config.sampleRate, startOffset)
        property date endTime: root.calculateTimestamp(config.startTime(), config.sampleRate, startOffset + config.count)

        property bool fetchPending: false
        property bool loading: fetchPending || wheelStopTimer.running || powerBalanceLogs.fetchingData
        onLoadingChanged: {
            if (!loading) {
                refresh()
            }
        }

        onConfigChanged: valueAxis.max = 1
        onStartOffsetChanged: {
            refresh()
        }

        function selectSet(set) {
            if (d.selectedSet === set) {
                d.selectedSet = null
            } else {
                d.selectedSet = set
            }
        }

        function refresh() {
            if (powerBalanceLogs.loadingInhibited) {
                return;
            }


            var upcomingTimestamp = root.calculateTimestamp(d.config.startTime(), d.config.sampleRate, d.config.count)
//            print("refreshing config start", d.config.startTime(), "upcoming:", upcomingTimestamp, "fetchPending", d.fetchPending)
            for (var i = 0; i < d.config.count; i++) {
                var timestamp = root.calculateTimestamp(d.config.startTime(), d.config.sampleRate, d.startOffset + i + 1)
                var previousTimestamp = root.calculateTimestamp(timestamp, d.config.sampleRate, -1)
                var idx = powerBalanceLogs.indexOf(timestamp);
                var entry = powerBalanceLogs.get(idx)
//                print("timestamp:", timestamp, "previousTimestamp:", previousTimestamp)
                var previousEntry = powerBalanceLogs.find(previousTimestamp);
                if (timestamp < upcomingTimestamp && entry && (previousEntry || !d.loading)) {
//                    print("found entry:", entry.timestamp, entry.totalConsumption)
//                    if (previousEntry) {
//                        print("found previous:", previousEntry.timestamp, previousEntry.totalConsumption)
//                    }
                    var consumption = entry.totalConsumption
                    var production = entry.totalProduction
                    var acquisition = entry.totalAcquisition
                    var returned = entry.totalReturn
                    if (previousEntry) {
                        consumption -= previousEntry.totalConsumption
                        production -= previousEntry.totalProduction
                        acquisition -= previousEntry.totalAcquisition
                        returned -= previousEntry.totalReturn
                    }
                    consumptionSet.replace(i, consumption)
                    productionSet.replace(i, production)
                    acquisitionSet.replace(i, acquisition)
                    returnSet.replace(i, returned)
                    valueAxis.adjustMax(consumption)
                    valueAxis.adjustMax(production)
                    valueAxis.adjustMax(acquisition)
                    valueAxis.adjustMax(returned)
                } else if (timestamp.getTime() == upcomingTimestamp.getTime() && (previousEntry || !d.loading)) {
//                    print("it's today!")
                    var consumption = energyManager.totalConsumption
                    var production = energyManager.totalProduction
                    var acquisition = energyManager.totalAcquisition
                    var returned = energyManager.totalReturn
                    if (previousEntry) {
                        consumption -= previousEntry.totalConsumption
                        production -= previousEntry.totalProduction
                        acquisition -= previousEntry.totalAcquisition
                        returned -= previousEntry.totalReturn
                    }
                    consumptionSet.replace(i, consumption)
                    productionSet.replace(i, production)
                    acquisitionSet.replace(i, acquisition)
                    returnSet.replace(i, returned)
                    valueAxis.adjustMax(consumption)
                    valueAxis.adjustMax(production)
                    valueAxis.adjustMax(acquisition)
                    valueAxis.adjustMax(returned)
                } else {
                    consumptionSet.replace(i, 0)
                    productionSet.replace(i, 0)
                    acquisitionSet.replace(i, 0)
                    returnSet.replace(i, 0)
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Label {
            Layout.fillWidth: true
            Layout.margins: Style.smallMargins
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Totals")
            visible: root.titleVisible
        }

        ConsolinnoSelectionTabs {
            id: selectionTabs
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            currentIndex: 1
            model: ListModel {
                ListElement { modelData: qsTr("Hours"); config: "hours" }
                ListElement { modelData: qsTr("Days"); config: "days" }
                ListElement { modelData: qsTr("Weeks"); config: "weeks" }
                ListElement { modelData: qsTr("Months"); config: "months" }
                ListElement { modelData: qsTr("Years"); config: "years" }
//                ListElement { modelData: qsTr("Minutes"); config: "minutes" }
            }
            onTabSelected: {
                d.startOffset = 0
                powerBalanceLogs.fetchLogs()
            }
        }

        Connections {
            target: energyManager
            onPowerBalanceChanged: {
//                print("updating because of power balance change. fetchingData", powerBalanceLogs.fetchingData, "fetchPending", d.fetchPending)
                d.refresh();
            }
        }

        PowerBalanceLogs {
            id: powerBalanceLogs
            engine: _engine
            startTime: root.calculateTimestamp(d.startTime, d.config.sampleRate, -d.config.count)
            endTime: root.calculateTimestamp(d.startTime, d.config.sampleRate, d.config.count)
            sampleRate: d.config.sampleRate
            Component.onCompleted: fetchLogs()

            onFetchingDataChanged: {
                if (!fetchingData) {
                    d.fetchPending = false
                    d.refresh()
                }
            }

            onEntriesAdded: {
                if (fetchingData) {
                    return
                }
                // Update the timeline by faking a left/right scroll
                d.startOffset--
                d.startOffset++
                //d.refresh()
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                x: chartView.x + chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                y: chartView.y + chartView.plotArea.y + Style.smallMargins
                text: d.config.toRangeLabel(d.startTime)
                font: Style.smallFont
                opacity: d.startOffset < -d.config.count ? .5 : 0
                Behavior on opacity { NumberAnimation {} }
            }

            ChartView {
                id: chartView
                animationOptions: ChartView.NoAnimation
                anchors.fill: parent

                backgroundColor: "transparent"

                legend.visible: false
                legend.alignment: Qt.AlignBottom
                legend.font: Style.extraSmallFont
                legend.labelColor: Style.foregroundColor

            //    margins.left: 0
                margins.right: 0
                margins.bottom: Style.smallIconSize + Style.margins
                margins.top: 0

                ActivityIndicator {
                    x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                    y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                    visible: powerBalanceLogs.fetchingData
                    opacity: .5
                }
                Label {
                    x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                    y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                    text: qsTr("No data available")
                    visible: !powerBalanceLogs.fetchingData && (powerBalanceLogs.count == 0 || powerBalanceLogs.get(0).timestamp > d.endTime) && d.startOffset != 0
                    font: Style.smallFont
                    opacity: .5
                    Behavior on opacity { NumberAnimation {}}
                }

                Item {
                    id: labelsLayout
                    x: Style.smallMargins
                    y: chartView.plotArea.y
                    height: chartView.plotArea.height
                    width: chartView.plotArea.x - x

                    Repeater {
                        model: valueAxis.tickCount
                        delegate: Label {
                            y: parent.height / (valueAxis.tickCount - 1) * index - font.pixelSize / 2
                            width: parent.width - Style.smallMargins
                            horizontalAlignment: Text.AlignRight
                            text: ((valueAxis.max - (index * valueAxis.max / (valueAxis.tickCount - 1)))).toFixed(1) + "kWh"
                            verticalAlignment: Text.AlignTop
                            font: Style.extraSmallFont
                        }
                    }
                }

                BarSeries {
                    id: barSeries
                    axisX: BarCategoryAxis {
                        id: categoryAxis
                        labelsColor: Style.foregroundColor
                        labelsFont: Style.extraSmallFont
                        gridVisible: false
                        gridLineColor: Style.tileOverlayColor
                        lineVisible: false
                        titleVisible: false
                        shadesVisible: false

                        categories: {
                            var ret = []
//                            print("Updating categories from", d.config.startTime())
                            for (var i = 0; i < d.config.count; i++) {
                                var timestamp = root.calculateTimestamp(d.config.startTime(), d.config.sampleRate, d.startOffset + i);
//                                print("*** adding", timestamp, d.startOffset, i)
                                ret.push(d.config.toLabel(timestamp))
                            }
                            return ret;
                        }
                    }
                    axisY: ValueAxis {
                        id: valueAxis
                        min: 0
                        gridLineColor: Style.tileOverlayColor
                        labelsVisible: false
                        labelsColor: Style.foregroundColor
                        labelsFont: Style.extraSmallFont
                        lineVisible: false
                        titleVisible: false
                        shadesVisible: false

                        function adjustMax(newValue) {
                            if (max < newValue) {
//                                print("adjusting to new max", newValue)
                                max = newValue // Math.ceil(newValue / 100) * 100
                            }
                        }
                    }

                    BarSet {
                        id: consumptionSet
                        label: qsTr("Consumed")
                        color:  {
                            var alpha = d.selectedSet == null || d.selectedSet == consumptionSet ? 1 : 0.3
                            var col = Configuration.customColor && Configuration.customPowerSockerColor !== "" ? Configuration.customPowerSockerColor : totalColors[0]
                            return Qt.hsla(col.hslHue, col.hslSaturation, col.hslLightness, alpha)
                        }
                        borderColor: color
                        borderWidth: 0
                        values: {
                            var ret = []
                            for (var i = 0; i < d.config.count; i++) {
                                ret.push(0)
                            }
                            return ret
                        }
                    }
                    BarSet {
                        id: productionSet
                        label: qsTr("Produced")
                        color:{
                            var alpha = d.selectedSet == null || d.selectedSet == productionSet ? 1 : 0.3
                            var col = Configuration.customColor && Configuration.customInverterColor !== "" ? Configuration.customInverterColor : totalColors[1]
                            return Qt.hsla(col.hslHue, col.hslSaturation, col.hslLightness, alpha)
                        }
                        borderColor: color
                        borderWidth: 0
                        values: {
                            var ret = []
                            for (var i = 0; i < d.config.count; i++) {
                                ret.push(0)
                            }
                            return ret
                        }
                    }
                    BarSet {
                        id: acquisitionSet
                        label: qsTr("From grid")
                        color: {
                            var alpha = d.selectedSet == null || d.selectedSet == acquisitionSet ? 1 : 0.3
                            var col = Configuration.customColor && Configuration.customGridDownColor !== "" ? Configuration.customGridDownColor : totalColors[2]
                            return Qt.hsla(col.hslHue, col.hslSaturation, col.hslLightness, alpha)
                        }
                        borderColor: color
                        borderWidth: 0
                        values: {
                            var ret = []
                            for (var i = 0; i < d.config.count; i++) {
                                ret.push(0)
                            }
                            return ret
                        }
                    }
                    BarSet {
                        id: returnSet
                        label: qsTr("To grid")
                        color: {
                            var alpha = d.selectedSet == null || d.selectedSet == returnSet ? 1 : 0.3
                            var col = Configuration.customColor && Configuration.customGridUpColor !== "" ? Configuration.customGridUpColor : totalColors[3]
                            return Qt.hsla(col.hslHue, col.hslSaturation, col.hslLightness, alpha)
                        }
                        borderColor: color
                        borderWidth: 0
                        values: {
                            var ret = []
                            for (var i = 0; i < d.config.count; i++) {
                                ret.push(0)
                            }
                            return ret
                        }
                    }
                }
            }

            RowLayout {
                id: legend
                anchors { left: parent.left; bottom: parent.bottom; right: parent.right }
                anchors.leftMargin: chartView.plotArea.x
                height: Style.smallIconSize
                anchors.margins: Style.margins

                MouseArea {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    opacity: d.selectedSet == null || d.selectedSet == consumptionSet ? 1 : 0.3
                    onClicked: d.selectSet(consumptionSet)
                    Row {
                        anchors.centerIn: parent
                        spacing: Style.smallMargins
                        ColorIcon {
                            name: "powersocket"
                            size: Style.smallIconSize
                            color: Configuration.customColor && Configuration.customPowerSockerColor !== "" ? Configuration.customPowerSockerColor : totalColors[0]
                        }
                        Label {
                            width: parent.parent.width - x
                            elide: Text.ElideRight
                            visible: legend.width > 500
                            text: qsTr("Consumed")
                            anchors.verticalCenter: parent.verticalCenter
                            font: Style.smallFont
                        }
                    }
                }

                MouseArea {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    opacity: d.selectedSet == null || d.selectedSet == productionSet ? 1 : 0.3
                    onClicked: d.selectSet(productionSet)
                    Row {
                        anchors.centerIn: parent
                        spacing: Style.smallMargins
                        ColorIcon {
                            id: sun
                            name: legend.selectIcons(Configuration.inverterIcon,"weathericons/weather-clear-day")
                            size: Style.smallIconSize
                            color: Configuration.customColor && Configuration.customInverterColor !== "" ? Configuration.customInverterColor : Qt.darker(totalColors[1], 1.1)

                            Rectangle{
                                color: Qt.darker(totalColors[1], 1.1)
                                height: 12 / 2
                                width: 12 / 2
                                radius: sun.width / 2
                                anchors.centerIn: sun
                                visible: Configuration.inverterIcon === ""
                            }

                            Image {
                                id: sunIcon
                                source: "qrc:/ui/images/"+Configuration.inverterIcon
                                width: sun.size
                                height: sun.size
                                visible: Configuration.inverterIcon !== ""
                            }

                            ColorOverlay {
                                anchors.fill: sunIcon
                                source: sunIcon
                                color: sun.color
                                visible: Configuration.inverterIcon !== ""
                            }

                        }
                        Label {
                            width: parent.parent.width - x
                            elide: Text.ElideRight
                            visible: legend.width > 500
                            text: qsTr("Produced")
                            anchors.verticalCenter: parent.verticalCenter
                            font: Style.smallFont
                        }
                    }
                }

                MouseArea {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    opacity: d.selectedSet == null || d.selectedSet == acquisitionSet ? 1 : 0.3
                    onClicked: d.selectSet(acquisitionSet)
                    Row {
                        anchors.centerIn: parent
                        spacing: Style.smallMargins
                        Row {
                            ColorIcon {
                                id: gridDownID
                                name: legend.selectIcons(Configuration.gridIcon,"power-grid")
                                size: Style.smallIconSize
                                color: Configuration.customColor && Configuration.customGridDownColor !== "" ? Configuration.customGridDownColor : totalColors[2]

                                Image {
                                    id: gridDown
                                    source: "qrc:/ui/images/"+Configuration.gridIcon
                                    width: gridDownID.size
                                    height: gridDownID.size
                                    visible: Configuration.gridIcon !== ""
                                }

                                ColorOverlay {
                                    anchors.fill: gridDown
                                    source: gridDown
                                    color: gridDownID.color
                                    visible: Configuration.gridIcon !== ""
                                }

                            }
                            ColorIcon {
                                id: arrowDown
                                name: "arrow-down"
                                size: Style.smallIconSize
                                color: gridDownID.color

                                Rectangle {
                                    color: parent.color
                                    height: 8
                                    width: 2
                                    rotation: 180
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.horizontalCenterOffset: 1
                                    anchors.verticalCenterOffset: -1
                                }

                                Rectangle {
                                    color: parent.color
                                    height: 8
                                    width: 2
                                    rotation: 180
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.horizontalCenterOffset: -1
                                    anchors.verticalCenterOffset: -1
                                }

                                Rectangle {
                                    color: parent.color
                                    radius: 1
                                    height: 4
                                    width: 3
                                    rotation: 180
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.horizontalCenterOffset: 0
                                    anchors.verticalCenterOffset: 2
                                }
                            }
                        }
                        Label {
                            width: parent.parent.width - x
                            elide: Text.ElideRight
                            visible: legend.width > 500
                            text: qsTr("From grid")
                            anchors.verticalCenter: parent.verticalCenter
                            font: Style.smallFont
                        }
                    }
                }
                MouseArea {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    opacity: d.selectedSet == null || d.selectedSet == returnSet ? 1 : 0.3
                    onClicked: d.selectSet(returnSet)
                    Row {
                        anchors.centerIn: parent
                        spacing: Style.smallMargins
                        Row {
                            ColorIcon {
                                id: gridUpID
                                name: legend.selectIcons(Configuration.gridIcon,"power-grid")
                                size: Style.smallIconSize
                                color: Configuration.customColor && Configuration.customGridUpColor !== "" ? Configuration.customGridUpColor : totalColors[3]

                                Image {
                                    id: gridUp
                                    source: "qrc:/ui/images/"+Configuration.gridIcon
                                    width: gridUpID.size
                                    height: gridUpID.size
                                    visible: Configuration.gridIcon !== ""
                                }

                                ColorOverlay {
                                    anchors.fill: gridUp
                                    source: gridUp
                                    color: gridUpID.color
                                    visible: Configuration.gridIcon !== ""
                                }

                            }
                            ColorIcon {
                                id: arrowUp
                                name: "arrow-up"
                                size: Style.smallIconSize
                                color: gridUpID.color

                                Rectangle {
                                    color: parent.color
                                    height: 8
                                    width: 2
                                    rotation: 180
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.horizontalCenterOffset: 1
                                    anchors.verticalCenterOffset: 1
                                }

                                Rectangle {
                                    color: parent.color
                                    height: 8
                                    width: 2
                                    rotation: 180
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.horizontalCenterOffset: -1
                                    anchors.verticalCenterOffset: 1
                                }

                                Rectangle {
                                    color: parent.color
                                    radius: 2
                                    height: 3
                                    width: 3
                                    rotation: 180
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.horizontalCenterOffset: 0
                                    anchors.verticalCenterOffset: -2
                                }
                            }
                        }
                        Label {
                            width: parent.parent.width - x
                            elide: Text.ElideRight
                            visible: legend.width > 500
                            text: qsTr("To grid")
                            anchors.verticalCenter: parent.verticalCenter
                            font: Style.smallFont
                        }
                    }
                }

                function selectIcons(customIcon,defaultIcon){
                    if(customIcon !== ""){
                        //let newIcon = customIcon.split(".")
                        return "qrc:/ui/images/"+customIcon
                    }else{
                        return defaultIcon
                    }
                }
            }


            Item {
                anchors.fill: parent
                anchors.leftMargin: chartView.x + chartView.plotArea.x
                anchors.topMargin: chartView.y + chartView.plotArea.y
                anchors.rightMargin: chartView.width - chartView.plotArea.width - chartView.plotArea.x
                anchors.bottomMargin: chartView.height - chartView.plotArea.height - chartView.plotArea.y
                z: -1

                Rectangle {
                    height: parent.height + Style.margins * 2
                    y: -Style.smallMargins
                    radius: Style.smallCornerRadius
                    width: chartView.plotArea.width / categoryAxis.count
                    color: Style.tileBackgroundColor
                    property int idx: Math.min(Math.max(0,Math.floor(mouseArea.mouseX * categoryAxis.count / mouseArea.width)), categoryAxis.count - 1)
                    visible: toolTip.visible

                    x: idx * parent.width / categoryAxis.count
                    Behavior on x { enabled: toolTip.animationsEnabled; NumberAnimation { duration: Style.animationDuration } }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                anchors.leftMargin: chartView.x + chartView.plotArea.x
                anchors.topMargin: chartView.y + chartView.plotArea.y
                anchors.rightMargin: chartView.width - chartView.plotArea.width - chartView.plotArea.x
                anchors.bottomMargin: chartView.height - chartView.plotArea.height - chartView.plotArea.y

                hoverEnabled: true
                preventStealing: tooltipping || dragging

                property int startMouseX: 0
                property bool dragging: false
                property bool tooltipping: false
                property int dragStartOffset: 0

                Timer {
                    interval: 300
                    running: mouseArea.pressed
                    onTriggered: {
                        if (!mouseArea.dragging) {
                            mouseArea.tooltipping = true
                        }
                    }
                }

                onReleased: {
                    if (mouseArea.dragging) {
                        powerBalanceLogs.fetchLogs()
                        mouseArea.dragging = false;
                    }

                    mouseArea.tooltipping = false;
                }

                onPressed: {
                    startMouseX = mouseX
                    dragStartOffset = d.startOffset
                }

                onDoubleClicked: {
                    var idx = Math.ceil(mouseArea.mouseX * d.config.count / mouseArea.width) - 1
                    var timestamp = root.calculateTimestamp(d.config.startTime(), d.config.sampleRate, d.startOffset + idx)
                    selectionTabs.currentIndex--
                    var startTime = d.config.startTime()
                    d.startOffset = (timestamp.getTime() - startTime.getTime()) / (d.config.sampleRate * 60 * 1000)
                    powerBalanceLogs.fetchLogs();
                }

                onMouseXChanged: {
                    if (!pressed || mouseArea.tooltipping) {
                        return;
                    }
                    if (Math.abs(startMouseX - mouseX) < 10) {
                        return;
                    }
                    dragging = true

                    var dragDelta = startMouseX - mouseX
                    var slotWidth = mouseArea.width / d.config.count
                    var offset = Math.floor(dragDelta / slotWidth);
                    d.startOffset = Math.min(dragStartOffset + offset, 0)
                    d.fetchPending = true;
                }

                property int wheelDelta: 0
                onWheel: function(wheel) {
                    wheelDelta += wheel.pixelDelta.x
                    var slotWidth = mouseArea.width / d.config.count
                    while (wheelDelta > slotWidth) {
                        d.startOffset--
                        wheelDelta -= slotWidth
                    }
                    while (wheelDelta < -slotWidth) {
                        d.startOffset = Math.min(d.startOffset + 1, 0)
                        wheelDelta += slotWidth
                    }
                    d.fetchPending = true;
                    wheelStopTimer.restart()
                }

                Timer {
                    id: wheelStopTimer
                    interval: 300
                    repeat: false
                    onTriggered: powerBalanceLogs.fetchLogs()
                }

                NymeaToolTip {
                    id: toolTip

                    backgroundItem: chartView
                    backgroundRect: Qt.rect(chartView.plotArea.x + toolTip.x, chartView.plotArea.y + toolTip.y, toolTip.width, toolTip.height)

                    property int idx: visible ? Math.min(d.config.count -1, Math.max(0, Math.ceil(mouseArea.mouseX * d.config.count / mouseArea.width) - 1)) : 0
                    property date timestamp: root.calculateTimestamp(d.config.startTime(), d.config.sampleRate, d.startOffset + idx)

                    visible: (mouseArea.containsMouse || mouseArea.tooltipping) && !mouseArea.dragging

                    property int chartWidth: chartView.plotArea.width
                    property int barWidth: chartWidth / categoryAxis.count

                    x: chartWidth - (idx * barWidth + barWidth + Style.smallMargins) > width ?
                           idx * barWidth + barWidth + Style.smallMargins
                         : idx * barWidth - Style.smallMargins - width
                    property double setMaxValue: d.startOffset !== undefined ? Math.max(consumptionSet.at(idx),
                                                          productionSet.at(idx),
                                                          acquisitionSet.at(idx),
                                                          returnSet.at(idx)) : 0
                    y: Math.min(Math.max(mouseArea.height - (setMaxValue * mouseArea.height / valueAxis.max) - height - Style.smallMargins, 0), mouseArea.height - height)
                    width: tooltipLayout.implicitWidth + Style.smallMargins * 2
                    height: tooltipLayout.implicitHeight + Style.smallMargins * 2

                    ColumnLayout {
                        id: tooltipLayout
                        anchors {
                            left: parent.left
                            top: parent.top
                            margins: Style.smallMargins
                        }

                        Label {
                            text: d.config.toLongLabel(toolTip.timestamp)
                            font: Style.smallFont
                        }

                        RowLayout {
                            visible: root.hasProducers
                            opacity: d.selectedSet == null || d.selectedSet == consumptionSet ? 1 : 0.3
                            Rectangle {
                                width: Style.extraSmallFont.pixelSize
                                height: width
                                color: Configuration.customColor && Configuration.customPowerSockerColor !== "" ? Configuration.customPowerSockerColor : totalColors[0]
                            }
                            Label {
                                text: d.startOffset !== undefined ? qsTr("Consumed: %1 kWh").arg((+consumptionSet.at(toolTip.idx).toFixed(2)).toLocaleString()) : ""
                                font: Style.extraSmallFont
                            }
                        }
                        RowLayout {
                            visible: root.hasProducers
                            opacity: d.selectedSet == null || d.selectedSet == productionSet ? 1 : 0.3
                            Rectangle {
                                width: Style.extraSmallFont.pixelSize
                                height: width
                                color: Configuration.customColor && Configuration.customInverterColor !== "" ? Configuration.customInverterColor : totalColors[1]
                            }
                            Label {
                                text: d.startOffset !== undefined ? qsTr("Produced: %1 kWh").arg((+productionSet.at(toolTip.idx).toFixed(2)).toLocaleString()) : ""
                                font: Style.extraSmallFont
                            }
                        }
                        RowLayout {
                            opacity: d.selectedSet == null || d.selectedSet == acquisitionSet ? 1 : 0.3
                            Rectangle {
                                width: Style.extraSmallFont.pixelSize
                                height: width
                                color: Configuration.customColor && Configuration.customGridDownColor !== "" ? Configuration.customGridDownColor : totalColors[2]
                            }
                            Label {
                                text: d.startOffset !== undefined ? qsTr("From grid: %1 kWh").arg((+acquisitionSet.at(toolTip.idx).toFixed(2)).toLocaleString()) :""
                                font: Style.extraSmallFont
                            }
                        }
                        RowLayout {
                            opacity: d.selectedSet == null || d.selectedSet == returnSet ? 1 : 0.3
                            Rectangle {
                                width: Style.extraSmallFont.pixelSize
                                height: width
                                color: Configuration.customColor && Configuration.customGridUpColor !== "" ? Configuration.customGridUpColor : totalColors[3]
                            }
                            Label {
                                text: d.startOffset !== undefined ? qsTr("To grid: %1 kWh").arg((+returnSet.at(toolTip.idx).toFixed(2)).toLocaleString()) : ""
                                font: Style.extraSmallFont
                            }
                        }
                    }
                }
            }
        }
    }
}
