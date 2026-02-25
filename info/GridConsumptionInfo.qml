import QtQuick
import QtQuick.Controls
import QtQml 2.2
import Nymea 1.0
import QtQuick.Layouts
import "../components"
import "../delegates"

Page {
    property var stack
    header: ConsolinnoHeader {
        id: header
        show_Image: true
        text: qsTr("Low solar avalaibility")
        backButtonVisible: true
        onBackPressed: stack.pop()
    }
    InfoTextInterface{
        anchors.fill: parent
        body: ColumnLayout{
            Layout.fillWidth: true
            id: bodyItem
            Label{
                Layout.fillWidth: true
                text: qsTr("Charging with minimum current:")
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
                text: qsTr("If there is not enough PV surplus to charge, charging continues at minimum charging current (grid supply).")
            }

            Label{
                Layout.topMargin: 15
                Layout.fillWidth: true
                text: qsTr("Pausing charging:")
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
                text: qsTr("If there is no sufficient PV surplus for approx. 2 minutes, the charging process is paused. If there is sufficient PV surplus again for approx. 2 minutes, the charging process is continued.")
            }

        }

    }

}

