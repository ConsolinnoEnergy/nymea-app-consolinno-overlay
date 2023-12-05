import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"

Page {
    id: root

    header: NymeaHeader {
        text: qsTr("Heating Element Configuration")
        backButtonVisible: true
        onBackPressed: pageStack.pop()
    }

    ColumnLayout {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: Style.margins
            leftMargin: Style.margins
            rightMargin: Style.margins
        }

        ConsolinnoPVTextField {
            id: maxPowerInput

            Layout.fillWidth: true
            Layout.fillHeight: false
            label: qsTr("Max power")
            text: pvConfiguration.kwPeak
            unit: qsTr("kW")

            validator: DoubleValidator {
                bottom: 1
            }
        }

        ConsolinnoSwitchDelegate {
            Layout.fillWidth: true
            text: qsTr("Operating mode (Solar Only)")
            warningText: checked ? qsTr("The heater is operated only with solar power. If a wallbox is connected to
the system, and a charging process is started, charging is prioritized.") : qsTr("The heating element is not controlled by the HEMS.")
        }

        //margins filler
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: Style.bigMargins
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Ok")
            onClicked: {

            }
        }
    }
}
