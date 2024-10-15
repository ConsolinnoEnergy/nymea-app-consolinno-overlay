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

    header: NymeaHeader {
        visible: true
        text: qsTr("Dynamic Electricity Settings")
        backButtonVisible: true
        onBackPressed: {
            pageStack.pop()
        }

    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: app.margins

        RowLayout{
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: qsTr("Current Market Price")

            }


            TextField {
                Layout.preferredWidth: 60
                Layout.rightMargin: 10
                text: "0.27"
                maximumLength: 5

            }

            Label {
                text: qsTr("ct")
            }
        }

        RowLayout{
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: qsTr("Average Market Price")

            }


            TextField {
                Layout.preferredWidth: 60
                Layout.rightMargin: 10
                text: "0.27"
                maximumLength: 5

            }

            Label {
                text: qsTr("ct")
            }
        }

        RowLayout{
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: qsTr("Lowest Market Price")

            }


            TextField {
                Layout.preferredWidth: 60
                Layout.rightMargin: 10
                text: "0.27"
                maximumLength: 5

            }

            Label {
                text: qsTr("ct")
            }
        }

        RowLayout{
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: qsTr("Highest Market Price")

            }


            TextField {
                Layout.preferredWidth: 60
                Layout.rightMargin: 10
                text: "0.27"
                maximumLength: 5

            }

            Label {
                text: qsTr("ct")
            }
        }

        Button {
            id: savebutton

            Layout.fillWidth: true
            text: qsTr("Save")
            onClicked: {

            }
        }

    }


}
