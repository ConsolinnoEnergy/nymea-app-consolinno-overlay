import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import NymeaApp.Utils 1.0
import "../components"
import "../delegates"

Page {
    id: root
    property int directionID: 0

    // #TODO needed here? i.e. should this screen be included in the setup assistant?
    signal done(bool skip, bool abort, bool back)

    header: NymeaHeader {
        text: qsTr("PV Device Prioritization") // #TODO wording
        backButtonVisible: true
        onBackPressed:{
            if (directionID == 0) {
                pageStack.pop();
            } else {
                root.done(false, false, true);
            }
        }
    }

    QtObject {
        id: d
        property int pendingCallId: -1
        // Incremented on every model modification so that bindings depending on
        // model order (which ListModel doesn't track reactively) are re-evaluated.
        property int modelRevision: 0
        property var firstBattery: {
            for (var i = 0; i < hemsManager.emsConfiguration.pvSurplusPriolist.length; i++) {
                var thing = engine.thingManager.things.getThing(hemsManager.emsConfiguration.pvSurplusPriolist[i]);
                if (thing && thing.thingClass.interfaces.indexOf("battery") >= 0) {
                    return thing;
                }
            }
            return null;
        }
        property bool hasBattery: firstBattery !== null
        property int batteryTargetSoc: {
            if (!firstBattery) return 0;
            var config = hemsManager.batteryConfigurations.getBatteryConfiguration(firstBattery.id);
            if (config && config.targetSocPvSurplus.length > 0) {
                return config.targetSocPvSurplus[0];
            }
            return 0;
        }
    }

    // #TODO the following 2 functions were copied from CoDashboardView.qml -> move to common utils file
    function batteryIconByLevel(batteryLevel) {
        let batteryLevelForIcon = NymeaUtils.pad(Math.round(batteryLevel / 10) * 10, 3);
        return Qt.resolvedUrl("qrc:/icons/battery/battery-" + batteryLevelForIcon + ".svg");
    }

    function thingToIcon(thing) {
        let ifaces = thing.thingClass.interfaces;
        if (ifaces.indexOf("battery") >= 0) {
            let batteryLevelState = thing.stateByName("batteryLevel");
            if (batteryLevelState) {
                let batteryLevel = batteryLevelState.value;
                return batteryIconByLevel(batteryLevel);
            } else {
                return Qt.resolvedUrl("qrc:/icons/battery/battery-060.svg");
            }
        }
        return app.interfacesToIcon(ifaces);
    }

    function thingOptimizationEnabled(thing) {
        let ifaces = thing.thingClass.interfaces;
        if (ifaces.indexOf("heatingrod") >= 0) {
            let config = hemsManager.heatingElementConfigurations.getHeatingElementConfiguration(thing.id);
            return config ? config.optimizationEnabled : false;
        }
        if (ifaces.indexOf("pvsurplusheatpump") >= 0) {
            return true;
        }
        if (ifaces.indexOf("smartgridheatpump") >= 0) {
            let config = hemsManager.heatingConfigurations.getHeatingConfiguration(thing.id);
            return config ? config.optimizationMode === HeatingConfiguration.OptimizationModePVSurplus : false;
        }
        if (ifaces.indexOf("battery") >= 0) {
            return true;
        }
        if (ifaces.indexOf("evcharger") >= 0) {
            let config = hemsManager.chargingConfigurations.getChargingConfiguration(thing.id);
            if (!config) return false;
            // pvPrioCard in ChargingConfigView is visible for pv_excess (2000–2999),
            // simple_pv_excess (3000–3999) and dyn_pricing (4000–4999) modes.
            return config.optimizationMode >= 2000 && config.optimizationMode < 5000;
        }
        return false;
    }

    function populatePrioModel() {
        populateFromPrioList(hemsManager.emsConfiguration.pvSurplusPriolist);
    }

    function populateFromPrioList(prioList) {
        prioListModel.clear();
        for (var i = 0; i < prioList.length; i++) {
            var thingId = prioList[i];
            var thing = engine.thingManager.things.getThing(thingId);
            prioListModel.append({
                "name": thing ? thing.name : thingId.toString(),
                // QML ListModel cannot store C++ QUuid/ThingId objects — they come back
                // as undefined on retrieval. Coercing with "" + thing.id forces a plain
                // JS string, which ListModel preserves and Qt auto-converts back to QUuid
                // when passed to setPVSurplusPriolist(QList<QUuid>).
                "thingId": thing ? "" + thing.id : "",
                "icon": thing ? root.thingToIcon(thing) : Qt.resolvedUrl("qrc:/icons/select-none.svg"),
                "optimizationEnabled": thing ? root.thingOptimizationEnabled(thing) : false
            });
        }
        d.modelRevision++;
    }

    Connections {
        target: hemsManager.emsConfiguration
        onPvSurplusPriolistChanged: root.populatePrioModel()
    }

    Connections {
        target: hemsManager
        onSetPVSurplusPriolistReply: function(commandId, error) {
            if (commandId === d.pendingCallId) {
                d.pendingCallId = -1;
                if (error === "HemsErrorNoError") {
                    if (directionID === 0) {
                        pageStack.pop();
                    } else {
                        root.done(false, false, false);
                    }
                } else {
                    var comp = Qt.createComponent("../components/ErrorDialog.qml");
                    var popup = comp.createObject(app, { errorCode: error });
                    popup.open();
                }
            }
        }
    }

    Component.onCompleted: root.populatePrioModel()

    ListModel {
        id: prioListModel
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.margins

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: flickableContent.implicitHeight
            clip: true

            ColumnLayout {
                id: flickableContent
                width: parent.width

                CoFrostyCard {
                    Layout.fillWidth: true
                    contentTopMargin: Style.smallMargins
                    headerText: qsTr("Device Prioritization") // #TODO wording

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: Style.margins
                        anchors.rightMargin: Style.margins
                        spacing: Style.smallMargins

                        Text {
                            Layout.fillWidth: true
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WordWrap
                            font: Style.newParagraphFont
                            color: Style.colors.typography_Basic_Default
                            // #TODO wording
                            text: qsTr("The following devices are configured for surplus PV power. Sort them by priority using drag and drop.") +
                                       (d.hasBattery ?
                                           " " + qsTr("The battery automatically moves to the last position when its SoC reaches %1%.").arg(d.batteryTargetSoc) :
                                           "")
                        }

                        ListView {
                            id: priorityListView
                            Layout.fillWidth: true
                            height: contentHeight
                            implicitHeight: contentHeight
                            model: prioListModel
                            clip: true

                            property bool dragging: draggingIndex >= 0
                            property int draggingIndex: -1

                            moveDisplaced: Transition { NumberAnimation { properties: "y" } }

                            delegate: CoSortableCard {
                                width: priorityListView.width
                                text: model.name
                                iconLeft: model.icon
                                visible: index !== priorityListView.draggingIndex
                                card.opacity: model.optimizationEnabled ? 1 : 0.3
                            }

                            MouseArea {
                                id: dndArea
                                anchors.fill: parent
                                propagateComposedEvents: true
                                preventStealing: priorityListView.dragging
                                property int dragOffset: 0

                                onPressed: (mouse) => {
                                    var mouseYInList = priorityListView.contentItem.mapFromItem(dndArea, mouseX, mouseY).y;
                                    var item = priorityListView.itemAt(mouseX, mouseYInList);
                                    if (!item || mouseX < item.dragHandleStartX) {
                                        mouse.accepted = false;
                                        return;
                                    }
                                    priorityListView.draggingIndex = priorityListView.indexAt(mouseX, mouseYInList);
                                    dndItem.text = prioListModel.get(priorityListView.draggingIndex).name;
                                    dndItem.iconLeft = prioListModel.get(priorityListView.draggingIndex).icon;
                                    dndArea.dragOffset = priorityListView.mapToItem(item, mouseX, mouseY).y;
                                }

                                onMouseYChanged: {
                                    if (!priorityListView.dragging) { return; }
                                    var mouseYInList = priorityListView.contentItem.mapFromItem(dndArea, mouseX, mouseY).y;
                                    var indexUnderMouse = priorityListView.indexAt(mouseX, mouseYInList - dndArea.dragOffset / 2);
                                    if (indexUnderMouse < 0) { return; }
                                    indexUnderMouse = Math.min(Math.max(0, indexUnderMouse), priorityListView.count - 1);
                                    if (priorityListView.draggingIndex !== indexUnderMouse) {
                                        prioListModel.move(priorityListView.draggingIndex, indexUnderMouse, 1);
                                        priorityListView.draggingIndex = indexUnderMouse;
                                    }
                                }

                                onReleased: {
                                    priorityListView.draggingIndex = -1;
                                    d.modelRevision++;
                                }
                            }

                            CoSortableCard {
                                id: dndItem
                                visible: priorityListView.dragging
                                dragging: true
                                y: dndArea.mouseY - dndArea.dragOffset
                                width: priorityListView.width
                            }
                        }

                        Button {
                            id: restoreDefaultListButton
                            // Layout.fillWidth: true
                            Layout.alignment: Qt.AlignHCenter
                            visible: hemsManager.emsConfiguration.defaultPvSurplusPriolist.length === hemsManager.emsConfiguration.pvSurplusPriolist.length
                            text: qsTr("Restore default order")
                            iconRight: Qt.resolvedUrl("qrc:/icons/undo.svg")
                            secondary: true

                            onClicked: {
                                populateFromPrioList(hemsManager.emsConfiguration.defaultPvSurplusPriolist);
                            }
                        }
                    }
                }
            }
        }

        Button {
            id: savebutton
            Layout.fillWidth: true
            text: qsTr("Apply changes")
            enabled: {
                // ListModel.move() and clear()+append() do not change any property that
                // QML's binding engine tracks, so this expression would never re-evaluate
                // after a drag or restore without an explicit reactive dependency.
                // d.modelRevision is incremented on every such modification to serve as
                // that dependency and trigger re-evaluation.
                d.modelRevision;
                // Enabled only when the current list order differs from the saved pvSurplusPriolist.
                var prioList = hemsManager.emsConfiguration.pvSurplusPriolist;
                if (prioListModel.count !== prioList.length) { return true; }
                for (var i = 0; i < prioListModel.count; i++) {
                    if (prioListModel.get(i).thingId !== "" + engine.thingManager.things.getThing(prioList[i]).id) {
                        return true;
                    }
                }
                return false;
            }

            onClicked: {
                var uuidList = [];
                for (var i = 0; i < prioListModel.count; i++) {
                    uuidList.push(prioListModel.get(i).thingId);
                }
                d.pendingCallId = hemsManager.setPVSurplusPriolist(uuidList);
            }
        }
    }
}
