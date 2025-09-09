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
    property HeatingConfiguration heatingConfiguration
    property double currentPrice: 0
    property double currentValue: heatingConfiguration.priceThreshold

    ColumnLayout {
        id: columnLayer

        width: parent.width

        DebugRectangle {
            visible: false
        }
        // Charging Plan Header

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

                text: Number(currentPrice).toLocaleString(Qt.locale(), 'f', 2) + " ct/kWh"
            }

        }

        // Graph Info Today
        ColumnLayout {
            Layout.fillWidth: true
            Component.onCompleted: {
                const dpThing = dynamicPrice.get(0);
                if (!dpThing)
                    return ;

                currentPrice = dpThing.stateByName("currentTotalCost").value;
                averagePrice = dpThing.stateByName("averageTotalCost").value.toFixed(0).toString();
                lowestPrice = dpThing.stateByName("lowestPrice").value;
                highestPrice = dpThing.stateByName("highestPrice").value;
                barSeries.addValues(dpThing.stateByName("totalCostSeries").value);
            }

            QtObject {
                id: d

                property date now: new Date()
                readonly property var startTimeSince: {
                    var date = new Date();
                    date.setHours(0);
                    date.setMinutes(0);
                    date.setSeconds(0);
                    return date;
                }
                readonly property var endTimeUntil: {
                    var date = new Date();
                    date.setHours(0);
                    date.setMinutes(0);
                    date.setSeconds(0);
                    date.setDate(date.getDate() + 1);
                    return date;
                }
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
                visible: optimizationController.checked
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
                    text: qsTr("Price limit : %1 ct/kWh").arg(currentValue)
                }

                Slider {
                    Layout.fillWidth: true
                    value: currentValue
                    onMoved: () => {
                        currentValue = value;
                        saveButton.enabled = heatingConfiguration.priceThreshold !== currentValue;
                        barSeries.clearValues();
                        barSeries.addValues(dynamicPrice.get(0).stateByName("totalCostSeries").value);
                    }
                    from: -5
                    to: 150
                    stepSize: 0.2
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

        // Save Button
        RowLayout {
            id: saveBtnContainer

            Button {
                id: saveButton

                Layout.fillWidth: true
                text: qsTr("Save")
                enabled: false
                onClicked: {
                    console.error("Saving new price limit: " + currentValue);
                    saveSettings();
                    saveButton.enabled = false;
                }
            }

        }

    }

}
