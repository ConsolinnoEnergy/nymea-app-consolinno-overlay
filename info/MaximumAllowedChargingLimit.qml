import QtQuick 2.12
import QtQuick.Controls 2.15
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts 1.2

import "../components"
import "../delegates"

Page {
    property var stack
    header: NymeaHeader {
        id: header
        text: qsTr("Maximum Allowed Charging Limit info")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }

    InfoTextInterface{
        anchors.fill: parent
        summaryText: qsTr("The charge limit is set in the vehicle or in the vehicle app and specifies the maximum amount that can be charged.")
        body: ColumnLayout{
            Layout.fillWidth: true
            id: bodyItem
            Label{
                Layout.fillWidth: true
                text: qsTr("Charging limit and target charge: ")
                leftPadding: app.margins +10
                rightPadding: app.margins +10

                font.bold: true
                font.pixelSize: 17

            }
            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("The charging limit also specifies how much can be charged with the energy manager, since the vehicle automatically limits the charging process. To ensure that the value is taken into account when setting the charging target, it should be entered here.")

            }

            Label{
                Layout.fillWidth: true
                text: qsTr("Higher target charge: ")
                leftPadding: app.margins +10
                rightPadding: app.margins +10

                font.bold: true
                font.pixelSize: 17

            }
            Label{
                Layout.fillWidth: true
                leftPadding: app.margins +10
                rightPadding: app.margins +10
                wrapMode: Text.WordWrap
                Layout.preferredWidth: app.width
                text: qsTr("If you want to specify a higher charging target, then you need to change the setting in your vehicle and in the energy manager accordingly.")

            }

        }

        infofooter: [
            {headline: qsTr("Target charge"), Link: "TargetChargeInfo"},

        ]


    }
}
