import "../components"
import "../delegates"
import "../devicepages"
import Nymea 1.0
import QtQml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

GenericConfigPage {
    id: root

    property Thing thing
    property HeatingConfiguration heatingconfig: hemsManager.heatingConfigurations.getHeatingConfiguration(thing.id)
    property double thresholdPrice: 0
    property double currentPrice: 0
    property double lowestPrice: 0
    property double highestPrice: 0

    function updatePrice() {
        currentPrice = dynamicPrice.get(0).stateByName("currentMarketPrice").value;
        currentPriceLabel.text = Number(currentPrice).toLocaleString(Qt.locale(), 'f', 2) + " ct/kWh";
    }

    function saveSettings() {
        var newConfig = JSON.parse(JSON.stringify(heatingconfig));
        newConfig.priceThreshold = -heatpumpPriceWidget.currentRelativeValue;
        newConfig.optimizationMode = optimizationModeDropdown.model.get(optimizationModeDropdown.currentIndex).enumname;
        newConfig.relativePriceEnabled = true;
        // Null UUID means: no meter selected → pass empty string,
        // so C++ omits the field from the RPC request (backend rejects null UUID).
        // Qt serialises QUuid with braces, e.g. "{00000000-0000-0000-0000-000000000000}",
        // so we check for the null-UUID pattern regardless of surrounding braces.
        if (!newConfig.heatMeterThingId ||
                newConfig.heatMeterThingId === "" ||
                (typeof newConfig.heatMeterThingId === "string" &&
                 newConfig.heatMeterThingId.indexOf("00000000-0000-0000-0000-000000000000") !== -1)) {
            newConfig.heatMeterThingId = "";
        }
        console.info("Saving new heating configuration: " + JSON.stringify(newConfig));
        rootObject.pendingCallId = hemsManager.setHeatingConfiguration(thing.id, newConfig);
    }

    function enableSave() {
        saveButton.enabled = true;
    }

    title: root.thing.name
    headerOptionsVisible: false
    content: [
        Flickable {
            anchors.fill: parent
            contentHeight: columnLayout.implicitHeight + 30
            clip: true

            ColumnLayout {
                id: columnLayout

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: Style.margins
                anchors.leftMargin: Style.margins
                anchors.rightMargin: Style.margins

                Row {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.smallMargins
                    visible: {
                        for (let i = 0; i < energyManagerRepeater.count; ++i) {
                            const item = energyManagerRepeater.itemAt(i);
                            if (item && item.visible) { return true; }
                        }
                        return false;
                    }

                    Label {
                        id: energyManager

                        text: qsTr("Energymanager")
                        font.bold: true
                    }

                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.margins
                    spacing: Style.margins

                    Repeater {
                        id: energyManagerRepeater

                        function translateNymeaHeatpumpValues(something) {
                            switch (something) {
                            case "Off":
                                return qsTr("Off");
                            case "Low":
                                return qsTr("Standard");
                            case "Standard":
                                return qsTr("Increased");
                            case "High":
                                return qsTr("High");
                            }
                        }

                        model: [{
                                "Id": "performanceTarget",
                                "name": qsTr("Forwarded Solar Surplus"),
                                "value": thing.stateByName("actualPvSurplus") ? thing.stateByName("actualPvSurplus").value : null,
                                "unit": "W",
                                "infoButtonURL": thing.stateByName("actualPvSurplus") ? "PvSurplusInfo.qml" : ""
                            }, {
                                "Id": "operatingModeSG",
                                "name": qsTr("Operating mode"),
                                "value": thing.stateByName("sgReadyMode") ? translateNymeaHeatpumpValues(thing.stateByName("sgReadyMode").value) : null,
                                "unit": "",
                                "infoButtonURL": thing.stateByName("sgReadyMode") ? "EnergyManagerInfo.qml" : ""
                            }]
                        delegate: stringValuesComponent

                    }

                }

                Row {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.margins

                    Label {
                        id: heatingPumpStates

                        text: qsTr("Heatpump condition")
                        font.bold: true
                    }

                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.margins
                    spacing: Style.margins

                    Repeater {
                        id: heatpumpConditions
                        model: [{
                                "Id": "operatingMode",
                                "name": qsTr("Status"),
                                "value": thing.stateByName("systemStatus") ? thing.stateByName("systemStatus").value : null,
                                "unit": ""
                            }, {
                                "Id": "currentConsumption",
                                "name": qsTr("Current consumption"),
                                "value": thing.stateByName("currentPower") ? thing.stateByName("currentPower").value : null,
                                "unit": "W"
                            }, {
                                "Id": "totalAmountOfEnergy",
                                "name": qsTr("Absorbed elec. energy"),
                                "value": thing.stateByName("totalEnergyConsumed") ? thing.stateByName("totalEnergyConsumed").value : null,
                                "unit": "kWh"
                            }, {
                                "Id": "totalThermalEnergyGenerated",
                                "name": qsTr("Total thermal energy generated"),
                                "value": thing.stateByName("totalOutputThermalEnergy") ? thing.stateByName("totalOutputThermalEnergy").value : null,
                                "unit": "kWh"
                            }, {
                                "Id": "outdoorTemperature",
                                "name": qsTr("Outdoor temperature"),
                                "value": thing.stateByName("outdoorTemperature") ? thing.stateByName("outdoorTemperature").value : null,
                                "unit": "°C"
                            }, {
                                "Id": "currentCoefficientOfPerformance",
                                "name": qsTr("Current COP"),
                                "value": thing.stateByName("coefficientOfPerformance") ? thing.stateByName("coefficientOfPerformance").value : null,
                                "unit": ""
                            }, {
                                "Id": "averageCoefficientOfPerformance",
                                "name": qsTr("Average COP"),
                                "value": thing.stateByName("averageCoefficientOfPerformance") ? thing.stateByName("averageCoefficientOfPerformance").value : null,
                                "unit": ""
                            }, {
                                "Id": "hotWaterTemperature",
                                "name": qsTr("Domestic hot water temperature"),
                                "value": thing.stateByName("hotWaterTemperature") ? thing.stateByName("hotWaterTemperature").value : null,
                                "unit": "°C"
                            }]
                        delegate: stringValuesComponent
                    }

                }

                Row {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.margins
                    visible: thing && (thing.stateByName("flowTemperature") || thing.stateByName("returnTemperature"))

                    Label {
                        id: heatingPumpCircuit

                        text: qsTr("Heating circuit")
                        font.bold: true
                    }

                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.margins
                    spacing: Style.margins

                    Repeater {
                        model: [{
                                "Id": "flowTemperature",
                                "name": qsTr("Flow temperature"),
                                "value": thing.stateByName("flowTemperature") ? thing.stateByName("flowTemperature").value : null,
                                "unit": "°C"
                            }, {
                                "Id": "returnTemperature",
                                "name": qsTr("Return temperature"),
                                "value": thing.stateByName("returnTemperature") ? thing.stateByName("returnTemperature").value : null,
                                "unit": "°C"
                            }]
                        delegate: stringValuesComponent
                    }
                }

                Component {
                    id: stringValuesComponent

                    RowLayout {
                        Layout.fillWidth: true
                        visible: modelData.value !== null

                        LabelWithInfo {
                            text: modelData.name
                            push: modelData.infoButtonURL ?? ""
                        }

                        Label {
                            text: {
                                var str = "";
                                var loc = Qt.locale();
                                loc.numberOptions = Locale.OmitGroupSeparator;
                                if (Number(modelData.value)) {
                                    if (modelData.Id === "currentCoefficientOfPerformance" ||
                                        modelData.Id === "averageCoefficientOfPerformance") {
                                        str = Math.abs(modelData.value).toLocaleString(loc, 'f', 1);
                                    } else if (modelData.Id === "flowTemperature" ||
                                               modelData.Id === "returnTemperature" ||
                                               modelData.Id === "hotWaterTemperature" ||
                                               modelData.Id === "outdoorTemperature") {
                                        str = modelData.value.toLocaleString(loc, 'f', 1);
                                    } else if (modelData.Id === "performanceTarget") {
                                        str = Math.max(0, modelData.value).toLocaleString(loc, 'f', 0);
                                    } else {
                                        str = modelData.value.toLocaleString(loc, 'f', 0);
                                    }
                                } else {
                                    str = modelData.value;
                                }
                                if (modelData.unit !== "") {
                                    str += " " + modelData.unit;
                                }
                                return str;
                            }
                        }
                    }
                }

                // Add a dropdown field "Optimization" with options "PV Surplus", "Dynamic Pricing", "Off"
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.margins
                    // visible only if interface of heatpump is smartgridheatpump
                    visible: thing.thingClass.interfaces.indexOf("smartgridheatpump") >= 0

                    Label {
                        Layout.fillWidth: true

                        text: qsTr("Optimization")
                        font.bold: true

                        InfoButton {
                            x: parent.paintedWidth + 10
                            push: "HeatpumpOptimizationInfo.qml"
                            Layout.alignment: Qt.AlignTop
                            Layout.fillWidth: true
                        }
                    }


                    ConsolinnoDropdown {
                         id: optimizationModeDropdown
                         Layout.fillWidth: true
                         textRole: "text"

                         // Base model that holds *all* possible options
                         property var fullModel: [
                             { text: qsTr("PV Surplus"), enumname: "OptimizationModePVSurplus", value: 0},
                             { text: qsTr("Dynamic Pricing"), enumname: "OptimizationModeDynamicPricing", value: 1},
                             { text: qsTr("Off"), enumname: "OptimizationModeOff", value: 2},
                         ]

                         // Actual ComboBox model
                         model: ListModel { id: filteredModel }

                         // Keep ComboBox selection consistent with config
                         currentIndex: {
                             if (!heatingconfig)
                                 return -1

                             for (let i = 0; i < filteredModel.count; ++i) {
                                 if (filteredModel.get(i).enumname === heatingconfig.optimizationMode)
                                     return i
                             }
                             return -1
                         }

                         onCurrentIndexChanged: {
                             console.info(heatingconfig.optimizationMode)
                             if (currentIndex >= 0 && model.get(currentIndex).value !== heatingconfig.optimizationMode) {
                                 console.debug("Optimization mode changed to:", model.get(currentIndex).enumname)
                                 enableSave()
                             }
                         }

                         // --- Core filtering logic ---
                         function rebuildModel() {
                             filteredModel.clear()

                             console.info("Heating Config:", JSON.stringify(heatingconfig))

                             const pvEnabled  = hemsManager.availableUseCases & HemsManager.HemsUseCasePv
                             const dynEnabled = hemsManager.availableUseCases & HemsManager.HemsUseCaseDynamicEPricing

                             for (let i = 0; i < fullModel.length; ++i) {
                                 const item = fullModel[i]

                                 // show PV Surplus only if PV use case is available
                                 if (item.enumname === "OptimizationModePVSurplus" && pvEnabled)
                                     filteredModel.append(item)

                                 // show Dynamic Pricing only if Dynamic Pricing use case is available
                                 else if (item.enumname === "OptimizationModeDynamicPricing" && dynEnabled)
                                     filteredModel.append(item)

                                 else if (item.enumname === "OptimizationModeOff")
                                     filteredModel.append(item)
                             }

                             // Set current index to match existing config
                             for (let i = 0; i < filteredModel.count; ++i) {
                                 if (filteredModel.get(i).value === heatingconfig.optimizationMode) {
                                     optimizationModeDropdown.currentIndex = i
                                     return
                                 }
                             }
                         }

                         Component.onCompleted: rebuildModel()
                         Connections {
                             target: hemsManager
                             onAvailableUseCasesChanged: optimizationModeDropdown.rebuildModel()
                         }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Style.margins
                    visible: optimizationModeDropdown.currentIndex >= 0 && optimizationModeDropdown.model.get(optimizationModeDropdown.currentIndex).enumname === "OptimizationModeDynamicPricing" 

                    HeatpumpPriceWidget {
                        id: heatpumpPriceWidget
                        currentPrice: currentPrice
                        heatingConfiguration: heatingconfig
                        dynamicPriceThing: dynamicPrice.get(0)
                    }

                }

                RowLayout {
                    id: saveBtnContainer
                    visible: thing.thingClass.interfaces.indexOf("smartgridheatpump") >= 0

                    Layout.fillWidth: true
                    Layout.topMargin: Style.margins

                    Button {
                        id: saveButton


                        Layout.fillWidth: true
                        text: qsTr("Save")
                        enabled: false
                        onClicked: {
                            console.error("Saving new price limit: " + heatpumpPriceWidget.currentValue);
                            saveSettings();
                            saveButton.enabled = false;
                        }
                    }

                }

            }

        }
    ]

    QtObject {
        id: rootObject

        property int pendingCallId: -1
    }

    Connections {
        target: engine.thingManager
        onThingStateChanged: (thingId, stateTypeId, value) => {
            if (thingId === dynamicPrice.get(0).id)
                updatePrice();

        }
    }

    ThingsProxy {
        id: dynamicPrice

        engine: _engine
        shownInterfaces: ["dynamicelectricitypricing"]
    }

}
