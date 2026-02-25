import "../components"
import "../delegates"
import "../devicepages"
import Nymea 1.0
import QtQml 2.15
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts
import "../utils/DynPricingUtils.js" as DynPricingUtils

Item {
    id: widgetRoot

    property HeatingConfiguration heatingConfiguration
    property double currentPrice: 0
    property double relativeValue: heatingConfiguration.priceThreshold
    property double currentValue: 0
    property double currentRelativeValue: -heatingConfiguration.priceThreshold
    property double averageDeviation: 0
    property int valueAxisUpdate: {
        (0 > barSeries.lowestValue) ? valueAxisUpdate = barSeries.lowestValue : (currentValue < 0) ? valueAxisUpdate = currentValue - 2 : valueAxisUpdate = -2;
    }
    property Thing dynamicPriceThing



    height: columnLayer.implicitHeight + 20
    Layout.fillWidth: true

    ColumnLayout {
        id: columnLayer

        Layout.fillWidth: true
        width: parent.width

        // Price Limit
        RowLayout {
            Layout.topMargin: Style.margins
            Layout.bottomMargin: Style.smallMargins

            Label {
                Layout.fillWidth: true
                text: qsTr("Current price")
            }

            Label {
                text: Number(currentPrice).toLocaleString(Qt.locale(), 'f', 1) + " ct/kWh"
            }
        }

        // Graph Info Today
        ColumnLayout {
            property var dpThing: (dynamicPrice && dynamicPrice.count > 0) ? dynamicPrice.get(0) : null

            Layout.fillWidth: true
            Component.onCompleted: {
                if (!dpThing)
                    return ;

                // update d object here
                d.startTimeSince = new Date(dpThing.stateByName("validSince").value * 1000);
                d.endTimeUntil = new Date(dpThing.stateByName("validUntil").value * 1000);
                widgetRoot.currentValue = DynPricingUtils.relPrice2AbsPrice(heatingConfiguration.priceThreshold, dpThing);
                widgetRoot.averageDeviation = dpThing.stateByName("averageDeviation").value;
//                barSeries.averageTotalCost = dpThing.stateByName("averageTotalCost").value;
                currentPrice = dpThing.stateByName("currentTotalCost").value;
                lowestPrice = dpThing.stateByName("lowestPrice").value;
                highestPrice = dpThing.stateByName("highestPrice").value;
                barSeries.addValues(dpThing.stateByName("totalCostSeries").value,
                                    dpThing.stateByName("priceSeries").value,
                                    dpThing.stateByName("gridFeeSeries").value,
                                    dpThing.stateByName("leviesSeries").value,
                                    DynPricingUtils.getVAT(dpThing));
            }

            QtObject {
                id: d

                property date now: new Date()
                property date startTimeSince: new Date(0) // placeholder
                property date endTimeUntil: new Date(0) // placeholder
            }

            Item {
                Layout.fillWidth: parent.width
                Layout.fillHeight: true
                Layout.minimumHeight: 150

                CustomBarSeries {
                    id: barSeries

                    anchors.fill: parent
                    margins.left: 0
                    margins.right: 0
                    margins.top: Style.margins
                    margins.bottom: 0
                    backgroundColor: "transparent"
                    startTime: d.startTimeSince
                    endTime: d.endTimeUntil
                    hoursNow: d.now.getHours()
                    currentPrice: currentValue
                    currentMarketPrice: currentPrice
                    lowestValue: root.lowestPrice
                    highestValue: root.highestPrice
                }

            }

            // breaks view when removed
            Label {
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                text: ""
                font.pixelSize: 1
            }

        }

        // Space divider
        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }


        Label {
            Layout.fillWidth: true
            text: qsTr("Limit below average: %1 %").arg(priceSlider.value.toFixed(0))
        }

        Slider {
            id: priceSlider

            Layout.fillWidth: true
            value: -relativeValue
            onMoved: () => {
                         currentValue = DynPricingUtils.relPrice2AbsPrice(-value, dynamicPrice.get(0));
                         currentRelativeValue = value;
                         if (heatingConfiguration.priceThreshold !== currentValue)
                         root.enableSave();

                         barSeries.clearValues();
                         barSeries.addValues(dynamicPrice.get(0).stateByName("totalCostSeries").value,
                                             dynamicPrice.get(0).stateByName("priceSeries").value,
                                             dynamicPrice.get(0).stateByName("gridFeeSeries").value,
                                             dynamicPrice.get(0).stateByName("leviesSeries").value,
                                             DynPricingUtils.getVAT(dynamicPrice.get(0)));
                     }
            from: 0
            to: 100
            stepSize: 1
        }
    }
}
