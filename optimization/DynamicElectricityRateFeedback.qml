import QtQuick 2.9
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.9
import QtQuick.Controls.Material 2.12
import QtGraphicalEffects 1.15

import Nymea 1.0
import "../components"
import "../delegates"
import "../optimization"

Page {
    id: root
    property HemsManager hemsManager
    property int directionID: 0
    property string thingName: ""

    signal done(bool skip, bool abort, bool back);

    header: NymeaHeader {
        text: qsTr("Dynamic electricity tariff")
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
                text: qsTr("The following tariff is submitted:")
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.Center
            }

            Text {
                id: electricityRate
                Layout.preferredWidth: app.width - 2*Style.margins
                color: Material.foreground
                text: qsTr(thingName)
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
                text: qsTr("to the dashboard")
                Layout.preferredWidth: 250
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    pageStack.pop()
                    pageStack.pop()
                    pageStack.pop()
                    pageStack.pop()
                }

            }

        }

    }
}
