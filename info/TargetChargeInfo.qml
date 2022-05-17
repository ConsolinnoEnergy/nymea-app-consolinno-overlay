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
        text: qsTr("Targetcharge Info")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }

    InfoTextInterface{
        //infotext: qsTr("With the charging target, you specify how full you want to charge the battery. Note that the charging limit set in the vehicle cannot be exceeded. For example, if you have preset a charging limit of 80%, you cannot charge more than 80% with the energy manager, as the vehicle automatically shuts down the charging process. To ensure that the energy manager takes this limit into account, enter the charging limit in the vehicle profile.")
        summaryText: qsTr("With the charging target, you specify how full you want to charge the battery.")
        body: ColumnLayout{
            id: bodyItem
            Label{
                Layout.fillWidth: true
                text: qsTr("Target charge and charging limit: ")
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

                text: qsTr("Note that the charging limit set in the vehicle cannot be exceeded. For example, if you have preset a charging limit of 80%, you cannot charge more than 80% with the energy manager, as the vehicle automatically shuts down the charging process. To ensure that the energy manager takes this limit into account, enter the charging limit in the vehicle profile.")

            }



        }
        footer:
            [
                 {headline: "Maximum charging limit", Link: "MaximumAllowedChargingLimit"},

            ]

    }
}

