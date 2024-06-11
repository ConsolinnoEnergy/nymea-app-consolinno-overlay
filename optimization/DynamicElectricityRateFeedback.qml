import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.15

import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

// This is the Development Page
// This is only visible if the Hidden Options are activated, so if you push something be sure it is disabled.
// In order to add something to the development page do the following step:
Page {
    id: root
    property HemsManager hemsManager

    property int directionID: 0

    signal done(bool skip, bool abort, bool back);

    header: NymeaHeader {
        text: qsTr("Dynamic Electricity Rate")
        Layout.preferredWidth: app.width - 2*Style.margins
        backButtonVisible: true
        onBackPressed: {
            if(directionID == 0) {
                pageStack.pop()
            }

        }

    }

    ColumnLayout {
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right;  margins: Style.margins }
        width: Math.min(parent.width - Style.margins * 2, 300)

        ColumnLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                Layout.preferredWidth: app.width - 2*Style.margins
                Layout.preferredHeight: 50
                color: Material.foreground
                text: qsTr("The following Electric Rate is submitted")
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.Center
            }

            Text {
                id: electricityRate
                Layout.preferredWidth: app.width - 2*Style.margins
                color: Material.foreground
                text: qsTr("Tibber")
                Layout.alignment: Qt.AlignCenter
                horizontalAlignment: Text.Center
            }

            Image {
                id: succesAddElectricRate
                Layout.preferredWidth: 150
                Layout.preferredHeight: 150
                fillMode: Image.PreserveAspectFit
                Layout.alignment: Qt.AlignCenter
                source: "../images/tick.svg"
            }

            ColorOverlay {
                anchors.fill: succesAddElectricRate
                source: succesAddElectricRate
                color: Material.accent
            }

        }

        ColumnLayout {
            spacing: 0
            Layout.alignment: Qt.AlignHCenter

            Button {
                id: nextButton
                text: qsTr("next")
                //color: Style.accentColor
                Layout.preferredWidth: 200
                Layout.alignment: Qt.AlignHCenter
                //Layout.alignment: Qt.AlignHCenter
                onClicked: {
                }

            }

        }

    }
}
