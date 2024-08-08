import QtQuick 2.9
import QtCharts 2.3
import Nymea 1.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12

import "qrc:/ui/components"

import "../components"
import "../delegates"
import "../devicepages"


RowLayout{
    id: root
    property int currentValue: 0;
    property int maxLimit: 0;
    property int minLimit: 0;
    property double averagePrice: null
    property string unit: "";
    property double thresholdPrice: 0
    property Timer timer: null

    property alias text: currentValueField.text
    property alias price: root.thresholdPrice

    property var callbackFunction

    signal clicked();
    signal pressAndHold();

    ToolBar {
        id: toolBar
        background: Rectangle {
            color: "transparent"
        }

        Component.onCompleted: {
            getThresholdPrice();
        }

        function getThresholdPrice(){
            root.thresholdPrice = (root.averagePrice * (1 + currentValue / 100)).toFixed(2)
        }

        RowLayout {
            anchors.fill: parent

            ToolButton {
                text: qsTr("-")
                onClicked: {
                    root.clicked();
                    toolBar.getThresholdPrice();
                    currentValue = currentValue > minLimit ? currentValue - 1 : minLimit
                    callbackFunction();
                }
                onPressAndHold: {
                    root.pressAndHold()
                    toolBar.getThresholdPrice();
                    currentValue = currentValue > minLimit ? currentValue - 10 : minLimit
                    callbackFunction();
                }
            }

            TextField {
                id: currentValueField
                text: currentValue
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.preferredWidth: 50
                validator: RegExpValidator {
                    regExp: /^-?(100|[1-9]?[0-9])$/
                }
                onTextChanged: {
                    currentValue = currentValueField.text
                    toolBar.getThresholdPrice();
                    callbackFunction();
                }
            }

            Label {
                text: unit
            }

            ToolButton {
                text: qsTr("+")
                onClicked: {
                    root.clicked();
                    toolBar.getThresholdPrice()
                    callbackFunction();
                    currentValue = currentValue < maxLimit ? currentValue + 1 : maxLimit
                }
                onPressAndHold: {
                    root.pressAndHold()
                    toolBar.getThresholdPrice()
                    callbackFunction();
                    currentValue = currentValue < maxLimit ? currentValue + 10 : maxLimit
                }
            }

        }

    }

}
