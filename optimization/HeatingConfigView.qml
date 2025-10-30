import "../components"
import "../delegates"
import "../devicepages"
import Nymea 1.0
import QtQml 2.15
import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3

GenericConfigPage {
    id: root

    property HemsManager hemsManager
    property Thing thing
    property HeatingConfiguration heatingconfig: hemsManager.heatingConfigurations.getHeatingConfiguration(thing.id)
    property double thresholdPrice: 0
    property int validSince: 0
    property int validUntil: 0
    property double averagePrice: 0
    property double currentPrice: 0
    property double lowestPrice: 0
    property double highestPrice: 0
    property var prices: ({
    })

    function updatePrice() {
        currentPrice = dynamicPrice.get(0).stateByName("currentMarketPrice").value;
        currentPriceLabel.text = Number(currentPrice).toLocaleString(Qt.locale(), 'f', 2) + " ct/kWh";
    }

    function saveSettings() {
        var newConfig = JSON.parse(JSON.stringify(heatingconfig));
        newConfig.priceThreshold = -heatpumpPriceWidget.currentRelativeValue;
        newConfig.optimizationMode = optimizationModeDropdown.model.get(optimizationModeDropdown.currentIndex).enumname;
        newConfig.relativePriceEnabled = true;
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
                anchors.topMargin: app.margins

                Row {
                    Layout.fillWidth: true
                    Layout.leftMargin: 15
                    Layout.topMargin: 10

                    Label {
                        id: energyManager

                        text: qsTr("Energymanager")
                        font.bold: true
                    }

                }

                Repeater {
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

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 5
                    model: [{
                        "Id": "performanceTarget",
                        "name": qsTr("Forwarded Solar Surplus"),
                        "value": thing.stateByName("actualPvSurplus") ? thing.stateByName("actualPvSurplus").value : null,
                        "unit": "W",
                        "component": stringValues,
                        "params": false,
                        "paramsSurPlus": thing.stateByName("actualPvSurplus") ? true : false
                    }, {
                        "Id": "operatingModeSG",
                        "name": qsTr("Operating mode"),
                        "value": translateNymeaHeatpumpValues(thing.stateByName("sgReadyMode") ? thing.stateByName("sgReadyMode").value : null),
                        "unit": "",
                        "component": stringValues,
                        "params": thing.stateByName("sgReadyMode") ? true : false,
                        "paramsSurPlus": false
                    }]

                    delegate: ItemDelegate {
                        id: optimizerMainParams

                        visible: modelData.value !== null && (modelData.params === true || modelData.paramsSurPlus === true) ? true : false
                        Layout.fillWidth: true

                        contentItem: ColumnLayout {
                            Layout.fillWidth: true

                            RowLayout {
                                Layout.fillWidth: true

                                Loader {
                                    id: optimizationParams

                                    Layout.fillWidth: true
                                    sourceComponent: {
                                        switch (modelData.Id) {
                                        case "performanceTarget":
                                            return modelData.component;
                                        case "operatingModeSG":
                                            return modelData.component;
                                        }
                                    }

                                    Binding {
                                        target: optimizationParams.item
                                        property: "delegateID"
                                        value: modelData.Id
                                    }

                                    Binding {
                                        target: optimizationParams.item
                                        property: "delegateName"
                                        value: modelData.name
                                    }

                                    Binding {
                                        target: optimizationParams.item
                                        property: "delegateValue"
                                        value: modelData.value
                                    }

                                    Binding {
                                        target: optimizationParams.item
                                        property: "delegateUnit"
                                        value: modelData.unit
                                    }

                                    Binding {
                                        target: optimizationParams.item
                                        property: "delegateParams"
                                        value: modelData.params
                                    }

                                    Binding {
                                        target: optimizationParams.item
                                        property: "delegateParamsSurPlus"
                                        value: modelData.paramsSurPlus
                                    }

                                }

                            }

                        }

                    }

                }

                Row {
                    Layout.fillWidth: true
                    Layout.leftMargin: 15
                    Layout.topMargin: 10

                    Label {
                        id: heatingPumpStates

                        text: qsTr("Heatpump condition")
                        font.bold: true
                    }

                }

                Repeater {
                    id: heatpumpConditions

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 5
                    model: [{
                        "Id": "operatingMode",
                        "name": qsTr("Operating mode"),
                        "value": thing.stateByName("systemStatus") ? thing.stateByName("systemStatus").value : null,
                        "unit": "",
                        "component": stringValues,
                        "params": false,
                        "paramsSurPlus": false
                    }, {
                        "Id": "currentConsumption",
                        "name": qsTr("Current consumption"),
                        "value": thing.stateByName("currentPower") ? thing.stateByName("currentPower").value : null,
                        "unit": "W",
                        "component": stringValues,
                        "params": false,
                        "paramsSurPlus": false
                    }, {
                        "Id": "totalAmountOfEnergy",
                        "name": qsTr("Absorbed elec. energy"),
                        "value": thing.stateByName("totalEnergyConsumed") ? thing.stateByName("totalEnergyConsumed").value : null,
                        "unit": "kWh",
                        "component": stringValues,
                        "params": false,
                        "paramsSurPlus": false
                    }, {
                        "Id": "totalThermalEnergyGenerated",
                        "name": qsTr("Total thermal energy generated"),
                        "value": thing.stateByName("compressorTotalHeatOutput") ? thing.stateByName("compressorTotalHeatOutput").value : null,
                        "unit": "kWh",
                        "component": stringValues,
                        "params": false,
                        "paramsSurPlus": false
                    }, {
                        "Id": "outdoorTemperature",
                        "name": qsTr("Outdoor temperature"),
                        "value": thing.stateByName("outdoorTemperature") ? thing.stateByName("outdoorTemperature").value : null,
                        "unit": "°C",
                        "component": stringValues,
                        "params": false,
                        "paramsSurPlus": false
                    }, {
                        "Id": "currentCoefficientOfPerformance",
                        "name": qsTr("Current COP"),
                        "value": thing.stateByName("coefficientOfPerformance") ? thing.stateByName("coefficientOfPerformance").value : null,
                        "unit": "",
                        "component": stringValues,
                        "params": false,
                        "paramsSurPlus": false
                    }, {
                        "Id": "averageCoefficientOfPerformance",
                        "name": qsTr("Average COP"),
                        "value": thing.stateByName("averageCoefficientOfPerformance") ? thing.stateByName("averageCoefficientOfPerformance").value : null,
                        "unit": "",
                        "component": stringValues,
                        "params": false,
                        "paramsSurPlus": false
                    }, {
                        "Id": "hotWaterTemperature",
                        "name": qsTr("Domestic hot water temperature"),
                        "value": thing.stateByName("hotWaterTemperature") ? thing.stateByName("hotWaterTemperature").value : null,
                        "unit": "°C",
                        "component": stringValues,
                        "params": false,
                        "paramsSurPlus": false
                    }]

                    delegate: ItemDelegate {
                        id: optimizerInputs

                        visible: modelData.value !== null ? true : false
                        Layout.fillWidth: true

                        contentItem: ColumnLayout {
                            Layout.fillWidth: true

                            RowLayout {
                                Layout.fillWidth: true

                                Loader {
                                    id: optimizationMainParams

                                    Layout.fillWidth: true
                                    sourceComponent: {
                                        switch (modelData.Id) {
                                        case "operatingMode":
                                            return modelData.component;
                                        case "currentConsumption":
                                            return modelData.component;
                                        case "totalAmountOfEnergy":
                                            return modelData.component;
                                        case "totalThermalEnergyGenerated":
                                            return modelData.component;
                                        case "outdoorTemperature":
                                            return modelData.component;
                                        case "currentCoefficientOfPerformance":
                                            return modelData.component;
                                        case "averageCoefficientOfPerformance":
                                            return modelData.component;
                                        case "hotWaterTemperature":
                                            return modelData.component;
                                        }
                                    }

                                    Binding {
                                        target: optimizationMainParams.item
                                        property: "delegateID"
                                        value: modelData.Id
                                    }

                                    Binding {
                                        target: optimizationMainParams.item
                                        property: "delegateValue"
                                        value: modelData.value
                                    }

                                    Binding {
                                        target: optimizationMainParams.item
                                        property: "delegateUnit"
                                        value: modelData.unit
                                    }

                                    Binding {
                                        target: optimizationMainParams.item
                                        property: "delegateName"
                                        value: modelData.name
                                    }

                                    Binding {
                                        target: optimizationMainParams.item
                                        property: "delegateParams"
                                        value: modelData.params
                                    }

                                    Binding {
                                        target: optimizationMainParams.item
                                        property: "delegateParamsSurPlus"
                                        value: modelData.paramsSurPlus
                                    }

                                }

                            }

                        }

                    }

                }

                Row {
                    Layout.fillWidth: true
                    Layout.leftMargin: 15
                    Layout.topMargin: 10
                    visible: thing && (thing.stateByName("flowTemperature") || thing.stateByName("returnTemperature"))

                    Label {
                        id: heatingPumpCircuit

                        text: qsTr("Heating circuit")
                        font.bold: true
                    }

                }

                Repeater {
                    model: [{
                        "Id": "flowTemperature",
                        "name": qsTr("Flow temperature"),
                        "value": thing.stateByName("flowTemperature") ? thing.stateByName("flowTemperature").value : null,
                        "unit": "°C",
                        "component": stringValues,
                        "params": false,
                        "paramsSurPlus": false
                    }, {
                        "Id": "returnTemperature",
                        "name": qsTr("Return temperature"),
                        "value": thing.stateByName("returnTemperature") ? thing.stateByName("returnTemperature").value : null,
                        "unit": "°C",
                        "component": stringValues,
                        "params": false,
                        "paramsSurPlus": false
                    }]

                    delegate: ItemDelegate {
                        id: optimizer

                        visible: modelData.value !== null && thing.stateByName("returnTemperature").value >= 0 ? true : false
                        Layout.fillWidth: true

                        contentItem: ColumnLayout {
                            Layout.fillWidth: true

                            RowLayout {
                                Layout.fillWidth: true

                                Loader {
                                    id: optimization

                                    Layout.fillWidth: true
                                    sourceComponent: {
                                        switch (modelData.Id) {
                                        case "flowTemperature":
                                            return modelData.component;
                                        case "returnTemperature":
                                            return modelData.component;
                                        }
                                    }

                                    Binding {
                                        target: optimization.item
                                        property: "delegateID"
                                        value: modelData.Id
                                    }

                                    Binding {
                                        target: optimization.item
                                        property: "delegateValue"
                                        value: modelData.value
                                    }

                                    Binding {
                                        target: optimization.item
                                        property: "delegateUnit"
                                        value: modelData.unit
                                    }

                                    Binding {
                                        target: optimization.item
                                        property: "delegateName"
                                        value: modelData.name
                                    }

                                    Binding {
                                        target: optimization.item
                                        property: "delegateParams"
                                        value: modelData.params
                                    }

                                    Binding {
                                        target: optimization.item
                                        property: "delegateParamsSurPlus"
                                        value: modelData.paramsSurPlus
                                    }

                                }

                            }

                        }

                    }

                }

                Component {
                    id: stringValues

                    RowLayout {
                        property string delegateID: ""
                        property var delegateName
                        property var delegateValue
                        property var delegateUnit
                        property var delegateParams
                        property bool delegateParamsSurPlus: false

                        Layout.fillWidth: true

                        Label {
                            id: singleInput

                            text: delegateName
                            Layout.fillWidth: delegateParams === true || delegateParamsSurPlus === true ? false : true
                        }

                        InfoButton {
                            stack: pageStack
                            push: "EnergyManagerInfo.qml"
                            Layout.alignment: Qt.AlignTop
                            Layout.fillWidth: true
                            visible: delegateParams
                        }

                        InfoButton {
                            stack: pageStack
                            push: "PvSurplusInfo.qml"
                            Layout.alignment: Qt.AlignTop
                            Layout.fillWidth: true
                            visible: delegateParamsSurPlus
                        }

                        Label {
                            id: singleValue

                            property string currentCOP: "currentCoefficientOfPerformance"
                            property string averageCOP: "averageCoefficientOfPerformance"
                            property double numberValue: Number(delegateValue)

                            text: (numberValue && (delegateID === currentCOP || delegateID === averageCOP) ? (((+delegateValue.toFixed(1)) <= 0) ? 0 : (+delegateValue.toFixed(1)).toLocaleString()) : numberValue ? (((delegateValue.toFixed(0)) <= 0) ? 0 : (delegateValue.toFixed(0)).toLocaleString()) : delegateValue) + " " + delegateUnit
                        }

                    }

                }

                // Add a dropdown field "Optimization" with options "PV Surplus", "Dynamic Pricing", "Off"
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 15
                    Layout.topMargin: 10
                    Layout.rightMargin: 15
                    // visible only if interface of heatpump is smartgridheatpump
                    visible: thing.thingClass.interfaces.indexOf("smartgridheatpump") >= 0

                    Label {
                        id: optimizationLabel
                        Layout.fillWidth: true

                        text: qsTr("Optimization")
                        font.bold: true
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
                             onHeatingConfigurationsChanged: optimizationModeDropdown.rebuildModel()
                         }
                    } 
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    Layout.leftMargin: 15
                    Layout.rightMargin: 15
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
                    Layout.topMargin: 10
                    Layout.leftMargin: 15
                    Layout.rightMargin: 15

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
