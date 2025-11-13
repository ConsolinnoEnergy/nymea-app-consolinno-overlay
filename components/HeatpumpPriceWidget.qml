import "../components"
import "../delegates"
import "../devicepages"
import Nymea 1.0
import QtQml 2.15
import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.3

Rectangle {
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

    function relPrice2AbsPrice(relPrice) {
        let averagePrice = dynamicPrice.get(0).stateByName("averageTotalCost").value;
        let minPrice = dynamicPrice.get(0).stateByName("lowestPrice").value;
        let maxPrice = dynamicPrice.get(0).stateByName("highestPrice").value;
        if (averagePrice == minPrice || averagePrice == maxPrice)
            return averagePrice;

        if (relPrice <= 0)
            thresholdPrice = averagePrice - 0.01 * relPrice * (minPrice - averagePrice);
        else
            thresholdPrice = 0.01 * relPrice * (maxPrice - averagePrice) + averagePrice;
        thresholdPrice = thresholdPrice.toFixed(2);
        return thresholdPrice;
    }

    height: columnLayer.implicitHeight + 20
    Layout.fillWidth: true

    ColumnLayout {
        id: columnLayer

        Layout.fillWidth: true
        // Charging Plan Header
        width: parent.width

        RowLayout {
            Layout.topMargin: 15

            Label {
                text: qsTr("Dynamic Pricing Optimization")
                font.weight: Font.Bold
            }

        }

        // Price Limit
        RowLayout {
            id: currentPriceRow

            Layout.topMargin: 5

            Label {
                Layout.fillWidth: true
                text: qsTr("Current price")
            }

            Label {
                id: currentPriceLabel

                text: Number(currentPrice).toLocaleString(Qt.locale(), 'f', 1) + " ct/kWh"
            }

        }

        RowLayout {
            id: averageDeviationRow

            Layout.topMargin: 5

            Label {
                Layout.fillWidth: true
                text: qsTr("Current average deviation")
            }

            Label {
                id: averageDeviationLabel

                text: (averageDeviation > 0 ? "+" : "") + Number(averageDeviation) + " %"
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
                widgetRoot.currentValue = relPrice2AbsPrice(heatingConfiguration.priceThreshold);
                widgetRoot.averageDeviation = dpThing.stateByName("averageDeviation").value;
                barSeries.averageTotalCost = dpThing.stateByName("averageTotalCost").value;
                currentPrice = dpThing.stateByName("currentTotalCost").value;
                averagePrice = dpThing.stateByName("averageTotalCost").value.toFixed(0).toString();
                lowestPrice = dpThing.stateByName("lowestPrice").value;
                highestPrice = dpThing.stateByName("highestPrice").value;
                barSeries.addValues(dpThing.stateByName("totalCostSeries").value, dpThing.stateByName("priceSeries").value, dpThing.stateByName("gridFeeSeries").value, dpThing.stateByName("leviesSeries").value, 19);
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
                    margins.top: 0
                    margins.bottom: 0
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

        ItemDelegate {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft
            topPadding: 0
            leftPadding: 0
            rightPadding: 0

            contentItem: ColumnLayout {
                Label {
                    Layout.fillWidth: true
                    text: qsTr("Limit below average: -%1 %").arg(priceSlider.value.toFixed(0))
                }

                Slider {
                    id: priceSlider

                    Layout.fillWidth: true
                    value: -relativeValue
                    onMoved: () => {
                        currentValue = relPrice2AbsPrice(-value);
                        currentRelativeValue = value;
                        if (heatingConfiguration.priceThreshold !== currentValue)
                            root.enableSave();

                        barSeries.clearValues();
                        barSeries.addValues(dynamicPrice.get(0).stateByName("totalCostSeries").value, dynamicPrice.get(0).stateByName("priceSeries").value, dynamicPrice.get(0).stateByName("gridFeeSeries").value, dynamicPrice.get(0).stateByName("leviesSeries").value, 19);
                    }
                    from: 0
                    to: 100
                    stepSize: 1
                }
                // Add a note below the slider

                Label {
                    Layout.fillWidth: true
                    text: qsTr("Note: The heat pump's operating mode is increased only at the top of each quarter-hour. After changing the price limit, there may be a delay of up to 15 minutes before the heat pump enters increased mode.")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12
                    color: "#666666"
                }

            }

        }

    }

}
