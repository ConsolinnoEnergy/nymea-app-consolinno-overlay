import QtQuick 2.0
import QtGraphicalEffects 1.12
import QtCharts 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import Nymea 1.0
import "qrc:/ui/components"

Item {
    id: root

    property EnergyManager energyManager: null
    property ThingsProxy consumers: null
    property bool titleVisible: true
    property var consumerColors: null

    PowerBalanceLogs {
        id: powerBalanceLogs
        engine: _engine
        startTime: new Date(d.startTime.getTime() - d.range * 60000)
        endTime: new Date(d.endTime.getTime() + d.range * 60000)
        sampleRate: d.sampleRate
        Component.onCompleted: fetchLogs()

        onEntriesAdded: {
            print("entries added", index, entries.length)
            for (var i = 0; i < entries.length; i++) {
                var entry = entries[i]
//                print("got entry", entry.timestamp)

                zeroSeries.ensureValue(entry.timestamp)
                valueAxis.adjustMax(entry.consumption)
                consumptionSeries.insertEntry(index + i, entry)
                if (entry.timestamp > d.now && new Date().getTime() - d.now.getTime() < 120000) {
                    d.now = entry.timestamp
                }
            }
        }

        onEntriesRemoved: {
            consumptionUpperSeries.removePoints(index, count)
            zeroSeries.shrink()
        }
    }

    ThingPowerLogsLoader {
        id: logsLoader
        engine: _engine
        startTime: new Date(d.startTime.getTime() - d.range * 60000)
        endTime: new Date(d.endTime.getTime() + d.range * 60000)
        sampleRate: d.sampleRate
    }

    QtObject {
        id: d

        property date now: new Date()

        property var selectedSeries: null

        readonly property int range: selectionTabs.currentValue.range
        readonly property int sampleRate: selectionTabs.currentValue.sampleRate
        readonly property int visibleValues: range / sampleRate

        readonly property var startTime: {
            var date = new Date(fixTime(now));
            date.setTime(date.getTime() - range * 60000 + 2000);
            return date;
        }

        readonly property var endTime: {
            var date = new Date(fixTime(now));
            date.setTime(date.getTime() + 2000)
            return date;
        }

        function fixTime(timestamp) {
            switch (sampleRate) {
            case EnergyLogs.SampleRate1Min:
                timestamp.setSeconds(0, 0)
                break;
            case EnergyLogs.SampleRate15Mins:
                timestamp.setMinutes(timestamp.getMinutes() - timestamp.getMinutes() % 15, 0, 0)
                break;
            case EnergyLogs.SampleRate1Hour:
                timestamp.setMinutes(0, 0, 0);
                break;
            case EnergyLogs.SampleRate3Hours:
                timestamp.setHours(timestamp.getHours() % 3, 0, 0, 0);
                break;
            case EnergyLogs.SampleRate1Day:
                timestamp.setHours(0, 0, 0, 0)
                break;
            }
            return timestamp
        }

        function update() {
            if (!engine.thingManager.fetchingData && !engine.tagsManager.busy && consumersRepeater.count == consumers.count) {
                logsLoader.fetchLogs();
            }
        }

        function selectSeries(series) {
            print("selecting series", series)
            if (d.selectedSeries === series) {
                d.selectedSeries = null
            } else {
                d.selectedSeries = series
            }
        }
    }

    Connections {
        target: engine.tagsManager
        onBusyChanged: d.update()
    }

    Component {
        id: lineSeriesComponent
        LineSeries { }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Label {
            Layout.fillWidth: true
            Layout.margins: Style.smallMargins
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("Consumers history")
            visible: root.titleVisible
        }

        SelectionTabs {
            id: selectionTabs
            Layout.fillWidth: true
            Layout.leftMargin: Style.smallMargins
            Layout.rightMargin: Style.smallMargins
            currentIndex: 1
            model: ListModel {
                ListElement {
                    modelData: qsTr("Hours")
                    sampleRate: EnergyLogs.SampleRate1Min
                    range: 180 // 3 Hours: 3 * 60
                }
                ListElement {
                    modelData: qsTr("Days")
                    sampleRate: EnergyLogs.SampleRate15Mins
                    range: 1440 // 1 Day: 24 * 60
                }
                ListElement {
                    modelData: qsTr("Weeks")
                    sampleRate: EnergyLogs.SampleRate1Hour
                    range: 10080 // 7 Days: 7 * 24 * 60
                }
                ListElement {
                    modelData: qsTr("Months")
                    sampleRate: EnergyLogs.SampleRate3Hours
                    range: 43200 // 30 Days: 30 * 24 * 60
                }
            }
            onTabSelected: {
                d.now = new Date()
                powerBalanceLogs.fetchLogs()
                d.update()
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                x: chartView.x + chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                y: chartView.y + chartView.plotArea.y + Style.smallMargins
                text: {
                    switch (d.sampleRate) {
                    case EnergyLogs.SampleRate1Min:
                        return d.startTime.toLocaleDateString(Qt.locale(), Locale.LongFormat)
                    case EnergyLogs.SampleRate15Mins:
                    case EnergyLogs.SampleRate1Hour:
                    case EnergyLogs.SampleRate3Hours:
                    case EnergyLogs.SampleRate1Day:
                    case EnergyLogs.SampleRate1Week:
                    case EnergyLogs.SampleRate1Month:
                    case EnergyLogs.SampleRate1Year:
                        return d.startTime.toLocaleDateString(Qt.locale(), Locale.ShortFormat) + " - " + d.endTime.toLocaleDateString(Qt.locale(), Locale.ShortFormat)
                    }
                }
                font: Style.smallFont
                opacity: ((new Date().getTime() - d.now.getTime()) / d.sampleRate / 60000) > d.visibleValues ? .5 : 0
                Behavior on opacity { NumberAnimation {} }
            }

            ChartView {
                id: chartView
                anchors.fill: parent

                backgroundColor: "transparent"
                margins.left: 0
                margins.right: 0
                margins.top: 0
                margins.bottom: Style.smallIconSize + Style.margins

                legend.visible: false
                legend.alignment: Qt.AlignBottom
                legend.font: Style.extraSmallFont
                legend.labelColor: Style.foregroundColor

                ActivityIndicator {
                    x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                    y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                    visible: powerBalanceLogs.fetchingData || logsLoader.fetchingData
                    opacity: .5
                }
                Label {
                    x: chartView.plotArea.x + (chartView.plotArea.width - width) / 2
                    y: chartView.plotArea.y + (chartView.plotArea.height - height) / 2 + (chartView.plotArea.height / 8)
                    text: qsTr("No data available")
                    visible: !powerBalanceLogs.fetchingData && !logsLoader.fetchingData && (powerBalanceLogs.count == 0 || powerBalanceLogs.get(0).timestamp > d.now)
                    font: Style.smallFont
                    opacity: .5
                }


                ValueAxis {
                    id: valueAxis
                    min: 0
                    max: 1
                    labelFormat: ""
                    gridLineColor: Style.tileOverlayColor
                    labelsVisible: false
                    lineVisible: false
                    titleVisible: false
                    shadesVisible: false
                    //        visible: false

                    function adjustMax(value) {
                        max = Math.max(max, Math.ceil(value / 100) * 100)
                    }
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
                            text: ((valueAxis.max - (index * valueAxis.max / (valueAxis.tickCount - 1))) / 1000).toFixed(2) + "kW"
                            verticalAlignment: Text.AlignTop
                            font: Style.extraSmallFont
                        }
                    }
                }

                DateTimeAxis {
                    id: dateTimeAxis
                    min: d.startTime
                    max: d.endTime
                    format: {
                        switch (selectionTabs.currentValue.sampleRate) {
                        case EnergyLogs.SampleRate1Min:
                        case EnergyLogs.SampleRate15Mins:
                            return "hh:mm"
                        case EnergyLogs.SampleRate1Hour:
                        case EnergyLogs.SampleRate3Hours:
                        case EnergyLogs.SampleRate1Day:
                            return "dd.MM."
                        }
                    }
                    tickCount: {
                        switch (selectionTabs.currentValue.sampleRate) {
                        case EnergyLogs.SampleRate1Min:
                        case EnergyLogs.SampleRate15Mins:
                            return root.width > 500 ? 13 : 7
                        case EnergyLogs.SampleRate1Hour:
                            return 7
                        case EnergyLogs.SampleRate3Hours:
                        case EnergyLogs.SampleRate1Day:
                            return root.width > 500 ? 12 : 6
                        }
                    }
                    labelsFont: Style.extraSmallFont
                    gridVisible: false
                    minorGridVisible: false
                    lineVisible: false
                    shadesVisible: false
                    labelsColor: Style.foregroundColor
                }

                AreaSeries {
                    id: consumptionSeries
                    axisX: dateTimeAxis
                    axisY: valueAxis
                    color: Style.gray
                    borderWidth: 0
                    borderColor: color
                    name: qsTr("Unknown")
//                    visible: false
                    opacity: .2

                    lowerSeries: LineSeries {
                        id: zeroSeries
                        XYPoint { x: dateTimeAxis.min.getTime(); y: 0 }
                        XYPoint { x: dateTimeAxis.max.getTime(); y: 0 }
                        function ensureValue(timestamp) {
                            if (count == 0) {
                                append(timestamp, 0)
                            } else if (count == 1) {
                                if (timestamp.getTime() < at(0).x) {
                                    insert(0, timestamp, 0)
                                } else {
                                    append(timestamp, 0)
                                }
                            } else {
                                if (timestamp.getTime() < at(0).x) {
                                    remove(0)
                                    insert(0, timestamp, 0)
                                } else if (timestamp.getTime() > at(1).x) {
                                    remove(1)
                                    append(timestamp, 0)
                                }
                            }
                        }
                        function shrink() {
                            clear();
                            if (powerBalanceLogs.count > 0) {
                                ensureValue(powerBalanceLogs.get(0).timestamp)
                                ensureValue(powerBalanceLogs.get(powerBalanceLogs.count - 1).timestamp)
                            }
                        }
                    }
                    upperSeries: LineSeries {
                        id: consumptionUpperSeries
                    }

                    function addEntry(entry) {
                        consumptionUpperSeries.append(entry.timestamp.getTime(), entry.consumption)
                    }
                    function insertEntry(index, entry) {
                        consumptionUpperSeries.insert(index, entry.timestamp.getTime(), entry.consumption)
                    }
                }

                Repeater {
                    id: consumersRepeater
                    model: consumers.count

                    Component.onCompleted: {
                        if (count != 0) {
                            d.update()
                        }
                    }

                    onCountChanged: {
                        if (count == consumers.count) {
                            d.update();
                        }
                    }

                    delegate: Item {
                        id: consumerDelegate

                        readonly property Thing thing: consumers.get(index)
                        property AreaSeries series: null

                        function calculateBaseValue(timestamp) {
                            if (index > 0) {
                                return consumersRepeater.itemAt(index - 1).calculateValue(timestamp)
                            }
                            return 0
                        }

                        function calculateValue(timestamp) {
                            var ret = calculateBaseValue(timestamp)

                            var entry = logs.find(timestamp)
                            if (entry) {
                                ret += entry.currentPower;
                            }

//                            print("calculating value for", thing.name, timestamp, ret)
                            return ret
                        }

                        function insertEntry(idx, entry) {
//                            print("inserting entry for", thing.name, entry.timestamp)

                            var baseValue = calculateBaseValue(entry.timestamp);
                            series.lowerSeries.insert(idx, entry.timestamp.getTime(), baseValue)
                            series.upperSeries.insert(idx, entry.timestamp.getTime(), baseValue + entry.currentPower)
                        }

                        function addEntries(index, entries) {
//                            print("adding entries for", thing.name)
                            // Remove the leading 0-value entry
                            series.lowerSeries.removePoints(0, 1);
                            series.upperSeries.removePoints(0, 1);

                            for (var i = 0; i < entries.length; i++) {
                                var entry = entries[i]
//                                    print("got thing entry", thing.name, entry.timestamp, entry.currentPower, index + i)

                                zeroSeries.ensureValue(entry.timestamp)
                                valueAxis.adjustMax(entry.currentPower)

                                insertEntry(index + i, entry)
                                if (entry.timestamp > d.now && new Date().getTime() - d.now.getTime() < 120000) {
                                    d.now = entry.timestamp
                                }
                            }

                            // Add the leading 0-value entry back
                            series.lowerSeries.insert(0, series.upperSeries.at(0).x, 0)
                            series.upperSeries.insert(0, series.upperSeries.at(0).x, 0)
                        }

                        readonly property ThingPowerLogs logs: ThingPowerLogs {
                            engine: _engine
                            startTime: new Date(d.startTime.getTime() - d.range * 60000)
                            endTime: new Date(d.endTime.getTime() + d.range * 60000)
                            sampleRate: d.sampleRate
                            thingId: consumerDelegate.thing.id
                            loader: logsLoader

                            onEntriesAdded: {
                                addTimer.addEntries(index, entries)
                            }

                            onEntriesRemoved: {
                                // Remove the leading 0-value entry
                                consumerDelegate.series.lowerSeries.removePoints(0, 1);
                                consumerDelegate.series.upperSeries.removePoints(0, 1);

                                consumerDelegate.series.lowerSeries.removePoints(index, count)
                                consumerDelegate.series.upperSeries.removePoints(index, count)

                                // Add the leading 0-value entry back
                                consumerDelegate.series.lowerSeries.insert(0, consumerDelegate.series.upperSeries.at(0).x, 0)
                                consumerDelegate.series.upperSeries.insert(0, consumerDelegate.series.upperSeries.at(0).x, 0)

                                zeroSeries.shrink()
                            }
                        }

                        // We'll have to make sure all the consumers have their data ready before adding
                        Timer {
                            id: addTimer
                            interval: 1000
                            repeat: false
                            onTriggered: consumerDelegate.addEntries(index, entries)
                            property int index
                            property var entries
                            function addEntries(index, entries) {
                                addTimer.index = index
                                addTimer.entries = entries
                                start()
                            }
                        }

                        Component.onCompleted: {
                            series = chartView.createSeries(ChartView.SeriesTypeArea, thing.name, dateTimeAxis, valueAxis)
                            series.lowerSeries = lineSeriesComponent.createObject(series)
                            series.upperSeries = lineSeriesComponent.createObject(series)

                            if(thing.thingClass.interfaces.indexOf("heatpump") >= 0){
                                series.color = Configuration.heatpumpColor
                            }else if(thing.thingClass.interfaces.indexOf("evcharger") >= 0){
                                series.color = Configuration.wallboxColor
                            }else if(thing.thingClass.interfaces.indexOf("smartheatingrod") >= 0){
                                series.color = Configuration.heatingRodColor
                            }else{
                                series.color = consumerColors[index]
                            }

                            series.opacity = Qt.binding(function() {
                                return d.selectedSeries == null || d.selectedSeries == series ? 1 : 0.3
                            })
                            series.borderWidth = 0;
                            series.borderColor = series.color                            

                            // Add a first point at 0 value
                            series.lowerSeries.insert(0, new Date().getTime(), 0)
                            series.upperSeries.insert(0, new Date().getTime(), 0)
                        }

                        Component.onDestruction: {
                            chartView.removeSeries(series)
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

                Repeater {
                    model: root.consumers
                    delegate: MouseArea {
                        id: legendDelegate
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        readonly property Thing thing: root.consumers.get(index)
                        onClicked: d.selectSeries(consumersRepeater.itemAt(index).series)
                        opacity: d.selectedSeries == null || d.selectedSeries === consumersRepeater.itemAt(index).series ? 1 : 0.3
                        Row {
                            anchors.centerIn: parent
                            spacing: Style.smallMargins
                            ColorIcon {
                                id: icons
                                name: {
                                    for(let i = 0; i < legendDelegate.thing.thingClass.interfaces.length; i++){
                                        let iconName = legendDelegate.thing.thingClass.interfaces[i];
                                        switch (iconName) {
                                        case "smartgridheatpump":
                                            if(Configuration.heatpumpIcon !== ""){
                                                return "qrc:/ui/images/"+Configuration.heatpumpIcon
                                            }else{
                                                return "qrc:/ui/images/heatpump.svg"
                                            }
                                        case "pvsurplusheatpump":
                                            if(Configuration.heatpumpIcon !== ""){
                                                return "qrc:/ui/images/"+Configuration.heatpumpIcon
                                            }else{
                                                return "qrc:/ui/images/heatpump.svg"
                                            }
                                        case "smartheatingrod":
                                            if(Configuration.heatingRodIcon !== ""){
                                                return "/ui/images/"+Configuration.heatingRodIcon
                                            }else{
                                                return "/ui/images/heating_rod.svg"
                                            }
                                        case "evcharger":
                                            if(Configuration.evchargerIcon !== ""){
                                                return "/ui/images/"+Configuration.evchargerIcon
                                            }else{
                                                return "/ui/images/ev-charger.svg"
                                            }
                                        default:
                                            return app.interfacesToIcon(legendDelegate.thing.thingClass.interfaces)
                                        }
                                    }

                                }
                                size: Style.smallIconSize
                                color: {
                                    if(thing.thingClass.interfaces.indexOf("heatpump") >= 0){
                                        return Configuration.heatpumpColor
                                    }else if(thing.thingClass.interfaces.indexOf("smartheatingrod") >= 0){
                                        return Configuration.heatingRodColor
                                    }else if(thing.thingClass.interfaces.indexOf("evcharger") >= 0){
                                        return Configuration.wallboxColor
                                    }else{
                                        return "white"
                                    }
                                }

                                Image {
                                    id: icon
                                    source: icons.name
                                    width: icons.size
                                    height: icons.size
                                    visible: Configuration.evchargerIcon !== "" || Configuration.heatingRodIcon !== "" || Configuration.heatpumpIcon
                                }

                                ColorOverlay {
                                    anchors.fill: icon
                                    source: icon
                                    color: icons.color
                                    visible: Configuration.evchargerIcon !== "" || Configuration.heatingRodIcon !== "" || Configuration.heatpumpIcon
                                }

                            }
                            Label {
                                text: legendDelegate.thing.name
                                width: Math.max(0, legendDelegate.width - x)
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                                font: Style.smallFont
                                visible: legend.width / root.consumers.count >= 80
                            }
                        }
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                anchors.leftMargin: chartView.plotArea.x
                anchors.topMargin: chartView.plotArea.y
                anchors.rightMargin: chartView.width - chartView.plotArea.width - chartView.plotArea.x
                anchors.bottomMargin: chartView.height - chartView.plotArea.height - chartView.plotArea.y

                hoverEnabled: true
                preventStealing: tooltipping || dragging

                property int startMouseX: 0
                property bool dragging: false
                property bool tooltipping: false

                property var startDatetime: null

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
                    mouseArea.tooltipping = false;

                    if (mouseArea.dragging) {
                        mouseArea.dragging = false;

                        for (var i = 0; i < consumersRepeater.count; i++) {
                            if (consumersRepeater.itemAt(i).logs.fetchingData) {
                                wheelStopTimer.start()
                                return;
                            }
                        }

                        powerBalanceLogs.fetchLogs()
                        logsLoader.fetchLogs()
//                        for (var i = 0; i < consumersRepeater.count; i++) {
//                            consumersRepeater.itemAt(i).logs.fetchLogs()
//                        }
                    }
                }

                onPressed: {
                    startMouseX = mouseX
                    startDatetime = d.now
                }


                onDoubleClicked: {
                    if (selectionTabs.currentIndex == 0) {
                        return;
                    }

                    var idx = Math.ceil(mouseArea.mouseX * d.visibleValues / mouseArea.width)
                    var timestamp = new Date(d.startTime.getTime() + (idx * d.sampleRate * 60000))
                    selectionTabs.currentIndex--
                    d.now = new Date(Math.min(new Date().getTime(), timestamp.getTime() + (d.visibleValues / 2) * d.sampleRate * 60000))
                    powerBalanceLogs.fetchLogs()
                    logsLoader.fetchLogs()
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
                    var totalTime = d.endTime.getTime() - d.startTime.getTime()
                    // dragDelta : timeDelta = width : totalTime
                    var timeDelta = dragDelta * totalTime / mouseArea.width
                    print("dragging", dragDelta, totalTime, mouseArea.width)
                    d.now = new Date(Math.min(new Date(), new Date(startDatetime.getTime() + timeDelta)))
                }

                onWheel: {
                    startDatetime = d.now
                    var totalTime = d.endTime.getTime() - d.startTime.getTime()
                    // pixelDelta : timeDelta = width : totalTime
                    var timeDelta = wheel.pixelDelta.x * totalTime / mouseArea.width
                    print("wheeling", wheel.pixelDelta.x, totalTime, mouseArea.width)
                    d.now = new Date(Math.min(new Date(), new Date(startDatetime.getTime() - timeDelta)))
                    wheelStopTimer.restart()
                }
                Timer {
                    id: wheelStopTimer
                    interval: 300
                    repeat: false
                    onTriggered: {
                        for (var i = 0; i < consumersRepeater.count; i++) {
                            if (consumersRepeater.itemAt(i).logs.fetchingData) {
                                wheelStopTimer.start()
                                return;
                            }
                        }

                        powerBalanceLogs.fetchLogs()
                        logsLoader.fetchLogs()
//                        for (var i = 0; i < consumersRepeater.count; i++) {
//                            consumersRepeater.itemAt(i).logs.fetchLogs()
//                        }
                    }
                }

                Rectangle {
                    height: parent.height
                    width: 1
                    color: Style.foregroundColor
                    x: Math.min(mouseArea.width - 1, Math.max(0, mouseArea.mouseX))
                    visible: (mouseArea.containsMouse || mouseArea.tooltipping) && !mouseArea.dragging
                }

                NymeaToolTip {
                    id: toolTip
                    visible: (mouseArea.containsMouse || mouseArea.tooltipping) && !mouseArea.dragging

                    backgroundItem: chartView
                    backgroundRect: Qt.rect(mouseArea.x + toolTip.x, mouseArea.y + toolTip.y, toolTip.width, toolTip.height)

                    property int idx: Math.min(d.visibleValues, Math.max(0, Math.round(mouseArea.mouseX * d.visibleValues / mouseArea.width)))
                    property var timestamp: new Date(Math.min(d.endTime.getTime(), Math.max(d.startTime, d.startTime.getTime() + (idx * d.sampleRate * 60000))))
                    property PowerBalanceLogEntry entry: powerBalanceLogs.find(timestamp)

                    property int xOnRight: Math.max(0, mouseArea.mouseX) + Style.smallMargins
                    property int xOnLeft: Math.min(mouseArea.width, mouseArea.mouseX) - Style.smallMargins - width
                    x: xOnRight + width < mouseArea.width ? xOnRight : xOnLeft
                    property double maxValue: toolTip.entry ? Math.max(0, entry.consumption) : 0
                    y: Math.min(Math.max(mouseArea.height - (maxValue * mouseArea.height / valueAxis.max) - height - Style.margins, 0), mouseArea.height - height)

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
                            text: toolTip.entry ? toolTip.entry.timestamp.toLocaleString(Qt.locale(), Locale.ShortFormat) : 0
                            font: Style.smallFont
                        }
                        RowLayout {
                            Rectangle {
                                width: Style.extraSmallFont.pixelSize
                                height: width
                                color: consumptionSeries.color
                            }
                            Label {
                                property double rawValue: toolTip.entry ? toolTip.entry.consumption : 0
                                property double displayValue: rawValue >= 1000 ? rawValue / 1000 : rawValue
                                property string unit: rawValue >= 1000 ? "kW" : "W"
                                text:  "%1: %2 %3".arg(qsTr("Total")).arg((+displayValue.toFixed(2)).toLocaleString()).arg(unit)
                                font: Style.extraSmallFont
                            }
                        }

                        Repeater {
                            model: consumersRepeater.count
                            delegate: RowLayout {
                                readonly property Item chartItem: consumersRepeater.itemAt(index)
                                readonly property Thing thing: chartItem.series.get(index).name
                                id: consumerToolTipDelegate
                                opacity: d.selectedSeries == null || d.selectedSeries === chartItem.series ? 1 : 0.3
                                Rectangle {
                                    width: Style.extraSmallFont.pixelSize
                                    height: width
                                    color: {
                                        if(chartItem.thing.thingClass.interfaces.indexOf("heatpump") >= 0){
                                            return Configuration.heatpumpColor
                                        }else if(chartItem.thing.thingClass.interfaces.indexOf("evcharger") >= 0){
                                            return Configuration.wallboxColor
                                        }else if(chartItem.thing.thingClass.interfaces.indexOf("smartheatingrod") >= 0){
                                            return Configuration.heatingRodColor
                                        }else{
                                           return consumerColors[index]
                                        }
                                    }
                                }

                                Label {
                                    property ThingPowerLogEntry entry: toolTip.idx >= 0 ? chartItem.logs.find(toolTip.timestamp) : null
                                    property double rawValue: entry ? entry.currentPower : 0
                                    property double displayValue: rawValue >= 1000 ? rawValue / 1000 : rawValue
                                    property string unit: rawValue >= 1000 ? "kW" : "W"
                                    text:  "%1: %2 %3".arg(chartItem.thing.name).arg((+displayValue.toFixed(2)).toLocaleString()).arg(unit)
                                    font: Style.extraSmallFont
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
