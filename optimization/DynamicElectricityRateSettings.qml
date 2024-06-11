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
        visible: false
        text: qsTr("Dynamic Electricity Settings")
        backButtonVisible: true
        onBackPressed: {
            if(directionID == 0) {
                pageStack.pop()
            }

        }

    }

    ColumnLayout {
     Layout.alignment: Qt.AlignHCenter

        RowLayout{
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Current Market Price:")
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("0.27")
            }


        }

        RowLayout{
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Average Market Price:")
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("0.27")
            }


        }

        RowLayout{
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Lowest Market Price:")
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("0.27")
            }


        }

        RowLayout{
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Highest Market Price:")
            }

            Label {
                Layout.fillWidth: true
                text: qsTr("0.27")
            }


        }


    }


}
